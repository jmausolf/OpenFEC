

"""
from _get_individuals.gen_indiv_profiles import *


from _util.util import *
from _build_db.clean_db import *


def gen_indiv_table(db, c):

	#(Clean file to merge, then calc levels, load)
	alter_create_table("schedule_a_cleaned", "individual_partisans", db, c, 
						alter_function=alt_group_indiv, 
						limit=False, 
						chunksize=100000000,
						alt_lim=10000)



gen_indiv_table(db, c)
"""

from _get_individuals.get_indiv import *


gen_indiv_table(db, c)