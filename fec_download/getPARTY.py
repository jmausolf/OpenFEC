import pandas as pd
import numpy as np
import sqlite3
import signal
import threading
import time
import warnings

#from config import *
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
			pids = df["cand_pty_affiliation"].tolist()
			pid = most_common_pid(pids)
			return pid

	else:

		#sort by date, so most recent are last
		df['cand_election_yr'] = pd.to_numeric(
			df['cand_election_yr'], 
			errors='coerce')
		df.sort_values('cand_election_yr', inplace=True)

		#Get unique pid's (in the event the candidate switches parties)
		pids = df["cand_pty_affiliation"].tolist()

		pid = most_common_pid(pids)
		name = list(Counter(df["cand_name"].tolist()).most_common(1))[0][0]

		if pid is None or pid is "":
			pid = "MISSING"

		if verbose is True:
			print(
				"[*] found...candidate {0:7} - {1:10} is {2}"
				.format(cand_id, name, pid)
				)

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

	try:
		pid = most_common_pid(pids)
		name = list(Counter(df["cmte_nm"].tolist()).most_common(1))[0][0]
	except Exception as e:
		print(e)
		pid = ""
		name = ""


	cand_id = list(Counter(df["cand_id"].tolist()).most_common(1))[0][0]

	if pid is None or pid is "":
		pid = "MISSING"

	if verbose is True:
		print(
			"[*] found...committee {0:7} - {1:10} is {2}"
			.format(cmte_id, name, pid)
			)

	return pid, cand_id



def get_other_ids_itemized_records(db, cmte_id, cycle=False):

	if cycle is False:
		item_qry = select_other_ids_itemized_records(cmte_id)
	else:
		item_qry = select_other_ids_itemized_records(cmte_id, cycle)

	df = pd.read_sql_query(item_qry, con=db, index_col=None)

	return df["other_id"].tolist()



def id_type(_id):
	if len(str(_id)) != 9:
		warnings.warn(
			"[*] committee or candidate id {} may be invalid..."
			.format(_id)
			)

	if str(_id)[0] == "C":
		return "cmte_id"
	else:
		return "cand_id"



def pid_codes(pid):
	pid = str(pid).upper()

	#Major Parties
	if pid == "DEM" or pid == "REP" or pid == "IND":
		return True

	#Major Third Parties
	elif pid == "CON" or pid == "LIB" or pid == "GRE":
		return True


	#Other Parties:
	others = ["ACE", "AKI", "AIC", "AIP", "AMP", "APF", "AE", "CIT", \
		"CMD", "CMP", "COM", "CNC", "CRV", "CST", "COU", "DCG", "DNL", \
		"D/C", "DFL", "DGR", "FED", "FLP", "FRE", "GWP", "GRT", "GR", \
		"HRP", "IDP", "IAP", "ICD", "IGR", "IP", "IDE", "IGD", "JCN", \
		"JUS", "LRU", "LBR", "LFT", "LBL", "LBU", "MTP", "NDP", "NLP", \
		"NA", "NJC", "NPP", "NPA", "NOP", "OE", "PG", "PSL", "PAF", \
		"PFP", "PFD", "POP", "PPY", "PCH", "PPD", "PRO", "NAP", "PRI", \
		"RUP", "REF", "RES", "RTL", "SEP", "SLP", "SUS", "SOC", "SWP", \
		"TX", "TWR", "TEA", "THD", "LAB", "USP", "UST", "UC", "UNI", \
		"VET", "WTP", "W"]

	if pid in others:
		return True


	#Unknown Categories
	elif pid is None:
		return False
	elif pid == "MISSING":
		return False
	elif pid == "UNK_OTHER":
		return False
	elif pid == "NNE" or pid == "UNK":
		return False
	elif pid == "UN" or pid == "NON" or pid == "N" or pid == "OTH":
		return False
	elif pid == "":
		return False
	elif pid == "NAN":
		return False

	#Errors
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

	#major 3rd parties
	elif pid == "CON":
		return 1
	elif pid == "LIB":
		return 0
	elif pid == "GRE":
		return -1

	else:
		return np.nan


def select_pids(pid_tuple):

	if isinstance(pid_tuple, tuple) is True:
		pid = pid_tuple[0]
	else:
		pid = pid_tuple

	return pid


