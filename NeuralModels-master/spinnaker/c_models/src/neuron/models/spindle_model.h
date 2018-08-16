#ifndef _NEURON_MODEL_MY_IMPL_H_
#define _NEURON_MODEL_MY_IMPL_H_

//#include <neuron/models/neuron_model.h>

#include <neuron/../common/neuron-typedefs.h>

//! Forward declaration of neuron type (creates a definition for a pointer to a
//   Neuron parameter struct
typedef struct neuron_t* neuron_pointer_t;

//! Forward declaration of global neuron parameters
typedef struct global_neuron_params_t* global_neuron_params_pointer_t;

//! \brief set the global neuron parameters
//! \param[in] params The parameters to set
void neuron_model_set_global_neuron_params(
    global_neuron_params_pointer_t params);

//! \brief primary function called in timer loop after synaptic updates
//! \param[in] exc_input The inputs received this timer tick that produces
//!     a positive reaction within the neuron in terms of stimulation.
//! \param[in] inh_input The inputs received this timer tick that produces
//!     a negative reaction within the neuron in terms of stimulation.
//! \param[in] external_bias This is the intrinsic plasticity which could be
//!     used for ac, noisy input etc etc. (general purpose input)
//! \param[in] neuron the pointer to a neuron parameter struct which contains
//!     all the parameters for a specific neuron
//! \return state_t which is the value to be compared with a threshold value
//!     to determine if the neuron has spiked
bool neuron_check_for_spike(neuron_pointer_t neuron);

//! \brief Indicates that the neuron has spiked
//! \param[in] neuron pointer to a neuron parameter struct which contains all
//!     the parameters for a specific neuron
void neuron_model_has_spiked(neuron_pointer_t neuron);

//! \brief get the neuron membrane voltage for a given neuron parameter set
//! \param[in] neuron a pointer to a neuron parameter struct which contains
//!     all the parameters for a specific neuron
//! \return state_t the voltage membrane for a given neuron with the neuron
//!     parameters specified in neuron
state_t neuron_model_get_membrane_voltage(restrict neuron_pointer_t neuron);

//! \brief printout of state variables i.e. those values that might change
//! \param[in] neuron a pointer to a neuron parameter struct which contains all
//!     the parameters for a specific neuron
void neuron_model_print_state_variables(restrict neuron_pointer_t neuron);

//! \brief printout of parameters i.e. those values that don't change
//! \param[in] neuron a pointer to a neuron parameter struct which contains all
//!     the parameters for a specific neuron
//! \return None, this method does not return anything
void neuron_model_print_parameters(restrict neuron_pointer_t neuron);

typedef struct neuron_t {

    // steps to next spike
    int32_t timer;
    int32_t primary;

} neuron_t;

typedef struct global_neuron_params_t {    

    // TODO: Add any parameters that apply to the whole model here (i.e. not
    // just to a single neuron)
    // Note: often these are not user supplied, but computed parameters
    uint32_t machine_time_step;

    // integration time
    REAL int_time;

    // firing rates
    REAL primary_afferent_rate;
    int32_t primary_spike_timer;
    REAL secondary_afferent_rate;
    int32_t secondary_spike_timer;

    // previous values of T for integration
    REAL T_bag1;
    REAL T_bag2;
    REAL T_chain;


} global_neuron_params_t;


// compute the firing rate of muscle spindle for all population
void spindle_model_compute_rate(REAL _f_dyn_bag1, REAL f_st_bag2, REAL f_st_chain,
    REAL L, REAL dL);


#endif // _NEURON_MODEL_MY_IMPL_H_

