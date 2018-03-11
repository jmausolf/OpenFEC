import pandas as pd
import sqlite3

from setlogger import *
from download import *
from build_db import *
from make_sql import *
from getPARTY import *
from clean_db import *

from master_config import *

#years = ['2000' , '2002', '2004', '2008']
#cycles = [int(year) for year in years]


#Connect to DB
#db = connect_db("openFEC.db")
#c = db.cursor()


#from config import years, cycles, companies, table_key
print(years)

def rename(cursor, input_tables, output_prefix, reverse=False):

	for input_table in input_tables:
		output_table = "{}_{}".format(output_prefix, input_table)

		if reverse is False:
			qry = alter_table_rename(input_table, output_table)
			print("[*] rename table {} to {}".format(input_table, output_table))
		elif reverse is True:
			qry = alter_table_rename(output_table, input_table)
			print("[*] rename table {} to {}".format(output_table, input_table))

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


write_config(make_pid_config('2008'))


def choose_config(config_spec):

	if config_spec is False:
		print("master_config")
		from master_config import years, cycles, companies, table_key
		return [years, cycles, companies, table_key]
	else:
		print("other config")
		from config import years, cycles, companies, table_key
		return [years, cycles, companies, table_key]



#cfig = choose_config(True)
#print(cfig)

#1. Rename Main Tables
#tables = [v[0] for k, v in table_key.items()]
#rename(c, tables, "all", reverse=True)
#rename(c, tables, "all")





#2. Loop


pid_counter = 0
for cycle in cycles:
	pid_counter +=1
	if pid_counter == 1:
		print("first cycle")
		write_config(make_pid_config(str(cycle)))
		subprocess.call("python3 build_db.py -c True -d True -b True", shell=True)
		#build config
		#download and build tables from config
		alter_create_table("committee_master", "committee_master_pids", db, c, alter_function=alt_cmte_pid_cycle, limit=10, chunksize=1000000, cycles=cycle)
	else:
		print("other cycle")
		write_config(make_pid_config(str(cycle)))
		subprocess.call("python3 build_db.py -c True -d True -b True", shell=True)
		alter_create_table("committee_master", "committee_master_pids", db, c, alter_function=alt_cmte_pid_cycle, limit=10, chunksize=1000000, cycles=cycle, create=False)		


#rename tables back
#rename(tables, "all", reverse=True)

