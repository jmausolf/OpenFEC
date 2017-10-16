from getFEC import *
#from getFEC_v2 import *


class openFEC:
	def __init__(self, companies, years):
		#self.company = company
		#self.year = year
		#self.year = year
		self.companies = companies
		self.years = years


	def run(companies, years):

		def collect(company, year):
			try:
				print(company, year)
				#print(company, year)
				#get_schedule_a_employer_year(company, year)
				#collapse_signature = collapse_csvs(company, "schedule a", year)
				#remove_files(collapse_signature)
			except:
				time.sleep(0.1)
			else:
				print("print else")
			finally:
				pass



		for company in companies:
			for year in years:
				try:
					#print("trying")
					#collect(adf)
					collect(company, year)
				except:
					#retry
					print("excepting")
					print("[*] ERROR COLLECTING {} in {}".format(company, year))
					time.sleep(0.1)
					collect(company, year)
				finally:
					print("finally")
					#print("[*] ERROR COLLECTING {} in {}".format(company, year))

	#def run(self):
		#loop(companies, years)
		#try:
		#	print("trying")
		#	loop(companies, years)
		#except:
		#	print("excepting")
		#finally:
		#	print("finally")



############################################################################
## STEP 1: Define Companies
############################################################################

companies = ["Walmart", "Exxon Mobile", "Goldman Sachs", "Apple", "Berkshire Hathaway", "Amazon", "Boeing"]
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

#a = openFEC(companies, years)
#print(a)

#for attr, value in a.__dict__.items():
#        print (attr, value)
#openFEC.run('Apple', '2012')
#a = openFEC(companies, years)
#a.run()
openFEC.run(companies, years)

"""
for company in companies:
    for year in years:
        try:
            print(company, year)
            get_schedule_a_employer_year(company, year)
            collapse_signature = collapse_csvs(company, "schedule a", year)
            remove_files(collapse_signature)
        except:
        	time.sleep(60)

            print("[*] ERROR COLLECTING {} in {}".format(company, year))

"""



############################################################################
## STEP 2: Get All Schedule A for Companies
############################################################################




############################################################################
## STEP 3: Get All Party IDs, Election for Committees on Schedule A
############################################################################


############################################################################
## STEP 4: Merge Data
############################################################################
