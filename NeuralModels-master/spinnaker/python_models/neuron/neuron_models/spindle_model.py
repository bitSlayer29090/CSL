from spynnaker.pyNN.models.neural_properties.neural_parameter \
    import NeuronParameter
from spynnaker.pyNN.models.neuron.neuron_models.abstract_neuron_model \
    import AbstractNeuronModel
from spynnaker.pyNN.utilities import utility_calls

from data_specification.enums.data_type import DataType


class SpindleModel(AbstractNeuronModel):

    def __init__(
            self, n_neurons, machine_time_step,
            primary,
            v_init=-70.0):
        AbstractNeuronModel.__init__(self)
        self._n_neurons = n_neurons
        self._machine_time_step = machine_time_step

        self._primary = utility_calls.convert_param_to_numpy(
            primary, n_neurons)

        self._v_init = utility_calls.convert_param_to_numpy(v_init, n_neurons)

    # getters and setters for the parameters

    @property
    def primary(self):
        return self._primary

    @primary.setter
    def primary(self, primary):
        self._primary = utility_calls.convert_param_to_numpy(
            primary, self._n_neurons)

    # initialisers for the state variables

    def initialize_v(self, v_init):
        self._v_init = utility_calls.convert_param_to_numpy(
            v_init, self._n_neurons)

    def get_n_neural_parameters(self):
        # Note: this must match the number of parameters in the neuron_t
        # data structure in the C code
        return 2

    def get_neural_parameters(self):
        # Note: this must match the order of the parameters in the neuron_t
        # data structure in the C code
        return [

            NeuronParameter(-1, DataType.INT32),
            NeuronParameter(self._primary, DataType.INT32)

        ]

    def get_n_global_parameters(self):
        # Note: This must match the number of parameters in the global_neuron_t
        # data structure in the C code
        return 9

    def get_global_parameters(self):
        # Note: This must match the order of the parameters in the
        # global_neuron_t data structure in the C code
        return [

            # uint32_t machine_time_step
            NeuronParameter(self._machine_time_step, DataType.UINT32),
            NeuronParameter(0.0, DataType.S1615),
            NeuronParameter(0.0, DataType.S1615),
            NeuronParameter(0, DataType.INT32),
            NeuronParameter(0.0, DataType.S1615),
            NeuronParameter(0, DataType.INT32),
            NeuronParameter(0.0, DataType.S1615),
            NeuronParameter(0.0, DataType.S1615),
            NeuronParameter(0.0, DataType.S1615)

        ]

    def get_n_cpu_cycles_per_neuron(self):
        # the number of CPU cycles taken by the
        # neuron_model_state_update, neuron_model_get_membrane_voltage
        # and neuron_model_has_spiked functions in the C code
        # Note: This is a guess
        return 80
