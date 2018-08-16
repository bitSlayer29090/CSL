import time
import math

from spynnaker_external_devices_plugin.pyNN.connections\
    .spynnaker_live_spikes_connection import SpynnakerLiveSpikesConnection

# class that sends a lenghts and extensions speeds, using SpiNNaker APIs
# it simulates a simple stretch
class SpindleLengthSender(object):

    def __init__(self, pop_labels):
        self._length_sender = SpynnakerLiveSpikesConnection(
                                receive_labels=None, local_port=19999,
                                send_labels=pop_labels)
        self._len = 0.95
        self._dlen = 0.0
        self._go_on = True

        for label in pop_labels:
            self._length_sender.add_start_callback(label, self.send_input_spindle)

        self._count = 0

    def len_to_intlist(self):
        l = list()
        l.append(int(math.trunc(self._len)))
        l.append(int((self._len - math.trunc(self._len)) * 1000))
        l.append(int(math.trunc(self._dlen)))
        l.append(int((self._dlen - math.trunc(self._dlen)) * 1000))
        return l

    def stop(self):
        self._go_on = False

    def generate_new_length(self):
        if self._count < 110:
            self._len = 0.95
            self._dlen = 0.0
        elif self._count < 220:
            self._len += (1.08-0.95)/110
            self._dlen = (1.08-0.95)/1.1
        else:
            self._len = 1.08
            self._dlen = 0.0
        self._count += 1

    def send_input_spindle(self, label, sender):
        while self._go_on:
            self.generate_new_length()
            sender.send_spikes(label, self.len_to_intlist())
            time.sleep(0.01)
