
from setlogger import *
import pandas as pd
import numpy as np
import sqlite3
import csv
import os.path

#test df

"""
df_in = pd.read_csv("df_chunk_sa_test_cleaned.csv")
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

#df.columns = cols

#df = df.drop(['cid'], axis=1)
#print(df.head(5))
#df = df.loc[df['cid'] == "Apple"]
#print(df.head(5))


###test1
"""

#print(df.head(5))

def det_emp_occ_levels(df):

	df = df[['contributor_employer_clean','contributor_occupation_clean']].drop_duplicates()

	executive_col = 'executive'
	director_col = 'director'
	manager_col = 'manager'

	keys = ['contributor_employer_clean', 'contributor_occupation_clean']

	#Criteria for all companies
	for key in keys:

		if key == 'contributor_employer_clean':
			executive_col = 'executive_emp'
			director_col = 'director_emp'
			manager_col = 'manager_emp'

		else:
			executive_col = 'executive_occ'
			director_col = 'director_occ'
			manager_col = 'manager_occ'			

		df[executive_col] = ''
		df[director_col] = ''
		df[manager_col] = ''


		exec_crit = (
					(
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

		df.loc[exec_crit, executive_col] = True


		#director criteria
		dir_crit = (
					(
						(	
							(df[key].str.contains('director')) |
							(df[key].str.contains('head')) 
						)	
					) & (df[executive_col] != True) 
					)

		df.loc[dir_crit, director_col] = True


		#manager criteria
		man_crit = (
					(
						(	
							(df[key].str.contains('manager')) |
							(df[key].str.contains('managing')) 
						)

					) &
					(
						(df[executive_col] != True) &
						(df[director_col] != True)
					)
					)

		df.loc[man_crit, manager_col] = True

	return df


#orig data
df = pd.read_csv("df_chunk_sa_test_cleaned.csv", sep=",", low_memory=False)
print(df.shape)

x = df.loc[(df['executive_emp'] == True) | (df['executive_occ'] == True)]
print(x.shape)

#clean
df_levels = det_emp_occ_levels(df)

#drop columns from cleaned data
#columns to drop or not create
dropcols = ['executive_emp', 'director_emp', 'manager_emp', 'executive_occ', 'director_occ', 'manager_occ']
df.drop(df[dropcols], axis=1, inplace=True)
print(df.shape)



#now join with original
df_new = pd.merge(df, df_levels, 
					on=['contributor_employer_clean', 'contributor_occupation_clean'])


print(df_new.shape)
print(df_new.head(10))

x = df.loc[(df['executive_emp'] == True) | (df['executive_occ'] == True)]
print(x.shape)

"""
df_test = df_in[['contributor_employer', 'contributor_occupation']]

print(df_test)

companies = ["Walmart", "Exxon Mobile", "Marathon Oil", "Apple", "Berkshire Hathaway", "Amazon", "Boeing", "Alphabet", "Home Depot", "Ford Motor", "Kroger", "Chevron", "Morgan Chase", "Wells Fargo"]
#companies = ["Ford Motors"]




def add_cid(dfc, companies):
	df = dfc.copy()
	df['cid'] = ''

	for cid in sorted(companies, key=len):
		df['cid'] = np.where(df['contributor_employer'].isnull(), 
						#if employer missing, search occupation
						np.where(df['contributor_occupation'].str.contains(
								str(cid), case=False, na=False), cid, df['cid']),
						#else search employer
						np.where(df['contributor_employer'].str.contains(
								str(cid), case=False, na=False), cid, df['cid']))

	print(df)
	return df


add_cid(df_test, companies)
"""



