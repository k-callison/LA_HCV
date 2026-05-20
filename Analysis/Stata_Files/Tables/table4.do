clear
set more off

/******************Direct Savings*****************************/
/*1. Table 4, Column 2: Actual Stock Attrition*/
use "$data/hcv_full.dta", clear
keep if qtr_since_dx>=0
qui: reg spend_nodaa $controls
keep if e(sample)

qui eststo model0: reg spend_nodaa service_yq if service_yq==242 & dx_yq<238
local stock_count=e(N)
estadd scalar year1=e(N)

qui: sum spend_nodaa if service_yq==246 & dx_yq<238
estadd scalar year2=r(N)

qui: sum spend_nodaa if service_yq==250 & dx_yq<238
estadd scalar year3=r(N)

qui: sum spend_nodaa if service_yq==254 & dx_yq<238
estadd scalar year4=r(N)

qui: sum spend_nodaa if service_yq==258 & dx_yq<238
estadd scalar year5=r(N)

/*2. Table 4, Column 3: Estimated post-policy attrition using a sample of HCV members diagnosed on or 
before July 2014, providing a full five years post-diagnosis before the policy*/
qui eststo model01: reg spend_nodaa service_yq
keep if dx_yq>=212 & dx_yq<=218
keep if qtr_since_dx>=0
bysort clr_recip_id (service_yq): egen enroll_1yr=sum(qtr_since_dx) if qtr_since_dx<4
bysort clr_recip_id (service_yq): ereplace enroll_1yr=max(enroll_1yr)
replace enroll_1yr=0 if enroll_1yr<6
replace enroll_1yr=1 if enroll_1yr==6
sum enroll_1yr
local enroll_1yr=r(mean)
di `enroll_1yr'*`stock_count'
estadd scalar year1=`enroll_1yr'*`stock_count'

bysort clr_recip_id (service_yq): egen enroll_2yr=sum(qtr_since_dx) if qtr_since_dx<8
bysort clr_recip_id (service_yq): ereplace enroll_2yr=max(enroll_2yr)
replace enroll_2yr=0 if enroll_2yr<28
replace enroll_2yr=1 if enroll_2yr==28
sum enroll_2yr
local enroll_2yr=r(mean)
di `enroll_2yr'*`stock_count'
estadd scalar year2=`enroll_2yr'*`stock_count'

bysort clr_recip_id (service_yq): egen enroll_3yr=sum(qtr_since_dx) if qtr_since_dx<12
bysort clr_recip_id (service_yq): ereplace enroll_3yr=max(enroll_3yr)
replace enroll_3yr=0 if enroll_3yr<66
replace enroll_3yr=1 if enroll_3yr==66
sum enroll_3yr
local enroll_3yr=r(mean)
di `enroll_3yr'*`stock_count'
estadd scalar year3=`enroll_3yr'*`stock_count'

bysort clr_recip_id (service_yq): egen enroll_4yr=sum(qtr_since_dx) if qtr_since_dx<16
bysort clr_recip_id (service_yq): ereplace enroll_4yr=max(enroll_4yr)
replace enroll_4yr=0 if enroll_4yr<120
replace enroll_4yr=1 if enroll_4yr==120
sum enroll_4yr
local enroll_4yr=r(mean)
di `enroll_4yr'*`stock_count'
estadd scalar year4=`enroll_4yr'*`stock_count'

bysort clr_recip_id (service_yq): egen enroll_5yr=sum(qtr_since_dx) if qtr_since_dx<20
bysort clr_recip_id (service_yq): ereplace enroll_5yr=max(enroll_5yr)
replace enroll_5yr=0 if enroll_5yr<190
replace enroll_5yr=1 if enroll_5yr==190
sum enroll_5yr
local enroll_5yr=r(mean)
di `enroll_5yr'*`stock_count'
estadd scalar year5=`enroll_5yr'*`stock_count'

/*3. Table 4, Column 4: Number of stock members treated with DAAs each year*/
use "$data/hcv_full.dta", clear
keep if qtr_since_dx>=0
keep if daa_yq!=.
drop if dx_yq>=238

qui: reg spend_nodaa $controls
keep if e(sample)

