from getFEC import *
from random import random


class openFEC:
	def __init__(self, companies, years):
		self.companies = companies
		self.years = years


	def run(companies, years):

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



############################################################################
## STEP 1: Define Companies
############################################################################

#companies = ["Goldman Sachs", "Walmart", "Exxon Mobile", "Marathon Oil", "Apple", "Berkshire Hathaway", "Amazon", "Boeing", "Alphabet", "Home Depot", "Ford Motor", "Kroger", "Chevron", "Morgan Chase", "Wells Fargo"]
companies = ["Walmart", "Exxon Mobile", "Marathon Oil", "Apple", "Berkshire Hathaway", "Amazon", "Boeing", "Alphabet", "Home Depot", "Ford Motor", "Kroger", "Chevron", "Morgan Chase", "Wells Fargo"]
years = ["2016", "2012", "2008", "2004", "2000", "1996", "1992", "1988", "1984"]

#companies = ["Exxon Mobile", "Amazon", "Boeing"]
#companies = ["Walmart"]
#companies = ["General Electric"]
#companies = ["Apple"]

#companies = ["Goldman Sachs"]
#years = ["2008"]
#companies = ["Walmart"]
#years = ["2012"]
#years = ["2016"]

openFEC.run(companies, years)




############################################################################
## STEP 2: Get All Schedule A for Companies
############################################################################




############################################################################
## STEP 3: Get All Party IDs, Election for Committees on Schedule A
############################################################################


############################################################################
## STEP 4: Merge Data
############################################################################
