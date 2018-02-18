from config import *
import logging
import datetime
import subprocess
import os

#Make Log File
subprocess.call("mv *.log logs 2>/dev/null", shell = True)

#Get Date for Filenames
now = datetime.datetime.now()
date = now.strftime("%Y-%m-%d")

#Bash Commands
#commit == git rev-parse HEAD
#branch == git rev-parse --abbrev-ref HEAD
commit = str(subprocess.check_output(["git", "rev-parse", "HEAD"]).strip()).replace("b'", "").replace("'", "")[0:7]
branch = str(subprocess.check_output(["git", "rev-parse", "--abbrev-ref", "HEAD"]).strip()).replace("b'", "").replace("'", "")
ext = "log"

#Logfilename
logfilename = "logs/OpenFEC_report_{}_{}_{}.{}".format(date, branch, commit, ext)

#Set Logger
logging.basicConfig(level=logging.INFO, format='%(message)s')
logger = logging.getLogger()
logger.addHandler(logging.FileHandler(logfilename, 'a'))
print = logger.info

