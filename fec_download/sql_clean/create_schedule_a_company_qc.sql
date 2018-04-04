--create new table with desired specs
DROP TABLE if exists schedule_a_cleaned;

CREATE TABLE schedule_a_cleaned (
			--info about individual contributor
			contributor_name TEXT, 
			contributor_employer TEXT,
			contributor_occupation TEXT,
			contributor_city TEXT,
			contributor_state TEXT,
			contributor_zip_code TEXT,
			contributor_cycle TEXT,

			--individual about cmte
			cmte_id TEXT NOT NULL,
			cmte_nm TEXT,
			cmte_pty_affiliation TEXT,
			cmte_dsgn TEXT,
			cmte_type TEXT,
			cmte_filing_freq TEXT,
			cmte_org_tp TEXT,
			cmte_connected_org_nm TEXT,

			--info about cmte parties
			party_id TEXT,
			partisan_score NUMERIC,
			cmte_cycle TEXT,

			--info about candidates
			cand_id TEXT,
			cand_name TEXT,
			cand_pty_affiliation TEXT,
			cand_election_yr NUMERIC,
			cand_fec_election_yr NUMERIC,
			cand_office TEXT,
			cand_pcc TEXT,
			cand_cmte_linkage_id TEXT,
			
			--info about contribution
			contributor_transaction_dt TEXT,
			contributor_transaction_amt TEXT,
			contributor_transaction_pgi TEXT,
			contributor_transaction_tp TEXT,
			
			
			--other info about contribution
			contributor_amndt_ind TEXT,
			contributor_rpt_tp TEXT,
			contributor_image_num TEXT,
			contributor_entity_tp TEXT,
			contributor_other_id TEXT,
			contributor_tran_id TEXT,
			contributor_file_num NUMERIC,
			contributor_memo_cd TEXT,
			contributor_memo_text TEXT,
			sub_id NUMERIC NOT NULL,

			--requested company
			--added to tmp after its creation
			cid TEXT,

			--qc cleaning cols
			contributor_employer_clean TEXT,
			contributor_occupation_clean TEXT,
			emp_count NUMERIC,
			occ_count NUMERIC,
			cid_valid TEXT,
			executive TEXT,
			director TEXT,
			manager TEXT,
			rank_emp NUMERIC,
			rank_occ NUMERIC
			
);

CREATE UNIQUE INDEX idx_schedule_a_cleaned ON schedule_a_cleaned (sub_id);