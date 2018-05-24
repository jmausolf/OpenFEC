import pandas as pd
import sqlite3
import signal
import threading
import time

from _util.setlogger import *
from _build_db.build_db import *
from _util.make_sql import *
from _build_db.clean_db import *
from _util.util import *
from master_config import *


def create_select_insert_company(
			db,
			c, 
			companies, 
			replace_if_exists=False,
			committee_table=None,
			pids=False
			):

	if pids is False and committee_table is None:
		create_qry = "create_schedule_a.sql"
		insert_qry = "insert_schedule_a.sql"
	elif pids is True and committee_table is not None:
		create_qry = "create_schedule_a_pids.sql"
		insert_qry = "insert_schedule_a_pids.sql"


	#create dest table
	if replace_if_exists is True:
		run_sql_query(c, create_qry, path='sql_clean/')
		pass


	global start_time
	time_elapsed(start_time)

	#create temporary table from selection
	companies_qry = select_schedule_a_by_company(
				companies,
				committee_table,
				pids)
	print(companies_qry)
		
		
	run_sql_query(c, companies_qry, inject=True)

	time_elapsed(start_time)
	alter_create_table("tmp", "tmp_cid", db, c, 
						alter_function=alt_cid_companies, 
						limit=False, 
						chunksize=1000000)

	#insert temporary table into destination
	time_elapsed(start_time)
	run_sql_query(c, insert_qry, path='sql_clean/')
		

#create_select_insert_company(db, c, companies)
#run = True

def create_company_table(db, c):
	#global db
	#global c
	#global run 


	#Connect to Data
	#db = connect_db("openFEC.db")
	#c = db.cursor()
	#from clean_db import db, c


	#Build Company Queries
	create_select_insert_company(
			db,
			c, 
			companies,
			replace_if_exists=True,
			committee_table="committee_master_pids", 
			pids=True
		)



	#Count Result
	count_result(c, "schedule_a")
	#exit_db(db)

	#Final Time
	#time_elapsed(start_time)
	print("[*] done")

	#db = None
	#c = None
	#run = False
	#return








if __name__ == "__main__":

	create_company_table()

