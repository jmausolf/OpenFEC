from credentials import *
import requests
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util.retry import Retry
import json
import csv
from glob import glob
import pandas as pd
import warnings
import os, time
from random import random


##############################################################
## helper functions
##############################################################

def requests_retry_session(
    retries=3,
    backoff_factor=0.3,
    status_forcelist=(500, 502, 504),
    session=None,
):
    session = session or requests.Session()
    retry = Retry(
        total=retries,
        read=retries,
        connect=retries,
        backoff_factor=backoff_factor,
        status_forcelist=status_forcelist,
    )
    adapter = HTTPAdapter(max_retries=retry)
    session.mount('http://', adapter)
    session.mount('https://', adapter)
    return session

def get_url(url):
    data = requests_retry_session().get(url, timeout=5).json()
    #data = requests.get(url).json()
    return(data)

def get_pages(data):
    pages = data['pagination']['pages']
    return pages

def get_count(data):
    count = data['pagination']['count']
    pages = data['pagination']['pages']
    print("[*] Total expected results: {}".format(count))
    print("[*] Total expected rows: {}".format(count-pages))
    return count

def get_last_index_contrib(data):
    last_index = data['pagination']['last_indexes']['last_index']
    last_contrib = data['pagination']['last_indexes']['last_contribution_receipt_date']
    return [last_index, last_contrib]

def get_last_index_contrib(data):
    try:
        last_index = data['pagination']['last_indexes']['last_index']
        last_contrib = data['pagination']['last_indexes']['last_contribution_receipt_date']
        return [last_index, last_contrib]
    except:
        last_index = data['pagination']['last_indexes']['last_index']
        print(data['pagination']['last_indexes'])
        return [last_index, last_index]

def still_results(data):
    results = data['results']
    return len(results)

##############################################################
## query functions
##############################################################

def req_start_url_schedule_a(employer, year):
    api_key = next(newkey)
    firm = employer.replace(" ", "%20")
    url = "https://api.open.fec.gov/v1/schedules/schedule_a/"+\
        "?sort=contribution_receipt_date"+\
        "&per_page=100"+\
        "&contributor_type=individual"+\
        "&is_individual=true"+\
        "&contributor_employer={}".format(firm)+\
        "&two_year_transaction_period={}".format(year)+\
        "&api_key={}".format(api_key)
    return url

def replacement_url_schedule_a(start_url):
    api_key = next(newkey)
    replacement_url_start = start_url.split("&api_key=")[0]+"&api_key={}".format(api_key)
    return replacement_url_start

def req_loop_url_schedule_a(start_url, last_indexes):
    """
    ::start_url = schedule_a url created by req_start_url_schedule_a
    ::last_indexes: a list including the following:
            'last_index' returned from the prior url
            'last_contribution_receipt_date' from prior url
    """

    end = "&last_index={}&last_contribution_receipt_date={}".format(last_indexes[0], last_indexes[1])
    url = start_url+end
    print(url)
    return url


##############################################################
## writing results
##############################################################


def write_csv_json_dict(json_results, filename="jsondata.csv"):
    with open(filename, 'w') as csvfile:
        writer = csv.DictWriter(csvfile, json_results[0].keys())
        count = 0
        for row in json_results:
            if count == 0:
                writer.writeheader()
                count += 1
            else:
                writer.writerow(row)
        csvfile.close()


##############################################################
## get FEC loop
##############################################################

def get_schedule_a_employer_year(employer, year):
    api_key = next(newkey)
    start_url = req_start_url_schedule_a(employer, year)
    #print(start_url)
    data = get_url(start_url)
    get_count(data)
    if still_results(data) <= 0:
        warnings.warn('WARNING: no data found for requested year')
        return


    #Repeated Internal Function
    def write_json_to_csv():
        print("[*] getting FEC SCHEDULE A results for {} in {}...page {} of {}".format(employer, year, page, (pages)))
        filename = "{}_{}_schedule_a_{}.csv".format(year, employer.replace(" ", "_"), page)
        write_csv_json_dict(data['results'], filename)

    #Looping
    page = 1
    pages = get_pages(data)
    results_count = still_results(data)
    last_indexes = get_last_index_contrib(data)

    #First Page
    write_json_to_csv()

    count = 0

    while results_count > 0:
        time.sleep(1.5)
        page +=1
        #Last Indexes From the Most Recent Data
        #TODO There seem to be inconsistencies on the last page of some company year, like walmart 2012. Try /except this
        
        base_sleep_time = 1
        attempts = 4

        try:
            last_indexes = get_last_index_contrib(data)
            start_url = req_start_url_schedule_a(employer, year)
            next_url = req_loop_url_schedule_a(start_url, last_indexes)
            #print(next_url)
            data = get_url(next_url)
            results_count = still_results(data)
            #test failure
            #if count<5:
            #    count+=1
            #    len(x)
            #else:
            #    pass


        except:
            for attempt in range(1, attempts+1):
                try:
                    if attempt<attempts:
                        count+=1
                        #print(count)
                        print("[*] ERROR there may still be api results...attempt {}".format(attempt))
                        time.sleep(pow(2, attempt) * base_sleep_time * random())
                        last_indexes = get_last_index_contrib(data)

                        #Try new API KEY
                        start_url = req_start_url_schedule_a(employer, year)
                        new_start_url = replacement_url_schedule_a(start_url)
                        next_url = req_loop_url_schedule_a(new_start_url, last_indexes)
                        print(next_url)
                        data = get_url(next_url)
                        results_count = still_results(data)
                        if results_count > 0:
                            break
                    else:
                        print(next_url)
                        print("[*] FINAL ERROR: there may still be api results, check count...")
                        pass
                except:
                    print("[*] OTHER ERROR: there may still be api results, check count...")
                    try:
                        print("Results: {}".format(still_results(data)))
                    finally:
                        if page < pages:
                            break
                        else:
                            return

        try:
            if results_count > 0:
                write_json_to_csv()
            else:
                pass
        except:
            if results_count <= 0:
                pass
            else:
                print("[*] ERROR: there are still api results, unknown error in writing json...")
                break

    else:
        if page < pages:
            print(next_url)
        print("[*] SUCCESS: collected all api results requested.")
        pass

