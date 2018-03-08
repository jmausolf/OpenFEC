
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