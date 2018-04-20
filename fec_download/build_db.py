import sqlite3
import csv
import re
import signal
import threading
import time
import codecs
import argparse
from glob import glob
#from config import *
from setlogger import *
from download import *


def choose_config(config_spec):

	if config_spec is False:
		from master_config import years, cycles, companies, table_key
		return [years, cycles, companies, table_key]
	else:
		from config import years, cycles, companies, table_key
		return [years, cycles, companies, table_key]


#Data Cleaning Functions
def sed_replace_null(file, script="clean_null.sh"):
        code = open(script, 'w')
        code.write('file={}\n'.format(file))
        sed_line = open('sed_null.sh', 'rU').read()
        code.write(sed_line)
        code.close()


#SQLite Database Functions
def connect_db(db_name):
	print("[*] launching sqlite db: {}".format(db_name))
	return sqlite3.connect(db_name)


def exit_db(db):
	print("[*] exiting db, done")
	db.commit()
	db.close()


def create_table(cursor, sql_script, path='sql/', inject=False):

	if inject is False:
		print("[*] create table with {}{}".format(path, sql_script))
		qry = open("{}{}".format(path, sql_script), 'rU').read()
	elif inject is True:
		print("[*] create table with sql injection: {}...".format(sql_script[0:30]))
		qry = sql_script

	cursor.executescript(qry)


def insert_file_into_table(cursor, sql_script, file, sep=',', path='sql/', inject=False):

	if inject is False:
		print("[*] inserting {} into table with {}{}".format(file, path, sql_script))
		qry = open("{}{}".format(path, sql_script), 'rU').read()
	elif inject is True:
		print("[*] inserting into table with sql injection: {}...".format(sql_script[0:21]))
		qry = sql_script

	fileObj = open(file, 'rU', encoding='latin-1')
	csvReader = csv.reader(fileObj, delimiter=sep, quotechar='"')

	try:
		for row in csvReader:
			try:
				cursor.execute(qry, row)
			except sqlite3.IntegrityError as e:
				pass

	except Exception as e:
		print("[*] error while processing file: {}, error code: {}".format(file, e))
		print("[*] sed replacing null bytes in file: {}".format(file))
		sed_replace_null(file, "clean_null.sh")
		subprocess.call("bash clean_null.sh", shell=True)

		try:
			print("[*] inserting {} into table with {}{}".format(file, path, sql_script))
			fileObj = open(file, 'rU', encoding='latin-1')
			csvReader = csv.reader(fileObj, delimiter=sep, quotechar='"')
			for row in csvReader:
				try:
					cursor.execute(qry, row)
				except sqlite3.IntegrityError as e:
					pass
					print(e)	
	
		except Exception as e:
			print("[*] error while processing file: {}, error code: {}".format(file, e))



def create_insert_table(c, files):

	keys = list(set([return_key(file) for file in files]))
	for key in keys:
		sql = return_sql("create", key=key)
		create_table(c, sql)

	for file in files:
		sql = return_sql("insert", file=file)
		insert_file_into_table(c, sql, file, '|')


def count_result(c, table):
	try:
		([print("[*] total: {:,} rows in {} table"
			.format(r[0], table)) 
			for r in c.execute("SELECT COUNT(*) FROM {};".format(table))])
	except Exception as e:
		print(e)


def count_results(c, table_key):
	[count_result(c, table_key[k][0]) for k, v in table_key.items()]


#Helper Functions
def return_files(path, ext, key=None):
	key = key if key is not None else ''
	return glob('{}*{}*.{}'.format(path, key, ext))


def return_key(file):
	filepath = file.rsplit('/', 1)
	if len(filepath)==2:
		file = filepath[1]
	else:
		file = filepath[0]

	return file.split('_', 1)[0][:-2]


def return_sql(action, **kwargs):

	source = [k for k,v in kwargs.items()][0]
	arg = [v for k,v in kwargs.items()][0]

	assert len(kwargs) == 1, ("ERROR: {}"
		.format("provide one and only one keyword argument"))
	assert source == 'key' or source == 'file', ("ERROR: {}"
		.format("incorrect keyword arguments, must be either 'key' or 'file'"))

	if source == 'key':	 key=arg
	if source == 'file': key=return_key(arg)

	return "{}_{}.sql".format(action, key)




db = None
shutdown = False

def build_tables(table_key, delete=True):
	global db

	#All Files in Config
	files = [file for k, v in table_key.items() for file in return_files("downloads/", "txt", k)]

	#Run: Build Database
	db = connect_db("openFEC.db")
	c = db.cursor()

	create_insert_table(c, files)
	count_results(c, table_key)
	exit_db(db)

	if delete is True:
		download_files = glob('{}*.{}'.format("downloads/", "txt"))
		remove_files(download_files, rmfiles=True)

	db = None
	return


def interrupt(signum, frame):
	global db
	global shutdown

	print ("[*] interrupt requested, control-C a second time to confirm")

	if db:
		db.interrupt()
		db.close()


def download_build(select_config, config=False):
	
	if select_config == "master_config":
		from master_config import years, cycles, companies, table_key


	if select_config == "config":
		years = config[0]
		cycles = config[1]
		companies = config[2]
		table_key = config[3]
		#from config import years, cycles, companies, table_key


	
	config_profile = [years, cycles, companies, table_key]
	print(config_profile)

	#Download Requested Data
	datasets = download_files(years, table_key)
	download(datasets, table_key)

	#Build Tables
	build_tables(table_key, delete=True)






#download_build("config")
#download_build("master_config")

"""
if __name__ == "__main__":

	parser = argparse.ArgumentParser()
	parser.add_argument("-c", "--config", default=False, type=bool, help="config files")
	parser.add_argument("-d", "--download", default=False, type=bool, help="download files")
	parser.add_argument("-b", "--build", default=False, type=bool, help="build tables")
	args = parser.parse_args()

	if not (args.config or args.download or args.build):
		parser.error('No action requested, add --config None or --download True or --build True')
	
	#to import config.py:: -c True
	if args.config is True:
		config = choose_config(True)
		from config import *
		print(config)
	#to import master config:: do nothing
	else:
		from master_config import *
		config = choose_config(args.config)
		print(config)



	if args.download is True:
		datasets = download_files(years, table_key)
		download(datasets, table_key)
	else:
		pass

	if args.build is True:
		signal.signal(signal.SIGINT, interrupt)
		mainthread = threading.Thread(target=main)
		mainthread.start()

		while mainthread.isAlive():
			time.sleep(0.2)
	else:
		pass
"""