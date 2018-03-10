import pandas as pd
import sqlite3

from config import *
from setlogger import *
#from download import *
from build_db import *
from make_sql import *
from getPARTY import *


def ren(invar, outvar, df):
    df.rename(columns={invar:outvar}, inplace=True)
    return(df)

def lower_var(var, df):
    s = df[var].str.lower()
    df = df.drop(var, axis=1)
    df = pd.concat([df, s], axis=1)
    return(df)



#Helper Functions Used in Example
def ren(invar, outvar, df):
    df.rename(columns={invar:outvar}, inplace=True)
    return(df)

def count_result(c, table):
    ([print("[*] total: {:,} rows in {} table"
        .format(r[0], table)) 
        for r in c.execute("SELECT COUNT(*) FROM {};".format(table))])


#Connect to Data
db = sqlite3.connect("openFEC.db")
#db = sqlite3.connect("openFEC.db", isolation_level=None)
#db = sqlite3.connect("openFEC.db", isolation_level="DEFERRED")
c = db.cursor()

cycles = [int(year) for year in years]

#alter function should be a function that takes a df, does stuff, returns df

def alt_cm_test(df, cycles=False):
	df = lower_var("cand_name", df)
	return df

def alt_cmte_test(df, cycles=False):
	return df

def alt_cmte_unique(df, cycles=False):
	cols = cols = ['cmte_id', 'cmte_nm', 'cmte_pty_affiliation', 'cand_id']
	df = df[cols]
	df = df.drop_duplicates()
	return df

def alt_cmte_pid(df, cycles=cycles):
	data = pd.DataFrame([])
	for cycle in cycles:
		data = data.append(get_party_ids_scores(df, cycle))
	return data


def alt_indiv_test(df, cycles=False):
	df = lower_var("name", df)
	return df


def get_alter_profile(input_table, output_table, db, alter_function, cycles=[2008], replace_null=False, replace_type=False, alt_types=[], **kwargs):

	df = pd.read_sql_query("SELECT * FROM {} LIMIT 2;".format(input_table), con=db)
	df = alter_function(df, cycles)

	cols = list(df)
	print(cols)

	#TODO get null, type vectors from db
	nulls = gen_nulls(cols, "", replace=replace_null)
	types = gen_types(cols, replace=replace_type, alt_vector=alt_types)

	#print(cols)

	#create_qry = make_sql_create_table(output_table, cols, types, nulls, index=True, unique=True, key="sub_id")
	create_qry = make_sql_create_table(output_table, cols, types, nulls, **kwargs)
	insert_qry = make_sql_insert_table(output_table, cols)

	#exit_db(db)
	#print(create_qry, insert_qry)
	return create_qry, insert_qry

#qrys = get_alter_profile("candidate_master", "test_cm", db, alt_cm_test)
#qrys = get_alter_profile("candidate_master", "test_cm", db, alt_cm_test, index=True, unique=True, key="cmte_id")
#print(qrys[0])
#print(qrys[1])

#print(get_alter_profile("individual_contributions", db, alt_indiv_test))

#TODO make work
def alter_create_table(input_table, output_table, db, conn, alter_function, path='sql_clean/', limit=False, chunksize=10000, **kwargs):

	#queries
	qrys = get_alter_profile(input_table, output_table, db, alter_function, **kwargs)

	if limit is False:
		limit_statement = ''
	else: 
		limit_statement = "LIMIT {}".format(limit)

	#create statement
	create_table(conn, qrys[0], inject=True)

	#Load Data in Chunks
	df_generator = pd.read_sql_query("SELECT * FROM {} {};".format(input_table, limit_statement), con=db, chunksize = chunksize)

	for df in df_generator:

		#make changes per passed alter function
	    df = alter_function(df)

	    #write chunk to csv
	    file = "df_chunk.csv"
	    df.to_csv(file, sep='|', header=None, index=False)

	    #insert chunk csv to db
	    insert_file_into_table(c, qrys[1], file, '|', inject=True)
	    db.commit()

	#Count if new table is created
	count_result(c, output_table)


#NB
#function still has weird extra inserts if SQL script does not have a unique ID and total rows > chunk size
#most tables without the unique id have a small enough row size that they can be modified in the first chunk
#big tables should have the unique key (sub_id) specificed to avoid issues


#since each modification will work from an alter_create_table function, the keys, types, nulls, 
#can be passed after some experimentation with get_alter_profile
#alter_create_table("candidate_master", "test_candidate", db, c, alter_function=alt_cm_test, limit=False, chunksize=1000000)

#create a unique id'd version of cmte_id's
alter_create_table("committee_master", "committee_master_unique", db, c, alter_function=alt_cmte_unique, limit=False, chunksize=1000000)
#alter_create_table("committee_master", "cmte_master_pids", db, c, alter_function=alt_cmte_pid, limit=False, chunksize=1000000)
#alter_create_table("committee_master_unique", "cmte_master_pids", db, c, alter_function=alt_cmte_pid, limit=5, chunksize=1000000)
alter_create_table("committee_master_unique", "committee_master_pids", db, c, alter_function=alt_cmte_pid, limit=False, chunksize=1000000)
#alter_create_table("individual_contributions", "test_indiv", db, c, alter_function=alt_indiv_test, limit=20000, chunksize=100000, index=True, unique=True, key="sub_id")

#alter_create_table("individual_contributions", "test_indiv", db, c, alter_function=alt_indiv_test)



















