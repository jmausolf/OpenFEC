INSERT INTO individual_contributions (
	cm_id,
	amendment_ind,
	report_type,
	transaction_pgi,
	image_num,
	transaction_type,
	entity_type,
	name,
	city,
	state,
	zip_code,
	employer,
	occupation,
	transaction_date,
	transaction_amount,
	other_id,
	transaction_id,
	file_num,
	memo_code,
	memo_text,
	sub_id
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
	?
	)
;
