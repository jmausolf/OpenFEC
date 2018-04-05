
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
import numpy as np
import csv
import re
import warnings
from glob import glob
#from company_name_ids import *
from collections import Counter
#from master_config import cmaster, company_key
from data.companies import *
#from master_config import companies


cmaster = "data/fortune1000-list_alias_master.csv"
company_key = key_aliases(cmaster)


#test df
#df = pd.read_csv("df_chunk.csv", sep="|")
#df = pd.read_csv("misscid_201804021651.csv", sep="|")
#df = pd.read_csv("misstest.csv", sep="|")
#df = pd.read_csv("misscid_201804021725.csv", sep="|")


#df = pd.read_csv("add_cid_test_2.csv", sep=",")
#df = df.loc[(df["cid"] != "GE") & (df["cid"] != "ATT")]
#print(df.shape)
#df.to_csv("sm_add_cid_test_2.csv", index=False)

"""
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
"""
#print(df.shape)
#print(df.head())
#print(df.head(5))
#df = df.loc[df['cid'] == "Apple"]
#print(df.head(5))




def clean_employer_occupation_col(df, col):
	col_clean = "{}_clean".format(col)

	stop_words = ['and', 'the', 'company', 'companies', 'corporation', 
				  'international']
	stop_abb = 	['inc', 'co', 'comp', 'corp', 'pcs', 'pc', 'llp', 
				 'llc', 'lp', 'int']
	spaces = [' ', '  ', '   ', '    ', '     ', '      ']

	pat1 = r'\b(?:{})\b'.format('|'.join(stop_words))
	pat2 = r'\b(?:{})\b'.format('|'.join(stop_abb))
	pat3 = r'\b(?:{})\b'.format('|'.join(spaces))

	df[col_clean] = (df[col].fillna('')
						.str.lower()
						.str.replace(pat1, ' ')
						.str.replace('[^\w\s]',' ')
						.str.replace('[^\x00-\x7F]+', ' ')
						.str.replace(pat2, ' ')
						.str.replace(pat3, ' ')
						.str.strip()
					)

	return df



def filter_company_ids(df, company=False, dev=False):

	print(df.shape)


	df = clean_employer_occupation_col(df, "contributor_employer")
	df = clean_employer_occupation_col(df, "contributor_occupation")

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
			#print(data_occ)

			company_name_ids_emp.extend(data_emp)
			company_name_ids_occ.extend(data_occ)

		df_emp = pd.DataFrame(company_name_ids_emp)
		cols = ['cid', 'contributor_employer_clean', 'emp_count']
		df_emp.columns = cols
		df_emp.to_csv("cid_emp_to_clean.csv", index=False)

		df_occ = pd.DataFrame(company_name_ids_occ)

		if df_occ.shape[0] == 0:
			warnings.warn('WARNING: no results in df_occ...')
			pass
		else:
			cols = ['cid', 'contributor_occupation_clean', 'occ_count']
			df_occ.columns = cols
			df_occ.to_csv("cid_occ_to_clean.csv", index=False)
			pass

		return df_emp


	elif dev is False:

		#merge on employer
		df_cid = (pd.read_csv("cid_emp_cleaned.csv"))
					#.drop(["emp_count"], axis=1))
		df_emp = pd.merge(df, df_cid, 
							on=['cid', 'contributor_employer_clean'])

		#merge on occupation
		occ_file = "cid_occ_cleaned.csv"
		if os.path.exists(occ_file):
			df_cid = (pd.read_csv(occ_file))
						#.drop(["occ_count"], axis=1))
			df_occ = pd.merge(df, df_cid, 
								on=['cid', 'contributor_occupation_clean'])

			df = (df_emp.append(df_occ, ignore_index=True)
					.drop_duplicates(subset="sub_id"))
		else:
			print("[*] file {} not found...".format(occ_file))
			df = df_emp.drop_duplicates(subset="sub_id")

			#add missing columns
			df['occ_count'] = ''
			df['rank_occ'] = ''

		print(df.head(10))
		print(df.shape)

		#write outfile
		outfile = "df_chunk_sa_test_cleaned.csv"
		df.to_csv(outfile, index=False)

		return df

	else:
		pass



#test df
"""
df = pd.read_csv("sa_dev_example.csv", sep="|")
df.columns = cols
print(df.shape)
print(df.head())


x = df.loc[(df['cid'] == "Amazon.com")]
print(x)
"""
#for alias in companies, run clean_dev...


