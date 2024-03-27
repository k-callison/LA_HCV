/*HCV MEMBER ELIGIBILITY*/

/*Step 1: Identify HCV Dx Claims - all HCV claims including acute, chronic, and unspecified*/
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

/*Step 2: Identify unique HCV members*/
CREATE TABLE mcaidwork.hcv_member_list AS
SELECT DISTINCT(clr_recip_id)
FROM mcaidwork.hcv_dx_claims;

/*Step 3: Identify Medicaid eligibility periods for unique HCV members*/
CREATE TABLE mcaidwork.hcv_eligibility AS
SELECT clr_recip_id, ele_elig_id, ele_begin_date, ele_end_date
FROM mcaidwork.hcv_member_list a 
INNER JOIN mcaid.ele b
ON a.clr_recip_id = b.ele_elig_id;

DROP TABLE mcaidwork.hcv_dx_claims
DROP TABLE mcaidwork.hcv_member_list