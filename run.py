from config import *
from setlogger import *
from getFEC import *
from getPARTY import *
from cleanFEC import *
from random import random
import traceback
import subprocess


class openFEC:
	def __init__(companies, years):
		self.companies = companies
		self.years = years

	def start(companies, years):
		print("{}\n[*] Initializing openFEC...".format("--"*20))
		print("[*] Total companies: {:<10}".format(len(companies)))
		print("[*] Total years: {:^10}".format(len(years)))
		subprocess.call("bash collect_files.sh", shell=True)	


	#Run = Download, Collapse, Remove
	def getFEC(companies, years):

		base_sleep_time = 1

		def tasks(company, year, test_break=False):
			if test_break is True:
				print("[*] BROKEN")
				len(p) #intentional error to test break
			else:
				get_schedule_a_employer_year(company, year)
				collapse_signature = collapse_csvs(company, "schedule a", year)
				remove_files(collapse_signature)
				return


		def retry(company, year):
				try:
					tasks(company, year) #not broken
					return
				except:
					for attempt in range(1, 10+1):
						try:
							print("[*] ERROR COLLECTING {} in {}...attempt {}".format(company, year, attempt))
							time.sleep(pow(2, attempt) * base_sleep_time * random())
							tasks(company, year)
							return
						except:
							if attempt>=10:
								print("[*] MAXIMUM retries exceeded...FINAL ERROR COLLECTING {} in {}".format(company, year))
				finally:
					pass


		for company in companies:
			for year in years:
				print("{}\n[*] {} {}".format("--"*20, company, year))
				try:
					retry(company, year)
				except:
					d = 3600
					print("[*] Possible rate limiting, trying again in {} minutes".format(d/60))
					time.sleep(d)
					retry(company, year)
				finally:
					pass



	#Combine = Collapse/Remove Across Years
	def combine(companies, name=""):
		for company in companies:
			try:
				print("{}\n[*] Combining yearly data for {}".format("--"*20, company))
				collapse_signature = collapse_csvs(company, "schedule a", None, name, False)
				remove_files(collapse_signature)
			except Exception as exc:
				print(traceback.format_exc())
				print(exc)
				pass

	#Dedupe = Combine Multiple Attempts of Run
	def dedupe(companies, column=None):
		for company in companies:
			try:
				print("{}\n[*] Combining/deduping data for {}".format("--"*20, company))
				collapse_signature = dedupe_merged_csvs(company, column)
				remove_files(collapse_signature)
			except Exception as exc:
				print(exc)
				pass

	#Get Party ID
	#Run = Download, Collapse, Remove
	def getPARTY(companies):

		base_sleep_time = 15

		def tasks(company, test_break=False):
			if test_break is True:
				print("[*] BROKEN")
				len(p) #intentional error to test break
			else:
				#tasks
				filenames = getPARTY(company)
				merge_contrib_pid(filenames)
				return


		def retry(company):
				try:
					tasks(company) #not broken
					return
				except:
					for attempt in range(1, 10+1):
						try:
							print("[*] ERROR COLLECTING PARTY IDS FOR {}...attempt {}".format(company, attempt))
							time.sleep(pow(3, attempt) * base_sleep_time)
							tasks(company)
							return
						except:
							if attempt>=10:
								print("[*] MAXIMUM retries exceeded...FINAL ERROR COLLECTING {}".format(company))
				finally:
					pass


		for company in companies:
			print("{}\n[*] {}".format("--"*20, company))

			try:
				company = str(company).replace(" ", "_")
				filenames = glob('downloads/*{}*'.format(company))
				if len(filenames)==1:
					retry(company)
				else:
					print("Only one file expected, check file exists and perform merge first...")

			except:
				d = 3600
				print("[*] Possible rate limiting, trying again in {} minutes".format(d/60))
				time.sleep(d)
				retry(company)
			finally:
				pass

	#Clean Company Results
	def clean(companies, dev=False):
		for company in companies:
			try:
				if dev is True:
					filter_company_ids(company, True)
				else:
					filter_company_ids(company)
			except Exception as exc:
				print(exc)
				pass

	#Merge All Cleaned Files
	def merge_master(filestem, rm=False):
		"""openFEC.merge_master("schedule_a__merged_ANALYSIS_cleaned")"""
		print("[*] combining all files of type *{}* ...".format(filestem))
		collapse_signature = collapse_csvs(None, filestem, None, "_MASTER", False)
		if rm is True:
			remove_files(collapse_signature)
		else:
			pass


############################################################################
## STEP 1: Define Companies
############################################################################


#openFEC.dedupe(companies)
#openFEC.dedupe(companies, "committee")


#test run
#openFEC.start(companies, years)
#openFEC.getFEC(companies, years)
#openFEC.combine(companies)
#openFEC.getPARTY(companies)

#TODO
#MOVE ANALYSIS FILES TO NEW FOLDER, THEN CLEAN
#openFEC.clean(companies)
openFEC.merge_master("ANALYSIS_cleaned")

#Merging Old Runs and New Partial Runs
#companies = ["Boeing", "Microsoft", "All"]
#openFEC.dedupe(companies, "committee")
#openFEC.merge_master("merged_deduped")



############################################################################
## STEP 2: Get All Schedule A for Companies
############################################################################




############################################################################
## STEP 3: Get All Party IDs, Election for Committees on Schedule A
############################################################################


############################################################################
## STEP 4: Merge Data
############################################################################
