import sqlite3
import csv
import re
from glob import glob
from download import table_key



#SQLite Database Functions
def connect_db(db_name):
	print("[*] launching sqlite db: {}".format(db_name))
	return sqlite3.connect(db_name)


def exit_db(db):
	print("[*] exiting db, done")
	db.commit()
	db.close()


def create_table(cursor, sql_script):
	print("[*] create table with {}".format(sql_script))
	qry = open(sql_script, 'rU').read()
	cursor.executescript(qry)


def insert_file_into_table(cursor, sql_script, file, sep=','):
	print("[*] inserting {} into table with {}".format(file, sql_script))
	qry = open(sql_script, 'rU').read()
	csvReader = csv.reader(open(file), delimiter=sep, quotechar='"')
	for row in csvReader:
		try:
			cursor.execute(qry, row)
		except sqlite3.IntegrityError as e:
			pass


def create_insert_table1(c, files):

	keys = list(set([return_key(file) for file in files]))
	for key in keys:
		sql = return_sql("create", key=key)
		create_table(c, sql)

	for file in files:
		sql = return_sql("insert", file=file)
		insert_file_into_table(c, sql, file, '|')


def count_result(c, table):
	[print(r) for r in c.execute("SELECT COUNT(*) FROM {};".format(table))]



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

	return re.split(r'[0-9]+', file)[0]


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






#All Files
#files = return_files("downloads/", "txt")

#DEV: Specify Type of File
files = return_files("downloads/", "txt", "cn")
#print(files)
#table_names = list(set([v[1] for d in datasets for k, v in d.items()]))
#print(table_names)


#Run: Build Database
db = connect_db("openFEC.db")
c = db.cursor()

create_insert_table1(c, files)
count_result(c, table_key["cn"])

exit_db(db)