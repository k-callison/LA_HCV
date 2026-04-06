clear
set more off

global data "/home/kcallison/data/kcallison/LA_HCV/data_files/original"
global out "/home/kcallison/data/kcallison/LA_HCV/data_files/created"

use "$data/hiv_analytic.dta", clear
drop clc_payment_date clq_payment clq_plan_paid_amt clc_service_from_date ///
clc_time_key clc_claim_key clc_claim_icn clq_claim_status clq_claim_mod ///
clrx_days_supply adv_liver_disease
destring year, replace
drop if year<2012 | year>2024
destring month, replace
gen service_ym=ym(year, month)
gen service_yq=qofd(dofm(service_ym))

/*Identify first HIV claim date*/
gen dx_year=substr(first_hiv_claim_date,1,4)
destring dx_year, replace
gen dx_month=substr(first_hiv_claim_date,5,2)
destring dx_month, replace
gen dx_ym=ym(dx_year, dx_month)
gen dx_yq=qofd(dofm(dx_ym))
gen qtr_since_dx=service_yq-dx_yq

/*Identify quarter since Medicaid enrollment*/
bysort clr_recip_id enrollment_spell (service_ym): gen enroll_ym=service_ym[1]
bysort clr_recip_id enrollment_spell (service_yq): gen enroll_yq=service_yq[1]
gen qtr_since_enroll=service_yq-enroll_yq

/*Identify members who have ever had an OUD*/
replace oud=0 if oud==.
bysort clr_recip_id (service_ym): ereplace oud=max(oud)

/*Residential SUD Program, Methadone, & Halfway House Claims*/
gen sud_flag=.
replace sud_flag=1 if strpos(clc_procedure_code,"H0010")>0
replace sud_flag=1 if strpos(clc_procedure_code,"H0011")>0
replace sud_flag=1 if strpos(clc_procedure_code,"H0017")>0
replace sud_flag=1 if strpos(clc_procedure_code,"H0018")>0
replace sud_flag=1 if strpos(clc_procedure_code,"H0019")>0
replace sud_flag=1 if strpos(clc_procedure_code,"T2048")>0
replace sud_flag=1 if clh_treat_place=="55"
replace sud_flag=1 if inlist(clc_procedure_code,"H2036","H0020","H2034")
replace sud_flag=1 if clc_procedure_code=="12496030001"
replace sud_flag=1 if clc_procedure_code=="12496120803"

/*Spending*/
replace clq_med_amt_allowed=0 if clq_med_amt_allowed==.
gen clq_med_amt_allowed_2024=.
replace clq_med_amt_allowed_2024=clq_med_amt_allowed if year==2024
replace clq_med_amt_allowed_2024=clq_med_amt_allowed/(549.07/559.89) if year==2023
replace clq_med_amt_allowed_2024=clq_med_amt_allowed/(546.53/559.89) if year==2022
replace clq_med_amt_allowed_2024=clq_med_amt_allowed/(525.25/559.89) if year==2021
replace clq_med_amt_allowed_2024=clq_med_amt_allowed/(518.85/559.89) if year==2020
replace clq_med_amt_allowed_2024=clq_med_amt_allowed/(498.40/559.89) if year==2019
replace clq_med_amt_allowed_2024=clq_med_amt_allowed/(484.70/559.89) if year==2018
replace clq_med_amt_allowed_2024=clq_med_amt_allowed/(475.32/559.89) if year==2017
replace clq_med_amt_allowed_2024=clq_med_amt_allowed/(463.68/559.89) if year==2016
replace clq_med_amt_allowed_2024=clq_med_amt_allowed/(446.76/559.89) if year==2015
replace clq_med_amt_allowed_2024=clq_med_amt_allowed/(435.31/559.89) if year==2014
replace clq_med_amt_allowed_2024=clq_med_amt_allowed/(425.13/559.89) if year==2013
replace clq_med_amt_allowed_2024=clq_med_amt_allowed/(414.92/559.89) if year==2012

gen clq_med_amt_allowed_nodaa_2024=clq_med_amt_allowed_2024
replace clq_med_amt_allowed_nodaa_2024=. if daa==1
rename clq_med_amt_allowed_2024 spend
rename clq_med_amt_allowed_nodaa_2024 spend_nodaa
drop clq_med_amt_allowed

/*Service category*/
*1 = inpatient
*2 = ltc
*3 = outpatient
*4 = rehab
*5 = transport
*6 = dme/medical & surgical supplies
*7 = dental
*8 = pharmacy
*9 = daycare
*10 = lab
*11 = ED
*12 = SUD facility
*13 = inpatient psych facility
*14 = urgent care
*15 = other

