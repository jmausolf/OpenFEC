#Run Locally
#PYTHONPATH='.' luigi --module luigi_setup_db CreatePidsTable --local-scheduler --date-interval 2018-03-19
#PYTHONPATH='.' luigi --module luigi_setup_db BuildDB --local-scheduler --date-interval 2018-03-19
#PYTHONPATH='.' luigi --module luigi_setup_db CreateIndivCycle --local-scheduler --date-interval 2018-03-19

import luigi
from luigi.util import inherits, requires
import subprocess


#import python code
from create_pids_table import *
from create_indiv_cycle import *
#from build_db import *


#Step 1
class CreatePidsTable(luigi.Task):

	date_interval = luigi.DateIntervalParameter()

	def output(self):
		return luigi.LocalTarget('logs/luigi/log_{}.txt'.format(self))

	def run(self):
		#make_pids_table(db, c)
		make_pids_table(db, c, lim=10)
		with self.output().open('w') as out_file:
			 out_file.write("Done with task: {}".format(self))


#Step 2: build main db tables
#requires step1
@requires(CreatePidsTable)
class BuildDB(luigi.Task):
	date_interval = luigi.DateIntervalParameter()

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

	def output(self):
		return luigi.LocalTarget('logs/luigi/log_{}.txt'.format(self))

	def run(self):
		add_cycle_indiv(db, c, "individual_contributions")

		with self.output().open('w') as out_file:
			 out_file.write("Done with task: {}".format(self))


#Step 4: join indiv_contrib aka create_company table
#requires step3

#Step 5: qc filtering




if __name__ == "__main__":
	luigi.run()

