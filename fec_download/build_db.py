import sqlite3
import csv
import re
from glob import glob
from download import table_key
import signal
import threading
import time
import os



#SQLite Database Functions
def connect_db(db_name):
	print("[*] launching sqlite db: {}".format(db_name))
	return sqlite3.connect(db_name)


def exit_db(db):
	print("[*] exiting db, done")
	db.commit()
	db.close()


def create_table(cursor, sql_script, path='sql/'):
	print("[*] create table with {}{}".format(path, sql_script))
	qry = open("{}{}".format(path, sql_script), 'rU').read()
	cursor.executescript(qry)


def insert_file_into_table(cursor, sql_script, file, sep=',', path='sql/'):
	print("[*] inserting {} into table with {}{}".format(file, path, sql_script))
	qry = open("{}{}".format(path, sql_script), 'rU').read()

	fileObj = open(file, 'rU', encoding='latin-1')
	csvReader = csv.reader(fileObj, delimiter=sep, quotechar='"')
	for row in csvReader:
		try:
			cursor.execute(qry, row)
		except sqlite3.IntegrityError as e:
			pass


def create_insert_table(c, files):

	keys = list(set([return_key(file) for file in files]))
	for key in keys:
		sql = return_sql("create", key=key)
		create_table(c, sql)

	for file in files:
		sql = return_sql("insert", file=file)
		insert_file_into_table(c, sql, file, '|')


def count_result(c, table):
	([print("[*] total: {:,} rows in {} table"
		.format(r[0], table)) 
		for r in c.execute("SELECT COUNT(*) FROM {};".format(table))])


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



#first step
db = None
shutdown = False

##conn == db
##cursor == c

def main():
	global db

	#All Files
	#files = return_files("downloads/", "txt")

	#All Files in Config
	files = [file for k, v in table_key.items() for file in return_files("downloads/", "txt", k)]


	#DEV: Specify Type of File
	#files = return_files("downloads/", "txt", "ccl")


	#Run: Build Database
	db = connect_db("openFEC.db")
	c = db.cursor()

	create_insert_table(c, files)
	count_results(c, table_key)
	exit_db(db)

	db = None
	return






def interrupt(signum, frame):
	global db
	global shutdown

	print ("[*] interrupt requested, control-C a second time to confirm")

	if db:
		db.interrupt()
		db.close()

if __name__ == "__main__":
    signal.signal(signal.SIGINT, interrupt)

    mainthread = threading.Thread(target=main)
    mainthread.start()

    while mainthread.isAlive():
        time.sleep(0.2)

