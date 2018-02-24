DROP TABLE if exists committee_contributions;

CREATE TABLE committee_contributions (
	cmte_id TEXT NOT NULL,
	amndt_ind TEXT,
	rpt_tp TEXT,
	transaction_pgi TEXT,
	image_num TEXT,
	transaction_tp TEXT,
	entity_tp TEXT,
	name TEXT,
	city TEXT,
	state TEXT,
	zip_code TEXT,
	employer TEXT,
	occupation TEXT,
	transaction_dt TEXT,
	transaction_amt TEXT,
	other_id TEXT,
	cand_id TEXT,
	tran_id TEXT,
	file_num NUMERIC,
	memo_cd TEXT,
	memo_text TEXT,
	sub_id NUMERIC NOT NULL
);

CREATE UNIQUE INDEX idx_committee_contributions ON committee_contributions (sub_id);

