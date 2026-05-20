clear
set more off

/*Table 2*/
use "$data/hcv_full.dta", clear
append using "$data/diab_full.dta"
keep if qtr_since_dx>=0
drop if service_yq<230 | service_yq>253
gen post=service_yq>=238
drop if dx_yq>237

gen year=.
replace year=1 if inlist(service_yq,238,239,240,241)
replace year=2 if inlist(service_yq,242,243,244,245)
replace year=3 if inlist(service_yq,246,247,248,249)
replace year=4 if inlist(service_yq,250,251,252,253)
replace year=0 if year==.

/******Diabetes Comparison Group*****/
/*Table 2, Column 1*/
eststo row1: reg spend_nodaa $controls i.hcv_flag##i.post, robust
scalar col1_dd=_b[1.hcv_flag#1.post]
estadd scalar obs=e(N)
sum spend_nodaa if e(sample) & hcv_flag==1 & post==0
estadd scalar spend_mean=r(mean)
estadd local controls "Yes"
estadd local fe "No"
preserve
keep if hcv_flag==1
replace daa_yq=. if daa_yq>253
gen pre_daa=1 if daa_yq<238 & daa_yq!=.
replace pre_daa=0 if pre_daa==.
gen post_daa=1 if daa_yq!=.
replace post_daa=0 if post_daa==.
collapse (mean) pre_daa (mean) post_daa, by(post clr_recip_id)
sum pre_daa if post==0
estadd scalar pre_rate=r(mean)
local pre_rate=r(mean)
sum post_daa
estadd scalar post_rate=r(mean)
local post_rate=r(mean)
estadd scalar wald=(col1_dd/(`post_rate'-`pre_rate'))
restore

/*Table 2, Column 2*/
eststo row2: areg spend_nodaa $controls i.hcv_flag##i.post, robust absorb(clr_recip_id)
scalar col2_dd=_b[1.hcv_flag#1.post]
estadd scalar obs=e(N)
sum spend_nodaa if e(sample) & hcv_flag==1 & post==0
estadd scalar spend_mean=r(mean)
estadd local controls "Yes"
estadd local fe "Yes"
preserve
keep if hcv_flag==1
replace daa_yq=. if daa_yq>253
gen pre_daa=1 if daa_yq<238 & daa_yq!=.
replace pre_daa=0 if pre_daa==.
gen post_daa=1 if daa_yq!=.
replace post_daa=0 if post_daa==.
collapse (mean) pre_daa (mean) post_daa, by(post clr_recip_id)
sum pre_daa if post==0
estadd scalar pre_rate=r(mean)
local pre_rate=r(mean)
sum post_daa
estadd scalar post_rate=r(mean)
local post_rate=r(mean)
estadd scalar wald=(col2_dd/(`post_rate'-`pre_rate'))
restore

/*Table 2, Column 3*/
eststo row3: areg spend_nodaa $controls i.hcv_flag##ib0.year, robust absorb(clr_recip_id)
scalar diab_y1=_b[1.hcv_flag#1.year]
scalar diab_y2=_b[1.hcv_flag#2.year]
scalar diab_y3=_b[1.hcv_flag#3.year]
scalar diab_y4=_b[1.hcv_flag#4.year]
estadd scalar obs=e(N)
sum spend_nodaa if e(sample) & hcv_flag==1 & year==0
estadd scalar spend_mean=r(mean)
estadd local controls "Yes"
estadd local fe "Yes"

preserve
keep if hcv_flag==1
replace daa_yq=. if daa_yq>253
gen pre_daa=1 if daa_yq<238 & daa_yq!=.
replace pre_daa=0 if pre_daa==.
gen post_daa=1 if daa_yq>=238 & daa_yq!=.
replace post_daa=0 if post_daa==.
collapse (mean) pre_daa (mean) post_daa (mean) daa_yq, by(post clr_recip_id)
sum pre_daa if post==0
estadd scalar pre_rate=r(mean)
local pre_rate=r(mean)
gen daa_year1=daa_yq<=241
gen daa_year2=daa_yq<=245
gen daa_year3=daa_yq<=249
gen daa_year4=daa_yq<=253
forvalues i=1/4{
sum daa_year`i'
scalar daa_rate_year`i'=r(mean)
scalar diab_wald_y`i'=diab_y`i'/(daa_rate_year`i'-`pre_rate')
}
sum daa_year4
estadd scalar post_rate=r(mean)
local daa_rate_year4=r(mean)
estadd scalar wald=diab_y4/(`daa_rate_year4'-`pre_rate')
restore

/******HIV Comparison Group*****/
use "$data/hcv_full.dta", clear
append using "$data/hiv_full.dta"
keep if qtr_since_dx>=0
drop if service_yq<230 | service_yq>253
gen post=service_yq>=238
drop if dx_yq>237

gen year=.
replace year=1 if inlist(service_yq,238,239,240,241)
replace year=2 if inlist(service_yq,242,243,244,245)
replace year=3 if inlist(service_yq,246,247,248,249)
replace year=4 if inlist(service_yq,250,251,252,253)
replace year=0 if year==.

/*Table 2, Column 4*/
eststo row4: reg spend_nodaa $controls i.hcv_flag##i.post, robust
scalar col4_dd=_b[1.hcv_flag#1.post]
estadd scalar obs=e(N)
sum spend_nodaa if e(sample) & hcv_flag==1 & post==0
estadd scalar spend_mean=r(mean)
estadd local controls "Yes"
estadd local fe "No"
preserve
keep if hcv_flag==1
replace daa_yq=. if daa_yq>253
gen pre_daa=1 if daa_yq<238 & daa_yq!=.
replace pre_daa=0 if pre_daa==.
gen post_daa=1 if daa_yq!=.
replace post_daa=0 if post_daa==.
collapse (mean) pre_daa (mean) post_daa, by(post clr_recip_id)
sum pre_daa if post==0
estadd scalar pre_rate=r(mean)
local pre_rate=r(mean)
sum post_daa
estadd scalar post_rate=r(mean)
local post_rate=r(mean)
estadd scalar wald=(col4_dd/(`post_rate'-`pre_rate'))
restore

/*Table 2, Column 5*/
eststo row5: areg spend_nodaa $controls i.hcv_flag##i.post, robust absorb(clr_recip_id)
scalar col5_dd=_b[1.hcv_flag#1.post]
estadd scalar obs=e(N)
sum spend_nodaa if e(sample) & hcv_flag==1 & post==0
estadd scalar spend_mean=r(mean)
estadd local controls "Yes"
estadd local fe "Yes"
preserve
keep if hcv_flag==1
replace daa_yq=. if daa_yq>253
gen pre_daa=1 if daa_yq<238 & daa_yq!=.
replace pre_daa=0 if pre_daa==.
gen post_daa=1 if daa_yq!=.
replace post_daa=0 if post_daa==.
collapse (mean) pre_daa (mean) post_daa, by(post clr_recip_id)
sum pre_daa if post==0
estadd scalar pre_rate=r(mean)
local pre_rate=r(mean)
sum post_daa
estadd scalar post_rate=r(mean)
local post_rate=r(mean)
estadd scalar wald=(col5_dd/(`post_rate'-`pre_rate'))
restore

/*Table 2, Column 6*/
eststo row6: areg spend_nodaa $controls i.hcv_flag##ib0.year, robust absorb(clr_recip_id)
scalar hiv_y1=_b[1.hcv_flag#1.year]
scalar hiv_y2=_b[1.hcv_flag#2.year]
scalar hiv_y3=_b[1.hcv_flag#3.year]
scalar hiv_y4=_b[1.hcv_flag#4.year]
estadd scalar obs=e(N)
sum spend_nodaa if e(sample) & hcv_flag==1 & year==0
estadd scalar spend_mean=r(mean)
estadd local controls "Yes"
estadd local fe "Yes"

preserve
keep if hcv_flag==1
replace daa_yq=. if daa_yq>253
gen pre_daa=1 if daa_yq<238 & daa_yq!=.
replace pre_daa=0 if pre_daa==.
gen post_daa=1 if daa_yq>=238 & daa_yq!=.
replace post_daa=0 if post_daa==.
collapse (mean) pre_daa (mean) post_daa (mean) daa_yq, by(post clr_recip_id)
sum pre_daa if post==0
estadd scalar pre_rate=r(mean)
local pre_rate=r(mean)
gen daa_year1=daa_yq<=241
gen daa_year2=daa_yq<=245
gen daa_year3=daa_yq<=249
gen daa_year4=daa_yq<=253
forvalues i=1/4{
sum daa_year`i'
scalar daa_rate_year`i'=r(mean)
scalar hiv_wald_y`i'=hiv_y`i'/(daa_rate_year`i'-`pre_rate')
}
sum daa_year4
estadd scalar post_rate=r(mean)
local daa_rate_year4=r(mean)
estadd scalar wald=hiv_y4/(`daa_rate_year4'-`pre_rate')
restore

estadd local space1=" "
esttab row1 row2 row3 row4 row5 row6 using "$tab/table2.tex", ///
replace style(tex) booktabs fragment ///
b(2) se(2) keep(1.hcv_flag#1.post 1.hcv_flag#1.year 1.hcv_flag#2.year ///
1.hcv_flag#3.year 1.hcv_flag#4.year) star(* 0.10 ** 0.05 *** 0.01) ///
coeflabels(1.hcv_flag#1.post "HCV x Post" 1.hcv_flag#1.year "HCV x Year 1" ///
1.hcv_flag#2.year "HCV x Year 2" 1.hcv_flag#3.year "HCV x Year 3" ///
1.hcv_flag#4.year "HCV x Year 4") ///
mgroups("DD w/ Diabetes" "DD w/ HIV", ///
pattern(1 0 0 1 0 0) span prefix(\multicolumn{@span}{c}{) suffix(}) ///
erepeat(\cmidrule(lr){@span})) ///
nonote compress nogaps mlabels(none) ///
noeqlines nomtitles eqlabels(none) noobs label ///
scalars("spend_mean Baseline Mean HCV Spending" "pre_rate Pre-Policy DAA Exposure" /// 
"post_rate Post-Policy DAA Exposure" "wald Wald Estimate" "space1 $$$$" /// 
"controls Controls" "fe Individual FEs" ///
"obs Observations") sfmt(%12.2fc 3 3 %12.2fc 0 0 %12.0fc) ///
prehead("\begin{table}[!htbp]\centering" ///
"\caption{Estimates of Subscription Model Effects on Quarterly HCV Spending}" ///
"\label{tab:dd-spending}" ///
"\resizebox{\textwidth}{!}{%" "\begin{tabular}{lcccccc}" "\toprule") ///
postfoot("\bottomrule" "\end{tabular}}" ///
"\caption*{\parbox{\linewidth} \footnotesize\raggedright\textit{Notes:} Sample is restricted to members who were diagnosed with HCV, diabetes, or HIV prior to July 2019. Controls include age, sex, race and Hispanic ethnicity, parish of residence, number of quarters from condition diagnosis, and number of quarters since Medicaid enrollment. Quarterly spend excludes DAA spending. Standard errors are calculated using the Huber/White sandwich estimator. \\ *p$<$0.10, **p$<$0.05, ***p$<$0.01}" ///
"\end{table}")
