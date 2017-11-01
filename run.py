from getFEC import *
from getPARTY import *
from random import random
import traceback


class openFEC:
	def __init__(self, companies, years):
		self.companies = companies
		self.years = years


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
				collapse_signature = collapse_csvs(company, "schedule a", None, name)
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

		base_sleep_time = 1

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
							time.sleep(pow(2, attempt) * base_sleep_time * random())
							tasks(company)
							return
						except:
							if attempt>=10:
								print("[*] MAXIMUM retries exceeded...FINAL ERROR COLLECTING {}".format(company))
				finally:
					pass


		for company in companies:
			print("{}\n[*] {} {}".format("--"*20, company))
			try:
				retry(company)
			except:
				d = 3600
				print("[*] Possible rate limiting, trying again in {} minutes".format(d/60))
				time.sleep(d)
				retry(company)
			finally:
				pass


############################################################################
## STEP 1: Define Companies
############################################################################

companies = ["Goldman Sachs", "Walmart", "Exxon Mobile", "Marathon Oil", "Apple", "Berkshire Hathaway", "Amazon", "Boeing", "Alphabet", "Home Depot", "Ford Motor", "Kroger", "Chevron", "Morgan Chase", "Wells Fargo"]
#companies = ["Walmart", "Exxon Mobile", "Marathon Oil", "Apple", "Berkshire Hathaway", "Amazon", "Boeing", "Alphabet", "Home Depot", "Ford Motor", "Kroger", "Chevron", "Morgan Chase", "Wells Fargo"]
years = ["2016", "2012", "2008", "2004", "2000", "1996", "1992", "1988", "1984"]

#companies = ["Exxon Mobile", "Amazon", "Boeing"]
#companies = ["Walmart"]
#companies = ["General Electric"]
#companies = ["Apple"]
companies = ["Exxon Mobile"]

#companies = ["Goldman Sachs"]
#years = ["2008"]
#companies = ["Walmart"]
#years = ["2012"]
#years = ["2016"]


#dedupe multiple runs (need to remove json/dict column)
#openFEC.dedupe(companies, "committee")

#openFEC.getFEC(companies, years)
#openFEC.combine(companies)

openFEC.getPARTY(companies)

############################################################################
## STEP 2: Get All Schedule A for Companies
############################################################################




############################################################################
## STEP 3: Get All Party IDs, Election for Committees on Schedule A
############################################################################


############################################################################
## STEP 4: Merge Data
############################################################################
