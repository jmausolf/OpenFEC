####################################################
#Copy this file to your home directory and run it with qsub
#"qsub pythonsubmit.sh" will start the job 
#This script will start 25 instances of python and report back with the rank 
#You will need to add "module load openmpi/1.10.7" to /home/USERNAME/.profile first
###################################################

#!/bin/bash
#PBS -N PythonTest
#PBS -j oe
#PBS -V
#PBS -l procs=25,mem=10gb

cd $PBS_O_WORKDIR

#mprirun will start 25 instances of helloworld.py
#$PBS_NODFILE tells mpirun which CPU's PBS reseved for the job
#helloworld.py will print the jobs rank
mpirun -n 1 -machinefile $PBS_NODEFILE python3 luigi_setup_db.py
#mpirun -n 25 -machinefile $PBS_NODEFILE PYTHONPATH='.' luigi --module luigi_setup_db CleanCompanyTable --local-scheduler --date-interval 2018-04-20
