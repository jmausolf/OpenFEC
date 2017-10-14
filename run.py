from getFEC import *
#from getFEC_v2 import *

############################################################################
## STEP 1: Define Companies
############################################################################

#companies = ["Walmart", "Exxon Mobile", "Goldman Sachs", "Apple", "Berkshire Hathaway", "Amazon", "Boeing"]
#years = ["2016", "2012", "2008", "2004", "2000", "1996", "1992", "1988", "1984"]

#companies = ["Exxon Mobile", "Amazon", "Boeing"]
#companies = ["Walmart"]
companies = ["General Electric"]


#companies = ["Goldman Sachs"]
#years = ["2008"]
#companies = ["Walmart"]
years = ["2012"]
#years = ["2016"]

for company in companies:
    for year in years:
        try:
            print(company, year)
            get_schedule_a_employer_year(company, year)
            collapse_signature = collapse_csvs(company, "schedule a", year)
            remove_files(collapse_signature)
        except:
            print("[*] ERROR COLLECTING {} in {}".format(company, year))





############################################################################
## STEP 2: Get All Schedule A for Companies
############################################################################




############################################################################
## STEP 3: Get All Party IDs, Election for Committees on Schedule A
############################################################################


############################################################################
## STEP 4: Merge Data
############################################################################
