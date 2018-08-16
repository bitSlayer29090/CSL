import multiprocessing as mp
import random
import string

def cube(x):
	return x**3

# both Pool.apply and Pool.map lock main program until all processes finished
# uncomment one or the other, but not both, of the 2 sections directly below
# Pool.apply
#pool = mp.Pool(processes=4)
#results = [pool.apply(cube, args=(x,)) for x in range(1,7)]
#print(results)

# Pool.map
#pool = mp.Pool(processes=4)
#results = pool.map(cube, range(1,7))
#print(results)

# both Pool.apply_async and Pool.map_async return stuff as soon as done ; must use get() after apply_async()
pool = mp.Pool(processes=4)
results = [pool.apply_async(cube, args=(x,)) for x in range(1,7)]
output = [p.get() for p in results]
print(output)

