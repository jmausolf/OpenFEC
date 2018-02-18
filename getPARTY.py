from setlogger import *
from credentials import *
from getFEC import *

from collections import Counter
import requests
import json, csv
import warnings
import random
import time
import pandas as pd
import numpy as np


def get_api_key(api_keys):
    used = []
    for key in api_keys:
        yield key
        used.append(key)
    while used:
        for key in used:
            yield key

newkey = get_api_key(api_keys)


def first_sample(n, sample_size):
    sample_frame = np.random.choice(n, size=n, replace=False, p=None)
    a = np.random.choice(n, size=sample_size, replace=False, p=None)
    return(sample_frame, a)


def resample_one(first_sample):

    sframe = first_sample[0]
    sample = first_sample[1]

    sframe = np.setdiff1d(sframe, sample)
    sample = np.random.choice(sframe, size=1, replace=False, p=None)

    return(sframe, sample)


def all_samples(n, first_sample_size=3):

    s0 = first_sample(n, first_sample_size)
    sr = s0
    count = len(np.atleast_1d(sr[0]))
    samples = [s0[1].tolist()]

    if n == first_sample_size:
        return(samples)
    else:
        pass

    while len(np.atleast_1d(sr[0])) != 1:
        if count == n:
            s1 = resample_one(s0)
            count -=1
            samples.append(s1[1].tolist())
            sr = (s1)
        else:
            sn = resample_one(sr)
            sr = (sn)
            samples.append(sn[1].tolist())
    else:
        pass

    return(samples)


def get_party_id(committee_id):
    api_key = next(newkey)
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

#C00053553 (NRA is UNKNOWN ALL METHODS)
#print(get_party_id("C00053553"))

def get_committee_details(committee_id):
    api_key = next(newkey)
    stem = "https://api.open.fec.gov/v1/committee/"
    end = "{}/?sort=name&api_key={}&per_page=100&page=1".format(committee_id, api_key)
    url = stem+end

    data = get_url(url)['results']
    party_id = data[0]['party_full']
    candidate_ids = data[0]['candidate_ids']
    return party_id, candidate_ids


def alt_receipt_id(rid, s, sample_frame):
    if rid == None:
        available = s
        next_sample = random.sample(set(sample_frame))
        r_new = r

def get_schedule_b_receipts(committee_id, year=None):
    api_key = next(newkey)
    stem = "https://api.open.fec.gov/v1/committee/{}/schedules/".format(committee_id)
    end = "schedule_b/by_recipient_id/?per_page=20&api_key={}&page=1".format(api_key)

    if year is not None:
        if len(get_url(stem+end+"&cycle={}".format(year))['results']) >0:
            end += "&cycle={}".format(year)
        else:
            pass

    else:
        pass

    url = stem+end


    data = get_url(url)['results']
    if len(data) <= 0:
        warnings.warn('WARNING: get_schedule_b_receipts search by committee id returns no results, try another method')
        return None
    elif len(data) > 0 and len(data) < 3:
        return data[0]['recipient_id']
    elif len(data) > 0 and len(data) >= 3:

        s = all_samples(len(data), 3)

        def get_rid(rid, sample_index=0):
            while rid is None:
                sample_index +=1
                rid = data[s[sample_index][0]]['recipient_id']
            else:
                return rid, sample_index

        r1 = get_rid(data[s[0][0]]['recipient_id'], 0)
        r2 = get_rid(data[s[0][1]]['recipient_id'], r1[1])
        r3 = get_rid(data[s[0][2]]['recipient_id'], r2[1])

        return [r1[0], r2[0], r3[0]]
    else:
        pass

def find_schedule_b_results(committee_ids):
    if type(committee_ids) is list:
        cids = committee_ids
    else:
        cids = [committee_ids]
    assert len(cids) > 0


    if len(cids) == 1:
        party_id = get_committee_details(cids[0])[0]
        return party_id
    else:

        pid_1 = get_committee_details(cids[0])[0]
        pid_2 = get_committee_details(cids[1])[0]
        pid_3 = get_committee_details(cids[2])[0]
        if (pid_1 == pid_2 == pid_3) is True:
            party_id = pid_1
            return party_id
        else:
            party_id = list(Counter([pid_1, pid_2, pid_3]).most_common(1))[0][0]
            return(party_id)

#print(find_schedule_b_results("C00053553"))

def search_party_id(committee_id, year=None):
    try:
        party_results = get_committee_details(committee_id)
        time.sleep(1.5)
        #TODO Add new column if the results are from a PAC or Not
        if party_results[0] is None and len(party_results[1]) == 0:
            print("[*] conducting schedule b search...")
            time.sleep(1)
            schedule_b_receipts = get_schedule_b_receipts(committee_id, year)
            party_id = find_schedule_b_results(schedule_b_receipts)
            time.sleep(1)

        elif party_results[0] is None and len(party_results[1]) > 0:
            print("[*] candidate id exists but no party results")
            party_id = get_party_id(committee_id)
            time.sleep(1)

        elif party_results[0] is not None:
            print("[*] party id found in committee details")
            party_id = party_results[0]
            time.sleep(1)

        else:
            print("[*] pass, unknown results", party_results)
            party_id = "UNKNOWN D"

    except:
        print("[*] unknown error, unknown results", party_results)
        party_id = "ERROR"

    return party_id
#print(search_party_id("C00053553"))

def getPARTY(company):

    company = str(company).replace(" ", "_")
    filenames = glob('downloads/*{}*'.format(company))
    assert len(filenames) == 1, "Only one file expected, check files and perform merge first..."
    
    in_file = filenames[0]
    out_file = in_file.replace(".csv", "_PARTY_IDs.csv")

    df = pd.read_csv(in_file)
    df = df[['committee_id','cycle']].drop_duplicates()
    print("Total unique committee's requested: {}".format(df.shape[0]))
    print("[*] finding party id's for {}, searching for requested committees...".format(company))
    df['party_id'] = np.vectorize(search_party_id)(df['committee_id'], df['cycle'])
    print("[*] writing results to csv...")
    df.to_csv(out_file, index=False)
    return in_file, out_file
 


def merge_contrib_pid(filenames, company=None):
    """
    Requires filenames from getPARTY

    or

    A company and two already generated filenames
    """

    if company is not None:
        company = str(company).replace(" ", "_")
        filenames = glob('downloads/{}__*'.format(company))
        assert len(filenames) == 2, "Two matching files required, check input"
    
    else:
        pass

    out_file = filenames[0].replace(".csv", "_ANALYSIS.csv")  
    df_contrib = pd.read_csv(filenames[0])
    df_pid = pd.read_csv(filenames[1])
    df_merged = pd.merge(df_contrib, df_pid)
    df_merged.to_csv(out_file)
    return out_file


