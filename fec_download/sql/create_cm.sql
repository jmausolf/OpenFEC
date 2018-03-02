DROP TABLE if exists committee_master;

CREATE TABLE committee_master (
	cmte_id TEXT NOT NULL,
	cmte_nm TEXT,
	tres_nm TEXT,
	cmte_st1 TEXT,
	cmte_st2 TEXT,
	cmte_city TEXT,
	cmte_st TEXT,
	cmte_zip TEXT,
	cmte_dsgn TEXT,
	cmte_tp TEXT,
	cmte_pty_affiliation TEXT,
	cmte_filing_freq TEXT,
	org_tp TEXT,
	connected_org_nm TEXT,
	cand_id TEXT
);

CREATE INDEX idx_committee_master ON committee_master (cmte_id);
