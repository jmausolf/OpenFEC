import pandas as pd
import csv
from glob import glob
#from company_name_ids import *

def read_company_csv(company):
	company = str(company).replace(" ", "_")
	file_type = "{}".format(company)
	print(file_type)
	filename = glob('*{}*'.format(file_type))
	print(filename)
	df = pd.read_csv(filename[0])
	return df

#df = read_company_csv("Goldman Sachs")
#print(df.shape)


#print(df['contributor_employer'])

print("TESTING")
#print(df["employer_clean"])


company_name_ids = {
	"Goldman Sachs" : ['goldman sachs', 'goldman sachs investment', 'goldman sachs bank', 'goldman sachs asset management', 'goldman sachs capital'],
	"Apple" : ['apple', 'apple computer', 'apple store', 'apple retail store', 'appleinc']
}

#print(company_name_ids)
#print(company_name_ids["Goldman Sachs"])

#df = df[df['employer_clean'].isin(goldman_sachs_ids)]
#print(df.shape)

def remove_non_ascii_2(text):
	import re
	return re.sub(r'[^\x00-\x7F]+', "", text)


def filter_company_ids(company, dev=False):
	df = read_company_csv(company)
	print(df.shape)

	stop_words = ['and', 'the', 'company', 'companies', 'corporation', 'group', 'international']
	stop_abb = ['inc', 'co', 'comp', 'corp', 'pcs', 'pc', 'llp', 'llc', 'lp', 'int']
	spaces = [' ', '   ', '    ', '  ']

	pat1 = r'\b(?:{})\b'.format('|'.join(stop_words))
	pat2 = r'\b(?:{})\b'.format('|'.join(stop_abb))
	pat3 = r'\b(?:{})\b'.format('|'.join(spaces))

	df["employer_clean"] = df['contributor_employer'].str.lower().str.replace(pat1, '')
	df["employer_clean"] = df['employer_clean'].str.replace('[^\w\s]','').str.replace('[^\x00-\x7F]+', '')
	df["employer_clean"] = df['employer_clean'].str.replace(pat2, '').str.replace(pat3, ' ').str.strip()

	#unique values
	if dev is True:
		#print("TRUE")
		all_cids = df.employer_clean.unique().tolist()
		print(len(all_cids), str(all_cids))
		#print(len(all_cids))
		#all_cids.sort()
		#print(all_cids.sort())
	elif dev is False:
		#print("FALSE")
		cid = company_name_ids[company]
		#TODO split on dict items
		df = df[df['employer_clean'].isin(cid)]
		print(df.shape)
		print(df.employer_clean.unique().tolist()) #check its working
	else:
		print("OTHER")




#filter_company_ids("Goldman Sachs", True)
#filter_company_ids("Goldman Sachs")

#filter_company_ids("Apple", True)
filter_company_ids("Apple")



