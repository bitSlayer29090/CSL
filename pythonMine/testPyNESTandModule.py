import nest
n = nest.Create("iaf_psc_alpha")
print(str(nest.GetStatus(n)))
nest.Install("muscle_module")
m = nest.Create("muscle_spindle", 40)
pop_size = 40
nest.SetStatus(m[pop_size:80], {'primary':False})
print(str(nest.GetStatus(m)))

