import pylab
import time
import random
from threading import Condition

# database stuff
from spynnaker.pyNN.utilities import conf
from spinn_front_end_common.utilities.notification_protocol.socket_address \
    import SocketAddress
from spynnaker_external_devices_plugin.pyNN.\
    spynnaker_external_device_plugin_manager import \
    SpynnakerExternalDevicePluginManager


import spynnaker.pyNN as p

from python_models.neuron.builds.muscle_spindle import MuscleSpindle

from spindle_length_sender import SpindleLengthSender

from spynnaker_external_devices_plugin.pyNN.connections\
    .spynnaker_live_spikes_connection import SpynnakerLiveSpikesConnection

import spynnaker_external_devices_plugin.pyNN as ExternalDevices

from spinn_front_end_common.utilities.database.database_reader import DatabaseReader

# p.set_number_of_neurons_per_core('MuscleSpindle', 100)

# Set the run time of the execution
run_time = 3300

# Set the time step of the simulation in milliseconds
time_step = 1.0

# Set the number of neurons to simulate
n_fibers = 100

# Set the i_offset current
i_offset = 1.0

# Set the weight of input spikes
weight = 1.0

p.setup(time_step)


# spindle population
spindle_pop = p.Population(
    n_fibers*2, MuscleSpindle,
    {
        "primary": [1] * n_fibers + [0] * n_fibers,
        "v_thresh": 100.0,
        "receive_port": 12345
    },
    label="spindle_pop")

spindle_pop.record()

# dynamic fusimotor drive
gamma_dyn = p.Population(1, p.SpikeSourcePoisson, {'rate': 70.0})
p.Projection(
     gamma_dyn, spindle_pop,
     p.OneToOneConnector(weights=weight),
     target="dynamic")


# static fusimotor drive
gamma_st = p.Population(1, p.SpikeSourcePoisson, {'rate': 40.0})
p.Projection(
    gamma_st, spindle_pop,
    p.OneToOneConnector(weights=weight),
    target="static")


# database for live communication
spynnaker_external_devices = SpynnakerExternalDevicePluginManager()
def create_database():
    database_notify_port_num = conf.config.getint("Database", "notify_port")
    database_notify_host = conf.config.get("Database", "notify_hostname")
    database_ack_port_num = conf.config.get("Database", "listen_port")
    if database_ack_port_num == "None":
        database_ack_port_num = None

    # build the database socket address used by the notification interface
    database_socket = SocketAddress(
        listen_port=database_ack_port_num,
        notify_host_name=database_notify_host,
        notify_port_no=database_notify_port_num)

    # update socket interface with new demands.
    spynnaker_external_devices.add_socket_address(database_socket)

create_database()


# send the length
lsender = SpindleLengthSender(['spindle_pop'])


# simulation
p.run(run_time)


# raster plot
spikes = spindle_pop.getSpikes()
if spikes is not None:
    # print spikes
    pylab.figure()
    pylab.plot([i[1] for i in spikes], [i[0] for i in spikes], ".")
    pylab.xlabel('Time/ms')
    pylab.ylabel('spikes')
    pylab.title('spikes')
    pylab.show()
else:
    print "No spikes received"
