# -*- coding: utf-8 -*-
#
# nest_example.py
#
# Copyright (C) 2017 Lorenzo Vannucci
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


import nest
from nest import raster_plot
import pylab


# simulation parameters
sim_time = 3300
pop_size = 50


# auxiliary class to simulate the muscle stretch
class SpindleLengthGenerator(object):

    def __init__(self):
        self._len = 0.95
        self._dlen = 0.0
        self._go_on = True

        self._count = 0

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

    @property
    def len(self):
        return self._len

    @property
    def dlen(self):
        return self._dlen

slg = SpindleLengthGenerator()


# muscle spindle population
# with primary and secondary afferents
nest.Install("muscle_module")
ms = nest.Create("muscle_spindle", 2*pop_size)
nest.SetStatus(ms[pop_size:2*pop_size], {'primary': False})

# fusimotor activation
dyn_gen = nest.Create('poisson_generator', 1, {'rate': 100.0})
nest.Connect(dyn_gen, ms, 'all_to_all', {'weight': 1.0, 'delay': 1.0, 'receptor_type': 1})
st_gen = nest.Create('poisson_generator', 1, {'rate': 30.0})
nest.Connect(st_gen, ms, 'all_to_all', {'weight': 1.0, 'delay': 1.0, 'receptor_type': 2})

# spike detector
sd = nest.Create("spike_detector")
nest.Connect(ms, sd)

# remove some output
nest.sli_run('M_WARNING setverbosity')

# simulation, setting the new length and stretch speeds every 10ms
for i in xrange(sim_time/10):
    slg.generate_new_length()
    nest.SetStatus(ms, {"L": slg.len, "dL": slg.dlen})
    nest.Simulate(10.0)

# spike raster plot
raster_plot.from_device(sd)
pylab.xlim(0, sim_time)
raster_plot.show()