/*!\file
 *
 * SUMMARY
 *  \brief This file contains the main function of the application framework,
 *  which the application programmer uses to configure and run applications.
 *
 *
 * This is the main entrance class for most of the neural models. The following
 * Figure shows how all of the c code interacts with each other and what classes
 * are used to represent over arching logic
 * (such as plasticity, spike processing, utilities, synapse types, models)
 *
 * @image html spynnaker_c_code_flow.png
 *
 */

#include <common/in_spikes.h>
#include "neuron.h"
#include "synapses.h"
#include <neuron/spike_processing.h>
#include <neuron/population_table/population_table.h>
#include <neuron/plasticity/synapse_dynamics.h>

#include <data_specification.h>
#include <simulation.h>
#include <debug.h>

#include "fp_math.h"

/* validates that the model being compiled does indeed contain a application
   magic number*/
#ifndef APPLICATION_NAME_HASH
#error APPLICATION_NAME_HASH was undefined.  Make sure you define this\
       constant
#endif

//! human readable definitions of each region in SDRAM
typedef enum regions_e{
    SYSTEM_REGION,
    NEURON_PARAMS_REGION,
    SYNAPSE_PARAMS_REGION,
    POPULATION_TABLE_REGION,
    SYNAPTIC_MATRIX_REGION,
    SYNAPSE_DYNAMICS_REGION,
    BUFFERING_OUT_SPIKE_RECORDING_REGION,
    BUFFERING_OUT_POTENTIAL_RECORDING_REGION,
    BUFFERING_OUT_GSYN_RECORDING_REGION,
    BUFFERING_OUT_CONTROL_REGION,
    PROVENANCE_DATA_REGION,
    BUFFER_REGION
} regions_e;

typedef enum extra_provenance_data_region_entries{
    NUMBER_OF_PRE_SYNAPTIC_EVENT_COUNT = 0,
    SYNAPTIC_WEIGHT_SATURATION_COUNT = 1,
    INPUT_BUFFER_OVERFLOW_COUNT = 2,
    CURRENT_TIMER_TICK = 3,
} extra_provenance_data_region_entries;

//! values for the priority for each callback
typedef enum callback_priorities{
    MC = -1, SDP_AND_DMA_AND_USER = 0, TIMER_AND_BUFFERING = 2
} callback_priorities;

//! The number of regions that are to be used for recording
#define NUMBER_OF_REGIONS_TO_RECORD 3

// Globals

//! the current timer tick value TODO this might be able to be removed with
//! the timer tick callback returning the same value.
uint32_t time;

//! The number of timer ticks to run for before being expected to exit
static uint32_t simulation_ticks = 0;

//! Determines if this model should run for infinite time
static uint32_t infinite_run;

//! The recording flags
static uint32_t recording_flags = 0;

//! The EIEIO prefix types
typedef enum eieio_prefix_types {
    PREFIX_TYPE_LOWER_HALF_WORD, PREFIX_TYPE_UPPER_HALF_WORD
} eieio_prefix_types;

typedef struct {
    uint16_t eieio_header_command;
    uint16_t chip_id;
    uint8_t processor;
    uint8_t pad1;
    uint8_t region;
    uint8_t sequence;
    uint32_t space_available;
} req_packet_sdp_t;

typedef enum eieio_data_message_types {
    KEY_16_BIT, KEY_PAYLOAD_16_BIT, KEY_32_BIT, KEY_PAYLOAD_32_bIT
} eieio_data_message_types;

#define MIN_BUFFER_SPACE 10
#define MAX_PACKET_SIZE 280
#define TICKS_BETWEEN_REQUESTS 25
#define SPIKE_HISTORY_CHANNEL 0

static bool apply_prefix;
static bool check;
static uint32_t prefix;
static bool has_key;
static uint32_t key_space;
static uint32_t mask;
static uint32_t incorrect_keys;
static uint32_t incorrect_packets;
static uint32_t late_packets;
static uint32_t last_stop_notification_request;
static eieio_prefix_types prefix_type;
static uint32_t buffer_region_size;
static uint32_t space_before_data_request;

static uint8_t *buffer_region;
static uint8_t *end_of_buffer_region;
static uint8_t *write_pointer;
static uint8_t *read_pointer;

sdp_msg_t req;
req_packet_sdp_t *req_ptr;
static eieio_msg_t msg_from_sdram;
static bool msg_from_sdram_in_use;
static int msg_from_sdram_length;
static uint32_t next_buffer_time;
static uint8_t pkt_last_sequence_seen;
static bool send_packet_reqs;
static bool last_buffer_operation;
static uint8_t return_tag_id;
static uint32_t last_space;
static uint32_t last_request_tick;



