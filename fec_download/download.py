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

#Get Date for Filenames
now = datetime.datetime.now()
date = now.strftime("%Y-%m-%d")

#Specify File Key (Source) and Value [download url]
#Data Type: Contributions by Individuals
individual = {
	'indiv16' : ['https://cg-519a459a-0ea3-42c2-b7bc-fa1143481f74.s3-us-gov-west-1.amazonaws.com/bulk-downloads/2016/indiv16.zip'],
	'indiv14' : ['https://cg-519a459a-0ea3-42c2-b7bc-fa1143481f74.s3-us-gov-west-1.amazonaws.com/bulk-downloads/2014/indiv14.zip'],
	#'indiv12' : ['https://cg-519a459a-0ea3-42c2-b7bc-fa1143481f74.s3-us-gov-west-1.amazonaws.com/bulk-downloads/2012/indiv12.zip'],
	#'indiv10' : ['https://cg-519a459a-0ea3-42c2-b7bc-fa1143481f74.s3-us-gov-west-1.amazonaws.com/bulk-downloads/2010/indiv10.zip']
}

#Data Type: Committee Master File
committee_master = {
	'cm16' : ['https://cg-519a459a-0ea3-42c2-b7bc-fa1143481f74.s3-us-gov-west-1.amazonaws.com/bulk-downloads/2016/cm16.zip'],
	'cm14' : ['https://cg-519a459a-0ea3-42c2-b7bc-fa1143481f74.s3-us-gov-west-1.amazonaws.com/bulk-downloads/2014/cm14.zip'],
}

#All Reports
datasets = [individual, committee_master]



#Download and Rename Files
def wget_download_rename(key, value):
	#report_type = value[0]
	tmp = wget.download(value[0])
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
	print(zip_files)	
	#name_stem = [n.split(".")[0] for n in zip_files]
	#print(name_stem)
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
	subprocess.call("bash collect_files.sh", shell=True)

download(datasets)
