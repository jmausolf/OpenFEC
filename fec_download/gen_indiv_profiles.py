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

#make copy of name
df['contributor_name_clean'] = df['contributor_name']

#add join multipart last names, e.g. van geis = vangeis mc afee = mcafee,
df = join_last_names('contributor_name_clean', df)
df = lower_clean_strip('contributor_name_clean', df) 

#correct non reversed names with commas
df = correct_non_reversed_names('contributor_name_clean', df)


df = reverse_names('contributor_name_clean', df, delim=',')
df = rm_name_punct_except_period_dash('contributor_name_clean', df)
df = concat_name_initials('contributor_name_clean', df)
df = rm_suffixes_titles('contributor_name_clean', df)
df = sep_first_middle('contributor_name_clean', df)
df = lower_clean_strip('contributor_name_clean', df)
df = rm_middle_name('contributor_name_clean', df)



df = df[['contributor_name_clean', 'contributor_name', 'cid_master']]
print(df.head(20))


x = df.groupby(['contributor_name_clean', 'cid_master']).first()
#x = df.groupby(['contributor_name']).first()
#print(x.shape)
print(x.head(200))
print(x.shape)

df.to_csv("mytest.csv", sep="|")


#unique_cids = df.contributor_name.unique().tolist()
#print(len(unique_cids))