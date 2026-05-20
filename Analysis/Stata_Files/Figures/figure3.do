clear
set more off

/*****Figure 3, Panel A: HCV & Diabetes Trends*****/
use "$data/hcv_full.dta", clear
append using "$data/diab_full.dta"
keep if qtr_since_dx>=0
drop if service_yq<230 | service_yq>253
gen post=service_yq>=238
drop if dx_yq>237

preserve
collapse (mean) spend_nodaa, by(hcv_flag service_yq)

label def dates 230 "Jul 2017" 234 "Jul 2018" 238 "Jul 2019" /// 
242 "Jul 2020" 246 "Jul 2021" 250 "Jul 2022" 254 "Jul 2023"
label val service_yq dates

format spend_nodaa %13.0fc
twoway connected spend_nodaa service_yq if hcv_flag==1, /// 
color(black) msize(small) msymbol(O) yaxis(1) || ///
connected spend_nodaa service_yq if hcv_flag==0, /// 
color(black) lpattern(dash_dot) msymbol(D) msize(small) yaxis(2) ///
xtitle("") xlabel(230(4)254, labsize(small) valuelabel angle(45)) /// 
xline(237.5, lpattern(dash)) ///
ytitle("HCV Spend (2024$)", height(5) size(small) axis(1)) /// 
ytitle("Diabetes Spend (2024$)", height(5) size(small) axis(2)) ///
ylabel(3500(300)5000, labsize(small) gmin gmax grid glcolor(gs14) glwidth(vthin) axis(1)) ///
ylabel(3000(300)4500, labsize(small) gmin gmax grid glcolor(gs14) glwidth(vthin) axis(2)) ///
legend(label(1 "HCV Spend") label(2 "Diabetes Spend") pos(6) cols(2) size(small)) ///
scheme(lean2) graphregion(color(white)) plotregion(margin(zero))
gr export "$fig/fig_3a.eps", replace
restore

/*****Figure 3, Panel B: HCV & Diabetes Event Study*****/
qui: areg spend_nodaa $controls i.hcv_flag##ib237.service_yq if e(sample), absorb(clr_recip_id) robust

regsave 1.hcv_flag#230.service_yq ///
1.hcv_flag#231.service_yq 1.hcv_flag#232.service_yq 1.hcv_flag#233.service_yq /// 
1.hcv_flag#234.service_yq 1.hcv_flag#235.service_yq 1.hcv_flag#236.service_yq ///
1.hcv_flag#238.service_yq 1.hcv_flag#239.service_yq 1.hcv_flag#240.service_yq /// 
1.hcv_flag#241.service_yq 1.hcv_flag#242.service_yq 1.hcv_flag#243.service_yq ///
1.hcv_flag#244.service_yq 1.hcv_flag#245.service_yq 1.hcv_flag#246.service_yq /// 
1.hcv_flag#247.service_yq 1.hcv_flag#248.service_yq 1.hcv_flag#249.service_yq ///
1.hcv_flag#250.service_yq 1.hcv_flag#251.service_yq 1.hcv_flag#252.service_yq /// 
1.hcv_flag#253.service_yq, ci

set obs 24
gen obs=_n if _n<=7
replace obs=_n+1 if _n>=8
replace obs=8 if obs==25
sort obs
replace coef=0 if obs==8
replace stderr=0 if obs==8
replace ci_lower=0 if obs==8
replace ci_upper=0 if obs==8
gen y_line=0
gen yq=225+_n

label def date 1 "-8" 2 "-7" 3 "-6" 4 "-5" 5 "-4" 6 "-3" 7 "-2" 8 "-1" /// 
9 "0" 10 "1" 11 "2" 12 "3" 13 "4" 14 "5" 15 "6" 16 "7" 17 "8" 18 "9" ///
19 "10" 20 "11" 21 "12" 22 "13" 23 "14" 24 "15"
label values obs date
 
format coef %13.0fc
format obs %13.0fc
twoway (rarea ci_lower ci_upper obs, msize(large) lcolor(gs6)) || ///
(line coef obs, lpattern(solid) lwidth(medthick)) ///
(line y_line obs, lcolor(gs6) lpattern(dash)), ///
xtitle("Quarters from Policy", size(small)) xline(8.5, lcolor(gs6) lpattern(dash)) ///
ytitle("Spending Change ($)", size(small)) ylabel(-750(250)500, ///
labsize(small) gmin gmax axis(1) grid glcolor(gs14) glwidth(vthin)) ///
xlabel(1(2)24, valuelabels labsize(small)) legend(off) scheme(lean2) ///
graphregion(color(white)) plotregion(margin(zero))
gr export "$fig/fig_3b.eps", replace

