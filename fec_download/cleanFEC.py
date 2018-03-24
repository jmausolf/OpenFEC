
##TODO develop for SQL queries
#in the api query, these functions were run on each company csv
#in the sql version, need to filter by the desired company.

#basically first run through the filtered company data and filter by desired company
#this would be according to string matching on the company
#likely CID
# user string contains
# df[df['model'].str.match('Mac')] match
# df[df['model'].str.contains('ac')] contains

#for company in config:
# if df[df['employer'].str.contains(company)]:
# 	df['cid'] = company

#then you can develop a function to clean it


#or conversely, write code that does all this for each company

from setlogger import *
import pandas as pd
import csv
from glob import glob
#from company_name_ids import *
from collections import Counter

"""
#test df
df = pd.read_csv("df_chunk.csv", sep="|")
cols = ['contributor_name', 'contributor_employer', 'contributor_occupation', 
		'contributor_city', 'contributor_state', 'contributor_zip_code', 
		'contributor_cycle', 'cmte_id', 'cmte_nm', 'cmte_pty_affiliation', 
		'cmte_dsgn', 'cmte_type', 'cmte_filing_freq', 'cmte_org_tp', 
		'cmte_connected_org_nm', 'party_id', 'partisan_score', 'cmte_cycle', 
		'cand_id', 'cand_name', 'cand_pty_affiliation', 'cand_election_yr', 
		'cand_fec_election_yr', 'cand_office', 'cand_pcc', 
		'cand_cmte_linkage_id', 'contributor_transaction_dt', 
		'contributor_transaction_amt', 'contributor_transaction_pgi', 
		'contributor_transaction_tp', 'contributor_amndt_ind', 
		'contributor_rpt_tp', 'contributor_image_num', 
		'contributor_entity_tp', 'contributor_other_id', 
		'contributor_tran_id', 'contributor_file_num', 'contributor_memo_cd', 
		'contributor_memo_text', 'sub_id', 'cid']

df.columns = cols
print(df.shape)
#print(df.head(5))
#df = df.loc[df['cid'] == "Apple"]
#print(df.head(5))
"""



def clean_employer_occupation_col(df, col):
	col_clean = "{}_clean".format(col)

	stop_words = ['and', 'the', 'company', 'companies', 'corporation', 
				  'group', 'international']
	stop_abb = 	['inc', 'co', 'comp', 'corp', 'pcs', 'pc', 'llp', 
				 'llc', 'lp', 'int']
	spaces = [' ', '   ', '    ', '  ']

	pat1 = r'\b(?:{})\b'.format('|'.join(stop_words))
	pat2 = r'\b(?:{})\b'.format('|'.join(stop_abb))
	pat3 = r'\b(?:{})\b'.format('|'.join(spaces))

	df[col_clean] = (df[col].fillna('')
						.str.lower()
						.str.replace(pat1, '')
						.str.replace('[^\w\s]','')
						.str.replace('[^\x00-\x7F]+', '')
						.str.replace(pat2, '')
						.str.replace(pat3, ' ')
						.str.strip()
					)

	return df


def filter_company_ids(df, company=False, dev=False):

	print(df.shape)


	df = clean_employer_occupation_col(df, "contributor_employer")
	df = clean_employer_occupation_col(df, "contributor_occupation")
	#print(df.head(5))

	#unique values
	if dev is True:

		unique_cids = df.cid.unique().tolist()

		emps = "contributor_employer_clean"
		occs = "contributor_occupation_clean"
		company_name_ids_emp = []
		company_name_ids_occ = []
		for cid in unique_cids:
			dfe = df.loc[df['cid'] == cid].copy()
			emp = Counter(dfe.contributor_employer_clean.tolist())

			dfo = dfe.loc[dfe[emps] == ''].copy()
			occ = Counter(dfo.contributor_occupation_clean.tolist())

			data_emp = [[cid]+list(x) for x in emp.most_common()]
			data_occ = [[cid]+list(x) for x in occ.most_common()]

			company_name_ids_emp.extend(data_emp)
			company_name_ids_occ.extend(data_occ)

		df_emp = pd.DataFrame(company_name_ids_emp)
		cols = ['cid', 'contributor_employer_clean', 'emp_count']
		df_emp.columns = cols
		df_emp.to_csv("cid_emp_to_clean.csv", index=False)

		df_occ = pd.DataFrame(company_name_ids_occ)
		cols = ['cid', 'contributor_occupation_clean', 'occ_count']
		df_occ.columns = cols
		df_occ.to_csv("cid_occ_to_clean.csv", index=False)

		pass


	elif dev is False:

		#merge on employer
		df_cid = (pd.read_csv("cid_emp_cleaned.csv")
					.drop(["emp_count"], axis=1))
		df_emp = pd.merge(df, df_cid, 
							on=['cid', 'contributor_employer_clean'])


		#merge on occupation
		df_cid = (pd.read_csv("cid_occ_cleaned.csv")
					.drop(["occ_count"], axis=1))
		df_occ = pd.merge(df, df_cid, 
							on=['cid', 'contributor_occupation_clean'])

		df = (df_emp.append(df_occ, ignore_index=True)
				.drop_duplicates(subset="sub_id"))

		print(df.head(10))
		print(df.shape)

		#write outfile
		outfile = "df_chunk_sa_test_cleaned.csv"
		df.to_csv(outfile, index=False)

		return df

	else:
		pass


	


#turn company_name_ids into csv
#df = pd.DataFrame.from_dict(company_name_ids, orient='index').transpose()
#df.to_csv("company_name_ids.csv")
#print(df.head)


#df = pd.read_csv("df_chunk.csv", sep="|")
#filter_company_ids(df, "Apple")


#filter_company_ids(df, dev=True)
#filter_company_ids(df)


#filter_company_ids(df, "Apple", dev=True)
#filter_company_ids(df, "Walmart", dev=True)
#filter_company_ids("Goldman Sachs", True)
#filter_company_ids("Goldman Sachs")

#filter_company_ids("Apple", True)
#filter_company_ids("Apple")

#filter_company_ids("Exxon Mobile", True)
#filter_company_ids("Exxon Mobile")

#filter_company_ids("Exxon", True)
#filter_company_ids("Exxon")

