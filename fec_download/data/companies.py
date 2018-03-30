
import pandas as pd


def fortune(csv, write=False):
	df = pd.read_csv(csv)
	df['alias'] = df['company']
	df['cid'] = df['company']

	outfile = csv.split(".csv")[0]+"_alias.csv"

	if write is True:
		df.to_csv(outfile)
	else:
		pass

	return outfile



def concat_alias(csv, limit=50):
	df = pd.read_csv(csv)
	df['companies'] = df['company']+ "|" + df['alias'].map(str)

	cl = df["companies"].tolist()

	if limit is False:
		cl = cl
	else:
		cl = cl[0:limit]

	l2 = [l.split("|") for l in cl]
	l3 = [item for sublist in l2 for item in sublist]
	return l3


def key_aliases(csv, inverse=True, limit=50):
	df = pd.read_csv(csv)
	df['companies'] = df['company']+ "|" + df['alias'].map(str)
	cl = df["companies"].tolist()

	if limit is False:
		cl = cl
	else:
		cl = cl[0:limit]

	aliases = [l.split("|") for l in cl]
	keys = df["cid"].tolist()

	my_map = dict(zip(keys, aliases))

	def invert(d):
		return dict( (v,k) for k in d for v in d[k] )

	if inverse is True:
		dictionary = invert(my_map)
	else:
		dictionary = my_map
		pass

	return dictionary



#companies = concat_alias(fortune("fortune1000-list.csv"))
#companies = concat_alias("data/fortune1000-list_alias_master.csv")
#company_key = key_aliases("data/fortune1000-list_alias_master.csv")


#TODO later
#look into df.replace({"col1": di})
#
