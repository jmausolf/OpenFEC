--create new table with desired specs
DROP TABLE if exists schedule_a;

CREATE TABLE schedule_a (
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

CREATE UNIQUE INDEX idx_schedule_a ON schedule_a (sub_id);