// spindle data
REAL sp_len;
REAL sp_dlen;
uint8_t data_has_come;


//! \brief Initialises the recording parts of the model
//! \return True if recording initialisation is successful, false otherwise
static bool initialise_recording(){
    address_t address = data_specification_get_data_address();
    address_t system_region = data_specification_get_region(
        SYSTEM_REGION, address);
    regions_e regions_to_record[] = {
        BUFFERING_OUT_SPIKE_RECORDING_REGION,
        BUFFERING_OUT_POTENTIAL_RECORDING_REGION,
        BUFFERING_OUT_GSYN_RECORDING_REGION
    };
    uint8_t n_regions_to_record = NUMBER_OF_REGIONS_TO_RECORD;
    uint32_t *recording_flags_from_system_conf =
        &system_region[SIMULATION_N_TIMING_DETAIL_WORDS];
    regions_e state_region = BUFFERING_OUT_CONTROL_REGION;

    bool success = recording_initialize(
        n_regions_to_record, regions_to_record,
        recording_flags_from_system_conf, state_region,
        TIMER_AND_BUFFERING, &recording_flags);
    log_info("Recording flags = 0x%08x", recording_flags);
    return success;
}

bool read_net_parameters(address_t region_address) {

    // Get the configuration data
    apply_prefix = 1;//region_address[APPLY_PREFIX];
    prefix = 128;//region_address[PREFIX];
    prefix_type = (eieio_prefix_types) 1;//region_address[PREFIX_TYPE];
    check = 0;//region_address[CHECK_KEYS];
    has_key = 1;//region_address[HAS_KEY];
    key_space = 128;//region_address[KEY_SPACE];
    mask = 4294967168;//region_address[MASK];
    buffer_region_size = 0;// region_address[BUFFER_REGION_SIZE];
    space_before_data_request = 0;// region_address[SPACE_BEFORE_DATA_REQUEST];
    return_tag_id = 0;// region_address[RETURN_TAG_ID];

    // There is no point in sending requests until there is space for
    // at least one packet
    if (space_before_data_request < MIN_BUFFER_SPACE) {
        space_before_data_request = MIN_BUFFER_SPACE;
    }

    // Set the initial values
    incorrect_keys = 0;
    incorrect_packets = 0;
    msg_from_sdram_in_use = false;
    next_buffer_time = 0;
    pkt_last_sequence_seen = MAX_SEQUENCE_NO;
    send_packet_reqs = true;
    last_request_tick = 0;

    if (buffer_region_size != 0) {
        last_buffer_operation = BUFFER_OPERATION_WRITE;
    } else {
        last_buffer_operation = BUFFER_OPERATION_READ;
    }

    // allocate a buffer size of the maximum SDP payload size
    msg_from_sdram = (eieio_msg_t) spin1_malloc(MAX_PACKET_SIZE);

    req.length = 8 + sizeof(req_packet_sdp_t);
    req.flags = 0x7;
    req.tag = return_tag_id;
    req.dest_port = 0xFF;
    req.srce_port = (1 << 5) | spin1_get_core_id();
    req.dest_addr = 0;
    req.srce_addr = spin1_get_chip_id();
    req_ptr = (req_packet_sdp_t*) &(req.cmd_rc);
    req_ptr->eieio_header_command = 1 << 14 | SPINNAKER_REQUEST_BUFFERS;
    req_ptr->chip_id = spin1_get_chip_id();
    req_ptr->processor = (spin1_get_core_id() << 3);
    req_ptr->pad1 = 0;
    req_ptr->region = BUFFER_REGION & 0x0F;

//    log_info("apply_prefix: %d", apply_prefix);
//    log_info("prefix: %d", prefix);
//    log_info("prefix_type: %d", prefix_type);
//    log_info("check: %d", check);
//    log_info("key_space: 0x%08x", key_space);
//    log_info("mask: 0x%08x", mask);
//    log_info("space_before_read_request: %d", space_before_data_request);
//    log_info("return_tag_id: %d", return_tag_id);

    buffer_region = (uint8_t *) region_address;
    read_pointer = buffer_region;
    write_pointer = buffer_region;
    end_of_buffer_region = buffer_region + buffer_region_size;

//    log_info("buffer_region: 0x%.8x", buffer_region);
//    log_info("buffer_region_size: %d", buffer_region_size);
//    log_info("end_of_buffer_region: 0x%.8x", end_of_buffer_region);

    return true;
}


