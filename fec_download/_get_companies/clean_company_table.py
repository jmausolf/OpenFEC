from _util.util import *
from _build_db.clean_db import *


def clean_company_table(db, c, dev=False):

	if dev is True:
		#TODO set chunksize as >= schedule_a
		#nb. if schedule a > chunksize, invalid results
		alter_create_table("schedule_a", "sa_dev", db, c, 
							alter_function=alt_dev_cids, 
							limit=False, 
							chunksize=100000000,
							alt_lim=10000)
	else:

		create_qry = "create_schedule_a_company_qc.sql"
		insert_qry = "insert_schedule_a_company_qc.sql"

		run_sql_query(c, create_qry, path='sql_clean/')


		#(Clean file to merge, then calc levels, load)
		alter_create_table("schedule_a", "sa_tmp", db, c, 
							alter_function=alt_clean_cids, 
							limit=False, 
							chunksize=1000000,
							alt_lim=10000)


		#insert temporary table into destination
		run_sql_query(c, insert_qry, path='sql_clean/')




#clean_company_table(db, c, dev=True)
#clean_company_table(db, c, dev=False)