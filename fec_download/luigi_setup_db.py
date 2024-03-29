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



#PYTHONPATH='.' luigi --module luigi_setup_db GenIndividualPartisansTable --local-scheduler --date-interval 2018-05-24



import luigi
from luigi.util import inherits, requires
import subprocess
import hashlib

#import python code
from _util.util import *
from _get_parties.create_pids_table import *
from _build_db.create_indiv_cycle import *
from _get_companies.create_company_table import *
from _get_companies.clean_company_table import *
from _get_individuals.get_indiv import *





#Step 1
class CreatePidsTable(luigi.Task):


	date_interval = luigi.DateIntervalParameter()
	cfg = check_config("master_config.py")
	#print(cfg)

	def output(self):
		return luigi.LocalTarget('logs/luigi/log_{}.txt'.format(self))

	def run(self):
		make_pids_table(db, c)
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
		clean_company_table(db, c)

		with self.output().open('w') as out_file:
			 out_file.write("Done with task: {}".format(self))



#Step 8: Get Individual Partisans
@requires(CleanCompanyTable)
class GenIndividualPartisansTable(luigi.Task):
	date_interval = luigi.DateIntervalParameter()
	cfg = check_config("master_config.py")

	def output(self):
		return luigi.LocalTarget('logs/luigi/log_{}.txt'.format(self))

	def run(self):
		gen_indiv_table(db, c)

		with self.output().open('w') as out_file:
			 out_file.write("Done with task: {}".format(self))




if __name__ == "__main__":
	luigi.run()