destring clq_claim_type, replace
gen inpatient_spend=spend if clq_claim_type==1 | clh_treat_place=="21"
replace inpatient_spend=0 if inpatient_spend==.
gen ltc_spend=spend if clq_claim_type==2 | inlist(clh_treat_place,"31","32")
replace ltc_spend=0 if ltc_spend==.
gen outpatient_spend=spend if inlist(clq_claim_type,3,6)
replace outpatient_spend=spend if (clq_claim_type==4 | clq_claim_type==15) & /// 
inlist(clh_treat_place,"03","11","12","19","22","24","49","50","53")
replace outpatient_spend=spend if (clq_claim_type==4 | clq_claim_type==15) & ///
inlist(clh_treat_place,"60","65","71","72")
replace outpatient_spend=0 if outpatient_spend==.
gen rehab_spend=spend if clq_claim_type==5 | clh_treat_place=="61"
replace rehab_spend=0 if rehab_spend==.
gen transport_spend=spend if clh_treat_place=="41" | inlist(clq_claim_type,7,8)
replace transport_spend=0 if transport_spend==.
gen dme_spend=spend if clq_claim_type==9
replace dme_spend=0 if dme_spend==.
gen dental_spend=spend if inlist(clq_claim_type,10,11)
replace dental_spend=0 if dental_spend==.
gen rx_spend=spend if clq_claim_type==12
replace rx_spend=0 if rx_spend==.
gen rx_spend_nodaa=spend_nodaa if clq_claim_type==12
replace rx_spend_nodaa=0 if rx_spend_nodaa==. & daa!=1
gen daycare_spend=spend if clq_claim_type==16
replace daycare_spend=0 if daycare_spend==.
gen lab_spend=spend if clh_treat_place=="81"
replace lab_spend=0 if lab_spend==.
gen ed_spend=spend if clh_treat_place=="23"
replace ed_spend=0 if ed_spend==.
gen sudfac_spend=spend if inlist(clh_treat_place,"55","57")
replace sudfac_spend=0 if sudfac_spend==.
gen psych_spend=spend if inlist(clh_treat_place,"51","56","52")
replace psych_spend=0 if psych_spend==.
gen urgent_spend=spend if clh_treat_place=="20"
replace urgent_spend=0 if urgent_spend==.
egen sum_spend=rowtotal(inpatient_spend-urgent_spend)
gen other_spend=spend if sum_spend==0
drop sum_spend
drop clh_treat_place
drop clq_claim_type

/*Clean up a few other things*/
destring els_sex, replace
gen female=els_sex==2
drop els_sex
gen zip5=substr(els_zip_code,1,5)
destring zip5, replace
drop els_zip_code
destring clr_recip_parish, replace
replace clr_recip_parish=. if clr_recip_parish==77
replace clr_recip_parish=26 if clr_recip_parish==6
rename clr_recip_parish parish
replace parish=99 if parish==.
gen birth_year=substr(els_birth_date,1,4)
gen birth_month=substr(els_birth_date,5,2)
destring birth_year, replace
destring birth_month, replace
gen birth_date=ym(birth_year, birth_month)
gen age=(service_ym-birth_date)/12
drop if age<18 | age>64

/*Race categories: 1=NH White, 2=NH Black, 3=Hispanic, 4=Other, 5=unknown*/
destring els_ethnicity_code, replace
bysort clr_recip_id: egen race_temp=mode(clr_race)
replace els_race=race_temp if missing(els_race) & !missing(race_temp)
gen race=.
replace race=1 if inlist(els_race,"1","A","H")
replace race=2 if inlist(els_race,"2","B")
replace race=4 if inlist(els_race,"3","4","6","7","8","C","F","G")
replace race=5 if inlist(els_race,"9","J")
replace race=3 if els_race=="5" | (els_ethnicity_code>=2 & els_ethnicity_code<=4)
drop race_temp

gen hcv_flag=0
keep if zip5>=70000 & zip5<=71497 /*Drop those who live outside Louisiana*/
gen rural=inlist(zip5,70038,70041,70050,70083,70091,70340,70341,70342, ///
70345,70346,70354,70357,70373,70380,70381,70391,70392,70393 ///
70422,70426,70427,70429,70436,70438,70443,70450,70456,70465,70467, ///
70514,70515,70516,70522,70523,70524,70525,70526,70527,70531,70534, ///
70535,70537,70538,70540,70541,70543,70546,70548,70549,70551,70556, ///
70559,70570,70571,70576,70577,70580,70585,70586,70589,70634,70639, ///
70645,70659,70662,70711,70712,70715,70723,70743,70747,70750,70753, ///
70792,71001,71002,71003,71008,71018,71021,71024,71028,71031,71038, ///
71039,71040,71048,71052,71055,71058,71065,71066,71070,71071,71072, ///
71073,71075,71079,71080,71082,71220,71221,71223,71227,71229,71230, ///
71232,71233,71235,71237,71242,71243,71245,71247,71249,71250,71251, ///
71253,71254,71256,71261,71263,71264,71266,71268,71270,71272,71273, ///
71275,71276,71277,71282,71284,71286,71295,71316,71320,71322,71324, ///
71326,71327,71329,71333,71334,71336,71339,71340,71341,71343,71345, ///
71350,71351,71354,71355,71357,71358,71362,71363,71366,71367,71368, ///
71369,71373,71375,71377,71378,71401,71403,71404,71406,71410,71411, ///
71414,71416,71419,71422,71425,71426,71428,71429,71430,71433,71434, ///
71439,71440,71443,71446,71448,71449,71450,71452,71456,71457,71458, ///
71459,71460,71461,71462,71463,71468,71469,71471,71473,71474,71475, ///
71483,71486,71496,71497)

capture drop clc_time_key clc_claim_key clc_claim_icn els_birth_date /// 
clq_claim_status clq_claim_mod birth_year birth_month birth_date ///
els_race els_ethnicity_code clr_race
compress

save "$out/hiv_cohort_file.dta", replace
exit


