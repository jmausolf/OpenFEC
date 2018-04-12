from setlogger import *
import pandas as pd
import numpy as np
import csv
import re
import warnings
import os.path
from glob import glob
from collections import Counter
from data.companies import *



#Load Company Master and Key
cmaster = "data/fortune1000-list_alias_master.csv"
company_key = key_aliases(cmaster, limit=False)



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
		executive_col = 'executive_emp'
		director_col = 'director_emp'
		manager_col = 'manager_emp'
		rank_col = 'rank_emp'
		outfile = 'cid_emp_cleaned.csv'

	if filetype == 'occ':
		cols = ['cid', 'contributor_occupation_clean', 'occ_count']
		df.columns = cols
		key = 'contributor_occupation_clean'
		count = 'occ_count'
		executive_col = 'executive_occ'
		director_col = 'director_occ'
		manager_col = 'manager_occ'
		rank_col = 'rank_occ'
		outfile = 'cid_occ_cleaned.csv'


	#make new cols
	df['cid_valid'] = ''
	df[executive_col] = ''
	df[director_col] = ''
	df[manager_col] = ''
	df['not_employed'] = ''
	df['cid_master'] = ''

	#drop rows with missing cid
	df.cid.fillna('', inplace=True)
	df = df[df.cid != '']
	print(df.shape)

	punct = r'[]\\?!\"\'#$%&(){}+*/:;,._`|~\\[<=>@\\^-]'

	#Companies
	companies = sorted(df['cid'].fillna('').unique().tolist())
	print(companies)
	
	for cid in companies:
		print("[*] cleaning {} for {}...".format(key, cid))

		cid_sub_punct = re.sub(punct, ' ', cid).lower()

		match_crit2 = "{} ".format(cid.lower())
		match_crit4 = "{}".format(cid_sub_punct)
		match_crit5 = "{} ".format(' '.join(cid_sub_punct.split()))

		#company criteria
		#exact match only
		criteria1 = (
					(df['cid'] == cid) &
					(	(df[key] == cid.lower()) |
						(df[key] == cid_sub_punct) |
						(df[key] == ' '.join(cid_sub_punct.split()))
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

		#exact match for cid less punct no space
		criteria5 = (
					(df['cid'] == cid) &
					(df[key].str.match(match_crit5))
					)



		df.loc[criteria1, 'cid_valid'] = True
		df.loc[criteria2, 'cid_valid'] = True
		df.loc[criteria3, 'cid_valid'] = True

		if re.search(punct, cid) is not None:
			df.loc[criteria4, 'cid_valid'] = True
			df.loc[criteria5, 'cid_valid'] = True


		#anti alias
		anti = anti_alias(cmaster, company_key[cid])
		if anti is False:
			pass
		else:
			anti_crit = (
						(df['cid'] == cid) &
						(df[key].str.contains(anti))
						) 
						

			df.loc[anti_crit, 'cid_valid'] = False


		#Criteria for all companies
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

		df.loc[exec_crit, executive_col] = True


		#director criteria
		dir_crit = (
					(df['cid_valid'] == True) &
					(
						(df['cid'] == cid) &
						(	
							(df[key].str.contains('director')) |
							(df[key].str.contains('head')) 
						)	
					) & (df[executive_col] != True) 
					)

		df.loc[dir_crit, director_col] = True


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
						(df[executive_col] != True) &
						(df[director_col] != True)
					)
					)

		df.loc[man_crit, manager_col] = True


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


	#Ranking
	df[rank_col] = df.groupby("cid")[count].rank(method="first", ascending=False)

	#Keep Only Top Rank Option
	if top_n is False:
		pass
	else:
		rank_crit = (df[rank_col] <= top_n)
		keep_leaders = 	(
							(df[executive_col] == True) |
							(df[director_col] == True) |
							(df[manager_col] == True) 
						)

		if leaders is False:
			df = df.loc[rank_crit]

		elif leaders is True:
			df = df.loc[(rank_crit | keep_leaders)]			




	#Finally Assign Master CID from Aliases
	df.cid_master = df.cid.apply(lambda cid: company_key[cid])

	#Write Outfile and Return
	print(df.head(10))
	print("[*] shape of all data: {}".format(df.shape))
	df.to_csv(outfile, index=False)
	return df



#clean_dev_contrib_csv("test")
#clean_dev_contrib_csv("emp", top_n=5, leaders=False)
#clean_dev_contrib_csv("emp", top_n=5, leaders=True)

#clean_dev_contrib_csv("emp")



