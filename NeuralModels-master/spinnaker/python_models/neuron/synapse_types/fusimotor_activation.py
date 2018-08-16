from spynnaker.pyNN.utilities import utility_calls
from spynnaker.pyNN.models.neural_properties.neural_parameter \
    import NeuronParameter
from spynnaker.pyNN.models.neuron.synapse_types.abstract_synapse_type \
    import AbstractSynapseType

from data_specification.enums.data_type import DataType

import numpy


def get_exponential_decay_and_init(a, tau, machine_time_step):

    decay = numpy.exp(numpy.divide(-float(machine_time_step),
                                   numpy.multiply(1000.0, tau)))
    init = numpy.multiply(a,numpy.multiply(numpy.multiply(tau, numpy.subtract(1.0, decay)),
                          (1000.0 / float(machine_time_step))))
    return decay, init


class FusimotorActivation(AbstractSynapseType):

    def __init__(self, n_neurons, machine_time_step, a_syn_D, tau_syn_D, a_syn_S, tau_syn_S):
        AbstractSynapseType.__init__(self)
        self._n_neurons = n_neurons
        self._machine_time_step = machine_time_step
        self._a_syn_D = a_syn_D
        self._tau_syn_D = tau_syn_D
        self._a_syn_S = a_syn_S
        self._tau_syn_S = tau_syn_S

    @property
    def tau_syn_D(self):
        return self._tau_syn_D

    @tau_syn_D.setter
    def tau_syn_D(self, tau_syn_D):
        self._tau_syn_D = utility_calls.convert_param_to_numpy(
            tau_syn_D, self._n_neurons)

    @property
    def tau_syn_S(self):
        return self._tau_syn_S

    @tau_syn_S.setter
    def tau_syn_S(self, tau_syn_S):
        self._tau_syn_S = utility_calls.convert_param_to_numpy(
            tau_syn_S, self._n_neurons)

    def get_n_synapse_types(self):
        return 2

    def get_synapse_id_by_target(self, target):
        if target == "dynamic":
            return 0
        elif target == "static":
            return 1
        return None

    def get_synapse_targets(self):
        return "dynamic", "static"

    def get_n_synapse_type_parameters(self):
        return 4

    def get_synapse_type_parameters(self):
        d_decay, d_init = get_exponential_decay_and_init(
            self._a_syn_D, self._tau_syn_D, self._machine_time_step)
        s_decay, s_init = get_exponential_decay_and_init(
            self._a_syn_S, self._tau_syn_S, self._machine_time_step)

        return [
            NeuronParameter(d_decay, DataType.S1615),
            NeuronParameter(d_init, DataType.S1615),
            NeuronParameter(s_decay, DataType.S1615),
            NeuronParameter(s_init, DataType.S1615)
        ]

    def get_n_cpu_cycles_per_neuron(self):
        # A guess
        return 100
