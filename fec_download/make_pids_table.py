import pandas as pd
import sqlite3

from config import *
from setlogger import *
#from download import *
from build_db import *
from make_sql import *
from getPARTY import *
from clean_db import *


years = ['2000' , '2002', '2004', '2008']
cycles = [int(year) for year in years]


pid_counter = 0

for cycle in cycles:
	pid_counter +=1
	if pid_counter == 1:
		print("first cycle")
		#download and build tables
		alter_create_table("committee_master_unique", "committee_master_pids", db, c, alter_function=alt_cmte_pid_cycle, limit=5, chunksize=1000000, cycles=cycle)
	else:
		print("other cycle")
		alter_create_table("committee_master_unique", "committee_master_pids", db, c, alter_function=alt_cmte_pid_cycle, limit=5, chunksize=1000000, cycles=cycle, create=False)		


