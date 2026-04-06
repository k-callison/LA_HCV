-- ============================================================
-- STEP 1: Diabetes claims
-- CLD is pre-aggregated to 1 row per claim (no fan-out risk)
-- before joining to CLC
-- ============================================================
DROP TABLE IF EXISTS mcaidwork.diab_dx_claims;
CREATE TABLE mcaidwork.diab_dx_claims AS
WITH cld_flags AS (
    SELECT
        cld_time_key,
        cld_claim_key
    FROM mcaid.cld
    WHERE cld_dx10_diag_code LIKE 'E08%'
       OR cld_dx10_diag_code LIKE 'E10%'
       OR cld_dx10_diag_code LIKE 'E11%'
       OR cld_dx10_diag_code LIKE 'E13%'
       OR cld_diag_code LIKE '250%'
    GROUP BY cld_time_key, cld_claim_key
)
SELECT
    a.clc_time_key,
    a.clc_claim_key,
    a.clc_service_from_date,
    b.clr_recip_id,
    c.clq_claim_type
FROM mcaid.clc a
INNER JOIN cld_flags f
    ON a.clc_time_key = f.cld_time_key
    AND a.clc_claim_key = f.cld_claim_key
LEFT JOIN mcaid.clr b
    ON a.clc_time_key = b.clr_time_key
    AND a.clc_claim_key = b.clr_claim_key
LEFT JOIN mcaid.clq c
    ON a.clc_time_key = c.clq_time_key
    AND a.clc_claim_key = c.clq_claim_key;


-- ============================================================
-- STEP 2: Diabetes member list
-- Criterion 1: >=1 inpatient claim with diabetes diagnosis
-- Criterion 2: >=2 claims on different service dates within 2 years
-- NOTE: Replace '01' with the inpatient claim type
--       code for this database before running
-- ============================================================
DROP TABLE IF EXISTS mcaidwork.diab_member_list;
CREATE TABLE mcaidwork.diab_member_list AS

-- Criterion 1: >=1 inpatient claim with diabetes diagnosis
SELECT DISTINCT clr_recip_id
FROM mcaidwork.diab_dx_claims
WHERE clq_claim_type = '01'

UNION

-- Criterion 2: >=2 claims on different service dates within a 2-year window
SELECT DISTINCT a.clr_recip_id
FROM mcaidwork.diab_dx_claims a
JOIN mcaidwork.diab_dx_claims b
    ON a.clr_recip_id = b.clr_recip_id
WHERE a.clc_service_from_date < b.clc_service_from_date
  AND date_diff('day',
        date_parse(CAST(a.clc_service_from_date AS VARCHAR), '%Y%m%d'),
        date_parse(CAST(b.clc_service_from_date AS VARCHAR), '%Y%m%d')
      ) <= 730;


