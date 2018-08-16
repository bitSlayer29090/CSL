# main interface to use the spynnaker related tools.
# ALL MODELS MUST INHERIT FROM THIS
from spynnaker.pyNN.models.neuron.abstract_population_vertex \
    import AbstractPopulationVertex

# input types (all imported for help, only use one)
from spynnaker.pyNN.models.neuron.input_types.input_type_current \
    import InputTypeCurrent

# new model template
from python_models.neuron.neuron_models.spindle_model \
    import SpindleModel

# synapse types
from python_models.neuron.synapse_types.fusimotor_activation \
    import FusimotorActivation

# threshold types
# standard
from spynnaker.pyNN.models.neuron.threshold_types.threshold_type_static \
    import ThresholdTypeStatic

# for getting data from a port
from spinn_front_end_common.utilities import constants
from pacman.model.constraints.tag_allocator_constraints\
    .tag_allocator_require_reverse_iptag_constraint \
    import TagAllocatorRequireReverseIptagConstraint
from spinn_front_end_common.interface.buffer_management.buffer_models\
    .receives_buffers_to_host_basic_impl import ReceiveBuffersToHostBasicImpl


class MuscleSpindle(AbstractPopulationVertex,
                    ReceiveBuffersToHostBasicImpl):

    # Maximum number of atoms per core that can be supported.
    _model_based_max_atoms_per_core = 256

    # default parameters for this build. Used when end user has not entered any
    default_parameters = {
        'v_thresh': -50.0,
        'a_syn_D': 0.08,
        'tau_syn_D': 310.0,
        'a_syn_S': 0.06,
        'tau_syn_S': 425.0,
        'primary': 1}

    def __init__(
            self, n_neurons, machine_time_step, timescale_factor,
            spikes_per_second=None, ring_buffer_sigma=None,
            incoming_spike_buffer_size=None, constraints=None, label=None,

            # neuron model parameters
            primary=default_parameters['primary'],

            # threshold types parameters
            v_thresh=default_parameters['v_thresh'],

            # initial values for the state values
            v_init=None,

            receive_port=None,
            receive_tag=None,
            board_address=None
            ):

        # create your neuron model class
        neuron_model = SpindleModel(
            n_neurons, machine_time_step, primary)

        # create your synapse type model
        synapse_type = FusimotorActivation(
            n_neurons, machine_time_step,
            MuscleSpindle.default_parameters['a_syn_D'],
            MuscleSpindle.default_parameters['tau_syn_D'],
            MuscleSpindle.default_parameters['a_syn_S'],
            MuscleSpindle.default_parameters['tau_syn_S'])

        # create your input type model
        input_type = InputTypeCurrent()

        # create your threshold type model
        threshold_type = ThresholdTypeStatic(n_neurons, v_thresh)

        # create your own additional inputs
        additional_input = None

        # instantiate the sPyNNaker system by initialising
        #  the AbstractPopulationVertex
        AbstractPopulationVertex.__init__(

            # standard inputs, do not need to change.
            self, n_neurons=n_neurons, label=label,
            machine_time_step=machine_time_step,
            timescale_factor=timescale_factor,
            spikes_per_second=spikes_per_second,
            ring_buffer_sigma=ring_buffer_sigma,
            incoming_spike_buffer_size=incoming_spike_buffer_size,

            # max units per core
            max_atoms_per_core=MuscleSpindle._model_based_max_atoms_per_core,

            # These are the various model types
            neuron_model=neuron_model, input_type=input_type,
            synapse_type=synapse_type, threshold_type=threshold_type,
            additional_input=additional_input,

            # model name (shown in reports)
            model_name="MuscleSpindle",

            # matching binary name
            binary="muscle_spindle.aplx")

        ReceiveBuffersToHostBasicImpl.__init__(self)

        self.add_constraint(TagAllocatorRequireReverseIptagConstraint(
                receive_port, constants.SDP_PORTS.INPUT_BUFFERING_SDP_PORT.value,
                board_address, receive_tag))

    @staticmethod
    def set_model_max_atoms_per_core(new_value):

        MuscleSpindle._model_based_max_atoms_per_core = new_value
