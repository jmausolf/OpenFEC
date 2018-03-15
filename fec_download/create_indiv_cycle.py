import sqlite3
import time
import warnings
from setlogger import *
from make_sql import *
from clean_db import *
from util import *



def get_index_rename(db, c, output_table, idx="idx_tmp"):

	idx_new = "idx_{}".format(output_table)
	get_index_qry = """
		SELECT sql FROM sqlite_master 
			WHERE type IS 'index' AND name IS '{}';
		""".format(idx)

	sqlobj = c.execute(get_index_qry)

	if list(sqlobj) == [] :
		warnings.warn(
			"[*] requested idx: {} does not exist..."
			.format(idx)
			)
	else:
		create_stem = [r[0] for r in c.execute(get_index_qry)][0]
		create_qry = create_stem.replace(idx, idx_new)+";"

		print("[*] renaming index: {} to {}...".format(idx, idx_new))
		c.execute("DROP INDEX if exists {};".format(idx))
		c.execute(create_qry)



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

	
	#Rename Table
	c.execute(alter_table_rename("tmp", output_table))

	#Rename Index
	get_index_rename(db, c, "individual_contributions")

	db.commit()
	print("[*] done")



if __name__ == "__main__":

	add_cycle_indiv(db, c, "individual_contributions")


	#add_cycle_indiv(db, c, "individual_contributions")