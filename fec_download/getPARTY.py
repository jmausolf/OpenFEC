import pandas as pd
import numpy as np
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

def get_pty_by_cand_id(db, cand_id, cycle=False):

	if cycle is False:
		cand_qry = select_pty_by_cand_id(cand_id)
	else:
		cand_qry = select_pty_by_cand_id(cand_id, cycle)

	#print(cand_qry)

	df = pd.read_sql_query(cand_qry, con=db, index_col=None)

	if df.shape[0] == 0:
		#print("[*] no candidate information for requested election cycle: {}...".format(cycle))
		#print("[*] searching candidate without election cycle...")

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
	#print(cmte_qry)

	df = pd.read_sql_query(cmte_qry, con=db, index_col=None)
	#print(df)

	#print(df.shape)

	if df.shape[0] == 0:
		pid = "MISSING"
		cand_id = ""
		return pid, cand_id

	#Get unique pid's (in the event the candidate switches parties)
	pids = df["cmte_pty_affiliation"].tolist()

	#if only two entries that are different, takes most recent
	try:
		pid = list(Counter(pids).most_common(1))[0][0]
		name = list(Counter(df["cmte_nm"].tolist()).most_common(1))[0][0]
	except Exception as e:
		print(e)
		print(pids)
		pid = ""
		name = ""


	cand_id = list(Counter(df["cand_id"].tolist()).most_common(1))[0][0]
	#print(cand_id)

	if pid is None or pid is "":
		pid = "MISSING"

	#TODO more robust searching, such that if 
	#pid is not dem/rep, keep searching
	#not return code for unknown or missing or none

	print("[*] found...committee {0:7} - {1:10} is {2}".format(cmte_id, name, pid))
	return pid, cand_id


def get_other_ids_itemized_records(db, cmte_id, cycle=False):

	if cycle is False:
		item_qry = select_other_ids_itemized_records(cmte_id)
	else:
		item_qry = select_other_ids_itemized_records(cmte_id, cycle)

	df = pd.read_sql_query(item_qry, con=db, index_col=None)
	#print(df)

	#print(item_qry)

	return df["other_id"].tolist()
	#item_qry = select_cmte_ids_itemized_records(cmte_id)

	#print(item_qry)

#get_pty_by_cmte_id(db, "C00001214")
#get_pty_by_cmte_id(db, "C00002592")


#get_pty_by_cand_id(db, "H6WA05023")

#get_other_ids_itemized_records(db, "C00042069", 2008)
#get_other_ids_itemized_records(db, "C00002592")
#get_other_ids_itemized_records(db, "C00000042")



def id_type(id):
	assert len(str(id)) == 9, (
		"[*] please input a valid committee or candidate id as a string")
	
	if str(id)[0] == "C":
		return "cmte_id"
	else:
		return "cand_id"


#ids = ["C00002592", "C00084954", "C00042069", "H0GA08032", "P80003338"]
#for id in ids:
#	print(id_type(id))


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


def partisan_dummy(pid):

	#print(type(pid))

	if isinstance(pid, tuple) is True:
		pid = pid[0]
	else:
		pass

	if pid == "REP":
		return 1
	elif pid == "IND":
		return 0
	elif pid == "DEM":
		return -1

	#TOOD assign scores to other 
	#types of parties
	else:
		return np.nan


def select_pids(pid_tuple):

	#print(type(pid_tuple))

	if isinstance(pid_tuple, tuple) is True:
		pid = pid_tuple[0]
	else:
		pid = pid_tuple

	return pid

"""
pids = ['DEM', 'REP', 'REP', ('DEM', -0.15738), 'DEM', 'DEM', 'REP']

binary_pid = [partisan_dummy(pid) for pid in pids]
partisan_score = float("{:0.5f}".format((np.nanmean(binary_pid))))


print(pids)
pids_clean = [select_pids(pid) for pid in pids]

#for pid in pids:
#	select_pids(pid)

print(pids_clean)
pid = list(Counter(pids_clean).most_common(1))[0][0]


print(binary_pid)
print(len(binary_pid))
print(partisan_score)
print(pid)
"""


counter = 0
first_missing = []
second_missing = []

def search_party_id(db, cmte_id, cycle=False, recursive=False, levels=False, itemized=False):

	global counter

	cmte_results = get_pty_by_cmte_id(db, cmte_id)

	pid = cmte_results[0]
	cmte_cand = cmte_results[1]

	#TODO, new option to get partisan scores for options 1, 2

	#direct cmte id
	if pid_codes(pid) is True:
		#print(pid)
		if itemized is True:
			results = get_parties_other_ids(db, cmte_id, cycle)
			pid = results[0]
			partisan_score = results[1]
			return pid, partisan_score

		else:
			return pid

	#search of candidate ids
	if pid_codes(pid) is False and len(str(cmte_cand)) == 9:
		pid = get_pty_by_cand_id(db, cmte_cand, cycle)

		if pid_codes(pid) is True:
			#print(pid)
			#partisan_score = "?"
			#return pid, partisan_score
			#return pid

			if itemized is True:
				results = get_parties_other_ids(db, cmte_id, cycle)
				pid = results[0]
				partisan_score = results[1]
				return pid, partisan_score

			else:
				return pid

		else: 
			pass

	#itemized search of other ids
	if pid_codes(pid) is False and len(str(cmte_cand)) < 9:

		if levels is True:
			second_missing.append(cmte_id)
			counter+=1

			if counter > len(first_missing):
				print("counter exceeds first missing")
				#print()
				return np.nan


		else:
			first_missing.append(cmte_id)

		print("Current counter = {}".format(counter))
		print("Current first missing = {}".format(len(first_missing)))

		if recursive is True:
			pid = get_parties_other_ids(db, cmte_id, cycle, recursive=True)
		else:
			results = get_parties_other_ids(db, cmte_id, cycle)
			pid = results[0]
			partisan_score = results[1]




		return pid, partisan_score
			



		#return pid, partisan_score