//! \brief Initialises the model by reading in the regions and checking
//!        recording data.
//! \param[in] timer_period a pointer for the memory address where the timer
//!            period should be stored during the function.
//! \return True if it successfully initialised, false otherwise
static bool initialise(uint32_t *timer_period) {
    log_info("Initialise: started");

    // Get the address this core's DTCM data starts at from SRAM
    address_t address = data_specification_get_data_address();

    // Read the header
    if (!data_specification_read_header(address)) {
        return false;
    }

    // Get the timing details
    address_t system_region = data_specification_get_region(
        SYSTEM_REGION, address);
    if (!simulation_read_timing_details(
            system_region, APPLICATION_NAME_HASH, timer_period)) {
        return false;
    }

    // setup recording region
    if (!initialise_recording()){
        return false;
    }

    // Set up the neurons
    uint32_t n_neurons;
    uint32_t incoming_spike_buffer_size;
    if (!neuron_initialise(
            data_specification_get_region(NEURON_PARAMS_REGION, address),
            recording_flags, &n_neurons, &incoming_spike_buffer_size)) {
        return false;
    }

    // Set up the synapses
    input_t *input_buffers;
    uint32_t *ring_buffer_to_input_buffer_left_shifts;
    if (!synapses_initialise(
            data_specification_get_region(SYNAPSE_PARAMS_REGION, address),
            n_neurons, &input_buffers,
            &ring_buffer_to_input_buffer_left_shifts)) {
        return false;
    }
    neuron_set_input_buffers(input_buffers);

    // Set up the population table
    uint32_t row_max_n_words;
    if (!population_table_initialise(
            data_specification_get_region(POPULATION_TABLE_REGION, address),
            data_specification_get_region(SYNAPTIC_MATRIX_REGION, address),
            &row_max_n_words)) {
        return false;
    }

    // Set up the synapse dynamics
    if (!synapse_dynamics_initialise(
            data_specification_get_region(SYNAPSE_DYNAMICS_REGION, address),
            n_neurons, ring_buffer_to_input_buffer_left_shifts)) {
        return false;
    }

    if (!spike_processing_initialise(
            row_max_n_words, MC, SDP_AND_DMA_AND_USER, SDP_AND_DMA_AND_USER,
            incoming_spike_buffer_size)) {
        return false;
    }

    if (!read_net_parameters(data_specification_get_region(
                                 BUFFER_REGION, address))) {
        return false;
    }

    log_info("Initialise: finished");
    return true;
}

void c_main_store_provenance_data(address_t provenance_region){
    //log_debug("writing other provenance data");

    // store the data into the provenance data region
    provenance_region[NUMBER_OF_PRE_SYNAPTIC_EVENT_COUNT] =
        synapses_get_pre_synaptic_events();
    provenance_region[SYNAPTIC_WEIGHT_SATURATION_COUNT] =
        synapses_get_saturation_count();
    provenance_region[INPUT_BUFFER_OVERFLOW_COUNT] =
        spike_processing_get_buffer_overflows();
    provenance_region[CURRENT_TIMER_TICK] = time;
    //log_debug("finished other provenance data");
}

void resume_callback() {
    // restart the recording status
    if (!initialise_recording()) {
        log_error("Error setting up recording");
        rt_error(RTE_SWERR);
    }
}







static inline void process_16_bit_packets_custom(
        void* event_pointer, bool pkt_prefix_upper, uint32_t pkt_count,
        uint32_t pkt_key_prefix, uint32_t pkt_payload_prefix,
        bool pkt_has_payload, bool pkt_payload_is_timestamp) {

//    log_info("process_16_bit_packets");
//    log_info("event_pointer: %08x", (uint32_t) event_pointer);
//    log_info("count: %d", pkt_count);
//    log_info("pkt_prefix: %08x", pkt_key_prefix);
//    log_info("pkt_payload_prefix: %08x", pkt_payload_prefix);
//    log_info("payload on: %d", pkt_has_payload);
//    log_info("pkt_format: %d", pkt_prefix_upper);

    // read length and speed
    uint16_t *next_event = (uint16_t *) event_pointer;
    sp_len = (REAL) next_event[0];
    next_event += 1;
    sp_len += fp_div((REAL) next_event[0], REAL_CONST(1000.0));
    next_event += 2;
    sp_dlen = fp_div((REAL) next_event[0], REAL_CONST(1000.0));
    next_event -= 1;
    if (next_event[0] < 32767) {
        sp_dlen += (REAL) next_event[0];
    } else {
        sp_dlen += (REAL)(next_event[0] - 32767);
        sp_dlen = -sp_dlen;
    }
//    sp_dlen = (REAL) next_event[0];
//    if (sp_dlen > 32767) {
//        sp_dlen = -(sp_dlen - 32767);
//    }

    data_has_come = 1;

//    log_info("received (%d.%03d), (%d.%03d) length: %k, dlength: %k",
//             ((uint16_t *)event_pointer)[0],
//             ((uint16_t *)event_pointer)[1],
//             ((uint16_t *)event_pointer)[2],
//             ((uint16_t *)event_pointer)[3],
//             sp_len, sp_dlen);

}


