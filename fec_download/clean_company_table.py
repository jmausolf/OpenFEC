from util import *
from clean_db import *


def clean_company_table(db, c, dev=False):

	if dev is True:
		alter_create_table("schedule_a", "sa_dev", db, c, 
							alter_function=alt_dev_cids, 
							limit=False, 
							chunksize=10000000,
							alt_lim=10)
	else:

		create_qry = "create_schedule_a_company_qc.sql"
		insert_qry = "insert_schedule_a_company_qc.sql"

		run_sql_query(c, create_qry, path='sql_clean/')


		alter_create_table("schedule_a", "sa_tmp", db, c, 
							alter_function=alt_clean_cids, 
							limit=False, 
							chunksize=1000000)


		#insert temporary table into destination
		run_sql_query(c, insert_qry, path='sql_clean/')


#clean_company_table(db, c, dev=True)