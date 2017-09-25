from credentials import *
import requests
import json
import csv



def get_url(url):
    data = requests.get(url).json()
    return(data)

def get_pages(data):
    pages = data['pagination']['pages']
    return pages

def get_count(data):
    count = data['pagination']['count']
    return count

def write_csv_json(json_results, filename="jsondata.csv"):

    csv_file = open(filename, 'a')
    csvwriter = csv.writer(csv_file)

    count = 0
    for row in results:
        if count == 0:
            header = row.keys()
            csvwriter.writerow(header)
            count += 1

        csvwriter.writerow(row.values())

    csv_file.close()

    

def get_party_id(committee_id):
    stem = "https://api.open.fec.gov/v1/committee/"
    end = "?employer=Goldman%20Sachs&per_page=100&api_key={}&page={}".format(api_key, page)
    end = "{}/candidates/?sort=name&page=1&api_key=DEMO_KEY&per_page=100".format(committee_id, api_key)
    url = stem+end

    data = get_url(url)
    party_id = data['results'][0]['party']
    office = data['results'][0]['office_full']
    name = data['results'][0]['name']
    print("[*] {}, {}, candidate for {}".format(name, party_id, office))
    return party_id



############################################################################
## STEP 1: Define Companies
############################################################################


############################################################################
## STEP 2: Get All Schedule A for Companies
############################################################################




############################################################################
## STEP 3: Get All Party IDs, Election for Committees on Schedule A
############################################################################
