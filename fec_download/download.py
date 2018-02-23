import wget
import time
import datetime
import subprocess
import pandas as pd
from glob import glob
import re
import zipfile
import os
#from setlogger import *

#Get Date for Filenames
now = datetime.datetime.now()
date = now.strftime("%Y-%m-%d")

#Specify File Key (Source) and Value [download url]
#table name == dictionary name

def get_download_url(year, type_key):
	base_url = "https://cg-519a459a-0ea3-42c2-b7bc-fa1143481f74.s3-us-gov-west-1.amazonaws.com/bulk-downloads"
	key = "{}{}".format(type_key, year[2:4])
	file = "{}.zip".format(key)
	#print(file)
	url = "{}/{}/{}".format(base_url, year, file)
	#print(url)

	return [key, url]



#x = get_download_url("2016", "cm")
#y = get_download_url("2016", "ccl")

#print(x)

def make_download_table_dicts(years, type_key, table_key):
	output = {}

	for year in years:
		key_url = get_download_url(year, type_key)
		key = key_url[0]
		url = key_url[1]
		table = table_key[type_key]

		output[key] = [type_key, table, url]
		
	#print(output)
	return output



table_key = {
	'cm' : 'committee_master',
	'cn' : 'candidate_master',
	'ccl' : 'cand_cmte_link',
	'indiv' : 'individual_contributions'
}


#make_download_table_dicts(['2014', '2016'], "cm", table_key)

#committee_master = make_download_table_dicts(['2014', '2016'], "cm", table_key)

#print(committee_master)

#years = ['2000', '2002', '2004', '2008', '2010', '2012', '2014', '2016']
years = ['2012']

#datasets = [(v = make_download_table_dicts(years, k, table_key)) for k, v in table_key.items()]

#datasets = [print(v, k) for k, v in table_key.items()]

def download_files(years, table_key):
	datasets = []
	for key, value in table_key.items():
		datasets.append(make_download_table_dicts(years, key, table_key))

	return datasets




#Download and Rename Files
def wget_download_rename(key, value):
	#report_type = value[0]
	tmp = wget.download(value[2])
	print('\n')
	time.sleep(5)
	ext = tmp.rsplit(".", 1)[1]
	filename = "{}_fec_{}.{}".format(key, date, ext)
	subprocess.call("mv {} {}".format(tmp, filename), shell=True)


def unzip(zipfilename, subfilename="", rename="", delete=False):
	with zipfile.ZipFile(zipfilename,"r") as zip_ref:
		print("[*] extracting requested subfile: {} from zipfile: {}...".format(subfilename, zipfilename))
		zip_ref.extract(subfilename, ".")
		if rename !="":
			os.rename(subfilename, rename)
		if delete is True:
			print("[*] removing zipfile: {}...".format(zipfilename))
			os.remove(zipfilename)


def unzip_rename(globstem, ext, req_subfiles):
	zip_files = glob('{}*.{}'.format(globstem, ext))
	sub = req_subfiles
	[unzip(z, s, '{}_{}'.format(z.split(".")[0], s.lower()), True) for z in zip_files for s in sub ]

def remove_files(filetype):
	files = glob('*.{}'.format(filetype))
	print("[*] removing {} files in 10 seconds, control-c to abort...".format(len(files)))
	time.sleep(10)
	[ os.remove(f) for f in files]


def download(data):
	print("[*] downloading files...")
	[wget_download_rename(k, v) for d in data for k, v in d.items()]
	print("[*] unzipping downloaded files...")
	unzip_rename('indiv', 'zip', ['itcont.txt'])
	unzip_rename('cm', 'zip', ['cm.txt'])
	unzip_rename('cn', 'zip', ['cn.txt'])
	unzip_rename('ccl', 'zip', ['ccl.txt'])
	subprocess.call("bash collect_files.sh", shell=True)


#Datasets to Download
datasets = download_files(years, table_key)

download(datasets)
