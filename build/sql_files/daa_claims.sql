/*DAA Rx Claims*/
CREATE TABLE mcaidwork.daa_claims AS
SELECT clc_time_key, clc_claim_key, clc_service_from_date, b.clr_recip_id
FROM mcaidwork.finaladjclaims a 
INNER JOIN mcaid.clr b 
ON a.clc_time_key=b.clr_time_key
AND a.clc_claim_key=b.clr_claim_key
WHERE a.clc_procedure_code IN('72626270101',
'72626260101',
'61958180101',
'61958180301',
'61958180401',
'61958180501',
'00074262501',
'00074260028',
'00074319716',
'00085131801',
'61958150101',
'00074309328',
'00074006328',
'61958240101',
'00006307401',
'00006307402');

CREATE TABLE mcaidwork.daa_claims_days AS
SELECT clc_time_key, clc_claim_key, clc_service_from_date, clr_recip_id, clrx_rx_physician, clrx_days_supply
FROM mcaidwork.daa_claims a 
INNER JOIN mcaid.clrx b 
ON a.clc_time_key=b.clrx_time_key
AND a.clc_claim_key=b.clrx_claim_key