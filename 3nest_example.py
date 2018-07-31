# edited version of nest_example.py, which has copyright (C) 2017 Lorenzo Vannucci
# reads lengths data, samples length at every 10 ms, converts sampled lengths to decimals of the muscle's
# optimal fiber length, makes population of primary and secondary muscle spindle afferents, simulates, times
# simulation, and plots afferent action potentials in a raster plot
# afferent action potentials in raster plot
# see documentation.txt for explanation of program

# edited version made by Stephanie Hachem

# change currentMuscle, currentFile = open( ,  myR, mySec

# shebang line to indicate the file is in python
#!/usr/bin/env python3

### parameters
pop_size = 50
mySec = "2"
myR = 1

# muscle optimal fiber lengths in meters
optFiberLengths = { \
        "SUBSC":0.0873, \
        "TRIlong" : 0.134, \
        "BIClong" : 0.1157, \
        "BICshort": 0.1321, \
        "BRA" : 0.0858, \
        "ECRL": 0.081, \
        "ECU" : 0.0622, \
        "EDCM" : 0.0724, \
	"FCR" : 0.0628}
currentMuscle = "FCR" # change this line to the name of the muscle, and put the muscle's name and optimal fiber length in the dictionary above

### read file
myStr = "pythonNESTtimingLengthsOfTryWithRm202/" + mySec + "s/" + currentMuscle + "lengths.mot"
currentFile = open(myStr, "r")
s = ""
for line in currentFile:
        s += "" + line

currentFile.close()
lengths = s.split("\n")

### sample muscle length alternating at every 2nd or 3rd index (around every (4*2 =) 8 + (4*3=) 12 = 20/2 = 10 ms (averages out to every 10 ms per sample) if the average timestep is around 4 ms)

leftover = len(lengths)%10
lengths = lengths[:len(lengths)-leftover]

every10lengths = []
c = 0
while(c<len(lengths)):
	if(c%2==0):
		every10lengths = every10lengths + [lengths[c]]
		c=c+3
	else:
		every10lengths = every10lengths + [lengths[c]]
		c=c+2

# print(len(every10lengths))

### calculate what decimal each sampled length is of the muscle's optimal fiber length
# lengths[i] is what decimal of optimal fiber length
# lengths[i] = x*optimalFiberLength
# lengths[i]/optimalFiberLength = x
#print(str(len(every10lengths)))
#print(float(every10lengths[186])/optFiberLengths.get(currentMuscle))
optLengths = []
for i in range(len(every10lengths)-1):
	#print(str(i))
	optLengths = optLengths + [(float(every10lengths[i])/optFiberLengths.get(currentMuscle))]

### basically mine, prepare nest
# import modules
import nest
from nest import raster_plot
import pylab
import time
#import timeit

# reset simulation kernel
nest.ResetKernel()

# set simulation kernel status for writing to file
nest.SetKernelStatus({"overwrite_files": True, "data_path": "", "data_prefix": ""})

### set up model
# install muscle_module module
nest.Install("muscle_module")

# create muscle spindle population, all primary afferents by default
ms = nest.Create("muscle_spindle", 2*pop_size)

# set half of muscle spindle population to secondary afferents
nest.SetStatus(ms[pop_size:2*pop_size], {'primary': False})

# fusimotor activation
dyn_gen = nest.Create('poisson_generator', 1, {'rate': 100.0})
nest.Connect(dyn_gen, ms, 'all_to_all', {'weight': 1.0, 'delay': 1.0, 'receptor_type': 1})
st_gen = nest.Create('poisson_generator', 1, {'rate': 30.0})
nest.Connect(st_gen, ms, 'all_to_all', {'weight': 1.0, 'delay': 1.0, 'receptor_type': 2})

# spike detector
sd = nest.Create("spike_detector")
nest.Connect(ms, sd)

# mine
# with 'Multimeter to file example' NEST tutorial params, edited for muscle_spindle
mm = nest.Create("multimeter", params={"interval": 0.1, "record_from": ["primary_rate", "secondary_rate"], "withgid": True, "to_file": True, "label": "my_multimeter"})

nest.Connect(mm, ms)
# mine ends

# remove some output
nest.sli_run('M_WARNING setverbosity')

print("muscle: " + currentMuscle)

# time simulation
ta = [] # time array
for c in range(myR):
	startTime = time.perf_counter()
	#def mySimu():
	### simulate
	before = 0.0
	for i in range(len(optLengths)):
		if(i==0):
			before = optLengths[i]
		else:
			before = optLengths[i-1]
		nest.SetStatus(ms, {"L": optLengths[i], "dL": (optLengths[i] - before)*100})
		nest.Simulate(10.0)

	#timeit.Timer("mySimu()", "from __main__ import mySimu")
	#timeit.timeit("mySimu()", number=5)

	endTime = time.perf_counter()
	ta=ta + [endTime - startTime]
	#print("seconds elapsed: " + str(endTime - startTime))

# average times
sum = 0
for c in range(len(ta)):
	sum += ta[c]

avg = sum/len(ta)

print("myR " + str(myR))
print("mySec " + mySec)
print("avg ") 
print(avg)
print("sum ")
print(sum)

"""
# get multimeter recordings with time
events = nest.GetStatus(mm)[0]["events"]
t = events["times"]

### spike raster plot
raster_plot.from_device(sd)
pylab.xlim(0, len(optLengths)*10) # multiply by 10 for actual length of time
raster_plot.show()
"""

