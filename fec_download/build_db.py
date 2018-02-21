import sqlite3
import csv
import re
from glob import glob


#db functions
def connect_db(db_name):
	return sqlite3.connect(db_name)


def exit_db(db):
	db.commit()
	db.close()


def create_table(cursor, sql_script):
	qry = open(sql_script, 'rU').read()
	cursor.executescript(qry)


def insert_file_into_table(cursor, sql_script, file, sep=','):
	qry = open(sql_script, 'rU').read()
	csvReader = csv.reader(open(file), delimiter=sep, quotechar='"')
	for row in csvReader:
		cursor.execute(qry, row)


#helper functions
def ret_files(path, filetype):
	return glob('{}*.{}'.format(path, filetype))


def ret_script_file(action, file):

	filepath = file.rsplit('/', 1)
	if len(filepath)==2:
		file = filepath[1]
	else:
		file = filepath[0]

	table_key = re.split(r'[0-9]+', file)[0]
	sql_script = "{}_{}.sql".format(action, table_key)
	return sql_script




db = connect_db("test.db")
c = db.cursor()


create_table(c, "create_tables.sql")


insert_file_into_table(c, 'insert_cm.sql', 'downloads/cm14_fec_2018-02-19_cm.txt', '|')


#eventually
#files = ret_files("downloads/", "txt")
#for file in files:
#	sql_script = ret_script_file("insert", file)
#	insert_file_into_table(c, sql_script, file, '|')




for row in c.execute('SELECT * FROM committee_master'):
	print(row)



exit_db(db)