DROP TABLE if exists operating_expenditures;

CREATE TABLE operating_expenditures (
	cmte_id TEXT NOT NULL,
	amndt_ind TEXT,
	rpt_yr NUMERIC,
	rpt_tp TEXT,
	image_num TEXT,
	line_num TEXT,
	form_tp_cd TEXT,
	sched_tp_cd TEXT,
	name TEXT,
	city TEXT,
	state TEXT,
	zip_code TEXT,
	transaction_dt TEXT,
	transaction_amt TEXT,
	transaction_pgi TEXT,
	purpose TEXT,
	category TEXT,
	category_desc TEXT,
	memo_cd TEXT,
	memo_text TEXT,
	entity_tp TEXT,
	sub_id NUMERIC NOT NULL,
	file_num NUMERIC,
	tran_id TEXT,
	back_ref_tran_id TEXT,
	unknown_column TEXT
);

CREATE UNIQUE INDEX idx_operating_expenditures ON operating_expenditures (sub_id);