def most_common_pid(pid_list):

	if len(pid_list) >= 2 and len(set(pid_list)) >= 2:

		major_pids = list(Counter(pid_list).most_common(2))
		first_pid = major_pids[0][0]
		second_pid = major_pids[1][0]
		first_count = major_pids[0][1]
		second_count = major_pids[1][1]
		mpid = sorted([first_pid, second_pid])

		#if tied, concat pids, else return most common
		if first_count == second_count:
			pid = "{}_{}".format(mpid[0], mpid[1])
		else:
			pid = list(Counter(pid_list).most_common(1))[0][0]

	else:
		pid = list(Counter(pid_list).most_common(1))[0][0]

	return pid



def search_party_id(
		db, 
		cmte_id, 
		cycle=False, 
		recursive=False, 
		levels=False, 
		itemized=False, 
		initial=False
		):

	np.random.seed(seed=524)

	if initial is True:
		print(
			"[*] searching for party, committee id: {} in cycle: {}..."
			.format(cmte_id, str(cycle))
			)

	global counter

	cmte_results = get_pty_by_cmte_id(db, cmte_id)
	pid = cmte_results[0]
	cmte_cand = cmte_results[1]
  
	#direct cmte id
	if pid_codes(pid) is True:
		if itemized is True:

			#try to get partisan score from itemized contrib
			results = get_parties_other_ids(db, cmte_id, cycle)
			pid = results[0]
			partisan_score = results[1]

			return pid, partisan_score

		else:
			return pid

	#search of candidate ids
	if pid_codes(pid) is not True and len(str(cmte_cand)) == 9:
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
			#partisan_score = float("{:0.5f}".format(partisan_dummy(pid)))
			#return pid, partisan_score
			pass

	#itemized search of other ids
	if pid_codes(pid) is not True and len(str(cmte_cand)) <= 9:
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



def get_parties_other_ids(
		db, 
		cmte_id, 
		cycle=False, 
		recursive=False, 
		depth=False, 
		itemized=False, 
		verbose=False
		):

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
		pids_count = [str(pid).upper() for pid in pids_clean \
			 if str(pid) != 'nan']

		if len(pids_count) > 0:
			pid = most_common_pid(pids_count)

		else:
			pid = "UNK_OTHER"

		binary_pid = [partisan_dummy(pid) for pid in pids_count]
		partisan_score = float("{:0.5f}".format((np.nanmean(binary_pid))))

		if itemized is True:
			return pid
		else:
			return pid, partisan_score



#Local Testing

#id error
#C00005173
#C0009
#C00538835
#C00000547

"""
global counter 
global first_missing
counter = 0
first_missing = []
#x = search_party_id(db, "C00068353", 2008, itemized=True, initial=True)
#x = search_party_id(db, "C00509836", 2008, itemized=True, initial=True)
#x = search_party_id(db, "C00505529", 2012, itemized=True, initial=True)
#x = search_party_id(db, "C00000638", 2008, itemized=True, initial=True)
#x = search_party_id(db, "C00446518", 2008, itemized=True, initial=True)
#print(x)


print("Starting test1")
test1 = ["C00068353", "C00257642", "C00279273", "C00279315", "C00280206", "C00305110", "C00309419", "C00358895", "C00397216", "C00446518"]
for test in test1:
	x = search_party_id(db, test, 2008, itemized=True, initial=True)
	print(x)

#x = get_pty_by_cand_id(db, "P20000527", 2008)
#print(x)


print("Starting test2")
test2 = ["C00397679", "C00368183", "C00430694"]
for test in test2:
	x = search_party_id(db, test, 2008, itemized=True, initial=True)
	print(x)



print("Starting test3")
test3 = ["C00006486", "C00007658", "C00010603", "C00016899", "C00017830", "C00019075", "C00019331", "C00023838"]
for test in test3:
	x = search_party_id(db, test, 2008, itemized=True, initial=True)
	print(x)

"""




#mean of empty slice: C00001347
#errors are when all the ids are unknown or 
#other and no party is associated with them in the id's
#x = search_party_id(db, "C00001347", 2012, itemized=True, initial=True)
#print(x)

#test lib, green, const parties
#x = search_party_id(db, "C00000992", 2012, itemized=True, initial=True)
#print(x)

def get_party_ids_scores(df, cycle=2008):

	def pid(cid, cycle):
		global counter 
		global first_missing
		counter = 0
		first_missing = []
		return search_party_id(db, cid, cycle, itemized=True, initial=True)

	df[['party_id', 'partisan_score']] = df['cmte_id'].apply(
		lambda cid: pid(cid, cycle)).apply(pd.Series)
	df['cycle'] = cycle

	return df




