import pandas as pd
import sqlite3
import signal
import threading
import time

from setlogger import *
from build_db import *
from make_sql import *
from clean_db import *
from util import *
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

	#TODO
	#adjust indiv contrib to add cycle column
	#Alter cycles example
	#drop table if exists indiv
	#rename table to indiv
	#adjust join query (add cycle col)
	#adjust create and insert qurs

	#create dest table
	if replace_if_exists is True:
		run_sql_query(c, create_qry, path='sql_clean/')
		pass


	#cid_counter = 0
	for company in companies:
		global start_time
		time_elapsed(start_time)

		#create temporary table from selection
		company_qry = select_schedule_a_by_company(
				company,
				committee_table,
				pids)
		#print(company_qry)
			
		run_sql_query(c, company_qry, inject=True)
		#db.commit()
		print(company)

		#alter to add cid to info before insert
		alter_create_table("tmp", "tmp_cid", db, c, 
						alter_function=alt_cid, 
						cid=company, 
						limit=False, 
						chunksize=1000000)


		#insert temporary table into destination
		run_sql_query(c, insert_qry, path='sql_clean/')


#create_select_insert_company(db, c, companies)
run = True

def main():
	global db
	global c
	global run 


	#Connect to Data
	#db = connect_db("openFEC.db")
	#c = db.cursor()
	from clean_db import db, c


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
	exit_db(db)

	#Final Time
	#time_elapsed(start_time)
	print("[*] done")

	db = None
	c = None
	run = False
	return





def interrupt(signum, frame):
	global db
	global shutdown

	print ("[*] interrupt requested, control-C a second time to confirm")

	if db:
		db.interrupt()
		db.close()




if __name__ == "__main__":

	parser = argparse.ArgumentParser()
	parser.add_argument("-b", "--build", 
			default=False, 
			type=bool, 
			help="clean files"
			)
	args = parser.parse_args()

	if not (args.build):
		parser.error('No action requested, add --build True')


	if args.build is True:
		main()

	else:
		pass
