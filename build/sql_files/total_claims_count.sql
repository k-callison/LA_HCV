/*Total Claims Count*/
CREATE TABLE mcaidwork.total_claims AS
SELECT clc_service_from_date, COUNT(*) AS claim_count
FROM mcaidwork.finaladjclaims
GROUP BY clc_service_from_date;