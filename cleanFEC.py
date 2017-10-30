import pandas as pd
import csv
from glob import glob

def read_company_csv(company):
	company = str(company).replace(" ", "_")
	file_type = "{}".format(company)
	print(file_type)
	filename = glob('*{}*'.format(file_type))
	print(filename)
	df = pd.read_csv(filename[0])
	return df

df = read_company_csv("Goldman Sachs")
print(df.shape)


#print(df['contributor_employer'])

df["employer_clean"] = df['contributor_employer'].str.replace('[^\w\s]','').str.replace('  ', ' ')
df["employer_clean"] = df['employer_clean'].str.lower()

#print(df["employer_clean"])



#example
#company_name_ids
#apple_ids = []
goldman_sachs_ids = ["goldman sachs", "goldman sachs co", "goldman sachs company"]

df = df[df['employer_clean'].isin(goldman_sachs_ids)]
print(df.shape)