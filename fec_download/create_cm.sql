DROP TABLE if exists committee_master;

CREATE TABLE committee_master (
	cm_id TEXT NOT NULL,
	cm_name TEXT,
	treasurer_name TEXT,
	cm_street1 TEXT,
	cm_street2 TEXT,
	cm_city TEXT,
	cm_state TEXT,
	cm_zip TEXT,
	cm_desig TEXT,
	cm_type TEXT,
	cm_party TEXT,
	cm_filing_freq TEXT,
	org_cat TEXT,
	connected_org_name TEXT,
	cand_id TEXT
	);

CREATE UNIQUE INDEX idx_committee_master ON committee_master (cm_id);
