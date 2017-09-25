from credentials import *
import requests
import json, csv
import warnings

from getFEC import *


def get_party_id(committee_id):
    stem = "https://api.open.fec.gov/v1/committee/"
    end = "{}/candidates/?sort=name&page=1&api_key={}&per_page=100".format(committee_id, api_key)
    url = stem+end

    data = get_url(url)['results']
    if len(data) <= 0:
        warnings.warn('WARNING: get_party_id search by committee id returns no results, try another method')
        return ("UNKNOWN PARTY ID")
    else:
        party_id = data[0]['party_full']
        return party_id


def get_committee_details(committee_id):
    stem = "https://api.open.fec.gov/v1/committee/"
    end = "{}/?sort=name&api_key={}&per_page=100&page=1".format(committee_id, api_key)
    url = stem+end

    data = get_url(url)['results']
    party_id = data[0]['party_full']
    candidate_ids = data[0]['candidate_ids']
    #office = data[0]['office_full']
    #name = data[0]['name']
    #return data[0]['party']
    return party_id, candidate_ids

def get_schedule_b_receipts(committee_id):
    stem = "https://api.open.fec.gov/v1/committee/{}/schedules/".format(committee_id)
    end = "schedule_b/by_recipient_id/?per_page=20&api_key={}&page=1".format(api_key)
    url = stem+end

    data = get_url(url)['results']
    if len(data) <= 0:
        warnings.warn('WARNING: get_schedule_b_receipts search by committee id returns no results, try another method')
        return None
    elif len(data) > 0 and len(data) < 3:
        return data[0]['recipient_id']
    elif len(data) > 0 and len(data) >= 3:
        #receipts
        r1 = data[0]['recipient_id']
        r2 = data[1]['recipient_id']
        r3 = data[2]['recipient_id']
        return [r1, r2, r3]
    else:
        pass

def find_schedule_b_results(committee_ids):
    if type(committee_ids) is list:
        cids = committee_ids
    else:
        cids = [committee_ids]
    assert len(cids) > 0

    if len(cids) == 1:
        #print(cids)
        party_id = get_committee_details(cids[0])[0]
        return party_id
    else:

        pid_1 = get_committee_details(cids[0])[0]
        pid_2 = get_committee_details(cids[1])[0]
        pid_3 = get_committee_details(cids[2])[0]
        #print(pid_1, pid_2, pid_3)
        if (pid_1 == pid_2 == pid_3) is True:
            party_id = pid_1
            return party_id
        else:
            return "UNCLEAR Schedule B Party ID"


def search_party_id(committee_id):

    party_results = get_committee_details(committee_id)

    if party_results[0] is None and len(party_results[1]) == 0:
        #print("no party results, further_tests_needed", party_results)
        #print("[*] conducting schedule b search...")
        schedule_b_receipts = get_schedule_b_receipts(committee_id)
        party_id = find_schedule_b_results(schedule_b_receipts)
        return party_id

    elif party_results[0] is None and len(party_results[1]) > 0:
        #print("candidate id exists but no party results", party_results)
        #try get_party_id search
        party_id = get_party_id(committee_id)
        return party_id

    elif party_results[0] is not None:
        #print("party id found in committee details: ", party_results)
        party_id = party_results[0]
        return party_id

    else:
        #print("pass, unknown results", party_results)
        party_id = "UNKNOWN D"
        return party_id

test_ids = ["C00401224", "C00000935", "C00464297", "C00571380"]
#test_manual_inf = ["dem pac", "dem comm", "rep can", "rep pac"]
for cid  in test_ids:
    party_id = search_party_id(cid)
    print(party_id)
