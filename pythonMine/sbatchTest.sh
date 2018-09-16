#!/bin/bash
#SBATCH -n 4
#SBATCH --ntasks-per-node=2

srun -n 2 -w hpc1 python 3main.py
