DROP TABLE if exists cand_cmte_link;

CREATE TABLE cand_cmte_link (
	cand_id TEXT NOT NULL,
	cand_election_yr NUMERIC NOT NULL,
	fec_election_yr NUMERIC NOT NULL,
	cmte_id TEXT,
	cmte_tp TEXT,
	cmte_dsgn TEXT,
	linkage_id NUMERIC NOT NULL
);

--CREATE UNIQUE INDEX idx_cand_cmte_link ON cand_cmte_link (linkage_id);
CREATE INDEX idx_cand_cmte_link ON cand_cmte_link (linkage_id);


