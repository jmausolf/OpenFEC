DROP TABLE if exists individual_contributions;

CREATE TABLE individual_contributions (
	cm_id TEXT NOT NULL,
	amendment_ind TEXT,
	report_type TEXT,
	transaction_pgi TEXT,
	image_num TEXT,
	transaction_type TEXT,
	entity_type TEXT,
	name TEXT,
	city TEXT,
	state TEXT,
	zip_code TEXT,
	employer TEXT,
	occupation TEXT,
	transaction_date TEXT,
	transaction_amount TEXT,
	other_id TEXT,
	transaction_id TEXT,
	file_num NUMERIC,
	memo_code TEXT,
	memo_text TEXT,
	sub_id NUMERIC NOT NULL
);

CREATE UNIQUE INDEX idx_individual_contributions ON individual_contributions (sub_id);