-- ============================================================
-- STEP 3: All final adjudicated claims for diabetes members
-- Restricted to: exactly one record per ICN, AND
-- (clq_claim_status = '1') OR (clq_claim_status = '2' AND clq_claim_mod = '2')
-- ============================================================
DROP TABLE IF EXISTS mcaidwork.diab_member_claims;
CREATE TABLE mcaidwork.diab_member_claims AS
WITH adv_liver AS (
    SELECT
        cld_time_key,
        cld_claim_key,
        1 AS adv_liver_disease
    FROM mcaid.cld
    WHERE cld_dx10_diag_code IN (
        -- Alcoholic liver disease
        'K702','K703','K704','K7030','K7031',
        -- Toxic/drug-induced liver disease with fibrosis or cirrhosis
        'K7151','K717',
        -- Cirrhosis (non-alcoholic)
        'K7460','K7469',
        -- Biliary cirrhosis
        'K743','K744','K745',
        -- Hepatic fibrosis (unspecified and advanced; excludes K7401 early fibrosis)
        'K7400','K7402',
        -- Hepatic failure
        'K7290','K7291',
        -- Hepatic encephalopathy (effective Oct 2022)
        'K7682',
        -- Portal hypertension
        'K766',
        -- Hepatorenal syndrome
        'K767',
        -- Esophageal varices
        'I8500','I8501','I8510','I8511',
        -- Varices in diseases classified elsewhere
        'I9820','I9830',
        -- Ascites
        'R188',
        -- Hepatocellular carcinoma
        'C220'
    )
    OR cld_diag_code IN (
        -- Alcoholic cirrhosis / alcoholic liver damage
        '5712','5713',
        -- Cirrhosis of liver without mention of alcohol
        '5715',
        -- Biliary cirrhosis
        '5716',
        -- Other chronic nonalcoholic liver disease
        '5718',
        -- Hepatic encephalopathy / hepatic coma
        '5722',
        -- Other sequelae of chronic liver disease (incl. hepatic failure)
        '5728',
        -- Portal hypertension
        '5723',
        -- Hepatorenal syndrome
        '5724',
        -- Esophageal varices
        '4560','4561','45620','45621',
        -- Ascites
        '7895','78959',
        -- Hepatocellular carcinoma (primary liver cancer)
        '1550'
    )
    GROUP BY cld_time_key, cld_claim_key
),
oud_dx AS (
    SELECT
        cld_time_key,
        cld_claim_key,
        1 AS oud_dx
    FROM mcaid.cld
    WHERE cld_dx10_diag_code LIKE 'F11%'
       OR cld_diag_code LIKE '3040%'
       OR cld_diag_code LIKE '3055%'
    GROUP BY cld_time_key, cld_claim_key
),
base AS (
    SELECT
        a.clc_time_key, a.clc_claim_key, a.clc_service_from_date, a.clc_claim_icn,
        a.clc_procedure_code, a.clc_payment_date,
        b.clr_recip_id, b.clr_recip_parish, b.clr_race,
        c.clq_payment, c.clq_claim_type, c.clq_med_amt_allowed, c.clq_claim_status,
        c.clq_plan_paid_amt, c.clq_claim_mod,
        f.clh_treat_place,
        g.clrx_days_supply,
        COALESCE(l.adv_liver_disease, 0) AS adv_liver_disease,
        CASE WHEN a.clc_procedure_code IN (
            '00003021301', -- Daklinza
            '00003021501', -- Daklinza
            '00006307401', -- Zepatier
            '00006307402', -- Zepatier
            '00074260028', -- Mavyret
            '00074262528', -- Mavyret
            '00074309328', -- Viekira Pak
            '00085031402', -- Victrelis
            '51167010001', -- Incivek
            '59676022528', -- Olysio
            '61958150101', -- Sovaldi
            '61958180101', -- Harvoni
            '61958180301', -- Harvoni
            '61958180401', -- Harvoni
            '61958180501', -- Harvoni
            '61958220101', -- Epclusa
            '61958220301', -- Epclusa
            '61958220401', -- Epclusa
            '61958220501', -- Epclusa
            '61958240101', -- Vosevi
            '72626260101', -- Harvoni (authorized generic)
            '72626270101'  -- Epclusa (authorized generic)
        ) THEN 1 ELSE 0 END AS daa,
        CASE WHEN COALESCE(o.oud_dx, 0) = 1
               OR a.clc_procedure_code IN (
                   'H0020',  -- Methadone dispensing, OTP
                   'J2315',  -- Naltrexone ER injectable (Vivitrol), per 1 mg
                   'J0570',  -- Buprenorphine HCl, oral, 1 mg
                   'J0571',  -- Buprenorphine/naloxone (administered), various strengths
                   'J0572',
                   'J0573',
                   'J0574',
                   'J0575',
                   'Q9991'   -- Buprenorphine ER injectable (Sublocade), per 1 mg
               )
               OR a.clc_procedure_code LIKE '12496%'  -- Indivior (Suboxone, Sublocade)
               OR a.clc_procedure_code LIKE '54123%'  -- Orexo (Zubsolv)
               OR a.clc_procedure_code LIKE '59385%'  -- BioDelivery Sciences (Bunavail)
               OR a.clc_procedure_code LIKE '52440%'  -- Braeburn/Titan (Probuphine)
               OR a.clc_procedure_code LIKE '58284%'  -- Braeburn (Brixadi)
             THEN 1 ELSE 0 END AS oud,
        COUNT(*) OVER (PARTITION BY a.clc_claim_icn) AS icn_count
    FROM mcaid.clc a
    LEFT JOIN mcaid.clr b
        ON a.clc_time_key = b.clr_time_key AND a.clc_claim_key = b.clr_claim_key
    LEFT JOIN mcaid.clq c
        ON a.clc_time_key = c.clq_time_key AND a.clc_claim_key = c.clq_claim_key
    LEFT JOIN mcaid.clh f
        ON a.clc_time_key = f.clh_time_key AND a.clc_claim_key = f.clh_claim_key
    LEFT JOIN mcaid.clrx g
        ON a.clc_time_key = g.clrx_time_key AND a.clc_claim_key = g.clrx_claim_key
    LEFT JOIN adv_liver l
        ON a.clc_time_key = l.cld_time_key AND a.clc_claim_key = l.cld_claim_key
    LEFT JOIN oud_dx o
        ON a.clc_time_key = o.cld_time_key AND a.clc_claim_key = o.cld_claim_key
    INNER JOIN mcaidwork.diab_member_list h
        ON b.clr_recip_id = h.clr_recip_id
)
SELECT
    clc_time_key, clc_claim_key, clc_service_from_date, clc_claim_icn,
    clc_procedure_code, clc_payment_date,
    clr_recip_id, clr_recip_parish, clr_race,
    clq_payment, clq_claim_type, clq_med_amt_allowed, clq_claim_status,
    clq_plan_paid_amt, clq_claim_mod,
    clh_treat_place,
    clrx_days_supply,
    adv_liver_disease,
    daa,
    oud
