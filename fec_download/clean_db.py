import pandas as pd
import sqlite3

from master_config import *
#from config import *
from setlogger import *
from build_db import *
from make_sql import *
from getPARTY import *
from cleanFEC import *
from util import *


#Connect to Data
db = sqlite3.connect("openFEC.db")
c = db.cursor()


#Helper Functions
def ren(invar, outvar, df):
    df.rename(columns={invar:outvar}, inplace=True)
    return(df)

def count_result(c, table):
    ([print("[*] total: {:,} rows in {} table"
        .format(r[0], table)) 
        for r in c.execute("SELECT COUNT(*) FROM {};".format(table))])


#Make Cycle Functions
def get_cycle(date, dformat="mdy"):

	global get_cycle_counter
	global recent_cycles

	if get_cycle_counter < 20:
		get_cycle_counter +=1
	else:
		recent_cycles = recent_cycles[:20]

	assert dformat == "mdy", (
		"[*] sorry, date format not currently supported")

	if dformat == "mdy":
		if len(str(date)) > 4:
			dyear = date[-4:]
			if int(dyear) % 2 == 0:
				cycle = str(dyear)
			else:
				cycle = str(int(dyear)+1)

			recent_cycles.append(cycle)

		else:
			try:
				cycle = list(Counter(recent_cycles).most_common(1))[0][0]
			except Exception as e:
				print(e)
				cycle = ''

		return cycle


def make_cycle(df, date_col, dformat="mdy"):
	global recent_cycles
	global get_cycle_counter

	get_cycle_counter = 0
	recent_cycles = []

	date = str(date_col)
	df[['cycle']] = df[date_col].apply(
		lambda date: get_cycle(date)).apply(pd.Series)

	return df


def add_cid(df, companies):
	df['cid'] = ''
	#sort companies,
	#start with shortest
	for cid in sorted(companies, key=len):
		df['cid'] = np.where(df['contributor_occupation'].str.contains(
								str(cid), case=False, na=False), cid, df['cid'])
		df['cid'] = np.where(df['contributor_employer'].str.contains(
								str(cid), case=False, na=False), cid, df['cid'])

	return df



#Alter Functions
def alt_cm_test(df, cycles=False, cid=False):
	df = lower_var("cand_name", df)
	return df


def alt_cmte_test(df, cycles=False, cid=False):
	return df


def alt_cmte_unique(df, cycles=False, cid=False):
	cols = cols = ['cmte_id', 'cmte_nm', 'cmte_pty_affiliation', 'cand_id']
	df = df[cols]
	df = df.drop_duplicates()
	return df


def alt_cmte_pid(df, cycles=cycles, cid=False):
	data = pd.DataFrame([])
	for cycle in cycles:
		data = data.append(get_party_ids_scores(df, cycle))
	return data


def alt_cmte_pid_cycle(df, cycles, cid=False):
	return get_party_ids_scores(df, cycles)


def alt_indiv_test(df, cycles=False, cid=False):
	df = lower_var("name", df)
	return df


def alt_cid(df, cycles=False, cid=False):
	df['cid'] = cid
	return df

def alt_cid_companies(df, cycles=False, cid=False):
	df = add_cid(df, companies)
	return df


def alt_cycle(df, cycles=False, cid=False):
	df = make_cycle(df, "transaction_dt")
	return df

def alt_clean_cids(df, cycles=False, cid=False):
	df = filter_company_ids(df)
	return df

def alt_dev_cids(df, cycles=False, cid=False):
	df = filter_company_ids(df, dev=True)
	return df


def get_alter_profile(
		input_table, 
		output_table, 
		db, 
		alter_function, 
		cycles=False,
		cid=False,
		replace_null=False, 
		replace_type=False,
		alt_lim = 1, 
		alt_types=[], **kwargs
		):

	df = pd.read_sql_query(
			"""
			SELECT * FROM {} LIMIT {};
			""".format(input_table, alt_lim), con=db)

	df = alter_function(df, cycles)

	cols = list(df)
	print(cols)

	#TODO get null, type vectors from db
	nulls = gen_nulls(cols, "", replace=replace_null)
	types = gen_types(cols, replace=replace_type, alt_vector=alt_types)

	create_qry = make_sql_create_table(
			output_table, 
			cols, 
			types, 
			nulls, **kwargs
			)
	insert_qry = make_sql_insert_table(output_table, cols)

	return create_qry, insert_qry