def clean_dev_contrib_csv(filetype, csv=False, sep=',', top_n=False, leaders=False):

	if csv is False:
		csv_file = 'cid_{}_to_clean.csv'.format(filetype)
	else:
		csv_file = csv

	if os.path.exists(csv_file):
		df = pd.read_csv(csv_file, sep=sep)
	else:
		print("[*] file {} not found...".format(csv_file))
		return


	if filetype == 'emp':
		cols = ['cid', 'contributor_employer_clean', 'emp_count']
		df.columns = cols
		key = 'contributor_employer_clean'
		count = 'emp_count'
		rank_col = 'rank_emp'
		outfile = 'cid_emp_cleaned.csv'

	if filetype == 'occ':
		cols = ['cid', 'contributor_occupation_clean', 'occ_count']
		df.columns = cols
		key = 'contributor_occupation_clean'
		count = 'occ_count'
		rank_col = 'rank_occ'
		outfile = 'cid_occ_cleaned.csv'


	#make new cols
	df['cid_valid'] = ''
	df['executive'] = ''
	df['director'] = ''
	df['manager'] = ''
	df['not_employed'] = ''

	#drop rows with missing cid
	df.cid.fillna('', inplace=True)
	df = df[df.cid != '']
	print(df.shape)

	punct = r'[]\\?!\"\'#$%&(){}+*/:;,._`|~\\[<=>@\\^-]'

	#companies = ['Goldman Sachs']
	companies = sorted(df['cid'].fillna('').unique().tolist())
	print(companies)
	
	for cid in companies:
		print("[*] cleaning {} for {}...".format(key, cid))
		match_crit2 = "{} ".format(cid.lower())
		match_crit4 = "{}".format(re.sub(punct, ' ', cid).lower())


		#company criteria
		#exact match only
		criteria1 = (
					(df['cid'] == cid) &
					(	(df[key] == cid.lower()) |
						(df[key] == re.sub(punct, ' ', cid).lower())	
					) 
					)

		#exact match space something else
		criteria2 = (
					(df['cid'] == cid) &
					(df[key].str.match(match_crit2))
					)

		#exact match for cid less punct with space
		criteria3 = (
					(df['cid'] == cid) &
					(
						#(df[key].str.match(match_crit3)) 
						(df[key].str.match(cid.lower()+'com')) |
						(df[key].str.match(cid.lower()+'inc'))
					)
					)

		#exact match for cid less punct no space
		criteria4 = (
					(df['cid'] == cid) &
					(df[key].str.match(match_crit4))
					)



		df.loc[criteria1, 'cid_valid'] = True
		df.loc[criteria2, 'cid_valid'] = True
		df.loc[criteria3, 'cid_valid'] = True

		if re.search(punct, cid) is not None:
			df.loc[criteria4, 'cid_valid'] = True


		#anti alias
		anti = anti_alias(cmaster, company_key[cid])
		#print(anti)
		if anti is False:
			pass
		else:
			anti_crit = (
						(df['cid'] == cid) &
						(df[key].str.contains(anti))
						) 
						

			df.loc[anti_crit, 'cid_valid'] = False

		#assign priority
		#TODO, keep x top rows, post clean per cid



		#Criteria for all companies
		#exec criteria
		exec_crit = (
					(df['cid_valid'] == True) &
					(
						(df['cid'] == cid) &
						(	
							(df[key].str.contains('president')) |
							(df[key].str.contains('ceo')) |
							(df[key].str.contains('vp')) |
							(	(df[key].str.contains('vice')) &
								(df[key].str.contains(r'^(?:(?!service).)*$'))
							) |
							(df[key].str.contains('chair')) |
							(df[key].str.contains('chief')) |
							(df[key].str.contains('exec')) |
							(df[key].str.contains('cfo')) |
							(df[key].str.contains('coo')) |
							(df[key].str.contains('board')) 
						)	
					)
					)

		df.loc[exec_crit, 'executive'] = True


		#director criteria
		dir_crit = (
					(df['cid_valid'] == True) &
					(
						(df['cid'] == cid) &
						(	
							(df[key].str.contains('director')) |
							(df[key].str.contains('head')) 
						)	
					) & (df['executive'] != True) 
					)

		df.loc[dir_crit, 'director'] = True


		#manager criteria
		man_crit = (
					(df['cid_valid'] == True) &
					(
						(df['cid'] == cid) &
						(	
							(df[key].str.contains('manager')) |
							(df[key].str.contains('managing')) 
						)

					) &
					(
						(df['executive'] != True) &
						(df['director'] != True)
					)
					)

		df.loc[man_crit, 'manager'] = True


		#self employed and other reject criteria
		not_emp_crit = 	(
						(df['cid_valid'] == True) &
						(
							(df[key].str.match('self')) |
							(df[key].str.contains('self-employed')) |
							(df[key].str.contains('self employed')) |
							(df[key].str.contains('independent contractor')) |
							(df[key].str.contains('freelance')) |
							(df[key].str.contains('franchisee')) |	
							(df[key].str.contains('unemployed')) |
							(df[key].str.contains('retired')) |
							(df[key].str.contains('former')) |
							(df[key].str.contains('previous')) |
							(df[key].str.contains('used to')) |	
							(df[key].str.contains('no longer')) |						
							(df[key].str.contains('recently fired')) |
							(df[key].str.contains('laid off')) |
							(df[key].str.contains('furloughed')) |
							(df[key].str.contains('spouse')) |
							(df[key].str.contains('wife')) |
							(df[key].str.contains('housewife')) |
							(df[key].str.contains('husband')) 
						)
						)

		df.loc[not_emp_crit, 'not_employed'] = True


	#Filtering of DF
	keep_crit = (	(df['cid_valid'] == True) &
					(df['not_employed'] != True)
				)


	#Keep Rows Matching Criteria
	df = df.loc[keep_crit]
	df = df.drop(['not_employed'], axis=1)

	print(df)


	#Ranking

	df[rank_col] = df.groupby("cid")[count].rank(method="first", ascending=False)
	#x = df.groupby("cid")[count].rank(method="first", ascending=False)
	#print(x.tolist())

	#Keep Only Top Rank Option
	if top_n is False:
		pass
	else:
		rank_crit = (df[rank_col] <= top_n)
		keep_leaders = 	(
							(df['executive'] == True) |
							(df['director'] == True) |
							(df['manager'] == True) 
						)

		if leaders is False:
			df = df.loc[rank_crit]

		elif leaders is True:
			df = df.loc[(rank_crit | keep_leaders)]			

	print(df)

	x = df.loc[(df['executive'] == True)]
	print("[*] shape of all data: {}".format(df.shape))
	print("[*] shape of executive data, where executive is True: {}".format(x.shape))


	#Write Outfile and Return
	df.to_csv(outfile, index=False)
	return df

	#y = df.loc[df['cid'] == cid]
	#print(y)
	#print(df.shape)
	#print(df.head())
	

	#exploring nan values
	#print(df.head())
	#x = df.loc[(df['cid'] == '')]
	#y = sorted(x[key].fillna('').unique().tolist())
	#print(y)


