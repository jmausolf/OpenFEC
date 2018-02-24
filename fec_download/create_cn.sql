DROP TABLE if exists candidate_master;

CREATE TABLE candidate_master (
	cand_id TEXT NOT NULL,
	cand_name TEXT,
	cand_pty_affiliation TEXT,
	cand_election_yr NUMERIC,
	cand_office_st TEXT,
	cand_office TEXT,
	cand_office_district TEXT,
	cand_ici TEXT,
	cand_status TEXT,
	cand_pcc TEXT,
	cand_st1 TEXT,
	cand_st2 TEXT,
	cand_city TEXT,
	cand_st TEXT,
	cand_zip TEXT
);

CREATE INDEX idx_candidate_master ON candidate_master (cand_id);
