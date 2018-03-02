

cols = ["cmte_id", "amndt_ind", "rpt_tp", "transaction_pgi", "image_num", "transaction_tp", "entity_tp"]
#types = ["TEXT", "TEXT", "TEXT", "TEXT", "TEXT", "TEXT", "TEXT"]
#nulls = ["NOT NULL", "", "", "", "","", ""]


def gen_types(columns, types="TEXT", replace=False, alt_vector=[]):
	#return ["{}".format(types) for c in columns]

	type_vector = ["{}".format(types) for c in columns]

	if replace is not False:
		assert type(replace) is list, "ERROR: please pass a replace vector as a list"
		assert type(alt_vector) is list, "ERROR: please pass an alternative type vector as a list"
		assert len(replace) == len(alt_vector), "ERROR: replace vector and alt vector different lengths"

		count = -1
		for position in replace:
			count+=1
			type_vector[position] = alt_vector[count]

	return type_vector

def gen_nulls(columns, nulls="", replace=False, alt="NOT NULL"):
	null_vector = ["{}".format(nulls) for c in columns]

	if replace is not False:
		assert type(replace) is list, "ERROR: please pass a replace vector as a list"
		
		for position in replace:
			null_vector[position] = alt

	return null_vector


#types = gen_types(cols)
#nulls = gen_nulls(cols)

#nulls = gen_nulls(cols, "", [0, 3, 5])
nulls = gen_nulls(cols, "", [0])

types = gen_types(cols, replace=[4], alt_vector=["NUMERIC"])
#types = gen_types(cols, "TEXT", [1, 4], ["BOOL", "NUMERIC"])
#types = gen_types(cols, replace=[1, 4], alt_vector=["BOOL", "NUMERIC"])

#nulls = gen_nulls(cols, "NOT NULL", "test")

#TODO
#functions to determine null vector and replace/alt vectors from original table

def create_col_specs(columns='', types='', nulls=False):

	create_profile = [cols, types, nulls]
	cp = create_profile
	create_col_spec = ''
	insert_col_spec = ''

	N = len(cp[0])
	for n in range(0, N):

		if n < N-1:
			create_col = "    {} {} {},".format(cp[0][n], cp[1][n], cp[2][n])
			create_col = create_col.replace(" ,", ",")
			insert_col = "    {},".format(cp[0][n])
		elif n == N-1:
			create_col = "    {} {} {}".format(cp[0][n], cp[1][n], cp[2][n])
			insert_col = "    {}".format(cp[0][n])
		else:
			pass

		create_col_spec = '\n'.join([create_col_spec, create_col])
		insert_col_spec = '\n'.join([insert_col_spec, insert_col])


	return create_col_spec, insert_col_spec



#create table
def sql_script_create_table(table_name, columns, types, nulls, drop=True, index=False, **kwargs):

	lb = '\n'

	#Drop Statement
	drop_statement = "DROP TABLE if exists {};\n".format(table_name)

	#Create Statement
	column_spec = create_col_specs(cols, types, nulls)[0]
	create_start = "CREATE TABLE {} (".format(table_name)
	create_cols = column_spec+lb
	create_end = ");"+lb
	create_statement = (create_start+create_cols+create_end)


	#Key Statement
	if index is True:

		assert kwargs['unique'] and kwargs['key'], "ERROR: please provide two keyword arguments: indicate unique=True/False and key=<table_key>"

		index_name = "idx_{}".format(table_name)
		if kwargs['unique'] is True:
			unique = "UNIQUE"
		else:
			unique = ""

		key = kwargs['key']

		index_statement = "CREATE {0} INDEX {1} ON {2} ({3});".format(unique, index_name, table_name, key)



	else:
		index_statement = ''
		pass



	script = "{1}{0}{2}{0}{3}".format(lb, drop_statement, create_statement, index_statement)
	print(script)



#testing
#sql_script_create_table("test_table2", cols, types, nulls)
sql_script_create_table("test_table_index", cols, types, nulls, index=True, unique=True, key="sub_id")




