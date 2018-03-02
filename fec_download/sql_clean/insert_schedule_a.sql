--insert joined table into new table
INSERT INTO schedule_a (
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