duplicates drop clr_recip_id, force
gen obs=1

gen year=.
replace year=1 if inlist(daa_yq,238,239,240,241)
replace year=2 if inlist(daa_yq,242,243,244,245)
replace year=3 if inlist(daa_yq,246,247,248,249)
replace year=4 if inlist(daa_yq,250,251,252,253)
replace year=5 if inlist(daa_yq,254,255,256,257)

qui eststo model02: reg spend_nodaa service_yq
sum obs if year==1
local year1_treat=r(N)
estadd scalar year1=r(N)
sum obs if year==2
local year2_treat=r(N)
estadd scalar year2=r(N)
sum obs if year==3
local year3_treat=r(N)
estadd scalar year3=r(N)
sum obs if year==4
local year4_treat=r(N)
estadd scalar year4=r(N)
sum obs if year==5
local year5_treat=r(N)
estadd scalar year5=r(N)
estadd scalar total=e(year1)+e(year2)+e(year3)+e(year4)+e(year5)


/*4. Table 4, Column 5:  Calculate stock savings adjusted using pre-policy attrition rate*/
use "$data/hcv_full.dta", clear
drop if dx_yq>=238
gen obs=1
collapse (sum) obs, by(service_yq)
qui: sum obs if service_yq==238
scalar n_hcv=r(mean)


