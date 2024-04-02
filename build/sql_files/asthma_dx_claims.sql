/*Asthma Claims*/
CREATE TABLE mcaidwork.asthma_dx_claims AS
SELECT clc_time_key, clc_claim_key, clc_service_from_date
FROM mcaidwork.finaladjclaims
WHERE clc_dx10_diag_code_1 LIKE 'J45%'
OR clc_dx10_diag_code_2 LIKE 'J45%';