import pandas as pd
import sqlite3
import signal
import threading
import time

from config import *
from setlogger import *
from build_db import *
from make_sql import *
from util import *

from collections import Counter

#Start Time
start_time = time.time()


#Connect to Data
db = connect_db("openFEC.db")
c = db.cursor()

def get_pty_by_cand_id(db, cand_id, year=False):

	if year is False:
		cand_qry = select_pty_by_cand_id(cand_id)
	else:
		cand_qry = select_pty_by_cand_id(cand_id, year)

	df = pd.read_sql_query(cand_qry, con=db, index_col=None)

	if df.shape[0] == 0:
		#print("[*] no candidate information for requested election year: {}...".format(year))
		#print("[*] searching candidate without election year...")

		cand_qry = select_pty_by_cand_id(cand_id)
		df = pd.read_sql_query(cand_qry, con=db, index_col=None)
	else:
		pass

	#sort by date, so most recent are last
	df['cand_election_yr'] = pd.to_numeric(df['cand_election_yr'], errors='coerce')
	df.sort_values('cand_election_yr', inplace=True)

	#Get unique pid's (in the event the candidate switches parties)
	pids = df["cand_pty_affiliation"].tolist()

	#if only two entries that are different, takes most recent
	pid = list(Counter(pids).most_common(1))[0][0]
	name = list(Counter(df["cand_name"].tolist()).most_common(1))[0][0]

	if pid is None or pid is "":
		pid = "MISSING"

	print("[*] found...candidate {0:7} - {1:10} is {2}".format(cand_id, name, pid))
	return pid

#get_pty_by_cand_id(db, "P80003338", "2008")
#get_pty_by_cand_id(db, "H0GA08032", "2000")
#get_pty_by_cand_id(db, "H8CT01046", "2004")
#get_pty_by_cand_id(db, "H0CA10057", "2008")

#where does not exist
#get_pty_by_cand_id(db, "H6KY03140", "2004")



def get_pty_by_cmte_id(db, cmte_id):

	cmte_qry = select_pty_by_cmte_id(cmte_id)

	df = pd.read_sql_query(cmte_qry, con=db, index_col=None)
	#print(df)

	#Get unique pid's (in the event the candidate switches parties)
	pids = df["cmte_pty_affiliation"].tolist()

	#if only two entries that are different, takes most recent
	pid = list(Counter(pids).most_common(1))[0][0]
	name = list(Counter(df["cmte_nm"].tolist()).most_common(1))[0][0]

	cand_id = list(Counter(df["cand_id"].tolist()).most_common(1))[0][0]
	#print(cand_id)

	if pid is None or pid is "":
		pid = "MISSING"

	#TODO more robust searching, such that if 
	#pid is not dem/rep, keep searching
	#not return code for unknown or missing or none

	print("[*] found...committee {0:7} - {1:10} is {2}".format(cmte_id, name, pid))
	return pid, cand_id


def get_cmte_ids_itemized_records(db, cmte_id, year=False):

	if year is False:
		item_qry = select_cmte_ids_itemized_records(cmte_id)
	else:
		item_qry = select_cmte_ids_itemized_records(cmte_id, year)

	df = pd.read_sql_query(item_qry, con=db, index_col=None)
	print(df)


	#item_qry = select_cmte_ids_itemized_records(cmte_id)

	print(item_qry)

#get_pty_by_cmte_id(db, "C00001214")
#get_pty_by_cmte_id(db, "C00002592")


#get_pty_by_cand_id(db, "H6WA05023")

get_cmte_ids_itemized_records(db, "C00042069", 2008)
get_cmte_ids_itemized_records(db, "C00002592")
get_cmte_ids_itemized_records(db, "C00000042")

def pid_codes(pid):

	if pid == "DEM" or pid == "REP":
		return True
	elif pid == "MISSING":
		return False
	elif pid == "NNE" or pid == "UNK":
		return False
	elif pid == "UN" or pid == "NON" or pid == "N" or pid == "OTH":
		return False
	else:
		return "CONTINUE"

def search_party_id(db, cmte_id, year=None):

	cmte_results = get_pty_by_cmte_id(db, cmte_id)

	pid = cmte_results[0]
	cmte_cand = cmte_results[1]
	#cmte_cand = ""

	#print(pid_codes(cmte_pty))

	if pid_codes(pid) is True:
		return pid

	if pid_codes(pid) is False and len(str(cmte_cand)) == 9:
		pid = get_pty_by_cand_id(db, cmte_cand)

		if pid_codes(pid) is True:
			return pid
		else: 
			pass


	if pid_codes(pid) is False and len(str(cmte_cand)) < 9:
		print("itemized search")
		return ""


		#print("-False-")

	#print(cmte_pty)
	#print(cmte_cand)

	#search pty affiliation in committee's table

	#if no party or undesired party code AND cand id
	#get party from cand id



	#if no party or undesired code BUT no cand id
	#search itemized contributions
	#query those id's etc

    #return party_id
#print(search_party_id("C00053553"))


cids = ["C00002592", "C00084954", "C00042069"]

for cid in cids:
	pid = search_party_id(db, cid, year=None)
	print(pid)
	pass


#qry = select_cmte_ids_itemized_records("C00002592", year=2008)
#print(qry)



"""
election_year = df["cand_election_yr"].unique().tolist()

#Get unique pid's (in the event the candidate switches parties)
pid = df["cand_pty_affiliation"].unique().tolist()

if len(pid) > 1:
	pass
elif len(pid) ==1:
	pass

print(pid)
"""

"""
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
"""