/*Method 1*/
qui eststo model1: reg obs service_yq
estadd scalar year1=n_hcv*(((diab_y1+hiv_y1)/2)*4)*`enroll_1yr'
local direct_save_y1=e(year1)
estadd scalar year2=(n_hcv*(((diab_y2+hiv_y2)/2)*4)*`enroll_2yr')*0.9688
local direct_save_y2=e(year2)
estadd scalar year3=(n_hcv*(((diab_y3+hiv_y3)/2)*4)*`enroll_3yr')*0.9388
local direct_save_y3=e(year3)
estadd scalar year4=(n_hcv*(((diab_y4+hiv_y4)/2)*4)*`enroll_4yr')*0.9095
local direct_save_y4=e(year4)
estadd scalar year5=(n_hcv*(((diab_y4+hiv_y4)/2)*4)*`enroll_5yr')*0.8811
local direct_save_y5=e(year5)
estadd scalar total=e(year1)+e(year2)+e(year3)+e(year4)+e(year5)

/******************Post-Policy Treatment Savings*****************************/
/*1. Table 4, Column 6: Number of post-policy diagnoses*/
use "$data/hcv_full.dta", clear
keep if dx_yq>=238
duplicates drop clr_recip_id, force
gen obs=1

gen year=.
replace year=1 if inlist(dx_yq,238,239,240,241)
replace year=2 if inlist(dx_yq,242,243,244,245)
replace year=3 if inlist(dx_yq,246,247,248,249)
replace year=4 if inlist(dx_yq,250,251,252,253)
replace year=5 if inlist(dx_yq,254,255,256,257)

qui eststo model03: reg obs year
sum obs if year==1
estadd scalar year1=r(N)
sum obs if year==2
estadd scalar year2=r(N)
sum obs if year==3
estadd scalar year3=r(N)
sum obs if year==4
estadd scalar year4=r(N)
sum obs if year==5
estadd scalar year5=r(N)
estadd scalar total=e(year1)+e(year2)+e(year3)+e(year4)+e(year5)

/*2. Table 4, Column 7: Number of post-policy diagnosed patients treated with DAAs*/
use "$data/hcv_full.dta", clear
drop if daa_yq==.
keep if dx_yq>=238
duplicates drop clr_recip_id, force
gen obs=1
collapse (sum) obs, by(daa_yq)

gen year=.
replace year=1 if inlist(daa_yq,238,239,240,241)
replace year=2 if inlist(daa_yq,242,243,244,245)
replace year=3 if inlist(daa_yq,246,247,248,249)
replace year=4 if inlist(daa_yq,250,251,252,253)
replace year=5 if inlist(daa_yq,254,255,256,257)
drop if year==.
collapse (sum) obs, by(year)

qui eststo model2: reg obs year
forvalues i = 1/5{
qui: sum obs if year==`i'
estadd scalar year`i'=r(mean)
local treat_y`i'=r(mean)
}
estadd scalar total=e(year1)+e(year2)+e(year3)+e(year4)+e(year5)

/*3. Table 4, Column 8: Estimate savings for those w/o advanced liver disease*/
/*a. Diabetes comparison*/
use "$data/hcv_full.dta", clear
bysort clr_recip_id (service_yq): egen pre_liver=max(adv_liver_disease) if service_yq<238
by clr_recip_id: ereplace pre_liver=max(pre_liver)
drop if pre_liver==1
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

qui: areg spend_nodaa $controls i.hcv_flag##ib0.year, absorb(clr_recip_id) robust
scalar nadv_diab_y1=_b[1.hcv_flag#1.year]
scalar nadv_diab_y2=_b[1.hcv_flag#2.year]
scalar nadv_diab_y3=_b[1.hcv_flag#3.year]
scalar nadv_diab_y4=_b[1.hcv_flag#4.year]

preserve
keep if hcv_flag==1
gen pre_daa=1 if daa_yq<238 & daa_yq!=.
replace pre_daa=0 if pre_daa==.
gen post_daa=1 if daa_yq>=238
replace post_daa=0 if post_daa==.
collapse (mean) pre_daa (mean) post_daa (mean) daa_yq, by(post clr_recip_id)
sum pre_daa if post==0
local pre_rate=r(mean)
gen daa_year1=daa_yq<=241
gen daa_year2=daa_yq<=245
gen daa_year3=daa_yq<=249
gen daa_year4=daa_yq<=253
forvalues i=1/4{
sum daa_year`i'
scalar nadv_daa_rate_year`i'=r(mean)
scalar nadv_diab_wald_y`i'=nadv_diab_y`i'/(nadv_daa_rate_year`i'-`pre_rate')
}
restore

/*b. HIV comparison*/
use "$data/hcv_full.dta", clear
bysort clr_recip_id (service_yq): egen pre_liver=max(adv_liver_disease) if service_yq<238
by clr_recip_id: ereplace pre_liver=max(pre_liver)
drop if pre_liver==1
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

qui: areg spend_nodaa $controls i.hcv_flag##ib0.year, absorb(clr_recip_id) robust
scalar nadv_hiv_y1=_b[1.hcv_flag#1.year]
scalar nadv_hiv_y2=_b[1.hcv_flag#2.year]
scalar nadv_hiv_y3=_b[1.hcv_flag#3.year]
scalar nadv_hiv_y4=_b[1.hcv_flag#4.year]

preserve
keep if hcv_flag==1
gen pre_daa=1 if daa_yq<238 & daa_yq!=.
replace pre_daa=0 if pre_daa==.
gen post_daa=1 if daa_yq>=238
replace post_daa=0 if post_daa==.
collapse (mean) pre_daa (mean) post_daa (mean) daa_yq, by(post clr_recip_id)
sum pre_daa if post==0
local pre_rate=r(mean)
gen daa_year1=daa_yq<=241
gen daa_year2=daa_yq<=245
gen daa_year3=daa_yq<=249
gen daa_year4=daa_yq<=253
forvalues i=1/4{
sum daa_year`i'
scalar nadv_daa_rate_year`i'=r(mean)
scalar nadv_hiv_wald_y`i'=nadv_hiv_y`i'/(nadv_daa_rate_year`i'-`pre_rate')
}
restore

/*c. Calculate post-policy treatment savings*/
qui eststo model3: reg spend_nodaa year
estadd scalar year1=((nadv_diab_wald_y1+nadv_hiv_wald_y1)/2)*4*`treat_y1'*`enroll_1yr'
local treat_save_y1=e(year1)

estadd scalar year2=(((nadv_diab_wald_y2+nadv_hiv_wald_y2)/2)*4*`treat_y1'*`enroll_2yr' + ///
((nadv_diab_wald_y1+nadv_hiv_wald_y1)/2)*4*`treat_y2'*`enroll_1yr')*0.9688
local treat_save_y2=e(year2)

estadd scalar year3=(((nadv_diab_wald_y3+nadv_hiv_wald_y3)/2)*4*`treat_y1'*`enroll_3yr' + ///
((nadv_diab_wald_y2+nadv_hiv_wald_y2)/2)*4*`treat_y2'*`enroll_2yr' + ///
((nadv_diab_wald_y1+nadv_hiv_wald_y1)/2)*4*`treat_y3'*`enroll_1yr')*0.9388
local treat_save_y3=e(year3)

estadd scalar year4=(((nadv_diab_wald_y4+nadv_hiv_wald_y4)/2)*4*`treat_y1'*`enroll_4yr' + ///
((nadv_diab_wald_y3+nadv_hiv_wald_y3)/2)*4*`treat_y2'*`enroll_3yr' + ///
((nadv_diab_wald_y2+nadv_hiv_wald_y2)/2)*4*`treat_y3'*`enroll_2yr' + ///
((nadv_diab_wald_y1+nadv_hiv_wald_y1)/2)*4*`treat_y4'*`enroll_1yr')*0.9095
local treat_save_y4=e(year4)

estadd scalar year5=(((nadv_diab_wald_y4+nadv_hiv_wald_y4)/2)*4*`treat_y1'*`enroll_5yr' + ///
((nadv_diab_wald_y4+nadv_hiv_wald_y4)/2)*4*`treat_y2'*`enroll_4yr' + ///
((nadv_diab_wald_y3+nadv_hiv_wald_y3)/2)*4*`treat_y3'*`enroll_3yr' + ///
((nadv_diab_wald_y2+nadv_hiv_wald_y2)/2)*4*`treat_y4'*`enroll_2yr' + ///
((nadv_diab_wald_y1+nadv_hiv_wald_y1)/2)*4*`treat_y5'*`enroll_1yr')*0.8811
local treat_save_y5=e(year5)
estadd scalar total=e(year1)+e(year2)+e(year3)+e(year4)+e(year5)


/******************Transmission Savings*****************************/
/*1. Table 4, Column 9: Cases averted*/
use "$data/hcv_full.dta", clear
bysort clr_recip_id (service_yq): egen pre_liver=max(adv_liver_disease) if service_yq<238
replace pre_liver=1 if pre_liver>0 & pre_liver!=.
bysort clr_recip_id (service_yq): ereplace pre_liver=max(pre_liver)
keep if pre_liver==0

qui eststo model4: reg hcv_flag service_yq
estadd scalar year1=0
estadd scalar year2=((diab_tx_y2+hiv_tx_y2)/2)*4*-1
estadd scalar year3=((diab_tx_y3+hiv_tx_y3)/2)*4*-1
estadd scalar year4=((diab_tx_y4+hiv_tx_y4)/2)*4*-1
estadd scalar year5=((diab_tx_y4+hiv_tx_y4)/2)*4*-1
estadd scalar total=e(year1)+e(year2)+e(year3)+e(year4)+e(year5)

/*2. Table 4, Column 10: Savings per Case Averted*/
/*Year 1 HCV Cost*/
preserve
keep if dx_yq>208 & dx_yq<235
collapse (sum) spend_nodaa, by(clr_recip_id qtr_since_dx service_yq) fast
gen in_range=inrange(qtr_since_dx, -4, 3)
egen range_qtr_count=total(in_range), by(clr_recip_id)
keep if range_qtr_count==8 & in_range==1
gen year=yofd(dofq(service_yq))
bysort clr_recip_id (service_yq): egen m_year=mode(year) if qtr_since_dx<0, minmode
by clr_recip_id: ereplace m_year=mode(year) if qtr_since_dx>=0, minmode
gen post=qtr_since_dx>=0
collapse (sum) spend_nodaa (mean) m_year, by(clr_recip_id post)
gen obs=1
collapse (mean) spend_nodaa (sum) obs, by(post m_year)
gsort m_year -post

gen cpi=.
replace cpi=1.0246 if m_year==2012 & post==0
replace cpi=1.0239 if m_year==2013 & post==0
replace cpi=1.0263 if m_year==2014 & post==0
replace cpi=1.0379 if m_year==2015 & post==0
replace cpi=1.0251 if m_year==2016 & post==0
replace cpi=1.0197 if m_year==2017 & post==0

gen hcv_spend1=spend_nodaa if post==1
sum hcv_spend1 if post==1
replace hcv_spend1=spend_nodaa*cpi if post==0
sum hcv_spend1  if post==0
gen adj_hcv_spend1=hcv_spend1-hcv_spend1[_n-1] if post==1

qui eststo model5: reg obs m_year
sum adj_hcv_spend1 [aw=obs] if m_year!=2013
estadd scalar year1=r(mean)
local hcv_spend1=r(mean)
restore

/*Year 2 HCV Cost*/
preserve
keep if dx_yq>208 & dx_yq<231
collapse (sum) spend_nodaa, by(clr_recip_id qtr_since_dx service_yq) fast
gen in_range=inrange(qtr_since_dx, -4, 7)
egen range_qtr_count=total(in_range), by(clr_recip_id)
keep if range_qtr_count==12 & in_range==1
drop if qtr_since_dx>=0 & qtr_since_dx<=3
gen year=yofd(dofq(service_yq))
bysort clr_recip_id (service_yq): egen m_year=mode(year) if qtr_since_dx<0, minmode
by clr_recip_id: ereplace m_year=mode(year) if qtr_since_dx>=0, minmode
gen post=qtr_since_dx>=0
collapse (sum) spend_nodaa (mean) m_year, by(clr_recip_id post)
gen obs=1
collapse (mean) spend_nodaa (sum) obs, by(post m_year)
gen sortyear=m_year
replace sortyear=m_year-2 if post==1
sort sortyear post
drop sortyear

gen cpi1=.
replace cpi1=1.0246 if m_year==2012 & post==0
replace cpi1=1.0239 if m_year==2013 & post==0
replace cpi1=1.0263 if m_year==2014 & post==0
replace cpi1=1.0379 if m_year==2015 & post==0
replace cpi1=1.0251 if m_year==2016 & post==0
gen cpi2=.
replace cpi2=1.0239 if m_year==2012 & post==0
replace cpi2=1.0263 if m_year==2013 & post==0
replace cpi2=1.0379 if m_year==2014 & post==0
replace cpi2=1.0251 if m_year==2015 & post==0
replace cpi2=1.0197 if m_year==2016 & post==0

gen hcv_spend2=spend_nodaa if post==1
replace hcv_spend2=spend_nodaa*cpi1*cpi2 if post==0

gen adj_hcv_spend2=hcv_spend2-hcv_spend2[_n-1] if post==1

sum adj_hcv_spend2 [aw=obs] if m_year!=2014
estadd scalar year2=r(mean)
local hcv_spend2=r(mean)
restore

/*Year 3 HCV Cost*/
preserve
keep if dx_yq>208 & dx_yq<227
collapse (sum) spend_nodaa, by(clr_recip_id qtr_since_dx service_yq) fast
gen in_range=inrange(qtr_since_dx, -4, 11)
egen range_qtr_count=total(in_range), by(clr_recip_id)
keep if range_qtr_count==16 & in_range==1
drop if qtr_since_dx>=0 & qtr_since_dx<=7
gen year=yofd(dofq(service_yq))
bysort clr_recip_id (service_yq): egen m_year=mode(year) if qtr_since_dx<0, minmode
by clr_recip_id: ereplace m_year=mode(year) if qtr_since_dx>=0, minmode
gen post=qtr_since_dx>=0
collapse (sum) spend_nodaa (mean) m_year, by(clr_recip_id post)
gen obs=1
collapse (mean) spend_nodaa (sum) obs, by(post m_year)
gen sortyear=m_year
replace sortyear=m_year-3 if post==1
sort sortyear post
drop sortyear

gen cpi1=.
replace cpi1=1.0246 if m_year==2012 & post==0
replace cpi1=1.0239 if m_year==2013 & post==0
replace cpi1=1.0263 if m_year==2014 & post==0
replace cpi1=1.0379 if m_year==2015 & post==0
gen cpi2=.
replace cpi2=1.0239 if m_year==2012 & post==0
replace cpi2=1.0263 if m_year==2013 & post==0
replace cpi2=1.0379 if m_year==2014 & post==0
replace cpi2=1.0251 if m_year==2015 & post==0
gen cpi3=.
replace cpi3=1.0263 if m_year==2012 & post==0
replace cpi3=1.0379 if m_year==2013 & post==0
replace cpi3=1.0251 if m_year==2014 & post==0
replace cpi3=1.0197 if m_year==2015 & post==0

gen hcv_spend3=spend_nodaa if post==1
replace hcv_spend3=spend_nodaa*cpi1*cpi2*cpi3 if post==0

gen adj_hcv_spend3=hcv_spend3-hcv_spend3[_n-1] if post==1

sum adj_hcv_spend3 [aw=obs] if m_year!=2015
estadd scalar year3=r(mean)
local hcv_spend3=r(mean)
restore

/*Year 4 HCV Cost*/
preserve
keep if dx_yq>208 & dx_yq<223
collapse (sum) spend_nodaa, by(clr_recip_id qtr_since_dx service_yq) fast
gen in_range=inrange(qtr_since_dx, -4, 15)
egen range_qtr_count=total(in_range), by(clr_recip_id)
keep if range_qtr_count==20 & in_range==1
drop if qtr_since_dx>=0 & qtr_since_dx<=11
gen year=yofd(dofq(service_yq))
bysort clr_recip_id (service_yq): egen m_year=mode(year) if qtr_since_dx<0, minmode
by clr_recip_id: ereplace m_year=mode(year) if qtr_since_dx>=0, minmode
gen post=qtr_since_dx>=0
collapse (sum) spend_nodaa (mean) m_year, by(clr_recip_id post)
gen obs=1
collapse (mean) spend_nodaa (sum) obs, by(post m_year)
gen sortyear=m_year
replace sortyear=m_year-4 if post==1
sort sortyear post
drop sortyear

gen cpi1=.
replace cpi1=1.0246 if m_year==2012 & post==0
replace cpi1=1.0239 if m_year==2013 & post==0
replace cpi1=1.0263 if m_year==2014 & post==0
gen cpi2=.
replace cpi2=1.0239 if m_year==2012 & post==0
replace cpi2=1.0263 if m_year==2013 & post==0
replace cpi2=1.0379 if m_year==2014 & post==0
gen cpi3=.
replace cpi3=1.0263 if m_year==2012 & post==0
replace cpi3=1.0379 if m_year==2013 & post==0
replace cpi3=1.0251 if m_year==2014 & post==0
gen cpi4=.
replace cpi4=1.0379 if m_year==2012 & post==0
replace cpi4=1.0251 if m_year==2013 & post==0
replace cpi4=1.0197 if m_year==2014 & post==0

gen hcv_spend4=spend_nodaa if post==1
replace hcv_spend4=spend_nodaa*cpi1*cpi2*cpi3*cpi4 if post==0

gen adj_hcv_spend4=hcv_spend4-hcv_spend4[_n-1] if post==1

sum adj_hcv_spend4 [aw=obs] if m_year!=2016
estadd scalar year4=r(mean)
local hcv_spend4=r(mean)
restore

/*Year 5 HCV Cost*/
preserve
keep if dx_yq>208 & dx_yq<219
collapse (sum) spend_nodaa, by(clr_recip_id qtr_since_dx service_yq) fast
gen in_range=inrange(qtr_since_dx, -4, 19)
egen range_qtr_count=total(in_range), by(clr_recip_id)
keep if range_qtr_count==24 & in_range==1
drop if qtr_since_dx>=0 & qtr_since_dx<=15
gen year=yofd(dofq(service_yq))
bysort clr_recip_id (service_yq): egen m_year=mode(year) if qtr_since_dx<0, minmode
by clr_recip_id: ereplace m_year=mode(year) if qtr_since_dx>=0, minmode
gen post=qtr_since_dx>=0
collapse (sum) spend_nodaa (mean) m_year, by(clr_recip_id post)
gen obs=1
collapse (mean) spend_nodaa (sum) obs, by(post m_year)
gen sortyear=m_year
replace sortyear=m_year-5 if post==1
sort sortyear post
drop sortyear

gen cpi1=.
replace cpi1=1.0246 if m_year==2012 & post==0
replace cpi1=1.0239 if m_year==2013 & post==0
gen cpi2=.
replace cpi2=1.0239 if m_year==2012 & post==0
replace cpi2=1.0263 if m_year==2013 & post==0
gen cpi3=.
replace cpi3=1.0263 if m_year==2012 & post==0
replace cpi3=1.0379 if m_year==2013 & post==0
gen cpi4=.
replace cpi4=1.0379 if m_year==2012 & post==0
replace cpi4=1.0251 if m_year==2013 & post==0
gen cpi5=.
replace cpi5=1.0251 if m_year==2012 & post==0
replace cpi5=1.0197 if m_year==2013 & post==0

gen hcv_spend5=spend_nodaa if post==1
replace hcv_spend5=spend_nodaa*cpi1*cpi2*cpi3*cpi4*cpi5 if post==0

gen adj_hcv_spend5=hcv_spend5-hcv_spend5[_n-1] if post==1

sum adj_hcv_spend5 [aw=obs] if m_year!=2017
estadd scalar year5=r(mean)
local hcv_spend5=r(mean)
restore

estadd scalar total=e(year1)+e(year2)+e(year3)+e(year4)+e(year5)

/*3. Table 4, Column 11: Savings from cases averted*/
qui eststo model6: reg spend_nodaa service_yq
estadd scalar year1=0
local trans_save_y1=0

estadd scalar year2=(((diab_tx_y1+hiv_tx_y1)/2)*4*`hcv_spend2'*`enroll_2yr' + ///
((diab_tx_y2+hiv_tx_y2)/2)*4*`hcv_spend1'*`enroll_1yr')*0.9688
local trans_save_y2=e(year2)

estadd scalar year3=(((diab_tx_y1+hiv_tx_y1)/2)*4*`hcv_spend3'*`enroll_3yr' + ///
((diab_tx_y2+hiv_tx_y2)/2)*4*`hcv_spend2'*`enroll_2yr' + ///
((diab_tx_y3+hiv_tx_y3)/2)*4*`hcv_spend1'*`enroll_1yr')*0.9388
local trans_save_y3=e(year3)

estadd scalar year4=(((diab_tx_y1+hiv_tx_y1)/2)*4*`hcv_spend4'*`enroll_4yr' + ///
((diab_tx_y2+hiv_tx_y2)/2)*4*`hcv_spend3'*`enroll_3yr' + ///
((diab_tx_y3+hiv_tx_y3)/2)*4*`hcv_spend2'*`enroll_2yr' + ///
((diab_tx_y4+hiv_tx_y4)/2)*4*`hcv_spend1'*`enroll_1yr')*0.9095
local trans_save_y4=e(year4)

estadd scalar year5=(((diab_tx_y1+hiv_tx_y1)/2)*4*`hcv_spend5'*`enroll_5yr' + ///
((diab_tx_y2+hiv_tx_y2)/2)*4*`hcv_spend4'*`enroll_4yr' + ///
((diab_tx_y3+hiv_tx_y3)/2)*4*`hcv_spend3'*`enroll_3yr' + ///
((diab_tx_y4+hiv_tx_y4)/2)*4*`hcv_spend2'*`enroll_2yr' + ///
((diab_tx_y4+hiv_tx_y4)/2)*4*`hcv_spend1'*`enroll_1yr')*0.8811
local trans_save_y5=e(year5)

estadd scalar total=e(year1)+e(year2)+e(year3)+ ///
e(year4)+e(year5)

/*Table 4, Column 12: Total Savings discounting by 3.22% per year*/
qui eststo model7: reg spend_nodaa service_yq
estadd scalar year1=`direct_save_y1'+`treat_save_y1'+`trans_save_y1'
estadd scalar year2=`direct_save_y2'+`treat_save_y2'+`trans_save_y2'
estadd scalar year3=`direct_save_y3'+`treat_save_y3'+`trans_save_y3'
estadd scalar year4=`direct_save_y4'+`treat_save_y4'+`trans_save_y4'
estadd scalar year5=`direct_save_y5'+`treat_save_y5'+`trans_save_y5'
estadd scalar total=e(year1)+e(year2)+e(year3)+ ///
e(year4)+e(year5)

estadd local space1=" "
esttab model02 model1 model2 model3 model4 /// 
model6 model7 using "$tab/table4.tex", ///
replace style(tex) booktabs fragment ///
drop(_cons service_yq year) ///
mgroups("Stock Treatment Savings" "Flow Treatment Savings" "Transmission Savings" "", ///
pattern(1 0 1 0 1 0 1) span prefix(\multicolumn{@span}{c}{) suffix(}) ///
erepeat(\cmidrule(lr){2-3}\cmidrule(lr){4-5}\cmidrule(lr){6-7})) ///
mlabels( ///
"\begin{tabular}{@{}c@{}}\# Treated \\ from Stock\end{tabular}" ///
"Stock Savings" ///
"\begin{tabular}{@{}c@{}}\# Treated \\ from Flow\end{tabular}" /// 
"\begin{tabular}{@{}c@{}}Flow Savings\end{tabular}" ///
"\begin{tabular}{@{}c@{}}Cases \\ Averted\end{tabular}" /// 
"\begin{tabular}{@{}c@{}}Savings from \\ Cases Averted\end{tabular}" ///
"Total Savings", /// 
pattern(1 1 1 1 1 1) span) ///
nonote compress nogaps nonumber ///
noeqlines eqlabels(none) noobs label ///
scalars("year1 Year 1" "year2 Year 2" "year3 Year 3" ///
"year4 Year 4" "year5 Year 5" "space1 $$$$" "total Total") sfmt(%15.0fc) ///
prehead("\begin{table}[!htbp]\centering" ///
"\caption{Cost-Benefit of the Louisiana Subscription Model}" ///
"\label{tab:cba}" ///
"\resizebox{\textwidth}{!}{%" "\begin{tabular}{lccccccc}" "\toprule") ///
postfoot("\bottomrule" "\end{tabular}}" ///
"\caption*{\parbox{\linewidth} \footnotesize\raggedright\textit{Notes:} Stock savings are calculated by averaging the annual difference-in-difference estimates in columns 3 \& 6 of Table 2 and multiplying these estimates by the number of Louisiana Medicaid members with HCV as of July 2019 adjusted for sample attrition. The number of Medicaid members treated post policy was calculated as the number of members filling prescriptions for a full course of DAA therapy. Savings from post policy treatment was calculated by applying annual Wald estimates from the difference-in-differences model using HCV members with early-stage liver disease averaged across the diabetes and HIV control groups and multiplied by the number of members treated with DAAs post-policy. We calculated 5 years of savings for those treated in the first year of the subscription model, 4 years of savings for those treated in second year, 3 years for those treated in the third year, and so on. All estimates were adjusted for estimated sample attrition. To calculate transmission savings, we first estimated the number of cases averted in each year following the methodology used to generate the estimates in Table 3, averaged across the diabetes and HIV control groups. We estimated savings per case by calculating the average cost of HCV using the difference between average member spending each year following an HCV diagnoses and average spending the year prior to diagnosis (i.e., baseline year spending). To account for secular increases in the cost of medical care, we adjusted baseline year spending by the annual medical CPI. For example, when comparing spending in the first year following diagnosis to baseline year spending for individuals diagnosed in 2013, we multiplied baseline spending by the 2013 medical CPI. When comparing sending in the second year following diagnosis for these individuals, we multiplied baseline spending by the 2013 medical CPI and the 2014 medical CPI. Savings from cases averted was calculated by multiplying the number of cases averted in each year by savings per case. We calculated 5 years of savings for cases averted in the first year of the subscription model, 4 years of savings for cases averted in second year, 3 years for cases averted in the third year, and so on. All estimates were adjusted for estimated sample attrition. Total savings was calculated as the sum of stock savings, savings from post-policy diagnosis and treatment (i.e., flow savings), and savings from cases averted. All savings estimates are discounted by Louisiana's borrowing cost in 2019 of 3.22\%.}}" ///
"\end{table}")

exit
