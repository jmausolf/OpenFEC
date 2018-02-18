from setlogger import *
import pandas as pd
import csv
from glob import glob
from company_name_ids import *
from collections import Counter

def read_company_csv(company):
	company = str(company).replace(" ", "_")
	file_type = "{}".format(company)
	print(file_type)
	filename = glob('downloads/*{}*'.format(file_type))
	print(filename)
	df = pd.read_csv(filename[0])
	return df, filename[0]


def filter_company_ids(company, dev=False):
	read_df = read_company_csv(company)
	df = read_df[0]
	outfile = read_df[1].split(".csv")[0]+"_cleaned.csv"
	print(outfile)

	print(df.shape)

	#add company cid col
	df["cid"] = company

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
		all_cids_unique = df.employer_clean.unique().tolist()
		all_cids = Counter(df.employer_clean.tolist())
		#c = Counter( input )
		print(len(all_cids_unique), all_cids.most_common())
	elif dev is False:
		cid = company_name_ids[company]
		#TODO split on dict items
		df = df[df['employer_clean'].isin(cid)]
		print(df.shape)
		print(df.employer_clean.unique().tolist()) #check its working
	else:
		pass

	#write outfile
	df.to_csv(outfile, index=False)


#filter_company_ids("Goldman Sachs", True)
#filter_company_ids("Goldman Sachs")

#filter_company_ids("Apple", True)
#filter_company_ids("Apple")

#filter_company_ids("Exxon Mobile", True)
#filter_company_ids("Exxon Mobile")

#filter_company_ids("Exxon", True)
#filter_company_ids("Exxon")

