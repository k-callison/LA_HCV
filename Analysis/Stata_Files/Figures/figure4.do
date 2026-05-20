clear
set more off

/*Figure 4 - New Diagnoses*/
/*Panel A - HCV vs. Diabetes Trends*/
use "$data/hcv_full.dta", clear
append using "$data/diab_full.dta"

duplicates drop clr_recip_id, force
gen obs=1
collapse (sum) obs (max) qtr_since_enroll ///
(max) female (mean) age, by(dx_yq hcv_flag)
drop if dx_yq<230 | dx_yq>253
gen post=dx_yq>=238

label def dates 230 "Jul 2017" 234 "Jul 2018" 238 "Jul 2019" /// 
242 "Jul 2020" 246 "Jul 2021" 250 "Jul 2022" 254 "Jul 2023"
label val dx_yq dates

format obs %13.0fc
twoway connected obs dx_yq if hcv_flag==1, /// 
yaxis(1) color(black) msize(small) msymbol(O) || ///
connected obs dx_yq if hcv_flag==0, /// 
yaxis(2) color(black) lpattern(dash_dot) msymbol(D) msize(small) ///
xtitle("") xlabel(230(4)254, labsize(small) valuelabel angle(45)) xline(237.5, lpattern(dash)) ///
ytitle("New HCV Diagnoses", height(5) axis(1) size(small)) ylabel(600(300)1800, /// 
labsize(small) gmin gmax axis(1) grid glcolor(gs14) glwidth(vthin)) ///
ytitle("New Diabetes Diagnoses", height(5) axis(2) size(small)) ylabel(1500(1250)6500, /// 
labsize(small) gmin gmax axis(2) nogrid) ///
legend(label(1 "HCV Members") label(2 "Diabetes Members") pos(6) cols(2) size(small)) ///
scheme(lean2) graphregion(color(white)) plotregion(margin(zero))
gr export "$fig/fig_4a.eps", replace

/*Panel B - HCV vs. HIV Trends*/
use "$data/hcv_full.dta", clear
append using "$data/hiv_full.dta"

duplicates drop clr_recip_id, force
gen obs=1
collapse (sum) obs (max) qtr_since_enroll ///
(max) female (mean) age, by(dx_yq hcv_flag)
drop if dx_yq<230 | dx_yq>253
gen post=dx_yq>=238

label def dates 230 "Jul 2017" 234 "Jul 2018" 238 "Jul 2019" /// 
242 "Jul 2020" 246 "Jul 2021" 250 "Jul 2022" 254 "Jul 2023"
label val dx_yq dates

format obs %13.0fc
twoway connected obs dx_yq if hcv_flag==1, /// 
yaxis(1) color(black) msize(small) msymbol(O) || ///
connected obs dx_yq if hcv_flag==0, /// 
yaxis(2) color(black) lpattern(dash_dot) msymbol(D) msize(small) ///
xtitle("") xlabel(230(4)254, labsize(small) valuelabel angle(45)) xline(237.5, lpattern(dash)) ///
ytitle("New HCV Diagnoses", height(5) axis(1) size(small)) ylabel(600(300)1800, /// 
labsize(small) gmin gmax axis(1) grid glcolor(gs14) glwidth(vthin)) ///
ytitle("New HIV Diagnoses", height(5) axis(2) size(small)) ylabel(0(150)600, /// 
labsize(small) gmin gmax axis(2) nogrid) ///
legend(label(1 "HCV Members") label(2 "HIV Members") pos(6) cols(2) size(small)) ///
scheme(lean2) graphregion(color(white)) plotregion(margin(zero))
gr export "$fig/fig_4b.eps", replace
