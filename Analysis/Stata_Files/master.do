clear
set more off
estimates clear
scalar drop _all

global orig "/home/kcallison/data/kcallison/LA_HCV/data_files/original"
global data "/home/kcallison/data/kcallison/LA_HCV/data_files/created"
global code "/home/kcallison/data/kcallison/LA_HCV/do_files"
global fig "/home/kcallison/data/kcallison/LA_HCV/figures"
global tab "/home/kcallison/data/kcallison/LA_HCV/tables"

global controls i.service_yq i.qtr_since_dx i.qtr_since_enroll ///
i.female i.age i.race i.parish

/*Create HCV, Diabetes, & HIV analytic files*/
use "$data/hcv_cohort_file.dta", clear
collapse (sum) spend (sum) spend_nodaa (mean) age (max) female (last) zip5 /// 
(last) qtr_since_dx (last) daa_yq (last) dx_yq (last) qtr_since_enroll (last) parish /// 
(max) hcv_flag (max) adv_liver_disease (mean) race (max) rural (max) sud_flag ///
(max) oud, by(clr_recip_id service_yq) fast
replace age=round(age)
save "$data/hcv_full.dta", replace

use "$data/hiv_cohort_file.dta", clear
collapse (sum) spend (sum) spend_nodaa (mean) age (max) female (last) zip5 /// 
(last) qtr_since_dx (last) dx_yq (last) qtr_since_enroll (last) parish /// 
(max) hcv_flag (mean) race (max) rural (max) oud, /// 
by(clr_recip_id service_yq) fast
replace age=round(age)
save "$data/hiv_full.dta", replace

use "$data/diab_cohort_file.dta", clear
collapse (sum) spend (sum) spend_nodaa (mean) age (max) female (last) zip5 /// 
(last) qtr_since_dx (last) dx_yq (last) qtr_since_enroll (last) parish /// 
(max) hcv_flag (mean) race (max) rural (max) oud, /// 
by(clr_recip_id service_yq) fast
replace age=round(age)
save "$data/diab_full.dta", replace

/*Generate Main Figures*/
do "$code/figure2.do"
do "$code/figure3.do"
do "$code/figure4.do"

/*Generate Main Tables*/
do "$code/table1.do"
do "$code/table2.do"
do "$code/table3.do"
do "$code/table4.do"
do "$code/table5.do"

/*Generate Appendix Figures*/
do "$code/app_figure1.do"
do "$code/app_figure2.do"
do "$code/app_figure3.do"
do "$code/app_figure4.do"
do "$code/app_figure5.do"
do "$code/app_figure6.do"
do "$code/app_figure7.do"
do "$code/app_figure8.do"
do "$code/app_figure9.do"
do "$code/app_figure10.do"

/*Generate Appendix Tables*/
do "$code/app_table2.do"
do "$code/app_table3.do"
