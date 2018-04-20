import wget
import time
import datetime
import subprocess
import pandas as pd
from glob import glob
import re
import zipfile
import os
from setlogger import *
#from config import *

#Get Date for Filenames
now = datetime.datetime.now()
date = now.strftime("%Y-%m-%d")


#################################################
## Functions to Define Download Files
#################################################

def get_download_url(year, type_key):
	base_url = "https://cg-519a459a-0ea3-42c2-b7bc-fa1143481f74.s3-us-gov-west-1.amazonaws.com/bulk-downloads"
	key = "{}{}".format(type_key, year[2:4])
	file = "{}.zip".format(key)
	url = "{}/{}/{}".format(base_url, year, file)

	return [key, url]


def make_download_table_dicts(years, type_key, table_key):
	output = {}

	for year in years:
		key_url = get_download_url(year, type_key)
		key = key_url[0]
		url = key_url[1]
		table = table_key[type_key][0]

		output[key] = [type_key, table, url]
		
	return output


def download_files(years, table_key):
	datasets = []
	for key, value in table_key.items():
		datasets.append(make_download_table_dicts(years, key, table_key))

	return datasets


#################################################
## Functions to Download and Extract Files
#################################################

#Download and Rename Files
def wget_download_rename(key, value):
	try:
		tmp = wget.download(value[2])
		print('\n')
		time.sleep(5)
		ext = tmp.rsplit(".", 1)[1]
		filename = "{}_fec_{}.{}".format(key, date, ext)
		subprocess.call("mv {} {}".format(tmp, filename), shell=True)
	except Exception as e:
		filename = "{}_fec_{}".format(key, date)
		print("[*] Error downloading requested file: {}, error code: {}...".format(filename, e))


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


def extract(type_key, table_key):
	return table_key[type_key][1]


def remove_files(filetype, rmfiles=False):
	if rmfiles is True:
		files = filetype
	else:
		files = glob('*.{}'.format(filetype))
	
	print("[*] removing {} files in 10 seconds, control-c to abort...".format(len(files)))
	time.sleep(10)
	[ os.remove(f) for f in files]


def download(data, tk):
	"""
	requires both requested data and table keys
	:: data: 	a list of data dictionaries, keys, and download urls
				created by the func, download_files(years, table_key)

	:: tk: 		the table_key from config.py, used to specify the 
				file to extract from the download zip file

				both years and table_key are specified in config.py
	"""
	try:
		print("[*] downloading files...")
		[wget_download_rename(k, v) for d in data for k, v in d.items()]
		print("[*] unzipping downloaded files...")
		[unzip_rename(k, 'zip', [extract(k, tk)]) for k, v in tk.items()]
		subprocess.call("bash collect_files.sh", shell=True)
	except Exception as e: 
		print(e)
		pass


#################################################
## Running the Code
#################################################

#datasets = download_files(years, table_key)
#download(datasets, table_key)

#TODO download code for data dict html files
