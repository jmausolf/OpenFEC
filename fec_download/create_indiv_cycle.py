#import pandas as pd
import sqlite3
import time

from setlogger import *
#from build_db import *
from make_sql import *
from clean_db import *
from util import *


def add_cycle_indiv(db, c, input_table, output_table=None, lim=False):
	
	if output_table is None or output_table == input_table:
		assert lim is False, (
			"[*] limit must be False if output_table is None...\n"
			"[*] otherwise, {} will be overwritten".format(input_table)
			)
		output_table = input_table


	c.execute("DROP INDEX if exists idx_tmp;")
	c.execute("DROP TABLE if exists {};".format("tmp"))


	alter_create_table(
			input_table, "tmp", 
			db, c, 
			alter_function=alt_cycle, 
			limit=lim, 
			chunksize=1000000,
			index=True, 
			unique=True, 
			key="sub_id",
			replace_null=[0, 20],
			alt_types=["NUMERIC", "NUMERIC"],
			replace_type=[0, 20]
			)
	

	if output_table == input_table:
		time_elapsed(start_time)
		print("[*] dropping table {}".format(input_table))
		c.execute("DELETE FROM {};".format(input_table))
		c.execute("DROP TABLE if exists {};".format(input_table))
		time_elapsed(start_time)
	else:
		pass


	c.execute(alter_table_rename("tmp", output_table))
	db.commit()
	print("[*] done")



if __name__ == "__main__":

	#add_cycle_indiv(db, c, "individual_contributions", "indiv_test", lim=500)
	#add_cycle_indiv(db, c, "individual_contributions", "indiv_test", lim=500)
	add_cycle_indiv(db, c, "indiv_test2", "indiv_test2", False)