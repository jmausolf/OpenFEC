import pandas as pd
import sqlite3

from master_config import *
from setlogger import *
from build_db import *
from make_sql import *
from getPARTY import *



#Helper Functions
def ren(invar, outvar, df):
    df.rename(columns={invar:outvar}, inplace=True)
    return(df)

def count_result(c, table):
    ([print("[*] total: {:,} rows in {} table"
        .format(r[0], table)) 
        for r in c.execute("SELECT COUNT(*) FROM {};".format(table))])


#Connect to Data
db = sqlite3.connect("openFEC.db")
c = db.cursor()



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



def get_alter_profile(
		input_table, 
		output_table, 
		db, 
		alter_function, 
		cycles=False,
		cid=False,
		replace_null=False, 
		replace_type=False, 
		alt_types=[], **kwargs
		):

	df = pd.read_sql_query(
			"""
			SELECT * FROM {} LIMIT 1;
			""".format(input_table), con=db)

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

		#make changes per passed alter function
	    df = alter_function(df, cycles, cid)

	    #write chunk to csv
	    file = "df_chunk.csv"
	    df.to_csv(file, sep='|', header=None, index=False)

	    #insert chunk csv to db
	    #print(qrys[1])
	    insert_file_into_table(c, qrys[1], file, '|', inject=True)
	    db.commit()

	#import pdb; pdb.set_trace()
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


#alter_create_table("tmp", "tmp2", db, c, alter_function=alt_cid, limit=False, chunksize=1000000)

"""
alter_create_table("tmp", "tmp_cid2", db, c, 
				alter_function=alt_cid, 
				cid="Goldman Sachs", 
				limit=False, 
				chunksize=1000000)
"""




