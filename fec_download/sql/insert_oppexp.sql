INSERT INTO operating_expenditures (
	cmte_id,
	amndt_ind,
	rpt_yr,
	rpt_tp,
	image_num,
	line_num,
	form_tp_cd,
	sched_tp_cd,
	name,
	city,
	state,
	zip_code,
	transaction_dt,
	transaction_amt,
	transaction_pgi,
	purpose,
	category,
	category_desc,
	memo_cd,
	memo_text,
	entity_tp,
	sub_id,
	file_num,
	tran_id,
	back_ref_tran_id,
	unknown_column
	) 
VALUES (
	?,
	?,
	?,
	?,
	?,
	?,
	?,
	?,
	?,
	?,
	?,
	?,
	?,
	?,
	?,
	?,
	?,
	?,
	?,
	?,
	?,
	?,
	?,
	?,
	?,
	?
);

