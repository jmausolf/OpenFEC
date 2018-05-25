import pandas as pd
import numpy as np
import csv
import re
import warnings
import os.path
from glob import glob
from collections import Counter
from collections import OrderedDict



from _util.setlogger import *
from _util.util import *
from data.companies import *
from . gen_indiv_utils import *




#SETUP TEST DF

#Load Company Master and Key
cmaster = "data/fortune1000-list_alias_master.csv"
company_key = key_aliases(cmaster, limit=False)





##STEP 1 Needs to Be Cleaning the Contributor Name 
#(To deal with diff in cases, mr, ms, middle initials, etc)


def clean_name_col(name_col, df):

	clean_col = name_col+"_clean"

	#make copy of name
	df[clean_col] = df[name_col]

	#add join multipart last names, e.g. van geis = vangeis mc afee = mcafee,
	df = join_last_names(clean_col, df)
	df = lower_clean_strip(clean_col, df) 

	#correct non reversed names with commas
	df = correct_non_reversed_names(clean_col, df)


	df = reverse_names(clean_col, df, delim=',')
	df = rm_punct_except_period_dash_comma(clean_col, df)
	df = concat_name_initials(clean_col, df)
	df = rm_suffixes_titles(clean_col, df)
	df = sep_first_middle(clean_col, df)
	df = lower_clean_strip(clean_col, df)
	df = rm_middle_name(clean_col, df)

	return df


def clean_city_col(city_col, df):

	clean_col = city_col+"_clean"
	df[clean_col] = df[city_col]

	df = lower_clean_strip(clean_col, df) 
	df = concat_split_cities(clean_col, df)
	df = rm_punct_col(clean_col, df)

	return df


def clean_state_col(state_col, df):

	clean_col = state_col+"_clean"
	df[clean_col] = df[state_col]

	df = lower_clean_strip(clean_col, df) 
	df = concat_split_cities(clean_col, df)
	df = rm_punct_col(clean_col, df)

	return df




def clean_contrib_data(input_df=None, file=None):

	#start time
	global start_time


	if file is None and input_df is not None:
		df = input_df
	else:
		df = pd.read_csv(file, sep="|", 
			dtype={	'contributor_zip_code' : 'str',
					'contributor_transaction_tp' : 'str',
					'sub_id' : 'str',
					'executive_emp' : 'str',
					'executive_occ' : 'str',
					'director_emp' : 'str',
					'director_occ' : 'str',
					'manager_emp' : 'str',
					'manager_occ' : 'str'})
	#print(df)
	df["cid_master"] = df.cid.apply(lambda cid: company_key[cid])

	print(df.shape)

	df = clean_name_col("contributor_name", df)
	df = clean_city_col("contributor_city", df)
	df = clean_state_col("contributor_state", df)

	time_elapsed(start_time)

	return df



#Make DF
#chedule_a_cleaned_201804101302.csv
#df = clean_contrib_data(file="schedule_a_cleaned_201805251423.csv")
#df = clean_contrib_data(input_df=df)





##STEP 2 do the group by and other indiv aggregates


def group_individuals(clean_df):

	#start time
	global start_time

	df = clean_df

	#need to groupby cycle not across cycles
	#group_cols = ['contributor_name_clean', 'cid_master', 'contributor_city_clean', 'contributor_state_clean', 'contributor_cycle']
	group_cols = ['contributor_name_clean', 'cid_master', 'contributor_cycle']


	#check NA vals for groupcols or other cols, could be source of count seg_faults
	#analysis_cols = ['sub_id', 'party_id', 'partisan_score', 'contributor_city_clean', 'contributor_state_clean']
	analysis_cols = [	'sub_id', \
						'contributor_city_clean', 'contributor_state_clean', 'contributor_zip_code', \
						'contributor_employer_clean', 'contributor_occupation_clean', \
						'executive_emp', 'executive_occ', \
						'director_emp', 'director_occ', \
						'manager_emp', 'manager_occ', \
						'cmte_id', 'cmte_nm', \
						'party_id', 'partisan_score', \
						'contributor_transaction_amt', \
						'contributor_transaction_tp', 'contributor_rpt_tp' \
					]



	#keep_cols = group_cols+analysis_cols+other_cols
	keep_cols = group_cols+analysis_cols
	df = df[keep_cols]
	df = df.fillna("missing") #key, some missing data in the states #prevents segfault error



	#Convert analysis cols to correct data type
	#cols = ['contributor_cycle', 'partisan_score']
	cols = ['partisan_score', 'contributor_transaction_amt']
	df[cols] = df[cols].apply(pd.to_numeric, errors='coerce', axis=1)



	#print(df.dtypes)


	#Custom mode function to avoid repetative lambda's
	def mode(x):
	    return x.mode()


	#Group By Code
	grouped = df.groupby(group_cols).agg(

			OrderedDict([
				('sub_id' , 'count'),
				('contributor_city_clean' , mode),
				('contributor_state_clean' , mode),
				('contributor_zip_code' , mode),
				('contributor_employer_clean' , mode),
				('contributor_occupation_clean' , mode),
				('executive_emp' , mode),
				('executive_occ' , mode),
				('director_emp' , mode),
				('director_occ' , mode),
				('manager_emp' , mode),
				('manager_occ' , mode),
				('cmte_id' , mode),
				('cmte_nm' , mode),
				('party_id' , ['count', 'first', mode]),
				('partisan_score' , ['count', min, max, 'mean', 'median', mode]),
				('contributor_transaction_amt' , ['count', min, max, 'mean', 'median', mode]),
				('contributor_transaction_tp' , mode),
				('contributor_rpt_tp' , mode)
			])
			)


	#Rename Grouped Columns
	grouped.columns = ["_".join(x) for x in grouped.columns.ravel()]


	#Inspect and Save
	print(grouped.shape)
	print(grouped.head(5))
	#grouped.to_csv("testgroupresults.csv", sep=",")

	grouped = grouped.reset_index()
	print(grouped.shape)
	print(grouped.head(5))


	time_elapsed(start_time)

	return grouped



#group_individuals(df)




def get_individual_partisans(df):

	clean_df = clean_contrib_data(input_df=df)

	return group_individuals(clean_df)



#get_individual_partisans(df)













