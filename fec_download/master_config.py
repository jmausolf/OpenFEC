#################################################
## Years
#################################################

years = ['1980', '1982', '1984', '1986', '1988', '1990', '1992', '1994', '1996', '1998', '2000', '2002', '2004', '2006', '2008', '2010', '2012', '2014', '2016', '2018']
#years = ['2004', '2008']
#years = ['1994']
#years = ['1980']
#years = ['1980', '1982']
#years = ['200', '2006', '2008']

#years = ['2000' , '2002', '2004', '2008']
cycles = [int(year) for year in years]


#################################################
## Companies
#################################################

#from data.companies import companies, company_key
from data.companies import *

N = 105
#N = 15
cmaster = "data/fortune1000-list_alias_master.csv"
companies = concat_alias(cmaster, limit=N)
company_key = key_aliases(cmaster, limit=N)
#companies = ["Walmart", "Exxon Mobile", "Marathon Oil", "Apple", "Berkshire Hathaway", "Amazon", "Boeing", "Alphabet", "Home Depot", "Ford Motor", "Kroger", "Chevron", "Morgan Chase", "Wells Fargo"]


#companies = ["Ford"]
#companies = ["Amazon", "Goldman Sachs"]

#companies = companies
#print(companies)
#print(company_key["Apple"])

#c = company_key["Apple"]
#anti = anti_alias(cmaster, c)
#print(anti)

#################################################
## Table Key
#################################################

"""
table key is input by the researcher, requiring the following:

:: keys:	the keys of the dict, which equal the zip file
			abbreviations provided by the FEC less the year and file ext

			e.g. the key for 'Committee Master File' in any year,
			such as 2012, which has the zip file 'cm12.zip,'
			would be simply 'cm'

:: values:	values are structured as a list ['val1', 'val2']
			
			val1 equals the SQL table_name
			val2 equals the file to be extracted from the zip file

			for the key, 'cm', these values are simple:

			value == ['committee_master', 'cm.txt']

			other keys, such as 'indiv' do not follow this pattern

			value == ['individual_contributions', 'itcont.txt']

"""


#key : [table, extract file]
table_key = {
	'cm'     : ['committee_master', 'cm.txt'],
	'cn'     : ['candidate_master', 'cn.txt'],
	'ccl'    : ['cand_cmte_link', 'ccl.txt'],
	'oth'    : ['itemized_records', 'itoth.txt'],
	'pas2'   : ['committee_contributions', 'itpas2.txt'],
	'indiv'  : ['individual_contributions', 'itcont.txt'],
	'oppexp' : ['operating_expenditures', 'oppexp.txt']
}






