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