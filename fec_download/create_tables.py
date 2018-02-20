import sqlite3


conn = sqlite3.connect("example.db")
c = conn.cursor()


qry = open('create_tables.sql', 'rU').read()
#print(qry)
c.executescript(qry)

line = "C90016999|TRANSPORTATION TRADES DEPARTMENT AFL-CIO POLITICAL EDUCATION FUND||815 16TH STREET NW|4TH FLOOR|WASHINGTON|DC|20006|U|I||Q|||"
line = line.replace("|", ",")
#print(line)

#c.execute("INSERT INTO committee_master VALUES ({})".format(line))

#c.execute(".mode")

qry = open('insert_committee_master.sql', 'rU').read()
#(qry)

import csv
csvReader = csv.reader(open('downloads/cm14_fec_2018-02-19_cm.txt'), delimiter='|', quotechar='"')
for row in csvReader:
	#print(row)
	c.execute(qry, row)
	#c.execute("INSERT INTO committee_master VALUES (?, ?, ?)", row)


for row in c.execute('SELECT * FROM committee_master'):
	print(row)

conn.commit()
conn.close()

