#Run Locally
#PYTHONPATH='.' luigi --module luigi_setup_db CreatePidsTable --local-scheduler --date-interval 2018-03-19
#PYTHONPATH='.' luigi --module luigi_setup_db BuildDB --local-scheduler --date-interval 2018-03-19
#PYTHONPATH='.' luigi --module luigi_setup_db CreateIndivCycle --local-scheduler --date-interval 2018-03-19
#PYTHONPATH='.' luigi --module luigi_setup_db CreateCompanyTable --local-scheduler --date-interval 2018-03-19
#PYTHONPATH='.' luigi --module luigi_setup_db GenDevEmpOcc --local-scheduler --date-interval 2018-03-19
#PYTHONPATH='.' luigi --module luigi_setup_db CleanDevEmpOcc --local-scheduler --date-interval 2018-03-19
#PYTHONPATH='.' luigi --module luigi_setup_db CleanCompanyTable --local-scheduler --date-interval 2018-03-19


#Python Path Examples to Take Only the Top-N (Cleaned) Employees plus Leaders Rather Than All Cleaned Employees
#Robustness Check

#PYTHONPATH='.' luigi --module luigi_setup_db CleanCompanyTable --local-scheduler --date-interval 2018-03-19
#PYTHONPATH='.' luigi --module luigi_setup_db CleanCompanyTable --local-scheduler --date-interval 2018-03-21 --top-n 50 --leaders

from mpi4py import MPI
#comm = MPI.COMM_WORLD
#print("hello world")
#print("my rank is: %d"%comm.rank)
#exit()


import luigi
#import luigi.contrib.mpi as mpi
from luigi.util import inherits, requires
import subprocess
import hashlib

#import python code
from util import *
from create_pids_table import *
from create_indiv_cycle import *
from create_company_table import *
#from cleanFEC import *
from clean_company_table import *
#from build_db import *


#class CheckConfig(luigi.Task):
#	cfg = luigi.Parameter()


#Step 1
#@requires(CheckConfig(cfg=check_config("master_config.py")))
class CreatePidsTable(luigi.Task):


	date_interval = luigi.DateIntervalParameter()
	cfg = check_config("master_config.py")
	#print(cfg)

	def output(self):
		return luigi.LocalTarget('logs/luigi/log_{}.txt'.format(self))

	def run(self):
		make_pids_table(db, c)
		#make_pids_table(db, c, lim=10)
		with self.output().open('w') as out_file:
			 out_file.write("Done with task: {}".format(self))


#Step 2: build main db tables
#requires step1
@requires(CreatePidsTable)
class BuildDB(luigi.Task):
	date_interval = luigi.DateIntervalParameter()
	cfg = check_config("master_config.py")

	def output(self):
		return luigi.LocalTarget('logs/luigi/log_{}.txt'.format(self))

	def run(self):
		download_build("master_config")
		with self.output().open('w') as out_file:
			 out_file.write("Done with task: {}".format(self))



#Step 3: Regen indiv contrib w/ cycle
#requires step2
@requires(BuildDB)
class CreateIndivCycle(luigi.Task):
	date_interval = luigi.DateIntervalParameter()
	cfg = check_config("master_config.py")

	def output(self):
		return luigi.LocalTarget('logs/luigi/log_{}.txt'.format(self))

	def run(self):
		add_cycle_indiv(db, c, "individual_contributions")

		with self.output().open('w') as out_file:
			 out_file.write("Done with task: {}".format(self))


#Step 4: join indiv_contrib aka create_company table
#requires step3
@requires(CreateIndivCycle)
class CreateCompanyTable(luigi.Task):
	date_interval = luigi.DateIntervalParameter()
	cfg = check_config("master_config.py")

	def output(self):
		return luigi.LocalTarget('logs/luigi/log_{}.txt'.format(self))

	def run(self):
		#add_cycle_indiv(db, c, "individual_contributions")
		create_company_table(db, c)

		with self.output().open('w') as out_file:
			 out_file.write("Done with task: {}".format(self))


#Step 5: Gen Dev Clean CSV's
@requires(CreateCompanyTable)
class GenDevEmpOcc(luigi.Task):
	date_interval = luigi.DateIntervalParameter()
	cfg = check_config("master_config.py")

	def output(self):
		return luigi.LocalTarget('logs/luigi/log_{}.txt'.format(self))

	def run(self):
		clean_company_table(db, c, dev=True)

		with self.output().open('w') as out_file:
			 out_file.write("Done with task: {}".format(self))


#Step 6: Clean Dev EmpOCC
@requires(GenDevEmpOcc)
class CleanDevEmpOcc(luigi.Task):
	date_interval = luigi.DateIntervalParameter()
	top_n = luigi.IntParameter(default=0)
	leaders = luigi.BoolParameter(default=False)

	cfg = check_config("master_config.py")

	def output(self):
		return luigi.LocalTarget('logs/luigi/log_{}.txt'.format(self))

	def run(self):
		print(self.top_n)
		print(self.leaders)

		if self.top_n > 0 and self.leaders is not False:
			clean_dev_contrib_csv("emp", top_n=self.top_n, leaders=self.leaders)
			clean_dev_contrib_csv("occ", top_n=self.top_n, leaders=self.leaders)

		else:
			clean_dev_contrib_csv("emp")
			clean_dev_contrib_csv("occ")

		#clean_dev_contrib_csv("occ", top_n=5, leaders=True)

		with self.output().open('w') as out_file:
			 out_file.write("Done with task: {}".format(self))




#Step 7: QC Filtering
@requires(CleanDevEmpOcc)
class CleanCompanyTable(luigi.Task):
	date_interval = luigi.DateIntervalParameter()
	cfg = check_config("master_config.py")

	def output(self):
		return luigi.LocalTarget('logs/luigi/log_{}.txt'.format(self))

	def run(self):
		#clean_company_table(db, c, dev=True)
		clean_company_table(db, c)

		with self.output().open('w') as out_file:
			 out_file.write("Done with task: {}".format(self))




if __name__ == "__main__":
	
	comm = MPI.COMM_WORLD
	rank = comm.Get_rank()

	if rank == 0:
		luigi.run(cmdline_args=["--local-scheduler",
					"--date-interval=2018-04-20"],
			main_task_cls=CleanCompanyTable)
	else:
		pass

	#luigi.run()
	#luigi.run(["--local-scheduler --date-interval 2018-04-20"], main_task_cls=CleanCompanyTable)
	#exit()

	#Step 1
	#tasks = [CreatePidsTable()]
	#mpi.run(tasks)

	#Step 2
	#tasks = [BuildDB()]
	#mpi.run(tasks)

	#Step 3
	#tasks = [CreateIndivCycle()]
	#mpi.run(tasks)
	
	#Step 4
	#tasks = [CreateCompanyTable()]
	#mpi.run(tasks)

	#Step 5
	#tasks = [GenDevEmpOcc()]
	#mpi.run(tasks)

	#Step 6
	#tasks = [CleanDevEmpOcc()]
	#mpi.run(tasks)

	#Step 7
	#tasks = [CleanCompanyTable()]
	#mpi.run(tasks)