##############################################################
## post download processing
##############################################################

def ren_cols(df, string):
    df.columns = ['{}{}'.format(string, x) for x in df.columns]
    return(df)

def map_dict_col(var, df, ren=None):
    """
    ## Maps a col containing dict or json to seperate columns
    ## Expected variable cell: '{u'key': u'value', u'key': u'value'}
    ## To rename the dict/json keys being mapped, specify a ren string
    """
    s = df[var].map(eval)

    if ren is not None:
        s = s.apply(pd.Series)
        s = ren_cols(s, str(ren))
        df = pd.concat([df.drop([var], axis=1), s], axis=1)

    else:
        df = pd.concat([df.drop([var], axis=1), s.apply(pd.Series)], axis=1)

    return df

def list_to_str(var, df):
    s = df[var].apply(lambda x : str(x) if type(x) is list else x)
    s.name = var
    df = pd.concat([df.drop([var], axis=1), s], axis=1)
    return df

def list_vars_to_str(df, *args):
    for arg in args:
        df = list_to_str(arg, df)

    return df



def dedupe_merged_csvs(company, column=None):
    company = str(company).replace(" ", "_")
    file_type = "{}".format(company)
    filenames = glob('*{}*'.format(file_type))
    outfile_name = "{}__merged_deduped.csv".format(company)
    

    assert len(filenames) > 0, "No matching file types, check filename input"
    print("[*] collapsing {} csv files...".format(len(filenames)))
    combined_csv = pd.concat( [ pd.read_csv(f) for f in filenames ] )
    print("[*] original combined size: {} results".format(combined_csv.shape[0]))
    
    #TODO Json to columns
    combined_csv = map_dict_col('committee', combined_csv, "cd_")
    combined_csv = list_vars_to_str(combined_csv, 'cd_candidate_ids', 'cd_cycles')


    if column is not None:
        df = combined_csv.drop(column, axis=1)
    else:
        df = combined_csv

    dedupe_csv = df.drop_duplicates()
    dedupe_csv.to_csv(outfile_name, index=False)
    print("[*] outfile size: {} results".format(dedupe_csv.shape[0]))
    print("[*] done")
    return [outfile_name, dedupe_csv.shape, filenames]

#dedupe_merged_csvs('Goldman Sachs')

def collapse_csvs(company, schedule_type, year=None, name=""):

    schedule_type = str(schedule_type).replace(" ", "_")    
    
    #all schedule files (all companies, all years)
    if company == None and year is None:
        print("A")
        file_type = "{}".format(schedule_type)
        filenames = glob('*{}*'.format(file_type))
        outfile_name = "{}__merged{}.csv".format(schedule_type, name)     
    
    #all schedule, for company X in all years
    elif company is not None and year is None:
        company = str(company).replace(" ", "_")
        print("B")
        file_type = "{}__{}".format(company, schedule_type)
        print(file_type)
        filenames = glob('*{}*'.format(file_type))
        outfile_name = "{}__{}__merged{}.csv".format(company, schedule_type, name)
    
    #all schedule, for company X in year Y
    else:
        company = str(company).replace(" ", "_")
        print("C")
        file_type = "{}_{}_{}".format(year, company, schedule_type)
        filenames = glob('*{}*'.format(file_type))
        outfile_name = "{}__{}__{}_merged{}.csv".format(year, company, schedule_type, name)


    assert len(filenames) > 0, "No matching file types, check filename input"
    print("[*] collapsing {} csv files...".format(len(filenames)))
    df = pd.concat( [ pd.read_csv(f) for f in filenames ] )
    print("[*] original combined size: {} results".format(df.shape[0]))

    #TODO 
    #Expand Committee Column Details and Rename 'cd_'
    df = map_dict_col('committee', df, "cd_")
    df = list_vars_to_str(df, 'cd_candidate_ids', 'cd_cycles')

    #TODO get drop duplicates working again
    dedupe_csv = df.drop_duplicates()
    dedupe_csv.to_csv(outfile_name, index=False)
    print("[*] outfile size: {} results".format(dedupe_csv.shape[0]))
    print("[*] done")
    return [outfile_name, dedupe_csv.shape, filenames]

#collapse_csvs('Goldman Sachs', 'schedule a', None, "_test")


def remove_files(collapse_signature):
    if pd.read_csv(str(collapse_signature[0])).shape == collapse_signature[1]:
        print("[*] infile matches output signature")
        print("[*] removing {} files in 10 seconds, control-c to abort...".format(len(collapse_signature[2])))
        time.sleep(10)
        [ os.remove(f) for f in collapse_signature[2]]
    else:
        return

