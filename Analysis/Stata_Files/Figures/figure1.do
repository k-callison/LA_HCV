clear
set more off

global data "/Users/kcallison/Dropbox/Projects/LA_HCV/analysis/data/Figure_1_Data"

/****Figure 1a - Average DAA Medicaid Prescription Price in Southern States******/
use "/Users/kcallison/Dropbox/Projects/LA_HCV/analysis/data/Figure_1_Data/DAA_LRX_file.dta", clear
keep if inlist(state,"AL","AR","DE","FL","GA","LA","MD","MS") | ///
inlist(state,"NC","SC","TN","TX","VA","WV")
keep if medicaid=="1"
destring year, replace
destring quarter, replace
gen yq=yq(year,quarter)

merge m:1 drug yq using "$data/daa_price_calc.dta", keep(match) nogen
destring rxcount, replace

collapse (sum) rxcount (mean) pills (mean) price, by(drug yq)
gen drug_spend=rxcount*pills*price
bysort yq (drug): egen sum_rx=sum(rxcount)
by yq: egen sum_spend=sum(drug_spend)
collapse (mean) sum_spend (mean) sum_rx, by(yq)
gen avg_price=sum_spend/sum_rx

label def dates 230 "Jul 2017" 234 "Jul 2018" 238 "Jul 2019" ///
242 "Jul 2020" 246 "Jul 2021" 250 "Jul 2022" 254 "Jul 2023"
label val yq dates

format avg_price %13.0fc
twoway connected avg_price yq, color(black) msize(small) msymbol(O) || ///
pcarrowi 37500 240 32000 238.2, ///
xline(238, lpattern(dash)) xlabel(230(4)254, labsize(small) valuelabel angle(45)) ///
ylabel(0(20000)80000, gmax grid glcolor(gs14) glwidth(vthin)) ///
xtitle("") ytitle("Average DAA Prescription Price", size(small)) scheme(lean2) ///
legend(off) ///
text(38500 244 "Subscription Model Begins", size(small))
gr export "/Users/kcallison/Dropbox/Projects/LA_HCV/analysis/data/Figure_1_Data/fig_1a.eps", replace

/*Counterfactual 2 Spending Estimate*/
set obs 30
replace yq=256 in 29
replace yq=257 in 30
replace avg_price=avg_price[_n-1] if avg_price==.
gen la_med_rx_stock=.
replace la_med_rx_stock=101 if yq==228
replace la_med_rx_stock=172 if yq==229
replace la_med_rx_stock=148 if yq==230
replace la_med_rx_stock=146 if yq==231
replace la_med_rx_stock=197 if yq==232
replace la_med_rx_stock=271 if yq==233
replace la_med_rx_stock=316 if yq==234
replace la_med_rx_stock=308 if yq==235
replace la_med_rx_stock=262 if yq==236
replace la_med_rx_stock=267 if yq==237
replace la_med_rx_stock=1349 if yq==238
replace la_med_rx_stock=885 if yq==239
replace la_med_rx_stock=653 if yq==240
replace la_med_rx_stock=333 if yq==241
replace la_med_rx_stock=387 if yq==242
replace la_med_rx_stock=360 if yq==243
replace la_med_rx_stock=335 if yq==244
replace la_med_rx_stock=316 if yq==245
replace la_med_rx_stock=213 if yq==246
replace la_med_rx_stock=209 if yq==247
replace la_med_rx_stock=196 if yq==248
replace la_med_rx_stock=203 if yq==249
replace la_med_rx_stock=204 if yq==250
replace la_med_rx_stock=172 if yq==251
replace la_med_rx_stock=172 if yq==252
replace la_med_rx_stock=149 if yq==253
replace la_med_rx_stock=136 if yq==254
replace la_med_rx_stock=119 if yq==255
replace la_med_rx_stock=130 if yq==256
replace la_med_rx_stock=135 if yq==257
gen la_med_rx_flow=.
replace la_med_rx_flow=144 if yq==238
replace la_med_rx_flow=334 if yq==239
replace la_med_rx_flow=408 if yq==240
replace la_med_rx_flow=235 if yq==241
replace la_med_rx_flow=346 if yq==242
replace la_med_rx_flow=364 if yq==243
replace la_med_rx_flow=412 if yq==244
replace la_med_rx_flow=368 if yq==245
replace la_med_rx_flow=327 if yq==246
replace la_med_rx_flow=358 if yq==247
replace la_med_rx_flow=300 if yq==248
replace la_med_rx_flow=427 if yq==249
replace la_med_rx_flow=364 if yq==250
replace la_med_rx_flow=344 if yq==251
replace la_med_rx_flow=365 if yq==252
replace la_med_rx_flow=347 if yq==253
replace la_med_rx_flow=319 if yq==254
replace la_med_rx_flow=295 if yq==255
replace la_med_rx_flow=266 if yq==256
replace la_med_rx_flow=305 if yq==257
replace la_med_rx_flow=0 if la_med_rx_flow==.
gen la_med_rx_total=la_med_rx_stock+la_med_rx_flow

