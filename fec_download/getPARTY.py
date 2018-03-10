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


def get_pty_by_cand_id(db, cand_id, cycle=False, verbose=False):

	if cycle is False:
		cand_qry = select_pty_by_cand_id(cand_id)
	else:
		cand_qry = select_pty_by_cand_id(cand_id, cycle)

	df = pd.read_sql_query(cand_qry, con=db, index_col=None)

	if df.shape[0] == 0:

		cand_qry = select_pty_by_cand_id(cand_id)
		df = pd.read_sql_query(cand_qry, con=db, index_col=None)

		if df.shape[0] == 0:
			pid = "MISSING"
			return pid
		else:
			pass

	else:

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

		if verbose is True:
			print("[*] found...candidate {0:7} - {1:10} is {2}".format(cand_id, name, pid))

		return pid




def get_pty_by_cmte_id(db, cmte_id, verbose=False):

	cmte_qry = select_pty_by_cmte_id(cmte_id)

	df = pd.read_sql_query(cmte_qry, con=db, index_col=None)

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

	if pid is None or pid is "":
		pid = "MISSING"

	if verbose is True:
		print("[*] found...committee {0:7} - {1:10} is {2}".format(cmte_id, name, pid))

	return pid, cand_id



def get_other_ids_itemized_records(db, cmte_id, cycle=False):

	if cycle is False:
		item_qry = select_other_ids_itemized_records(cmte_id)
	else:
		item_qry = select_other_ids_itemized_records(cmte_id, cycle)

	df = pd.read_sql_query(item_qry, con=db, index_col=None)

	return df["other_id"].tolist()



def id_type(id):
	assert len(str(id)) == 9, (
		"[*] please input a valid committee or candidate id as a string")
	
	if str(id)[0] == "C":
		return "cmte_id"
	else:
		return "cand_id"



def pid_codes(pid):
	pid = str(pid).upper()

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

	if isinstance(pid, tuple) is True:
		pid = pid[0]
		pid = str(pid).upper()
	else:
		pid = str(pid).upper()

	if pid == "REP":
		return 1
	elif pid == "IND":
		return 0
	elif pid == "DEM":
		return -1

	else:
		return np.nan


def select_pids(pid_tuple):

	if isinstance(pid_tuple, tuple) is True:
		pid = pid_tuple[0]
	else:
		pid = pid_tuple

	return pid



def search_party_id(db, cmte_id, cycle=False, recursive=False, levels=False, itemized=False, initial=False):

	np.random.seed(seed=524)

	if initial is True:
		print("[*] searching for political party, committee id: {} in cycle: {}...".format(cmte_id, str(cycle)))

	global counter

	cmte_results = get_pty_by_cmte_id(db, cmte_id)
	pid = cmte_results[0]
	cmte_cand = cmte_results[1]

	#direct cmte id
	if pid_codes(pid) is True:
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
			counter+=1

			if counter > len(first_missing):
				return np.nan


		else:
			first_missing.append(cmte_id)

		if recursive is True:
			pid = get_parties_other_ids(db, cmte_id, cycle, recursive=True)
			return pid
		else:
			results = get_parties_other_ids(db, cmte_id, cycle)
			pid = results[0]
			partisan_score = results[1]
			return pid, partisan_score



def get_parties_other_ids(db, cmte_id, cycle=False, recursive=False, depth=False, itemized=False, verbose=False):

	other_ids = get_other_ids_itemized_records(db, cmte_id, cycle)

	if verbose is True:
		print(other_ids)

	#if requested cycle has no data, get data for all cycles
	if len(other_ids) == 0:
		other_ids = get_other_ids_itemized_records(db, cmte_id)

		#if still no results:
		if len(other_ids) == 0:
			pid = search_party_id(db, cmte_id, levels=True)

			if pid_codes(pid) is False or pid_codes(pid) == "CONTINUE":
				pid = "UNK_OTHER"
				partisan_score = float("{:0.5f}".format(partisan_dummy(pid)))
			else:
				pid = pid
				partisan_score = float("{:0.5f}".format(partisan_dummy(pid)))

			return pid, partisan_score

	else:
		pass

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
			pid = get_pty_by_cand_id(db, oid, cycle)
			pids.append(pid)
			pass



	if recursive is True:
		return pids
	else:
		pids_clean = [select_pids(pid) for pid in pids]
		pids_count = [pid for pid in pids_clean if str(pid) != 'nan']

		if len(pids_count) > 0:
			pid = list(Counter(pids_count).most_common(1))[0][0]
		else:
			pid = "UNK_OTHER"

		binary_pid = [partisan_dummy(pid) for pid in pids_count]
		partisan_score = float("{:0.5f}".format((np.nanmean(binary_pid))))

		if itemized is True:
			return pid
		else:
			return pid, partisan_score



#Local Testing
#df = pd.read_csv("test_cmte.csv", sep="|")
#cols = ['cmte_id', 'cmte_nm', 'tres_nm', 'cmte_st1', 'cmte_st2', 'cmte_city', 'cmte_st', 'cmte_zip', 'cmte_dsgn', 'cmte_tp', 'cmte_pty_affiliation', 'cmte_filing_freq', 'org_tp', 'connected_org_nm', 'cand_id']
#df.columns = cols
#df = df.head(n=25)
#df = df.head(n=150)
#df = df.loc[17:19]
#df = df.loc[df['cmte_id'] == "C00000638"]
#print(df)
#df = df.loc[df['cmte_id'] == "C00009282"]
#df = df.loc[df['cmte_id'] == "C00000422"]




def get_party_ids_scores(df, cycle=2008):

	def pid(cid, cycle):
		global counter 
		global first_missing
		counter = 0
		first_missing = []
		return search_party_id(db, cid, cycle, itemized=True, initial=True)

	df[['party_id', 'partisan_score']] = df['cmte_id'].apply(lambda cid: pid(cid, cycle)).apply(pd.Series)
	df['cycle'] = cycle

	return df


#cycles = [int(year) for year in years]

def test(df, cycles):
	data = pd.DataFrame([])
	for cycle in cycles:
		data = data.append(get_party_ids_scores(df, cycle))
	return data


#dft = test(df, cycles)
#print(dft)

