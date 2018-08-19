import nest
import numpy
import pylab

nest.ResetKernel()

nest.SetKernelStatus({"overwrite_files": True, "data_path": "", "data_prefix": ""})

print("iaf_cond_alpha recordables: {0}".format(nest.GetDefaults("iaf_cond_alpha")["recordables"]))

n = nest.Create("iaf_cond_alpha", params={"tau_syn_ex": 1.0, "V_reset": -70.0})
m = nest.Create("multimeter", params={"interval": 0.1, "record_from": ["V_m", "g_ex", "g_in"], "withgid": True, "to_file": True, "label": "my_multimeter"})
s_ex = nest.Create("spike_generator", params={"spike_times": numpy.array([10.0, 20.0, 50.0])})
s_in = nest.Create("spike_generator", params={"spike_times": numpy.array([15.0, 25.0, 55.0])})

nest.Connect(s_ex, n, syn_spec={"weight": 40.0})
nest.Connect(s_in, n, syn_spec={"weight": -20.0})
nest.Connect(m, n)

nest.Simulate(100.)

events = nest.GetStatus(m)[0]["events"]
t = events["times"]

pylab.clf()

pylab.subplot(211)
pylab.plot(t, events["V_m"])
pylab.axis([0, 100, -75, -53])
pylab.ylabel("membrane potential (mV)")

pylab.subplot(212)
pylab.plot(t, events["g_ex"], t, events["g_in"])
pylab.axis([0,100,0,45])
pylab.xlabel("time (ms)")
pylab.ylabel("synaptic conductance (nS)")
pylab.legend(("g_exc", "g_inh"))
pylab.show()