#clean_dev_contrib_csv("test")
#clean_dev_contrib_csv("emp", top_n=5, leaders=False)
#clean_dev_contrib_csv("emp", top_n=5, leaders=True)

#clean_dev_contrib_csv("emp")

#turn company_name_ids into csv
#df = pd.DataFrame.from_dict(company_name_ids, orient='index').transpose()
#df.to_csv("company_name_ids.csv")
#print(df.head)

#tests = "Amazon.com"
#punct = r'[]\\?!\"\'#$%&(){}+*/:;,._`|~\\[<=>@\\^-]'
#x = re.search(punct, tests)
#print(x.span())

"""
tests = "Amazon.com"
x = tests.replace('[^\x00-\x7F]+', '')
print(x)

def test_col(test):
	#col_clean = "{}_clean".format(col)

	stop_words = ['and', 'the', 'company', 'companies', 'corporation', 
				  'international']
	stop_abb = 	['inc', 'co', 'comp', 'corp', 'pcs', 'pc', 'llp', 
				 'llc', 'lp', 'int']
	spaces = [' ', '   ', '    ', '  ']

	pat1 = r'\b(?:{})\b'.format('|'.join(stop_words))
	pat2 = r'\b(?:{})\b'.format('|'.join(stop_abb))
	pat3 = r'\b(?:{})\b'.format('|'.join(spaces))

	output = (test.lower()
						.replace(pat1, '')
						.replace('[^\w\s]','')
						.replace('[^\x00-\x7F]+', ' ')
						.replace(pat2, '')
						.replace(pat3, ' ')
						.strip()
					)

	print(output)

"""
#test_col(tests)
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
#apple discount drug|
