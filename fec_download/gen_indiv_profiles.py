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



#df = pd.read_csv("schedule_a_cleaned_201804101300.csv", sep="|")
df = pd.read_csv("schedule_a_cleaned_201804101302.csv", sep="|")


df["cid_master"] = df.cid.apply(lambda cid: company_key[cid])

print(df.shape)
print(df.head(10))




unique_cids = df.contributor_name.unique().tolist()
print(len(unique_cids))