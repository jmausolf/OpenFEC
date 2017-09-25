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
    for row in json_results:
        if count == 0:
            header = row.keys()
            csvwriter.writerow(header)
            count += 1

        csvwriter.writerow(row.values())

    csv_file.close()


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


def get_schedule_a_employer_year(employer, api_key, year=2016):
    firm = employer.replace(" ", "%20")


    url = req_url_schedule_a(firm, api_key, year)
    data = get_url(url)

    pages = get_pages(data)
    for page in range(1, pages+1):
        print("[*] getting FEC SCHEDULE A results for {} in {}...page {} of {}".format(employer, year, page, (pages)))
        filename = "{}_{}_schedule_a.csv".format(year, employer.replace(" ", "_"))
        url = req_url_schedule_a(firm, api_key, year, page)
        page_data = get_url(url)
        results = page_data['results']
        write_csv_json(results, filename)


############################################################################
## STEP 1: Define Companies
############################################################################


############################################################################
## STEP 2: Get All Schedule A for Companies
############################################################################




############################################################################
## STEP 3: Get All Party IDs, Election for Committees on Schedule A
############################################################################


############################################################################
## STEP 4: Merge Data
############################################################################
