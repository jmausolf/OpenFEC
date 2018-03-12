import pandas as pd
import sqlite3
from setlogger import *
from download import *
from build_db import *
from make_sql import *
from getPARTY import *
from clean_db import *
from master_config import *



def rename(cursor, input_tables, output_prefix, reverse=False):

	for input_table in input_tables:
		output_table = "{}_{}".format(output_prefix, input_table)

		if reverse is False:
			qry = alter_table_rename(input_table, output_table)
			print("[*] rename table {} to {}".
				format(input_table, output_table)
				)
		elif reverse is True:
			qry = alter_table_rename(output_table, input_table)
			print("[*] rename table {} to {}".
				format(output_table, input_table)
				)

		try:
			cursor.executescript(qry)
		except Exception as e:
			print(e)

	print("[*] done")



def make_pid_config(year):
	years = [year]
	cycles = [int(year) for year in years]
	companies = f500("data/fortune500-list.csv")[0:10]
	table_key = {
		'cm'     : ['committee_master', 'cm.txt'],
		'cn'     : ['candidate_master', 'cn.txt'],
		'oth'    : ['itemized_records', 'itoth.txt']
	}

	config = [years, cycles, companies, table_key]
	return config



def write_config(config, script="config.py"):
        code = open(script, 'w')
        code.write('years = {}\n'.format(config[0]))
        code.write('cycles = {}\n'.format(config[1]))
        code.write('companies = {}\n'.format(config[2]))
        code.write('table_key = {}\n'.format(config[3]))
        code.close()




def make_pids_table(db, c, dest=False, lim=False, af=alt_cmte_pid_cycle):
	"""
	:: db:		database
	:: c:		database cursor
	:: dest:	output table, default False writes to "committee_master_pids"
	:: lim:		number of rows for each table, default=False, e.g. no limit
	:: af:		alter function, default=alt_cmte_pid_cycle
	"""

	source = "committee_master"

	if dest is not False:
		assert isinstance(dest, str) is True, (
			print("[*] please pass a valid table name as string"))
	else:
		dest =  "committee_master_pids"

	build_cmd = "python3 build_db.py -c True -d True -b True"

	pid_counter = 0
	for cycle in cycles:
		pid_counter +=1
		if pid_counter == 1:
			write_config(make_pid_config(str(cycle)))
			subprocess.call(build_cmd, shell=True)
			alter_create_table(source, dest, db, c, alter_function=af, 
				limit=lim, chunksize=1000000, cycles=cycle)
		else:
			write_config(make_pid_config(str(cycle)))
			subprocess.call(build_cmd, shell=True)
			alter_create_table(source, dest, db, c, alter_function=af, 
				limit=lim, chunksize=1000000, cycles=cycle, create=False)		


make_pids_table(db, c, lim=15)



