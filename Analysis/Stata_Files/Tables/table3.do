clear
set more off

/*Table 3 - Transmission Estimates*/
/*Column 1 - HCV vs. Diabetes*/
use "$data/hcv_full.dta", clear
append using "$data/diab_full.dta"

duplicates drop clr_recip_id, force
gen obs=1
collapse (sum) obs (mean) qtr_since_enroll ///
(mean) female (mean) age, by(dx_yq hcv_flag)
drop if dx_yq<230 | dx_yq>253
gen post=dx_yq>=238

foreach flag in 0 1{
summarize obs if hcv_flag==`flag' & dx_yq==230
gen obs_norm_`flag'=obs/r(mean)*100 if hcv_flag==`flag'
}

eststo row1a: reg obs i.dx_yq i.hcv_flag##i.post, robust
estadd scalar obs=e(N)
sum obs if hcv_flag==1 & post==0 & e(sample)
estadd scalar dx_mean=r(mean)

gen year=.
replace year=1 if inlist(dx_yq,238,239,240,241)
replace year=2 if inlist(dx_yq,242,243,244,245)
replace year=3 if inlist(dx_yq,246,247,248,249)
replace year=4 if inlist(dx_yq,250,251,252,253)
replace year=0 if year==.

eststo row1b: reg obs i.dx_yq i.hcv_flag##i.year, robust
estadd scalar obs=e(N)
scalar diab_tx_y1=_b[1.hcv_flag#1.year]
scalar diab_tx_y2=_b[1.hcv_flag#2.year]
scalar diab_tx_y3=_b[1.hcv_flag#3.year]
scalar diab_tx_y4=_b[1.hcv_flag#4.year]
sum obs if hcv_flag==1 & post==0 & e(sample)
estadd scalar dx_mean=r(mean)

/*Column 2 - HCV vs. HIV*/
use "$data/hcv_full.dta", clear
append using "$data/hiv_full.dta"

duplicates drop clr_recip_id, force
gen obs=1
collapse (sum) obs (mean) qtr_since_enroll ///
(mean) female (mean) age, by(dx_yq hcv_flag)
drop if dx_yq<230 | dx_yq>253
gen post=dx_yq>=238

foreach flag in 0 1{
summarize obs if hcv_flag==`flag' & dx_yq==230
gen obs_norm_`flag'=obs/r(mean)*100 if hcv_flag==`flag'
}

eststo row1c: reg obs i.dx_yq i.hcv_flag##i.post, robust
estadd scalar obs=e(N)
sum obs if hcv_flag==1 & post==0 & e(sample)
estadd scalar dx_mean=r(mean)

gen year=.
replace year=1 if inlist(dx_yq,238,239,240,241)
replace year=2 if inlist(dx_yq,242,243,244,245)
replace year=3 if inlist(dx_yq,246,247,248,249)
replace year=4 if inlist(dx_yq,250,251,252,253)
replace year=0 if year==.

eststo row1d: reg obs i.dx_yq i.hcv_flag##i.year, robust
estadd scalar obs=e(N)
scalar hiv_tx_y1=_b[1.hcv_flag#1.year]
scalar hiv_tx_y2=_b[1.hcv_flag#2.year]
scalar hiv_tx_y3=_b[1.hcv_flag#3.year]
scalar hiv_tx_y4=_b[1.hcv_flag#4.year]
sum obs if hcv_flag==1 & post==0 & e(sample)
estadd scalar dx_mean=r(mean)

estadd local space1=" "
esttab row1a row1b row1c row1d using "$tab/table3.tex", ///
replace style(tex) booktabs fragment ///
b(2) se(2) keep(1.hcv_flag#1.post 1.hcv_flag#1.year 1.hcv_flag#2.year ///
1.hcv_flag#3.year 1.hcv_flag#4.year) /// 
star(* 0.10 ** 0.05 *** 0.01) ///
coeflabels(1.hcv_flag#1.post "HCV x Post" 1.hcv_flag#1.year "HCV x Year 1" ///
1.hcv_flag#2.year "HCV x Year 2" 1.hcv_flag#3.year "HCV x Year 3" ///
1.hcv_flag#4.year "HCV x Year 4") ///
mgroups("DD w/ Diabetes" "DD w/ HIV", ///
pattern(1 0 1 0) span prefix(\multicolumn{@span}{c}{) suffix(}) ///
erepeat(\cmidrule(lr){@span})) ///
nonote compress nogaps mlabels(none) ///
noeqlines nomtitles eqlabels(none) noobs label ///
scalars("dx_mean Baseline Mean HCV Diagnoses" ///
"obs Observations") sfmt(%12.0fc %12.0fc) ///
prehead("\begin{table}[!htbp]\centering" ///
"\begin{minipage}{0.75\textwidth}" ///
"\caption{Estimates of Subscription Model Effects on HCV Transmission}" ///
"\label{tab:dd-transmission}" ///
"\resizebox{\linewidth}{!}{%" ///
"\begin{tabular}{lcccc}" "\toprule") ///
postfoot("\bottomrule" "\end{tabular}" ///
"}" ///
"\smallskip" ///
"\parbox{\linewidth}{\footnotesize\raggedright \textit{Notes:} Diagnoses are aggregated to the condition-year-quarter level. All models include year-quarter controls. Standard errors are calculated using the Huber/White sandwich estimator.\par *p$<$0.10, **p$<$0.05, ***p$<$0.01}" ///
"\end{minipage}" ///
"\end{table}")
