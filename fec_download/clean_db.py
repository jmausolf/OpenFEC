import pandas as pd
import sqlite3

from config import *
from setlogger import *
#from download import *
from build_db import *
from make_sql import *


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
#new_table = "new_table_nolim1"

#working snippet
"""
#create statement
create_table(c, "create_test.sql", path='sql_clean/')

#Load Data in Chunks
df_generator = pd.read_sql_query("select * from individual_contributions;", con=db, chunksize = 100000)

for df in df_generator:
    #Functions to modify data, example
    #df = ren("name", "renamed_name", df)
    df = lower_var("name", df) #changes column order
    db_order = ["cmte_id", "amndt_ind", "rpt_tp", "transaction_pgi", "image_num", "transaction_tp", \
    	"entity_tp", "name", "city", "state", "zip_code", "employer", "occupation", "transaction_dt", \
    	"transaction_amt", "other_id", "tran_id", "file_num", "memo_cd", "memo_text", "sub_id"]

    #print(db_order)
    #change column order to desired sql table
    df = df[db_order]

    #write chunk to csv
    file = "df_chunk.csv"
    df.to_csv(file, sep='|', header=None, index=False)

    #insert chunk csv to db
    insert_file_into_table(c, "insert_test.sql", file, '|', path='sql_clean/')
    db.commit()
"""

#alter function should be a function that takes a df, does stuff, returns df

def alt_cm_test(df):
	df = lower_var("cand_name", df)
	return df

def alt_indiv_test(df):
	df = lower_var("name", df)
	return df


def get_alter_profile(input_table, output_table, db, alter_function):

	df = pd.read_sql_query("SELECT * FROM {} LIMIT 100;".format(input_table), con=db)
	df = alter_function(df)

	cols = list(df)

	#TODO get null, type vectors from db
	nulls = gen_nulls(cols, "", [0])
	types = gen_types(cols, replace=[4], alt_vector=["NUMERIC"])

	#print(cols)

	#create_qry = make_sql_create_table(output_table, cols, types, nulls, index=True, unique=True, key="sub_id")
	create_qry = make_sql_create_table(output_table, cols, types, nulls)
	insert_qry = make_sql_insert_table(output_table, cols)

	return create_qry, insert_qry

qrys = get_alter_profile("candidate_master", "test_cm", db, alt_cm_test)
#print(qrys[0])


#print(get_alter_profile("individual_contributions", db, alt_indiv_test))

#TODO make work
def alter_create_table(input_table, output_table, db, conn, alter_function, path='sql_clean/', limit=False, chunksize=10000):

	#TODO
	#code to create a SQL scripts based on output_table, and df manipulations, column order

	#queries
	qrys = get_alter_profile(input_table, output_table, db, alter_function)

	if limit is False:
		limit_statement = ''
	else: 
		limit_statement = "LIMIT {}".format(limit)

	#create statement
	create_table(conn, qrys[0], inject=True)

	#Load Data in Chunks
	df_generator = pd.read_sql_query("SELECT * FROM {} {};".format(input_table, limit_statement), con=db, chunksize = chunksize)

	for df in df_generator:
	    #Functions to modify data, example
	    #df = ren("name", "renamed_name", df)
	    #df = lower_var("cand_name", df) #changes column order
	    df = alter_function(df)


	    #print(cols)
	    #db_order = ["cmte_id", "amndt_ind", "rpt_tp", "transaction_pgi", "image_num", "transaction_tp", \
	    #	"entity_tp", "name", "city", "state", "zip_code", "employer", "occupation", "transaction_dt", \
	    #	"transaction_amt", "other_id", "tran_id", "file_num", "memo_cd", "memo_text", "sub_id"]

	    #print(db_order)
	    #change column order to desired sql table
	    #df = df[db_order]
	    print(df.shape)

	    #write chunk to csv
	    file = "df_chunk.csv"
	    df.to_csv(file, sep='|', header=None, index=False)

	    #insert chunk csv to db
	    insert_file_into_table(c, qrys[1], file, '|', inject=True)
	    db.commit()

	#Count if new table is created
	count_result(c, output_table)


alter_create_table("candidate_master", "test_candidate", db, c, alter_function=alt_cm_test, limit=10000)





