FROM base
WHERE icn_count = 1
  AND (clq_claim_status = '1'
       OR (clq_claim_status = '2' AND clq_claim_mod = '2'));


-- ============================================================
-- STEP 4: Enrollment months with spell number
-- ============================================================
DROP TABLE IF EXISTS mcaidwork.diab_enrollment_months;
CREATE TABLE mcaidwork.diab_enrollment_months AS
WITH enrollment_months AS (
    SELECT DISTINCT
        e.elb_elig_id AS member_id,
        date_parse(CAST(e.elb_time_key AS VARCHAR) || '01', '%Y%m%d') AS month_start,
        date_add('day', -1,
            date_add('month', 1,
                date_parse(CAST(e.elb_time_key AS VARCHAR) || '01', '%Y%m%d')
            )
        ) AS month_end
    FROM mcaid.elb e
    INNER JOIN mcaidwork.diab_member_list h
        ON e.elb_elig_id = h.clr_recip_id
),
lagged AS (
    SELECT
        member_id,
        month_start,
        month_end,
        LAG(month_end) OVER (
            PARTITION BY member_id ORDER BY month_start
        ) AS prev_month_end
    FROM enrollment_months
),
spell_flags AS (
    SELECT
        member_id,
        month_start,
        CASE
            WHEN prev_month_end IS NULL                              THEN 1
            WHEN date_diff('day', prev_month_end, month_start) > 30 THEN 1
            ELSE 0
        END AS is_new_spell
    FROM lagged
),
spell_ids AS (
    SELECT
        member_id,
        month_start,
        SUM(is_new_spell) OVER (
            PARTITION BY member_id ORDER BY month_start
            ROWS UNBOUNDED PRECEDING
        ) AS enrollment_spell
    FROM spell_flags
)
SELECT
    member_id          AS clr_recip_id,
    YEAR(month_start)  AS year,
    MONTH(month_start) AS month,
    enrollment_spell
FROM spell_ids;


-- ============================================================
-- STEP 5: Analytic file — one row per claim, with zero-claim
-- enrollment months retained
-- ============================================================
DROP TABLE IF EXISTS mcaidwork.diab_analytic;
CREATE TABLE mcaidwork.diab_analytic AS
WITH first_diab AS (
    SELECT
        clr_recip_id,
        MIN(clc_service_from_date) AS first_diab_claim_date
    FROM mcaidwork.diab_dx_claims
    GROUP BY clr_recip_id
),
ever_daa AS (
    SELECT DISTINCT clr_recip_id
    FROM mcaidwork.diab_member_claims
    WHERE daa = 1
)
SELECT
    -- Enrollment context (always populated)
    e.clr_recip_id,
    e.year,
    e.month,
    e.enrollment_spell,
    x.first_diab_claim_date,

    -- Claim identifiers (NULL for zero-claim months)
    c.clc_time_key,
    c.clc_claim_key,
    c.clc_claim_icn,
    c.clc_service_from_date,
    c.clc_payment_date,
    c.clc_procedure_code,

    -- Recipient demographics (always populated)
    d.els_birth_date,
    d.els_sex,
    d.els_zip_code,
    d.els_race,
    d.els_ethnicity_code,

    -- Claim details (NULL for zero-claim months)
    c.clr_recip_parish,
    c.clr_race,

    -- Claim financials (NULL for zero-claim months)
    c.clq_payment,
    c.clq_claim_type,
    c.clq_med_amt_allowed,
    c.clq_claim_status,
    c.clq_plan_paid_amt,
    c.clq_claim_mod,

    -- Other claim details (NULL for zero-claim months)
    c.clh_treat_place,
    c.clrx_days_supply,
    c.adv_liver_disease,
    c.daa,
    c.oud

FROM mcaidwork.diab_enrollment_months e
LEFT JOIN mcaidwork.diab_member_claims c
    ON  e.clr_recip_id = c.clr_recip_id
    AND e.year          = c.clc_service_from_date / 10000
    AND e.month         = (c.clc_service_from_date % 10000) / 100
LEFT JOIN mcaid.els d
    ON e.clr_recip_id = d.els_elig_id
INNER JOIN first_diab x
    ON e.clr_recip_id = x.clr_recip_id
-- Exclude members with HCV
LEFT JOIN mcaidwork.hcv_member_list hcv_excl
    ON e.clr_recip_id = hcv_excl.clr_recip_id
-- Exclude members who ever filled a DAA prescription
LEFT JOIN ever_daa daa_excl
    ON e.clr_recip_id = daa_excl.clr_recip_id
WHERE hcv_excl.clr_recip_id IS NULL
  AND daa_excl.clr_recip_id IS NULL;
