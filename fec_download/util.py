import time
import sqlite3

#Start Time
start_time = time.time()

def time_elapsed(start_time):
	current_time = time.time()
	time_elapsed = current_time-start_time
	minutes, seconds = divmod(time_elapsed, 60)
	hours, minutes = divmod(minutes, 60)
	message1 = "[*] time elapsed:"
	message2 = "...current time:"

	print("{0} {1:7} hours, {2:3} minutes, {3:3} seconds{4} {5:10}"
		.format(message1,
				int(hours), 
				int(minutes), 
				int(seconds),
				message2,
				time.strftime('%l:%M%p %Z on %b %d, %Y')))



def run_sql_query(cursor, sql_script, path='sql/', inject=False):
 
	if inject is False:
		print("[*] run queries with {}{}".format(path, sql_script))
		qry = open("{}{}".format(path, sql_script), 'rU').read()
	elif inject is True:
		print("[*] run queries with sql injection: {}..."
			.format(sql_script[0:30]))
		qry = sql_script

	try:
		cursor.executescript(qry)
	except sqlite3.IntegrityError as e:
		pass