def get_parties_other_ids(db, cmte_id, cycle=False, recursive=False, depth=False, itemized=False):
	#global counter
	#counter+=1

	other_ids = get_other_ids_itemized_records(db, cmte_id, cycle)

	#if requested cycle has no data, get data for all cycles
	if len(other_ids) == 0:
		other_ids = get_other_ids_itemized_records(db, cmte_id)

		#if still no results:
		print("still no results")
		if len(other_ids) == 0:
			#get score for pid
			pid = search_party_id(db, cmte_id, levels=True)
			partisan_score = float("{:0.5f}".format(partisan_dummy(pid)))
			#partisan_score = round(float(partisan_dummy(pid)), 4)
			#partisan_score = np.around(partisan_dummy(pid), 3)
			return pid, partisan_score
	else:
		pass

	print(other_ids)

	#id_types = [id_type(oid) for oid in other_ids][0:10]
	#print(id_types)
	pids = []

	for oid in other_ids:
		if id_type(oid) == 'cmte_id':
			if depth is False:
				pid = search_party_id(db, oid, cycle, levels=True)

				if isinstance(pid, list) is True:
					pids.extend(pid)
				else:
					pids.append(pid)

			elif depth is True:
				pid = search_party_id(db, oid, cycle, levels=False)

				if isinstance(pid, list) is True:
					pids.extend(pid)
				else:
					pids.append(pid)



		elif id_type(oid) == 'cand_id':
			#cand search
			pid = get_pty_by_cand_id(db, oid, cycle)
			pids.append(pid)
			pass



	if recursive is True:
		return pids
	else:
		pids_clean = [select_pids(pid) for pid in pids]
		binary_pid = [partisan_dummy(pid) for pid in pids_clean]
		partisan_score = float("{:0.5f}".format((np.nanmean(binary_pid))))

		pids_count = [pid for pid in pids_clean if str(pid) != 'nan']
		print(pids_count)
		#for pid in range(pids_clean.count('nan')):
		#	print(pid)
		#	pids_clean.remove('nan')

		#cleanedList = [x for x in countries if str(x) != 'nan']

		#print(pids_clean)
		#print(pids_count)
		pid = list(Counter(pids_count).most_common(1))[0][0]

		print(binary_pid)
		print(len(binary_pid))
		print(partisan_score)

		#print(counter)
		print(pid)
		#pid = 'DEMMY'

		if itemized is True:
			return pid
		else:
			return pid, partisan_score



#x = get_parties_other_ids(db, "C00000042", 2007)
#get_parties_other_ids(db, "C00000042", 2008)



#TODO need to program a depth, so the recursion does not go in circles infinately
#e.g. below
#get_parties_other_ids(db, "C00046474")
#get_parties_other_ids(db, "C00051979")


#search_party_id(db, "C00000042", 2007)
#search_party_id(db, "C00000042", 2008)
#search_party_id(db, "C00046474", 2008)

#x = get_parties_other_ids(db, "C00451773", 2008)

#strange err explore
#x = search_party_id(db, "C00329862")
#x = get_parties_other_ids(db, "C00329862")

#Obama for America
#x = search_party_id(db, "C00431445", 2008)
#cx = search_party_id(db, "C00431445", 2008, itemized=True)
#x = search_party_id(db, "C00431445", 2004, itemized=True)

#Montana for Obama
#x = search_party_id(db, "C00451773", 2008)
#x = search_party_id(db, "C00451773", 2008, itemized=True)


#IL Tool Works for Better Gov
#x = search_party_id(db, "C00000042", 2004)

#Nisource PAC
#x = search_party_id(db, "C00051979")

#Ford Motor Civic Action Fund
#x = search_party_id(db, "C00046474", 2008)
#x = search_party_id(db, "C00046474", 2004)

#x = search_party_id(db, "C00000489", 2008, itemized=True)

#TODO figure out why this is not working
#x = search_party_id(db, "C00000638", 2008, itemized=True)

#print(x)
#print("Final counter = {}".format(counter))
#print("Final first missing = {}".format(len(first_missing)))


df = pd.read_csv("test_cmte.csv", sep="|")
cols = ['cmte_id', 'cmte_nm', 'tres_nm', 'cmte_st1', 'cmte_st2', 'cmte_city', 'cmte_st', 'cmte_zip', 'cmte_dsgn', 'cmte_tp', 'cmte_pty_affiliation', 'cmte_filing_freq', 'org_tp', 'connected_org_nm', 'cand_id']
df.columns = cols
df = df.head(n=10)
print(df)

#TODO
#need the "cycle" of candidate info to use in searching
#so given a cycle, need to adjust my queries to be where dt like cycle or dt like cycle-1



df['party_id'], df['partisan_score'] = np.vectorize(search_party_id)(db, df['cmte_id'], 2008, itemized=True)
print(df)


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