gen counter2_spend=avg_price*la_med_rx_total
egen sum_counter2_spend=sum(counter2_spend) if yq>=238
format sum_counter2_spend %13.0fc
sum sum_counter2_spend

sum la_med_rx_stock if yq<238

/****Figure 1b - Number Individuals Treated with DAAs in Louisiana Medicaid, Louisiana
Non-Medicaid, and Southern States Medicaid******/
use "/Users/kcallison/Dropbox/Projects/LA_HCV/analysis/data/Figure_1_Data/DAA_LRX_file.dta", clear
destring year, replace
destring quarter, replace
gen yq=yq(year,quarter)
destring rxcount, replace
destring medicaid, replace

collapse (sum) rxcount, by(medicaid state yq)

gen person_count=.
replace person_count=82 if state=="LA" & medicaid==1 & yq==228
replace person_count=128 if state=="LA" & medicaid==1 & yq==229
replace person_count=175 if state=="LA" & medicaid==1 & yq==230
replace person_count=195 if state=="LA" & medicaid==1 & yq==231
replace person_count=207 if state=="LA" & medicaid==1 & yq==232
replace person_count=224 if state=="LA" & medicaid==1 & yq==233
replace person_count=251 if state=="LA" & medicaid==1 & yq==234
replace person_count=242 if state=="LA" & medicaid==1 & yq==235
replace person_count=223 if state=="LA" & medicaid==1 & yq==236
replace person_count=221 if state=="LA" & medicaid==1 & yq==237
replace person_count=1098 if state=="LA" & medicaid==1 &  yq==238
replace person_count=1334 if state=="LA" & medicaid==1 & yq==239
replace person_count=1205 if state=="LA" & medicaid==1 & yq==240
replace person_count=795 if state=="LA" & medicaid==1 & yq==241
replace person_count=730 if state=="LA" & medicaid==1 & yq==242
replace person_count=737 if state=="LA" & medicaid==1 & yq==243
replace person_count=750 if state=="LA" & medicaid==1 & yq==244
replace person_count=908 if state=="LA" & medicaid==1 & yq==245
replace person_count=577 if state=="LA" & medicaid==1 & yq==246
replace person_count=484 if state=="LA" & medicaid==1 & yq==247
replace person_count=514 if state=="LA" & medicaid==1 & yq==248
replace person_count=632 if state=="LA" & medicaid==1 & yq==249
replace person_count=539 if state=="LA" & medicaid==1 & yq==250
replace person_count=574 if state=="LA" & medicaid==1 & yq==251
replace person_count=558 if state=="LA" & medicaid==1 & yq==252
replace person_count=548 if state=="LA" & medicaid==1 & yq==253
replace person_count=394 if state=="LA" & medicaid==1 & yq==254
replace person_count=403 if state=="LA" & medicaid==1 & yq==255

