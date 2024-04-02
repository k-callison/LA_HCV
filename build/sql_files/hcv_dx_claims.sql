/*HCV Dx Claims - all HCV including acute, chronic, and unspecified*/
CREATE TABLE hcv_dx_claims AS
SELECT clc_time_key, clc_claim_key, clc_service_from_date, clr_recip_id
FROM mcaidwork.finaladjclaims a
INNER JOIN mcaid.clr b
ON a.clc_time_key = b.clr_time_key
AND a.clc_claim_key = b.clr_claim_key
WHERE clc_dx10_diag_code_1 IN('B171',
'B182',
'B1820',
'B192',
'B1920',
'B1921') 
OR clc_dx10_diag_code_2 IN('B171',
'B182',
'B1820',
'B192',
'B1920',
'B1921');