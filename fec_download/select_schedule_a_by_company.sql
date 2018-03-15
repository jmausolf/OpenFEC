--create joined table as tmp
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
	WHERE employer LIKE "%Apple%"
	GROUP BY sub_id;



--quality check for duplicate subids
--SELECT sub_id, COUNT(sub_id) FROM tmp GROUP BY sub_id HAVING COUNT(sub_id)>1;

--create new table with desired specs
DROP TABLE if exists cm_indiv1;

CREATE TABLE cm_indiv1 (
	cmte_id TEXT NOT NULL,
	cmte_pty_affiliation TEXT,
	contributor_name TEXT,
	contributor_employer TEXT,
	contributor_transaction_dt TEXT,
	cand_id TEXT,
	transaction_amt TEXT,
	file_num NUMERIC,
	sub_id NUMERIC NOT NULL
);

CREATE UNIQUE INDEX idx_cm_indiv1 ON cm_indiv1 (sub_id);


--insert joined table into new table
INSERT INTO cm_indiv1 (
	cmte_id,
	cmte_pty_affiliation,
	contributor_name,
	contributor_employer,
	contributor_transaction_dt,
	cand_id,
	transaction_amt,
	file_num,
	sub_id
	)
SELECT 
	[individual_contributions.cmte_id],
	cmte_pty_affiliation,
	name,
	employer,
	transaction_dt,
	cand_id,
	transaction_amt,
	file_num,
	sub_id
	FROM tmp;

