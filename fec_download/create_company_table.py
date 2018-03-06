import pandas as pd
import sqlite3
import signal
import threading
import time

from config import *
from setlogger import *
from build_db import *
from make_sql import *

#Start Time
start_time = time.time()

def time_elapsed(start_time):
	current_time = time.time()
	time_elapsed = current_time-start_time
	minutes, seconds = divmod(time_elapsed, 60)
	hours, minutes = divmod(minutes, 60)

	print("[*] time elapsed: {0:7} hours, {1:3} minutes, {2:3} seconds...current time: {3:10}"
		.format(int(hours), int(minutes), int(seconds),  time.strftime('%l:%M%p %Z on %b %d, %Y')))



def run_sql_query(cursor, sql_script, path='sql/', inject=False):
 
	if inject is False:
		print("[*] run queries with {}{}".format(path, sql_script))
		qry = open("{}{}".format(path, sql_script), 'rU').read()
	elif inject is True:
		print("[*] run queries with sql injection: {}...".format(sql_script[0:30]))
		qry = sql_script

	try:
		cursor.executescript(qry)
	except sqlite3.IntegrityError as e:
		pass


def create_select_insert_company(c, companies, replace_if_exists=False):

	#create dest table
	if replace_if_exists is True:
		run_sql_query(c, "create_schedule_a.sql", path='sql_clean/')
	else:
		#TODO test if table exists
		pass

	for company in companies:

		#create temporary table from selection
		company_qry = select_schedule_a_by_company(company)
		print(company_qry)
		run_sql_query(c, company_qry, inject=True)

		#insert temporary table into destination
		run_sql_query(c, "insert_schedule_a.sql", path='sql_clean/')



db = None
shutdown = False
run = False

def main():
	global db
	global run 
	run = True

	#Connect to Data
	db = connect_db("openFEC.db")
	c = db.cursor()

	#Build Company Queries
	create_select_insert_company(c, companies, replace_if_exists=True)
	#create_select_insert_company(c, companies)

	#Count Result
	count_result(c, "schedule_a")
	exit_db(db)

	#Final Time
	time_elapsed(start_time)
	print("[*] done")

	db = None
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
	parser.add_argument("-b", "--build", default=False, type=bool, help="clean files")
	args = parser.parse_args()

	if not (args.build):
		parser.error('No action requested, add --build True')


	if args.build is True:
		signal.signal(signal.SIGINT, interrupt)
		mainthread = threading.Thread(target=main)
		mainthread.start()

		while mainthread.isAlive():
			if run is True:
				time_elapsed(start_time)
				time.sleep(60)
			else:
				pass

	else:
		pass
