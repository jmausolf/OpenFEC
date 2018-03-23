
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
from company_name_ids import *
from collections import Counter

#test df
df = pd.read_csv("df_chunk.csv", sep="|")
cols = ['contributor_name', 'contributor_employer', 'contributor_occupation', 'contributor_city', 'contributor_state', 'contributor_zip_code', 'contributor_cycle', 'cmte_id', 'cmte_nm', 'cmte_pty_affiliation', 'cmte_dsgn', 'cmte_type', 'cmte_filing_freq', 'cmte_org_tp', 'cmte_connected_org_nm', 'party_id', 'partisan_score', 'cmte_cycle', 'cand_id', 'cand_name', 'cand_pty_affiliation', 'cand_election_yr', 'cand_fec_election_yr', 'cand_office', 'cand_pcc', 'cand_cmte_linkage_id', 'contributor_transaction_dt', 'contributor_transaction_amt', 'contributor_transaction_pgi', 'contributor_transaction_tp', 'contributor_amndt_ind', 'contributor_rpt_tp', 'contributor_image_num', 'contributor_entity_tp', 'contributor_other_id', 'contributor_tran_id', 'contributor_file_num', 'contributor_memo_cd', 'contributor_memo_text', 'sub_id', 'cid']
df.columns = cols
print(df.shape)
#print(df.head(5))
#df = df.loc[df['cid'] == "Apple"]
#print(df.head(5))


def read_company_csv(company):
	company = str(company).replace(" ", "_")
	file_type = "{}".format(company)
	print(file_type)
	filename = glob('downloads/*{}*ANALYSIS.csv'.format(file_type))
	print(filename)
	df = pd.read_csv(filename[0])
	return df, filename[0]

def clean_employer_occupation_col(df, col):
	col_clean = "{}_clean".format(col)

	stop_words = ['and', 'the', 'company', 'companies', 'corporation', 'group', 'international']
	stop_abb = ['inc', 'co', 'comp', 'corp', 'pcs', 'pc', 'llp', 'llc', 'lp', 'int']
	spaces = [' ', '   ', '    ', '  ']

	pat1 = r'\b(?:{})\b'.format('|'.join(stop_words))
	pat2 = r'\b(?:{})\b'.format('|'.join(stop_abb))
	pat3 = r'\b(?:{})\b'.format('|'.join(spaces))

	stop_words = ['and', 'the', 'company', 'companies', 'corporation', 'group', 'international']
	stop_abb = ['inc', 'co', 'comp', 'corp', 'pcs', 'pc', 'llp', 'llc', 'lp', 'int']
	spaces = [' ', '   ', '    ', '  ']

	df[col_clean] = df[col].fillna('')
	df[col_clean] = df[col_clean].str.lower().str.replace(pat1, '')
	df[col_clean] = df[col_clean].str.replace('[^\w\s]','').str.replace('[^\x00-\x7F]+', '')
	df[col_clean] = df[col_clean].str.replace(pat2, '').str.replace(pat3, ' ').str.strip()

	return df

def filter_company_ids(df, company=False, dev=False):
	#read_df = read_company_csv(company)
	#df = pd.read_csv("df_chunk.csv", sep="|")
	#df = read_df[0]
	#outfile = read_df[1].split(".csv")[0]+"_cleaned.csv"
	outfile = "df_chunk_sa_test_cleaned.csv"
	#print(outfile)

	#df = df.loc[df['cid'] == company].copy()
	print(df.shape)


	df = clean_employer_occupation_col(df, "contributor_employer")
	df = clean_employer_occupation_col(df, "contributor_occupation")
	#print(df.head(5))

	#unique values
	if dev is True:
		#all_cids_unique = df.contributor_employer_clean.unique().tolist()
		#all_cids = Counter(df.contributor_employer_clean.tolist())
		#c = Counter( input )
		#print(len(all_cids_unique), all_cids.most_common())
		#print(all_cids.most_common())

		unique_cids = df.cid.unique().tolist()
		for cid in unique_cids:
			dfc = df.loc[df['cid'] == cid].copy()
			emp = Counter(dfc.contributor_employer_clean.tolist())
			#c = Counter( input )
			#print(len(all_cids_unique), all_cids.most_common())
			print(emp.most_common())
			print('\n'*5)

	elif dev is False:
		#cid = company_name_ids[company]
		#TODO split on dict items
		
		#df = df['contributor_employer_clean'].isin(cid)
		
		#merge on employer
		df_cid = (pd.read_csv("company_name_ids_clean.csv")
					.drop(["contributor_occupation_clean"], axis=1))
		df_emp = pd.merge(df, df_cid, on=['cid', 'contributor_employer_clean'])


		#merge on occupation
		df_cid = (pd.read_csv("company_name_ids_clean.csv")
					.drop(["contributor_employer_clean"], axis=1))
		df_occ = pd.merge(df, df_cid, on=['cid', 'contributor_occupation_clean'])

		#inner join vs merge? per pandas, default .merge is type "inner"


		df = df_emp.append(df_occ, ignore_index=True)
		print(df.head(50))

		#df = df[df['contributor_occupation_clean'].isin(cid)]
		#df = df[df['contributor_employer_clean'].isin(cid)]
		#df[df['contributor_employer_clean'].isin(cid) | df['contributor_occupation_clean'].isin(cid)]
		print(df.shape)
		#print(df.contributor_employer_clean.unique().tolist()) #check its working
	else:
		pass

	#write outfile
	df.to_csv(outfile, index=False)
	


#turn company_name_ids into csv
#df = pd.DataFrame.from_dict(company_name_ids, orient='index').transpose()
#df.to_csv("company_name_ids.csv")
#print(df.head)


#df = pd.read_csv("df_chunk.csv", sep="|")
#filter_company_ids(df, "Apple")
filter_company_ids(df, dev=True)
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

