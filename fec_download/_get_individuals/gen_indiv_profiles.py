import pandas as pd
import numpy as np
import csv
import re
import warnings
import os.path
from glob import glob
from collections import Counter


#Attach Code in Parent Dir
#p = '../'
#p = '.'
#import sys
#print(sys.path)
#sys.path.append(p)
#print(sys.path)

#from ... import setlogger
#from ..setlogger import *

from _util.setlogger import *
from data.companies import *
from . gen_indiv_utils import *
#from . gen_indiv_utils import *



#SETUP TEST DF

#Load Company Master and Key
cmaster = "data/fortune1000-list_alias_master.csv"
company_key = key_aliases(cmaster, limit=False)


#df = pd.read_csv("schedule_a_cleaned_201804101300.csv", sep="|")
df = pd.read_csv("schedule_a_cleaned_201804101302.csv", sep="|")
#print(df)
df["cid_master"] = df.cid.apply(lambda cid: company_key[cid])

print(df.shape)
#print(df.head(10))

#####################



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



	#what cols to pass to the next groupby?
	#df = df[[clean_col, name_col, 'cid_master', contributor_city, ]]
	#print(df.head(20))
	return df


def clean_city_col(city_col, df):

	clean_col = city_col+"_clean"
	df[clean_col] = df[city_col]

	df = lower_clean_strip(clean_col, df) 
	df = concat_split_cities(clean_col, df)
	df = rm_punct_col(clean_col, df)

	#df = df[[clean_col, city_col]]
	#print(df.head(20))
	return df


def clean_state_col(state_col, df):

	clean_col = state_col+"_clean"
	df[clean_col] = df[state_col]

	df = lower_clean_strip(clean_col, df) 
	df = concat_split_cities(clean_col, df)
	df = rm_punct_col(clean_col, df)

	#keep_cols = ['contributor_name_clean', 'cid_master', 'contributor_city_clean', 'contributor_state_clean']
	#df = df[keep_cols]
	#print(x.head(20))
	return df





##STEP 2 do the group by and other indiv aggregates

df = clean_name_col("contributor_name", df)
df = clean_city_col("contributor_city", df)
df = clean_state_col("contributor_state", df)
#df.to_csv("mytest.csv", sep="|")

#df = pd.read_csv("mytest.csv", sep="|")

def clean_contrib_data(df):

	df = clean_name_col("contributor_name", df)
	df = clean_city_col("contributor_city", df)
	df = clean_state_col("contributor_state", df)
	return df


#clean_contrib_data(df)


df = clean_name_col("contributor_name", df)
df = clean_city_col("contributor_city", df)
df = clean_state_col("contributor_state", df)

#need to groupby cycle not across cycles

#group_cols = ['contributor_name_clean', 'cid_master']
#group_cols = ['contributor_name_clean', 'cid_master', 'contributor_city_clean']
#group_cols = ['contributor_name_clean', 'cid_master', 'contributor_state_clean']
group_cols = ['contributor_name_clean', 'cid_master', 'contributor_city_clean', 'contributor_state_clean', 'contributor_cycle']


#check NA vals for groupcols or other cols, could be source of count seg_faults



#analysis_cols = ['sub_id', 'party_id', 'partisan_score', 'contributor_cycle']
#analysis_cols = ['contributor_cycle', 'sub_id', 'party_id', 'partisan_score']
analysis_cols = ['sub_id', 'party_id', 'partisan_score']
#other_cols = ['contributor_city_clean']

#keep_cols = group_cols+analysis_cols+other_cols
keep_cols = group_cols+analysis_cols
df = df[keep_cols]
df = df.fillna("0") #key, some missing data in the states #prevents segfault error


#x = df.groupby(group_cols).count().add_suffix('_Count').reset_index()
#x = df.groupby(group_cols).count().add_suffix('_Count')
#x = df.groupby(['contributor_name']).first()
#x = df.groupby(group_cols).min()

##Need to convert cols to correct datatypes
print(df.dtypes)

#Convert analysis cols to correct data type


#cols = ['contributor_cycle', 'partisan_score']
cols = ['partisan_score']
df[cols] = df[cols].apply(pd.to_numeric, errors='coerce', axis=1)

print(df.dtypes)


"""
x = df.groupby(group_cols).count()
print(x.shape)
print(x.head(5))
x.to_csv("testgroupresults.csv", sep=",")

"""


#x = df.groupby(group_cols).count()


x = df.groupby(group_cols).agg(
		{	'contributor_cycle' : [min, max, 'count'],
			'sub_id' : 'count',
			'party_id': ['first', 'count'],
			'partisan_score': [min, max, 'mean', 'median']
		}
		)



print(x.shape)
#print(x.head(200))
print(x.head(5))
#print(x.shape)

x.to_csv("testgroupresults.csv", sep=",")

#


#unique_cids = df.contributor_name.unique().tolist()
#print(len(unique_cids))