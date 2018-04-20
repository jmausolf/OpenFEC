--insert joined table into new table
INSERT INTO schedule_a_cleaned (
			--info about individual contributor
			contributor_name, 
			contributor_employer,
			contributor_occupation,
			contributor_city,
			contributor_state,
			contributor_zip_code,
			contributor_cycle,

			--individual about cmte
			cmte_id,
			cmte_nm,
			cmte_pty_affiliation,
			cmte_dsgn,
			cmte_type,
			cmte_filing_freq,
			cmte_org_tp,
			cmte_connected_org_nm,

			--info about cmte parties
			party_id,
			partisan_score,
			cmte_cycle,

			--info about candidates
			cand_id,
			cand_name,
			cand_pty_affiliation,
			cand_election_yr,
			cand_office,
			cand_pcc,
			
			--info about contribution
			contributor_transaction_dt,
			contributor_transaction_amt,
			contributor_transaction_pgi,
			contributor_transaction_tp,
			
			
			--other info about contribution
			contributor_amndt_ind,
			contributor_rpt_tp,
			contributor_image_num,
			contributor_entity_tp,
			contributor_other_id,
			contributor_tran_id,
			contributor_file_num,
			contributor_memo_cd,
			contributor_memo_text,
			sub_id,

			--requested company
			--added to tmp after its creation
			cid,

			--qc cleaning cols
			cid_master,
			contributor_employer_clean,
			contributor_occupation_clean,
			emp_count,
			occ_count,
			cid_valid,
			executive_emp,
			executive_occ,
			director_emp,
			director_occ,
			manager_emp,
			manager_occ,
			rank_emp,
			rank_occ
			
	)
SELECT 
			contributor_name, 
			contributor_employer,
			contributor_occupation,
			contributor_city,
			contributor_state,
			contributor_zip_code,
			contributor_cycle,

			--individual about cmte
			cmte_id,
			cmte_nm,
			cmte_pty_affiliation,
			cmte_dsgn,
			cmte_type,
			cmte_filing_freq,
			cmte_org_tp,
			cmte_connected_org_nm,

			--info about cmte parties
			party_id,
			partisan_score,
			cmte_cycle,

			--info about candidates
			cand_id,
			cand_name,
			cand_pty_affiliation,
			cand_election_yr,
			cand_office,
			cand_pcc,
			
			--info about contribution
			contributor_transaction_dt,
			contributor_transaction_amt,
			contributor_transaction_pgi,
			contributor_transaction_tp,
			
			
			--other info about contribution
			contributor_amndt_ind,
			contributor_rpt_tp,
			contributor_image_num,
			contributor_entity_tp,
			contributor_other_id,
			contributor_tran_id,
			contributor_file_num,
			contributor_memo_cd,
			contributor_memo_text,
			sub_id,

			--requested company
			--added to tmp after its creation
			cid,

			--qc cleaning cols
			cid_master,
			contributor_employer_clean,
			contributor_occupation_clean,
			emp_count,
			occ_count,
			cid_valid,
			executive_emp,
			executive_occ,
			director_emp,
			director_occ,
			manager_emp,
			manager_occ,
			rank_emp,
			rank_occ
			
	FROM sa_tmp;

