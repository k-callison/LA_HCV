/*Diabetes Dx Claims*/
CREATE TABLE mcaidwork.diab_dx_claims AS
SELECT clc_time_key, clc_claim_key, clc_service_from_date
FROM mcaidwork.finaladjclaims
WHERE clc_dx10_diag_code_1 LIKE 'E08%'
OR clc_dx10_diag_code_1 LIKE 'E10%'
OR clc_dx10_diag_code_1 LIKE 'E11%'
OR clc_dx10_diag_code_1 LIKE 'E13%'
OR clc_dx10_diag_code_2 LIKE 'E08%'
OR clc_dx10_diag_code_2 LIKE 'E10%'
OR clc_dx10_diag_code_2 LIKE 'E11%'
OR clc_dx10_diag_code_2 LIKE 'E13%'; 