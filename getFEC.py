from credentials import *
import requests
import json
import csv
from glob import glob
import pandas as pd
import warnings
import os, time

def get_url(url):
    data = requests.get(url).json()
    return(data)

def get_pages(data):
    pages = data['pagination']['pages']
    return pages

def get_count(data):
    count = data['pagination']['count']
    return count

def get_last_index_contrib(data):
    last_index = data['pagination']['last_indexes']['last_index']
    last_contrib = data['pagination']['last_indexes']['last_contribution_receipt_date']
    return [last_index, last_contrib]

def still_results(data):
    results = data['results']
    return len(results)



def write_csv_json(json_results, filename="jsondata.csv"):
    csv_file = open(filename, 'w')
    csvwriter = csv.writer(csv_file)
    count = 0
    for row in json_results:
        if count == 0:
            header = row.keys()
            csvwriter.writerow(header)
            count += 1
        csvwriter.writerow(row.values())
    csv_file.close()


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


def get_party_id_det(committee_id):
    stem = "https://api.open.fec.gov/v1/committee/"
    end = "{}/candidates/?sort=name&page=1&api_key=DEMO_KEY&per_page=100".format(committee_id, api_key)
    url = stem+end

    data = get_url(url)
    party_id = data['results'][0]['party']
    office = data['results'][0]['office_full']
    name = data['results'][0]['name']
    print("[*] {}, {}, candidate for {}".format(name, party_id, office))
    return party_id


def req_url_schedule_a(employer, api_key, year=2016, page=1):
    firm = employer.replace(" ", "%20")
    stem = "https://api.open.fec.gov/v1/schedules/schedule_a/?per_page=100&sort=contribution_receipt_date&"
    end = "contributor_employer={}&api_key={}&two_year_transaction_period={}&page={}".format(firm, api_key, year, page)
    url = stem+end
    return url

def req_start_url_schedule_a(employer, year, api_key=api_key):
    firm = employer.replace(" ", "%20")
    url = "https://api.open.fec.gov/v1/schedules/schedule_a/?sort=contribution_receipt_date&per_page=100&"+\
    "contributor_employer={}&two_year_transaction_period={}&api_key={}".format(firm, year, api_key)
    return url

def req_loop_url_schedule_a(start_url, last_indexes):
    """
    ::start_url = schedule_a url created by req_start_url_schedule_a
    ::last_indexes: a list including the following:
            'last_index' returned from the prior url
            'last_contribution_receipt_date' from prior url
    """

    end = "&last_index={}&last_contribution_receipt_date={}".format(last_indexes[0], last_indexes[1])
    url = start_url+end
    return url


def get_schedule_a_employer_year(employer, year, api_key=api_key):
    start_url = req_start_url_schedule_a(employer, year, api_key)
    data = get_url(start_url)
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

    while results_count > 0:
        page +=1
        #Last Indexes From the Most Recent Data
        last_indexes = get_last_index_contrib(data)
        next_url = req_loop_url_schedule_a(start_url, last_indexes)
        data = get_url(next_url)
        results_count = still_results(data)
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
        print("[*] SUCCESS: collected all api results requested.")
        pass


def collapse_csvs(company, schedule_type, year=None):
    company = str(company).replace(" ", "_")
    schedule_type = str(schedule_type).replace(" ", "_")

    if year is None:
        file_type = "{}_{}".format(company, schedule_type)
        filenames = glob('*{}*'.format(file_type))
        outfile_name = "{}__{}__merged.csv".format(company, schedule_type)
    else:
        file_type = "{}_{}_{}".format(year, company, schedule_type)
        filenames = glob('*{}*'.format(file_type))
        outfile_name = "{}__{}__{}_merged.csv".format(year, company, schedule_type)

    assert len(filenames) > 0, "No matching file types, check filename input"
    print("[*] collapsing {} csv files...".format(len(filenames)))
    combined_csv = pd.concat( [ pd.read_csv(f) for f in filenames ] )
    dedupe_csv = combined_csv.drop_duplicates()
    dedupe_csv.to_csv(outfile_name, index=False)
    print("[*] done")
    return [outfile_name, dedupe_csv.shape, filenames]


def remove_files(collapse_signature):
    if pd.read_csv(str(collapse_signature[0])).shape == collapse_signature[1]:
        print("[*] infile matches output signature")
        print("[*] removing {} files in 5 seconds, control-c to abort...".format(len(collapse_signature[2])))
        time.sleep(5)
        [ os.remove(f) for f in collapse_signature[2]]
    else:
        return

#TODO Integrate Party ID Assignments with Spreadsheets

############################################################################
## STEP 1: Define Companies
############################################################################

companies = ["Walmart", "Exxon Mobile", "Goldman Sachs", "Apple", "Berkshire Hathaway", "Amazon", "Boeing"]
years = ["2016", "2012", "2008", "2004", "2000", "1996", "1992", "1988", "1984"]

for company in companies:
    for year in years:
        print(company, year)
        get_schedule_a_employer_year(company, year)
        collapse_signature = collapse_csvs(company, "schedule a", year)
        remove_files(collapse_signature)




############################################################################
## STEP 2: Get All Schedule A for Companies
############################################################################




############################################################################
## STEP 3: Get All Party IDs, Election for Committees on Schedule A
############################################################################


############################################################################
## STEP 4: Merge Data
############################################################################
