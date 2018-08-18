# edited version of nest_example.py, which has copyright (C) 2017 Lorenzo Vannucci
# reads lengths data, samples length at every 10 ms, converts sampled lengths to decimals of the muscle's
# optimal fiber length, makes population of primary and secondary muscle spindle afferents, simulates, times
# simulation, and plots afferent action potentials in a raster plot
# afferent action potentials in raster plot
# see documentation.txt for explanation of program

# edited version made by Stephanie Hachem

# shebang line to indicate the file is in python
#!/usr/bin/env python3

### parameters
myP = 1 # if printing
myW = 0 # if writing
myPl = 0 # if plotting
pop_size = 50
#mySec = "2"
myR = 1
myLenS = 3
inputDir = "/cluster/2020shachem/CSL/dataMine/lengths/merge2lengths/"\
+ str(myLenS) + "s/"
outputDir = "/cluster/2020shachem/CSL/dataMine/NESToutput/merge2lengths/"\
+ str(myLenS) + "s/"
if(myLenS==1):
	names = ["1with2MTstart6.63", "5with-1MTstart32.26", \
	"8with-1MTstart52.24","10with-1MTstart63.26", "10with-1MTstart63.55", \
	"10with-1MTstart63.57","13with-1MTstart85.39","14with15MTstart97.33", \
	"17with-1MTstart117.63","19with-1MTstart127.91", \
	"19with-1MTstart128.16"]
elif(myLenS==3):
	names=["1with2MTstart6.63","5with6MTstart32.26","8with-1MTstart52.24",\
	"9with10MTstart63.26","9with10MTstart63.55","9with10MTstart63.57",\
	"13with-1MTstart85.39","14with15MTstart97.33","17with-1MTstart117.63",\
	"19with-1MTstart127.91","19with-1MTstart128.16"]

didntCrash = ["0_1","0_2","1_1","1_2","1_3","2_1","2_2","2_3","3_0","3_1","3_2",\
	"3_3","4_1","4_2","5_1","5_2","6_1","6_2","6_3","7_0","7_1","7_2","7_3",\
	"8_0","8_1","8_2","8_3","9_0","9_1","9_2","9_3","10_0","10_1","10_2",\
	"10_3"]

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
currentMuscles=["ECRL","ECU","EDCM","FCR"]

metadataFile = open(outputDir + "metadataFile4cores.txt", "w")
smf = open(outputDir + "shortMetadataFile4cores.txt", "w")

### basically mine, prepare nest
# import modules
import nest
from nest import raster_plot
import pylab
import time

# install muscle_module module
nest.Install("muscle_module")

