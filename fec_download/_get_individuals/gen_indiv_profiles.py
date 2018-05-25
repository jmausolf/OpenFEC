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





##STEP 2 do the group by and other indiv aggregates

#df = clean_name_col("contributor_name", df)
#df = clean_city_col("contributor_city", df)
#df = clean_state_col("contributor_state", df)
#df.to_csv("mytest.csv", sep="|")

#df = pd.read_csv("mytest.csv", sep="|")

def clean_contrib_data():

	df = pd.read_csv("schedule_a_cleaned_201804101302.csv", sep="|")
	#print(df)
	df["cid_master"] = df.cid.apply(lambda cid: company_key[cid])

	print(df.shape)

	df = clean_name_col("contributor_name", df)
	df = clean_city_col("contributor_city", df)
	df = clean_state_col("contributor_state", df)
	return df



#Make DF
df = clean_contrib_data()




#need to groupby cycle not across cycles
#group_cols = ['contributor_name_clean', 'cid_master', 'contributor_city_clean', 'contributor_state_clean', 'contributor_cycle']
group_cols = ['contributor_name_clean', 'cid_master', 'contributor_cycle']


#check NA vals for groupcols or other cols, could be source of count seg_faults
analysis_cols = ['sub_id', 'party_id', 'partisan_score', 'contributor_city_clean', 'contributor_state_clean']
#other_cols = ['contributor_city_clean']

#TODO Analysis Columns
#city most common
#state most common
#party_id most common
#cmte id most common
#cmte name most common
#contributor position most common

#so basically, need a way to get the most common text value, or convert to category and do that

#keep_cols = group_cols+analysis_cols+other_cols
keep_cols = group_cols+analysis_cols
df = df[keep_cols]
df = df.fillna("missing") #key, some missing data in the states #prevents segfault error



#Convert analysis cols to correct data type
#cols = ['contributor_cycle', 'partisan_score']
cols = ['partisan_score']
df[cols] = df[cols].apply(pd.to_numeric, errors='coerce', axis=1)

print(df.dtypes)


#Custom mode function to avoid repetative lambda's
def mode(x):
    return x.mode()

#Custom mode name for pretty columns
#mode.__name__ = 'mode'


grouped = df.groupby(group_cols).agg(

		OrderedDict([
			('contributor_cycle' , [min, max, 'count']),
			('contributor_city_clean' , mode),
			('contributor_state_clean' , mode),
			('sub_id' , 'count'),
			('party_id' , ['first', 'count']),
			('partisan_score' , [min, max, 'mean', 'median'])
		])
		)


#Rename Grouped Columns
grouped.columns = ["_".join(x) for x in grouped.columns.ravel()]


#Inspect and Save
print(grouped.shape)
print(grouped.head(5))
grouped.to_csv("testgroupresults.csv", sep=",")

