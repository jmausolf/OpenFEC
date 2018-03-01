import pandas as pd
import sqlite3

from config import *
from setlogger import *
#from download import *
from build_db import *


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

#create statement
create_table(c, "create_test.sql", path='sql_clean/')

#Load Data in Chunks
df_generator = pd.read_sql_query("select * from individual_contributions;", con=db, chunksize = 10000)

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

    #for row in df.values:
    #for row in df.itertuples(index=False, header=False):

    	#x = row.to_string(header=False, index=False)
    	#x = row.to_csv(sep=',', header=False, index=False)
    	#print(row)

    #print(list(df))
    #csvstring = df.to_csv(sep=',', header=False, index=False)
    #for row in csvstring:
    #	print(row)
    #print(csvstring)
    #df.to_sql(new_table, con=db, if_exists = "append", index=False)
    #db.commit()

    #write_statement

    #alternative thought. Instead of using pandas to sql to do the write, 
    #write your own sql create statement then insert statement like before
    #might be fater than tosql
    #you would just need to be very careful about the order of the columns and names


#Count if new table is created
try:
    count_result(c, "test_indiv")
except:
    pass

