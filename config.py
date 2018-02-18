import datetime
import subprocess

#Get Date for Filenames
now = datetime.datetime.now()
date = now.strftime("%Y-%m-%d")

#Bash Commands
#commit == git rev-parse HEAD
#branch == git rev-parse --abbrev-ref HEAD
commit = str(subprocess.check_output(["git", "rev-parse", "HEAD"]).strip()).replace("b'", "").replace("'", "")[0:7]
branch = str(subprocess.check_output(["git", "rev-parse", "--abbrev-ref", "HEAD"]).strip()).replace("b'", "").replace("'", "")
ext = "log"

#Export Logfilename
logfilename = "OpenFEC_report_{}_{}_{}.{}".format(date, branch, commit, ext)