static inline bool eieio_data_parse_packet(
        eieio_msg_t eieio_msg_ptr, uint32_t length) {
    //log_debug("eieio_data_process_data_packet");
//    print_packet_bytes(eieio_msg_ptr, length);

    uint16_t data_hdr_value = eieio_msg_ptr[0];
    void *event_pointer = (void *) &eieio_msg_ptr[1];

    if (data_hdr_value == 0) {

        // Count is 0, so no data
        return true;
    }

    //log_debug("====================================");
    //log_debug("eieio_msg_ptr: %08x", (uint32_t) eieio_msg_ptr);
    //log_debug("event_pointer: %08x", (uint32_t) event_pointer);
//    print_packet(eieio_msg_ptr);

    bool pkt_apply_prefix = (bool) ((data_hdr_value >> 15) & 0x1);
    bool pkt_prefix_upper = (bool) ((data_hdr_value >> 14) & 0x1);
    bool pkt_payload_apply_prefix = (bool) ((data_hdr_value >> 13) & 0x1);
    uint8_t pkt_type = (uint8_t) ((data_hdr_value >> 10) & 0x3);
    uint8_t pkt_count = (uint8_t) (data_hdr_value & 0xFF);
    bool pkt_has_payload = (bool) (pkt_type & 0x1);

    uint32_t pkt_key_prefix = 0;
    uint32_t pkt_payload_prefix = 0;
    bool pkt_payload_is_timestamp = (bool)((data_hdr_value >> 12) & 0x1);

    //log_debug("data_hdr_value: %04x", data_hdr_value);
    //log_debug("pkt_apply_prefix: %d", pkt_apply_prefix);
    //log_debug("pkt_format: %d", pkt_prefix_upper);
    //log_debug("pkt_payload_prefix: %d", pkt_payload_apply_prefix);
    //log_debug("pkt_timestamp: %d", pkt_payload_is_timestamp);
    //log_debug("pkt_type: %d", pkt_type);
    //log_debug("pkt_count: %d", pkt_count);
    //log_debug("payload_on: %d", pkt_has_payload);

    uint16_t *hdr_pointer = (uint16_t *) event_pointer;

    if (pkt_apply_prefix) {

        // Key prefix in the packet
        pkt_key_prefix = (uint32_t) hdr_pointer[0];
        hdr_pointer += 1;

        // If the prefix is in the upper part, shift the prefix
        if (pkt_prefix_upper) {
            pkt_key_prefix <<= 16;
        }
    } else if (!pkt_apply_prefix && apply_prefix) {

        // If there isn't a key prefix, but the config applies a prefix,
        // apply the prefix depending on the key_left_shift
        pkt_key_prefix = prefix;
        if (prefix_type == PREFIX_TYPE_UPPER_HALF_WORD) {
            pkt_prefix_upper = true;
        } else {
            pkt_prefix_upper = false;
        }
    }

//    if (pkt_payload_apply_prefix) {

//        log_info("ciaone");

//        if (!(pkt_type & 0x2)) {

//            // If there is a payload prefix and the payload is 16-bit
//            pkt_payload_prefix = (uint32_t) hdr_pointer[0];
//            hdr_pointer += 1;
//        } else {

//            // If there is a payload prefix and the payload is 32-bit
//            pkt_payload_prefix =
//                (((uint32_t) hdr_pointer[1] << 16) |
//                 (uint32_t) hdr_pointer[0]);
//            hdr_pointer += 2;
//        }
//    }

    // Take the event pointer to start at the header pointer
    event_pointer = (void *) hdr_pointer;

    // If the packet has a payload that is a timestamp, but the timestamp
    // is not the current time, buffer it
//    if (pkt_has_payload && pkt_payload_is_timestamp &&
//            pkt_payload_prefix != time) {
//        log_info("packet has payload");
//        if (pkt_payload_prefix > time) {
//            log_info("adding packet to sdram");
//            add_eieio_packet_to_sdram(eieio_msg_ptr, length);
//            return true;
//        }
//        late_packets += 1;
//        return false;
//    }

    if (pkt_type <= 1) {
//        log_info("received 16bit packet");
        process_16_bit_packets_custom(
            event_pointer, pkt_prefix_upper, pkt_count, pkt_key_prefix,
            pkt_payload_prefix, pkt_has_payload, pkt_payload_is_timestamp);
//        if (recording_flags > 0) {
//            //log_debug("recording a eieio message with length %u", length);
//            recording_record(SPIKE_HISTORY_CHANNEL, eieio_msg_ptr, length);
//        }
        return true;
    }/* else {
        log_info("received 32bit packet");
        process_32_bit_packets(
            event_pointer, pkt_count, pkt_key_prefix,
            pkt_payload_prefix, pkt_has_payload, pkt_payload_is_timestamp);
        if (recording_flags > 0) {
            //log_debug("recording a eieio message with length %u", length);
            recording_record(SPIKE_HISTORY_CHANNEL, eieio_msg_ptr, length);
        }
        return false;
    }*/
}


