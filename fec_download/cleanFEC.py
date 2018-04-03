
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
from glob import glob
#from company_name_ids import *
from collections import Counter
#from master_config import companies



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


def add_cid_test(dfc, companies, method):
	df = dfc.copy()
	df = df.drop(['cid'], axis=1)
	df['cid'] = ''
	#df['emp_na'] = ''
	#df['occ_na'] = ''

	outfile = "add_cid_test_{}.csv".format(str(method))

	if method==1:
		print("method1")
		for cid in sorted(companies, key=len):
			df['cid'] = np.where(df['contributor_employer'].isnull(), 
							#if employer missing, search occupation
							np.where(df['contributor_occupation'].str.contains(
									str(cid), case=False, na=False), cid, df['cid']),
							#else search employer
							np.where(df['contributor_employer'].str.contains(
									str(cid), case=False, na=False), cid, df['cid']))

	
	if method==2:
		print("method2")
		for cid in sorted(companies, key=len):

			emp = 'contributor_employer'
			occ = 'contributor_occupation'

			#fill na's in employer/occupation
			df[emp].fillna('', inplace=True)
			df[occ].fillna('', inplace=True)

			#(emp missing OR emp does not contain cid) & occ contains cid
			crit_emp_na = 	(
								(
									(df[emp] == '') |
									~(df[emp].str.contains(cid, case=False))
								) &
								(df[occ].str.contains(cid, case=False))
							)


			#(occ missing OR occ does not contain cid) & emp contains cid
			crit_occ_na = 	(
								(
									(df[occ] == '') |
									~(df[occ].str.contains(cid, case=False))
								) &
								(df[emp].str.contains(cid, case=False))
							)

			

			#both contain
			crit_both = 	(
								(df[occ].str.contains(cid, case=False)) &
								(df[emp].str.contains(cid, case=False))
							)			


			#both missing or not contain
			#do nothing implicitly


			#df.loc[crit_emp_na, 'emp_na'] = True
			#df.loc[crit_occ_na, 'occ_na'] = True
			df.loc[crit_emp_na, 'cid'] = cid #fill from occ only	
			df.loc[crit_occ_na, 'cid'] = cid #fill from emp only
			df.loc[crit_both, 'cid'] = cid	#both occ and emp match

	print("Still missing cid for the following df:")
	x = df.loc[(df['cid'] == '')]
	#y = sorted(x[key].fillna('').unique().tolist())
	print(x.shape)

	#y = df.loc[(df['cid'] != '')]
	#print(y)

	unique_cids = df.cid.unique().tolist()
	print(unique_cids)
	#df.to_csv(outfile, index=False)
	return df


#add_cid_test(df, companies, method=1)
#add_cid_test(df, companies, method=2)

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
			pass
		else:
			cols = ['cid', 'contributor_occupation_clean', 'occ_count']
			df_occ.columns = cols
			df_occ.to_csv("cid_occ_to_clean.csv", index=False)
			pass

		return df_emp


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



#test df
"""
df = pd.read_csv("sa_dev_example.csv", sep="|")
cols = ['cid', 'contributor_employer_clean', 'emp_count']
df.columns = cols
print(df.shape)
print(df.head())


x = df.loc[(df['cid'] == "Amazon.com")]
print(x)
"""
#for alias in companies, run clean_dev...


def clean_dev_contrib_csv(filetype, csv=False, sep=','):

	if csv is False:
		df = pd.read_csv('cid_{}_to_clean.csv'.format(filetype), sep=sep)
	else:
		df = pd.read_csv(csv, sep=sep)

	print(df.head())

	if filetype == 'emp':
		cols = ['cid', 'contributor_employer_clean', 'emp_count']
		df.columns = cols
		key = 'contributor_employer_clean'
		outfile = 'cid_emp_cleaned.csv'

	if filetype == 'occ':
		cols = ['cid', 'contributor_occupation_clean', 'occ_count']
		df.columns = cols
		key = 'contributor_occupation_clean'
		outfile = 'cid_occ_cleaned.csv'


	#make new cols
	df['cid_val'] = ''
	df['exec'] = ''
	df['dir'] = ''
	df['man'] = ''

	#drop rows with missing cid
	df.cid.fillna('', inplace=True)
	df = df[df.cid != '']
	print(df.shape)

	punct = r'[]\\?!\"\'#$%&(){}+*/:;,._`|~\\[<=>@\\^-]'

	#companies = ['Amazon.com']
	companies = sorted(df['cid'].fillna('').unique().tolist())
	print(companies)
	
	for cid in companies:
		match_crit2 = "{} ".format(cid.lower())
		#match_crit3 = "{}".format(re.sub(punct, '', cid).lower())
		match_crit4 = "{}".format(re.sub(punct, '', cid).lower())
		#print(match_crit3)
		#match_crit = "general electric"

		#company criteria
		#exact match only
		criteria1 = (
					(df['cid'] == cid) &
					(	(df[key] == cid.lower()) |
						(df[key] == re.sub(punct, '', cid).lower())	
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


		#TODO New column & criteria to reject
		#self employed, retired, spouse, etc

		df.loc[criteria1, 'cid_val'] = True
		df.loc[criteria2, 'cid_val'] = True
		df.loc[criteria3, 'cid_val'] = True

		if re.search(punct, cid) is not None:
			#print("punct found")
			df.loc[criteria4, 'cid_val'] = True
	

		#exec criteria
		exec_crit = (
					(df['cid_val'] == True) &
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

		df.loc[exec_crit, 'exec'] = True


		#director criteria
		dir_crit = (
					(df['cid_val'] == True) &
					(
						(df['cid'] == cid) &
						(	
							(df[key].str.contains('director')) |
							(df[key].str.contains('head')) 
						)	
					) & (df['exec'] != True) 
					)

		df.loc[dir_crit, 'dir'] = True


		#manager criteria
		man_crit = (
					(df['cid_val'] == True) &
					(
						(df['cid'] == cid) &
						(	
							(df[key].str.contains('manager')) |
							(df[key].str.contains('managing')) 
						)

					) &
					(
						(df['exec'] != True) &
						(df['dir'] != True)
					)
					)

		df.loc[man_crit, 'man'] = True



		x = df.loc[(df['cid_val'] == True)]
		print(x)

		y = df.loc[(df['exec'] == True)]
		print(y)


	#Filtering of DF
	keep_crit = (
				(df['cid_val'] == True)				
				)


	#Keep Rows Matching Criteria
	df = df.loc[keep_crit]

	#Drop New Columns 
	#TODO edit sql so can keep new cols
	df = df.drop(['cid_val', 'exec', 'dir', 'man'], axis=1)

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