def alter_create_table(
		input_table, 
		output_table, 
		db, 
		conn, 
		alter_function, 
		path='sql_clean/', 
		cycles=False,
		cid=False,
		create=True, 
		limit=False, 
		chunksize=10000, **kwargs
		):

	"""
	::kwargs, modifying alter SQL (default types are TEXT (all can be null))

	::replace_null: 	a vector of intergers indicating the positions
						for SQL columns that should be NOT NULL
						e.g. replace_null=[0, 20]

	::alt_types:		a vector of strings indicating the type of var
						a column should be besides TEXT
						e.g. alt_types=["NUMERIC", "NUMERIC"]

	::replace_type:		a vector of integers indicating the position of
						the alt types (often equals the replace null vector)
						e.g. replace_type=[0, 20]

	"""

	#start time
	global start_time
	time_elapsed(start_time)

	#queries
	qrys = get_alter_profile(
			input_table, 
			output_table, 
			db, 
			alter_function,
			cycles,
			cid, **kwargs
			)

	if limit is False:
		limit_statement = ''
	else: 
		limit_statement = "LIMIT {}".format(limit)

	if create is True:
		create_table(conn, qrys[0], inject=True)
	else:
		pass

	#Load Data in Chunks
	df_generator = pd.read_sql_query(
			"""
			SELECT * FROM {} {};
			""".format(input_table, limit_statement), 
			con=db, chunksize = chunksize
		)

	for df in df_generator:

		#check time:
		time_elapsed(start_time)

		#make changes per passed alter function
		df = alter_function(df, cycles, cid)

		#write chunk to csv
		file = "df_chunk.csv"
		df.to_csv(file, sep='|', header=None, index=False)

		#insert chunk csv to db
		insert_file_into_table(c, qrys[1], file, '|', inject=True)
		db.commit()

	#Count if new table is created
	count_result(c, output_table)


#Examples
#create a unique id'd version of cmte_id's
#alter_create_table("committee_master", "committee_master_unique", db, c, alter_function=alt_cmte_unique, limit=False, chunksize=1000000)
#alter_create_table("committee_master", "cmte_master_pids", db, c, alter_function=alt_cmte_pid, limit=False, chunksize=1000000)
#alter_create_table("committee_master_unique", "cmte_master_pids", db, c, alter_function=alt_cmte_pid, limit=5, chunksize=1000000)
#alter_create_table("committee_master_unique", "committee_master_pids", db, c, alter_function=alt_cmte_pid, limit=False, chunksize=1000000)
#alter_create_table("individual_contributions", "test_indiv", db, c, alter_function=alt_indiv_test, limit=20000, chunksize=100000, index=True, unique=True, key="sub_id")
#alter_create_table("individual_contributions", "test_indiv", db, c, alter_function=alt_indiv_test)
#alter_create_table("committee_master", "committee_master_unique", db, c, alter_function=alt_cmte_unique, limit=False, chunksize=1000000)
#alter_create_table("committee_master_unique", "committee_master_pids", db, c, alter_function=alt_cmte_pid, limit=False, chunksize=1000000)

#alter_create_table("schedule_a", "sa_test", db, c, alter_function=alt_clean_cids, limit=False, chunksize=1000000)


#alter_create_table("schedule_a", "test", db, c, alter_function=alt_cmte_test, limit=False, chunksize=1000000)


#alter_create_table("test_cid", "sa_cid_test", db, c, alter_function=alt_cid_companies, limit=False, chunksize=1000000)


#alter_create_table("tmp", "tmp2", db, c, alter_function=alt_cid, limit=False, chunksize=1000000)

"""
alter_create_table("tmp", "tmp_cid2", db, c, 
				alter_function=alt_cid, 
				cid="Goldman Sachs", 
				limit=False, 
				chunksize=1000000)
"""


#Alter cycles example
"""
alter_create_table(
		"indiv_miss", "indiv_cycle", 
		db, c, 
		alter_function=alt_cycle, 
		limit=False, 
		chunksize=1000000, 
		index=True, 
		unique=True, 
		key="sub_id",
		replace_null=[0, 20],
		alt_types=["NUMERIC", "NUMERIC"],
		replace_type=[0, 20]
		)
"""

