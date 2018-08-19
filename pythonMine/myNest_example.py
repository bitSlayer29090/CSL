import nest
from nest import raster_plot
import pylab

# simulation parameters
sim_time = 3300
pop_size = 50

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

# set simulation kernel status for writing to file
nest.SetKernelStatus({"overwrite_files": True, "data_path": "", \
	"data_prefix": ""})

# muscle spindle population
# with primary and secondary afferents
nest.Install("muscle_module")
ms = nest.Create("muscle_spindle", 2*pop_size)
nest.SetStatus(ms[pop_size:2*pop_size], {'primary': False})

# fusimotor activation
dyn_gen = nest.Create('poisson_generator', 1, {'rate': 100.0})
nest.Connect(dyn_gen, ms, 'all_to_all', {'weight': 1.0, 'delay': 1.0, 'receptor_type': 1})
st_gen	= nest.Create('poisson_generator', 1, {'rate': 30.0})
nest.Connect(st_gen, ms, 'all_to_all',	{'weight': 1.0,	'delay': 1.0, 'receptor_type': 2})

# spike detector
sd = nest.Create("spike_detector")
nest.Connect(ms, sd)

# with 'Multimeter to file example' NEST tutorial params, edited for \
# muscle_spindle
mm = nest.Create("multimeter", params={"interval": 0.1, "record_from": \
	["primary_rate", "secondary_rate"], "withgid": True, "to_file": True, \
	"label": "myNest_exampleOutputz"})

nest.Connect(mm,ms)

# remove some output
nest.sli_run('M_WARNING setverbosity')

# mine
my_int_sim_time = int(sim_time/10)
# print(type(my_int_sim_time))

# simulation, setting the new length and stretch speeds every 10ms
for i in range(my_int_sim_time):
	slg.generate_new_length()
	nest.SetStatus(ms, {"L": slg.len, "dL": slg.dlen})
	nest.Simulate(10.0)

# get multimeter recordings with time 
events = nest.GetStatus(mm)[0]["events"]
"""
# spike raster plot
raster_plot.from_device(sd)
pylab.xlim(0, sim_time)
raster_plot.show()
"""