//! \brief Timer interrupt callback
//! \param[in] timer_count the number of times this call back has been
//!            executed since start of simulation
//! \param[in] unused unused parameter kept for API consistency
//! \return None
void timer_callback(uint timer_count, uint unused) {
    use(timer_count);
    use(unused);

    time++;

    //log_debug("Timer tick %u \n", time);

    /* if a fixed number of simulation ticks that were specified at startup
       then do reporting for finishing */
    if (infinite_run != TRUE && time >= simulation_ticks) {

        // Enter pause and resume state to avoid another tick
        simulation_handle_pause_resume(resume_callback);

        // Finalise any recordings that are in progress, writing back the final
        // amounts of samples recorded to SDRAM
        if (recording_flags > 0) {
            log_info("updating recording regions");
            recording_finalise();
        }

        // Subtract 1 from the time so this tick gets done again on the next
        // run
        time -= 1;
        return;
    }

//    if (send_packet_reqs &&
//            ((time - last_request_tick) >= TICKS_BETWEEN_REQUESTS)) {
//        send_buffer_request_pkt();
//        last_request_tick = time;
//    }

//    if (!msg_from_sdram_in_use) {
//        fetch_and_process_packet();
//    } else if (next_buffer_time < time) {
//        late_packets += 1;
//        fetch_and_process_packet();
//    } else if (next_buffer_time == time) {
//        eieio_data_parse_packet(msg_from_sdram, msg_from_sdram_length);
//        fetch_and_process_packet();
//    }


    // otherwise do synapse and neuron time step updates
    synapses_do_timestep_update(time, get_f_dyn(), get_f_st());
    neuron_do_timestep_update(time, sp_len, sp_dlen, data_has_come);

    // trigger buffering_out_mechanism
    if (recording_flags > 0) {
        recording_do_timestep_update(time);
    }
}

void sdp_packet_callback(uint mailbox, uint port) {

//    log_info("packet callback on port %d", port);

    use(port);
    sdp_msg_t *msg = (sdp_msg_t *) mailbox;
    uint16_t length = msg->length;
    eieio_msg_t eieio_msg_ptr = (eieio_msg_t) &(msg->cmd_rc);

//    packet_handler_selector(eieio_msg_ptr, length - 8);
    eieio_data_parse_packet(eieio_msg_ptr, length - 8);

    // free the message to stop overload
    spin1_msg_free(msg);
}

//! \brief The entry point for this model.
void c_main(void) {

    data_has_come = 0;

    // Load DTCM data
    uint32_t timer_period;

    // initialise the model
    if (!initialise(&timer_period)){
        rt_error(RTE_API);
    }

    // Start the time at "-1" so that the first tick will be 0
    time = UINT32_MAX;

    // Set timer tick (in microseconds)
    log_info("setting timer tick callback for %d microseconds",
              timer_period);
    spin1_set_timer_tick(timer_period);

    // Set up the timer tick callback (others are handled elsewhere)
    spin1_callback_on(TIMER_TICK, timer_callback, TIMER_AND_BUFFERING);

    // Set up callback listening to SDP messages
    simulation_register_simulation_sdp_callback(
        &simulation_ticks, &infinite_run, SDP_AND_DMA_AND_USER);

    // set up provenance registration
    simulation_register_provenance_callback(
        c_main_store_provenance_data, PROVENANCE_DATA_REGION);

    spin1_sdp_callback_on(
            BUFFERING_IN_SDP_PORT, sdp_packet_callback, SDP_AND_DMA_AND_USER);

    simulation_run();
}
