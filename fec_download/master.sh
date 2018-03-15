#Step 0: define years in master config

#Step 1: make committee_master_pids table
python3 make_pids_table.py

#Step 2: download and build main tables from master config
python3 build_db.py -d True -b True

#Step 3: Join tables