replace person_count=626 if state=="LA" & medicaid==0 & yq==228
replace person_count=753 if state=="LA" & medicaid==0 & yq==229
replace person_count=621 if state=="LA" & medicaid==0 & yq==230
replace person_count=726 if state=="LA" & medicaid==0 & yq==231
replace person_count=723 if state=="LA" & medicaid==0 & yq==232
replace person_count=633 if state=="LA" & medicaid==0 & yq==233
replace person_count=526 if state=="LA" & medicaid==0 & yq==234
replace person_count=533 if state=="LA" & medicaid==0 & yq==235
replace person_count=503 if state=="LA" & medicaid==0 & yq==236
replace person_count=565 if state=="LA" & medicaid==0 & yq==237
replace person_count=520 if state=="LA" & medicaid==0 &  yq==238
replace person_count=552 if state=="LA" & medicaid==0 & yq==239
replace person_count=542 if state=="LA" & medicaid==0 & yq==240
replace person_count=435 if state=="LA" & medicaid==0 & yq==241
replace person_count=400 if state=="LA" & medicaid==0 & yq==242
replace person_count=384 if state=="LA" & medicaid==0 & yq==243
replace person_count=371 if state=="LA" & medicaid==0 & yq==244
replace person_count=456 if state=="LA" & medicaid==0 & yq==245
replace person_count=383 if state=="LA" & medicaid==0 & yq==246
replace person_count=394 if state=="LA" & medicaid==0 & yq==247
replace person_count=413 if state=="LA" & medicaid==0 & yq==248
replace person_count=415 if state=="LA" & medicaid==0 & yq==249
replace person_count=406 if state=="LA" & medicaid==0 & yq==250
replace person_count=400 if state=="LA" & medicaid==0 & yq==251
replace person_count=406 if state=="LA" & medicaid==0 & yq==252
replace person_count=420 if state=="LA" & medicaid==0 & yq==253
replace person_count=358 if state=="LA" & medicaid==0 & yq==254
replace person_count=421 if state=="LA" & medicaid==0 & yq==255

gen rx_person=rxcount/person_count
bysort medicaid yq: ereplace rx_person=max(rx_person)

sort state yq medicaid
replace person_count=rxcount/rx_person

keep if inlist(state,"AL","AR","DE","FL","GA","LA","MD","MS") | ///
inlist(state,"NC","SC","TN","TX","VA","WV")
gen treat=state=="LA"
collapse (mean) person_count, by(yq treat medicaid)

label def dates 230 "Jul 2017" 234 "Jul 2018" 238 "Jul 2019" ///
242 "Jul 2020" 246 "Jul 2021" 250 "Jul 2022" 254 "Jul 2023"
label val yq dates

format person_count %13.0fc
twoway connected person_count yq if medicaid==1 & treat==1, color(black) msize(small) msymbol(O) || ///
connected person_count yq if medicaid==0 & treat==1, color(black) msize(small) msymbol(D) lpattern(dash) || ///
connected person_count yq if medicaid==1 & treat==0, color(black) msize(small) msymbol(T) lpattern(shortdash) || ///
pcarrowi 1250 235.75 1225 237.7, ///
xline(238, lpattern(dash)) xlabel(230(4)254, labsize(small) valuelabel angle(45)) ///
ylabel(0(300)1500, gmax grid glcolor(gs14) glwidth(vthin)) ///
xtitle("") ytitle("Individuals Treated with DAAs", size(small)) scheme(lean2) ///
legend(order(1 "Louisiana Medicaid" 2 "Louisiana Non-Medicaid" /// 
3 "Southern Medicaid States") pos(6) col(2) size(small)) ///
text(1300 232 "Subscription Model Begins", size(small))
gr export "/Users/kcallison/Dropbox/Projects/LA_HCV/analysis/data/Figure_1_Data/fig_1b.eps", replace

