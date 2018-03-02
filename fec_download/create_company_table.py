import pandas as pd
import sqlite3

from config import *
from setlogger import *
#from download import *
from build_db import *
from make_sql import *


def run_sql_queries(cursor, sql_script, path='sql/', inject=False):
 
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
	


db = None
shutdown = False

def main():
	global db

	#Connect to Data
	#Run: Build Database
	db = connect_db("openFEC.db")
	c = db.cursor()

	#create_table(c, "select_schedule_a_by_company.sql", path="")
	run_sql_queries(c, "select_schedule_a_by_company.sql", path="")

	count_result(c, "cm_indiv")
	exit_db(db)

	db = None
	return


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
			time.sleep(0.2)
	else:
		pass