for myV in range(1):#len(names)):
	#myV = 0
	for myDC in range(len(didntCrash)):#len(currentMuscles)):
		#myC = 1
		
		underscoreIndex = didntCrash[myDC].find("_")
		myV = int(didntCrash[myDC][:underscoreIndex])
		myC = int(didntCrash[myDC][underscoreIndex+1:])
		
		### account for irregular timestep 
		# read file
		myStr = inputDir + names[myV] + "time.mot"
		currentFile = open(myStr, "r")
		s = ""
		for line in currentFile:
		        s += "" + line

		currentFile.close()
		ta = s.split("\n") # times array

		metadataFile.write("times array ; should be reasonable times"\
		" given MTstart\n")
		for i in range(10):
			metadataFile.write(ta[i] + "\n")
		
		if(myP):
			print("times array ; should be reasonable times"\
			" given MTstart\n")
			for i in range(10):
				print(ta[i] + "\n")

		before = float(ta[0]) 
		after = float(ta[0])
		c = 0
		checkA = [] # check array
		indiciesA = [] # indicies array
		checkA = checkA + [float(ta[c])]
		indiciesA = indiciesA + [c]
		# time.mot in s (1000ms/1s)(1sim/10ms) = 100sim/1s = 0.01s/1sim
		while(c<(len(ta)-1)):
			while((after-before<0.01) and (c<(len(ta)-1))):
				c=c+1
				after = float(ta[c])
			before = float(ta[c])
			checkA = checkA + [float(ta[c])]
			indiciesA = indiciesA + [c]

		# print checkA, indiciesA
		metadataFile.write("checkA ; should typically have 0.01 s"\
		" diffs\n")
		for i in range(10):
			metadataFile.write(str(checkA[i])+"\n")

		metadataFile.write("indiciesA \n")
		for i in range(10):
			metadataFile.write(str(indiciesA[i]) + "\n")

		if(myP):
			print("checkA ; should typically have 0.01 s"\
			" diffs\n")
			for i in range(10):
				print(str(checkA[i])+"\n")

			print("indiciesA \n")
			for i in range(10):
				print(str(indiciesA[i]) + "\n")

		"""
		# replaced by 'account for irregular timestep section above
		### sample muscle length alternating at every 2nd or 3rd index 
		#(around every (4*2 =) 8 + (4*3=) 12 = 20/2 = 10 ms (averages 
		#out to every 10 ms per sample) if the average timestep is 
		#around 4 ms)

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
		"""
		
		### read lengths.mot
		#read file
		myStr = inputDir + names[myV] + currentMuscles[myC] \
			+ "lengths.mot"
		currentFile = open(myStr, "r")
		s = ""
		for line in currentFile:
		        s += "" + line

		currentFile.close()
		lengths = s.split("\n")

		metadataFile.write("lengths ; should be reasonable lengths\n")
		for i in range(10):
			metadataFile.write(str(lengths[i])+"\n")

		if(myP):
			print("lengths ; should be reasonable lengths\n")
			for i in range(10):
				print(str(lengths[i])+"\n")
		
		# take lengths at 10 ms intervals
		every10msLengths = []
		for i in range(len(indiciesA)):
			every10msLengths = every10msLengths \
			+ [lengths[indiciesA[i]]]

		metadataFile.write("every 10 ms lengths ; should be reasonable"\
		" lengths\n")
		for i in range(10):
			metadataFile.write(str(every10msLengths[i])+"\n")

		if(myP):
			print("every 10 ms lengths ; should be reasonable"\
			" lengths\n")
			for i in range(10):
				print(str(every10msLengths[i])+"\n")

		### calculate what decimal each sampled length is of the 
		#muscle's optimal fiber length
		# lengths[i] is what decimal of optimal fiber length
		# lengths[i] = x*optimalFiberLength
		# lengths[i]/optimalFiberLength = x
		#print(str(len(every10msLengths)))
		#print(float(every10msLengths[186])/optFiberLengths.get(
		#currentMuscle))
		optLengths = []
		for i in range(len(every10msLengths)-1):
			#print(str(i))
			optLengths = optLengths \
			+ [(float(every10msLengths[i]) \
			/optFiberLengths.get(currentMuscles[myC]))]

		metadataFile.write("optLengths ; should be reasonable lengths"\
			" as decimal of optimal fiber length\n")
		for i in range(10):
			metadataFile.write(str(optLengths[i])+"\n")

		### print before sim

		metadataFile.write("optLengths start "+str(optLengths[0])+"\n")
		metadataFile.write("optLengths end " \
		+ str(optLengths[len(optLengths)-1]) +"\n")
		metadataFile.write("myLenS " + str(myLenS) + " myR " + str(myR)\
		+ " myV " + str(myV) + " myC " + str(myC)+"\n")

		smf.write("optLengths start "+str(optLengths[0])+"\n")
		smf.write("optLengths end " \
		+ str(optLengths[len(optLengths)-1]) +"\n")
		smf.write("myLenS " + str(myLenS) + " myR " + str(myR)\
		+ " myV " + str(myV) + " myC " + str(myC)+"\n")

		if(myP):
			print("optLengths start "+str(optLengths[0])+"\n")
			print("optLengths end " \
			+ str(optLengths[len(optLengths)-1]) +"\n")
			print("myLenS " + str(myLenS) + " myR " + str(myR)\
			+ " myV " + str(myV) + " myC " + str(myC)+"\n")

		### NEST
		# including reset since it seems to speed up
		# reset simulation kernel
		nest.ResetKernel()

		# set simulation kernel status for writing to file
		nest.SetKernelStatus({"overwrite_files": True, "data_path": "", \
		"data_prefix": ""})

		# create spindle population, all primary afferents by default
		ms = nest.Create("muscle_spindle", 2*pop_size)

		# set half of muscle spindle population to secondary afferents
		nest.SetStatus(ms[pop_size:2*pop_size], {'primary': False})

		# fusimotor activation
		dyn_gen = nest.Create('poisson_generator', 1, {'rate': 100.0})
		nest.Connect(dyn_gen, ms, 'all_to_all', {'weight': 1.0, \
		'delay': 1.0, 'receptor_type': 1})
		st_gen = nest.Create('poisson_generator', 1, {'rate': 30.0})
		nest.Connect(st_gen, ms, 'all_to_all', {'weight': 1.0, \
		'delay': 1.0, 'receptor_type': 2})

		# spike detector
		sd = nest.Create("spike_detector")
		nest.Connect(ms, sd)

		# with 'Multimeter to file example' NEST tutorial params, edited\
		# for muscle_spindle
		myLabel = outputDir + names[myV] + currentMuscles[myC] \
			+ "afferents"
		mm = nest.Create("multimeter", params={"interval": 0.1, \
		"record_from": ["primary_rate", "secondary_rate"], "withgid": \
		True, "to_file": True, "label": myLabel})

		nest.Connect(mm, ms)

		# remove some output
		nest.sli_run('M_WARNING setverbosity')
	
		# time simulation
		ta = [] # time array
		for c in range(myR):
			#print(str(myR))
			startTime = time.perf_counter()
			### simulate
			before = 0.0
			#print(str(len(optLengths))) #debug
			for i in range(len(optLengths)):
				if(i==0):
					before = optLengths[i]
				else:
					before = optLengths[i-1]
				nest.SetStatus(ms, {"L": optLengths[i], "dL":\
				 (optLengths[i] - before)*100})
				metadataFile.write(str(i) +"\n") #debug
				if(myP):
					print("sim " + str(i) +"\n") #debug
				nest.Simulate(10.0)

			endTime = time.perf_counter()
			ta=ta + [endTime - startTime]
			#print("seconds elapsed: " + str(endTime - startTime))

		### timing
		# average times
		sum = 0
		for c in range(len(ta)):
			sum += ta[c]
		
		avg = sum/len(ta)

		metadataFile.write("avg seconds spent per nest.Simulate()"\
		" simulation " + str(avg) + "\n")
		smf.write("avg seconds spent per nest.Simulate()"\
		" simulation " + str(avg) + "\n")
		if(myP):
			print("avg seconds spent per nest.Simulate()"\
			" simulation " + str(avg) + "\n")
		
		##print("sum " + str(sum))

		if(myW):		
			### for writing to file
			# get multimeter recordings with time
			events = nest.GetStatus(mm)[0]["events"]
			t = events["times"]
		
		if(myPl):
			### for plotting 
			# spike raster plot
			raster_plot.from_device(sd)
			# multiply by 10 for actual length of time
			pylab.xlim(0, len(optLengths)*10)
			raster_plot.show()
