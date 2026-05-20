clear
set more off

/*****Figure 2 - Spending Trajectories Around DAA Use*****/
use "$data/hcv_cohort_file.dta", clear

collapse (sum) spend_nodaa (max) daa_yq (max) qtr_since_dx /// 
(max) qtr_since_enroll, by(clr_recip_id service_yq) fast

gen qtrs_from_daa=service_yq-daa_yq
drop if qtrs_from_daa==.

reghdfe spend_nodaa, absorb(qtr_since_dx qtr_since_enroll) resid
predict spend_alt, resid 
replace spend_alt=spend_alt + _b[_cons]

drop if daa_yq<230 | daa_yq>253
collapse (mean) spend_alt, by(qtrs_from_daa)
keep if qtrs_from_daa>=-8 & qtrs_from_daa<=16

format spend_alt %13.0fc
twoway connected spend_alt qtrs_from_daa, ///
color(black) msize(small) msymbol(O) || ///
pcarrowi 5150 2 4900 0.25, ///
xtitle("Quarters from DAA") xlabel(-8(2)16) xline(-0.5, lpattern(dash)) ///
ylabel(0(1000)6000, gmax grid glcolor(gs14) glwidth(vthin)) /// 
ytitle("Quarterly Spend (2024$)") ///
text(5200 3.9 "First DAA Fill", size(small)) /// 
scheme(lean2) legend(off)
gr export "$fig/fig_2.eps", replace
