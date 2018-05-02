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
from gen_indiv_utils import *



#SETUP TEST DF

#Load Company Master and Key
cmaster = "data/fortune1000-list_alias_master.csv"
company_key = key_aliases(cmaster, limit=False)


#df = pd.read_csv("schedule_a_cleaned_201804101300.csv", sep="|")
df = pd.read_csv("schedule_a_cleaned_201804101302.csv", sep="|")
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
	df = rm_name_punct_except_period_dash(clean_col, df)
	df = concat_name_initials(clean_col, df)
	df = rm_suffixes_titles(clean_col, df)
	df = sep_first_middle(clean_col, df)
	df = lower_clean_strip(clean_col, df)
	df = rm_middle_name(clean_col, df)



	df = df[[clean_col, name_col, 'cid_master']]
	print(df.head(20))
	return df


##STEP 2 do the group by and other indiv aggregates

df = clean_name_col("contributor_name", df)

x = df.groupby(['contributor_name_clean', 'cid_master']).first()
#x = df.groupby(['contributor_name']).first()
#print(x.shape)
print(x.head(200))
print(x.shape)

df.to_csv("mytest.csv", sep="|")


#unique_cids = df.contributor_name.unique().tolist()
#print(len(unique_cids))