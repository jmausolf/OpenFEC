

#cols = ["cmte_id", "amndt_ind", "rpt_tp", "transaction_pgi", "image_num", "transaction_tp", "entity_tp"]
#types = ["TEXT", "TEXT", "TEXT", "TEXT", "TEXT", "TEXT", "TEXT"]
#nulls = ["NOT NULL", "", "", "", "","", ""]



def gen_types(columns, types="TEXT", replace=False, alt_vector=[]):
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

#nulls = gen_nulls(cols, "", [0])
#types = gen_types(cols, replace=[4], alt_vector=["NUMERIC"])
#types = gen_types(cols, "TEXT", [1, 4], ["BOOL", "NUMERIC"])
#types = gen_types(cols, replace=[1, 4], alt_vector=["BOOL", "NUMERIC"])

#nulls = gen_nulls(cols, "NOT NULL", "test")

#TODO
#functions to determine null vector and replace/alt vectors from original table

def create_col_specs(columns, types=False, nulls=False):

	if types is False and nulls is False:
		types = gen_types(columns)
		nulls = gen_nulls(columns)

	create_profile = [columns, types, nulls]
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

def create_value_questions(columns):
	value_questions = ''
	N = len(columns)
	for n in range(0, N):

		if n < N-1:
			q = "    ?,\n"
		elif n == N-1:
			q = "    ?"
		
		value_questions = value_questions+q

	return value_questions



#create table
def make_sql_create_table(table_name, columns, types, nulls, drop=True, index=False, **kwargs):

	lb = '\n'

	#Drop Statement
	drop_statement = "DROP TABLE if exists {};\n".format(table_name)

	#Create Statement
	column_spec = create_col_specs(columns, types, nulls)[0]
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
		index_statement = "CREATE {0} INDEX {1} ON {2} ({3});".format(unique, index_name, table_name, key)+lb

	else:
		index_statement = ''
		pass



	script = "{1}{0}{2}{0}{3}".format(lb, drop_statement, create_statement, index_statement)
	return script


#testing
#make_sql_create_table("test_table2", cols, types, nulls)
#create_sql = make_sql_create_table("test_table_index", cols, types, nulls, index=True, unique=True, key="sub_id")
#print(create_sql)

#TODO save sql scripts as .sql by default

#insert table
def make_sql_insert_table(table_name, columns):

	lb = '\n'

	#Insert Statement - Part 1
	column_spec = create_col_specs(columns)[1]
	insert_start = "INSERT INTO {} (".format(table_name)
	insert_cols = column_spec+lb
	insert_end = "    )"+lb
	insert_statement_pt1 = (insert_start+insert_cols+insert_end)

	#Insert Statement - Part 2, Values
	value_start = "VALUES ("+lb
	value_questions = create_value_questions(columns)+lb
	value_end = ");"+lb
	insert_statement_pt2 = (value_start+value_questions+value_end)

	script = "{1}{2}{0}".format(lb, insert_statement_pt1, insert_statement_pt2)
	return script

#insert_qry = make_sql_insert_table("insert_test", cols)
#print(insert_qry)


def select_schedule_a_by_company_org(company):

	#TODO refine base query and joins
	sql_query = """
	DROP TABLE if exists tmp;

	CREATE TABLE tmp AS
	SELECT 
		individual_contributions.cmte_id, 
		cmte_pty_affiliation, 
		name, 
		employer, 
		transaction_dt,
		transaction_amt,
		file_num,
		cand_id,
		sub_id 
		FROM individual_contributions LEFT JOIN committee_master 
		ON individual_contributions.cmte_id=committee_master.cmte_id
		WHERE employer LIKE "%{}%"
		GROUP BY sub_id;

	""".format(company)

	return sql_query

def select_schedule_a_by_company(company):

	#TODO refine base query and joins
	sql_query = """
		DROP TABLE if exists tmp;

		CREATE TABLE tmp AS
		SELECT 
			--info about individual contributor
			name AS contributor_name, 
			employer AS contributor_employer,
			occupation AS contributor_occupation,
			city AS contributor_city,
			state AS contributor_state,
			zip_code AS contributor_zip_code,

			--individual about cmte
			individual_contributions.cmte_id AS cmte_id,
			cmte_nm,
			cmte_pty_affiliation,
			committee_master.cmte_dsgn AS cmte_dsgn,
			committee_master.cmte_tp AS cmte_type,
			cmte_filing_freq,
			org_tp AS cmte_org_tp,
			connected_org_nm AS cmte_connected_org_nm,

			--info about candidates
			committee_master.cand_id AS cand_id,
			cand_name,
			cand_pty_affiliation,
			cand_cmte_link.cand_election_yr AS cand_election_yr,
			fec_election_yr AS cand_fec_election_yr,
			cand_office,
			cand_pcc,
			linkage_id AS cand_cmte_linkage_id,
			
			--info about contribution
			transaction_dt AS contributor_transaction_dt,
			transaction_amt AS contributor_transaction_amt,
			transaction_pgi AS contributor_transaction_pgi,
			transaction_tp AS contributor_transaction_tp,
			
			
			--other info about contribution
			amndt_ind AS contributor_amndt_ind,
			rpt_tp AS contributor_rpt_tp,
			image_num AS contributor_image_num,
			entity_tp AS contributor_entity_tp,
			other_id AS contributor_other_id,
			tran_id AS contributor_tran_id,
			file_num AS contributor_file_num,
			memo_cd AS contributor_memo_cd,
			memo_text AS contributor_memo_text,
			sub_id
			
			FROM individual_contributions LEFT JOIN committee_master
			ON individual_contributions.cmte_id=committee_master.cmte_id
			
			--FROM committee_master LEFT JOIN cand_cmte_link
			LEFT JOIN cand_cmte_link
			ON committee_master.cand_id=cand_cmte_link.cand_id
			LEFT JOIN candidate_master
			ON cand_cmte_link.cand_id=candidate_master.cand_id

			WHERE employer LIKE "%{}%"
			GROUP BY sub_id;

	""".format(company)

	return sql_query