/*****Figure 3, Panel C: HCV & HIV Trends*****/
use "$data/hcv_full.dta", clear
append using "$data/hiv_full.dta"
keep if qtr_since_dx>=0
drop if service_yq<230 | service_yq>253
gen post=service_yq>=238
drop if dx_yq>237

preserve
collapse (mean) spend_nodaa, by(hcv_flag service_yq)

label def dates 230 "Jul 2017" 234 "Jul 2018" 238 "Jul 2019" /// 
242 "Jul 2020" 246 "Jul 2021" 250 "Jul 2022" 254 "Jul 2023"
label val service_yq dates

format spend_nodaa %13.0fc
twoway connected spend_nodaa service_yq if hcv_flag==1, /// 
color(black) msize(small) msymbol(O) yaxis(1) || ///
connected spend_nodaa service_yq if hcv_flag==0, /// 
color(black) lpattern(dash_dot) msymbol(D) msize(small) yaxis(2) ///
xtitle("") xlabel(230(4)254, labsize(small) valuelabel angle(45)) /// 
xline(237.5, lpattern(dash)) ///
ytitle("HCV Spend (2024$)", height(5) size(small) axis(1)) ///
ytitle("HIV Spend (2024$)", height(5) size(small) axis(2)) ///
ylabel(3500(300)5000, labsize(small) gmin gmax grid glcolor(gs14) glwidth(vthin) axis(1)) ///
ylabel(4000(400)6000, labsize(small) gmin gmax grid glcolor(gs14) glwidth(vthin) axis(2)) ///
legend(label(1 "HCV Spend") label(2 "HIV Spend") pos(6) cols(2) size(small)) ///
scheme(lean2) graphregion(color(white)) plotregion(margin(zero))
gr export "$fig/fig_3c.eps", replace
restore

/*****Figure 3, Panel D: HCV & HIV Event Study*****/
qui: areg spend_nodaa $controls i.hcv_flag##ib237.service_yq, absorb(clr_recip_id) robust

regsave 1.hcv_flag#230.service_yq ///
1.hcv_flag#231.service_yq 1.hcv_flag#232.service_yq 1.hcv_flag#233.service_yq /// 
1.hcv_flag#234.service_yq 1.hcv_flag#235.service_yq 1.hcv_flag#236.service_yq ///
1.hcv_flag#238.service_yq 1.hcv_flag#239.service_yq 1.hcv_flag#240.service_yq /// 
1.hcv_flag#241.service_yq 1.hcv_flag#242.service_yq 1.hcv_flag#243.service_yq ///
1.hcv_flag#244.service_yq 1.hcv_flag#245.service_yq 1.hcv_flag#246.service_yq /// 
1.hcv_flag#247.service_yq 1.hcv_flag#248.service_yq 1.hcv_flag#249.service_yq ///
1.hcv_flag#250.service_yq 1.hcv_flag#251.service_yq 1.hcv_flag#252.service_yq /// 
1.hcv_flag#253.service_yq, ci

set obs 24
gen obs=_n if _n<=7
replace obs=_n+1 if _n>=8
replace obs=8 if obs==25
sort obs
replace coef=0 if obs==8
replace stderr=0 if obs==8
replace ci_lower=0 if obs==8
replace ci_upper=0 if obs==8
gen y_line=0
gen yq=225+_n

label def date 1 "-8" 2 "-7" 3 "-6" 4 "-5" 5 "-4" 6 "-3" 7 "-2" 8 "-1" /// 
9 "0" 10 "1" 11 "2" 12 "3" 13 "4" 14 "5" 15 "6" 16 "7" 17 "8" 18 "9" ///
19 "10" 20 "11" 21 "12" 22 "13" 23 "14" 24 "15"
label values obs date
 
format coef %13.0fc
format obs %13.0fc
twoway (rarea ci_lower ci_upper obs, msize(large) lcolor(gs6)) || ///
(line coef obs, lpattern(solid) lwidth(medthick)) ///
(line y_line obs, lcolor(gs6) lpattern(dash)), ///
xtitle("Quarters from Policy", size(small)) xline(8.5, lcolor(gs6) lpattern(dash)) ///
ytitle("Spending Change ($)", size(small)) ylabel(-750(250)500, ///
labsize(small) gmin gmax axis(1) grid glcolor(gs14) glwidth(vthin)) ///
xlabel(1(2)24, valuelabels labsize(small)) legend(off) scheme(lean2) ///
graphregion(color(white)) plotregion(margin(zero))
gr export "$fig/fig_3d.eps", replace
