/*Mental Claims*/
CREATE TABLE mcaidwork.mental_dx_claims AS
SELECT clc_time_key, clc_claim_key, clc_service_from_date, clc_dx10_diag_code_1
FROM mcaidwork.finaladjclaims
WHERE clc_dx10_diag_code_1 LIKE 'F0%'
OR clc_dx10_diag_code_1 LIKE 'F2%'
OR clc_dx10_diag_code_1 LIKE 'F3%'
OR clc_dx10_diag_code_1 LIKE 'F4%'
OR clc_dx10_diag_code_1 LIKE 'F5%'
OR clc_dx10_diag_code_1 LIKE 'F6%'
OR clc_dx10_diag_code_1 LIKE 'F7%'
OR clc_dx10_diag_code_1 LIKE 'F8%'
OR clc_dx10_diag_code_1 LIKE 'F9%'
OR clc_dx10_diag_code_2 LIKE 'F0%'
OR clc_dx10_diag_code_2 LIKE 'F2%'
OR clc_dx10_diag_code_2 LIKE 'F3%'
OR clc_dx10_diag_code_2 LIKE 'F4%'
OR clc_dx10_diag_code_2 LIKE 'F5%'
OR clc_dx10_diag_code_2 LIKE 'F6%'
OR clc_dx10_diag_code_2 LIKE 'F7%'
OR clc_dx10_diag_code_2 LIKE 'F8%'
OR clc_dx10_diag_code_2 LIKE 'F9%';