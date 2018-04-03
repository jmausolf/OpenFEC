#Run Locally
#PYTHONPATH='.' luigi --module luigi_setup_db CreatePidsTable --local-scheduler --date-interval 2018-03-19
#PYTHONPATH='.' luigi --module luigi_setup_db BuildDB --local-scheduler --date-interval 2018-03-19
#PYTHONPATH='.' luigi --module luigi_setup_db CreateIndivCycle --local-scheduler --date-interval 2018-03-19
#PYTHONPATH='.' luigi --module luigi_setup_db CreateCompanyTable --local-scheduler --date-interval 2018-03-19
#PYTHONPATH='.' luigi --module luigi_setup_db CleanCompanyTable --local-scheduler --date-interval 2018-03-19

import luigi
from luigi.util import inherits, requires
import subprocess
import hashlib

#import python code
from util import *
from create_pids_table import *
from create_indiv_cycle import *
from create_company_table import *
from cleanFEC import *
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
	cfg = check_config("master_config.py")

	def output(self):
		return luigi.LocalTarget('logs/luigi/log_{}.txt'.format(self))

	def run(self):
		clean_dev_contrib_csv("emp")
		clean_dev_contrib_csv("occ")

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
	luigi.run()

