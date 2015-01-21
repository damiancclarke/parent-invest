/* laborPrep.do v0.00               DC / SZ                yyyy-mm-dd:2014-10-19
----|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

This file takes raw data from the Chile Unemployment Insurance dataset and conv-
erts it into a format with alternative variable names and labels.

The file can be controlled in section 1, which defines various globals and loca-
ls to determine where data is stored, where it should be output, and so forth.

   contact: mailto:damian.clarke@economics.ox.ac.uk

previous versions
   v0.00: Works with SAFP data

*/

vers 11
clear all
set more off
cap log close

********************************************************************************
*** (1) Globals and locals
********************************************************************************
global DAT "~/database/SAFP"
global OUT "~/investigacion/2014/ParentalInvestments/data/labor/SAFP"
global LOG "~/investigacion/2014/ParentalInvestments/log"
global GRA "~/investigacion/2014/ParentalInvestments/results/descriptives/Income" 
global GEO "~/investigacion/2014/ParentalInvestments/data/Geo"

log using "$LOG/laborPrep.txt", text replace


********************************************************************************
*** (2) Import various datasets
********************************************************************************
use "$DAT/afiliados.dta"

rename v1 ID
rename v2 Sex
rename v3 BirthDate
rename v4 BirthComuna
rename v5 EducLevel
rename v7 CivStatus
rename v8 ResComuna

drop v6 v9

label define educ 0 "None" 1 "Incomplete Primary" 2 "Complete Primary"      /*
*/ 3 "Special-Ed" 4 "Incomplete Secondary" 5 "Complete Secondary"           /*
*/ 6 "Incomplete Secondary (tech)" 7 "Complete Secondary (tech)"            /*
*/ 8 "Tertiary Incomplete (tech)" 9 "Tertiary Complete (tech)"              /*
*/ 10 "Tertiary Incomplete" 11 "Tertiary Complete" 12 "Postgrad Incomplete" /*
*/ 13 "Postgrad Complete" 14 "Preparatory (incomplete)" 15 "Prep (complete)"/*
*/ 16 "Humanities Incomplete" 17 "Humantites Complete"
label values EducLevel educ

label data "SAFP data on affiliates (characteristics and ID)"
save "$OUT/Affiliates", replace

use "$DAT/rentas.dta"
rename v1 ID
rename v2 Employer
rename v3 PayDate
rename v4 Contract
rename v6 JobType
rename v7 JobComuna
rename v8 Income

label define cont 1 "Permanent" 2 "Temporary (per job)"
label define jobs 0 "Not specified" 1 "Farming, hunting" 2 "Fishing"     /*
*/ 3 "Mining" 4 "Non-metallic manufacturing" 5 "Manufacturing"           /*
*/ 6 "Electricity, water, gas" 7 "Construction" 8 "Commerce, household"  /*
*/ 9 "Hotels/restaurants" 10 "Transport and communications" 11 "Finance" /*
*/ 12 "Real Estate" 13 "Defense" 14 "Teaching" 15 "Social and Health"    /*
*/ 16 "Other community services" 17 "Administration" 18 "Foreign companies"
label values Contract cont
label values JobType  jobs 

label data "SAFP data on incomes (may be multiple per person per month)"
save "$OUT/Incomes", replace

********************************************************************************
*** (3) Basic descriptives
********************************************************************************
use "$OUT/Incomes"

gen region=floor(JobComuna/1000)

gen regionClass=region==13
replace regionClass=2 if region==15|region<=5
replace regionClass=3 if regionClass==0
label define regn 1 "Santiago" 2 "North" 3 "South"
label values regionClass regn
	
drop if region==0

gen year=floor(PayDate/100)
gen month=(PayDate/100-year)*100
gen yearmonth=year+(month-1)/12

collapse Income, by(regionClass yearmonth)
keep if yearmonth<2012
	
twoway line Income yearmonth if reg==1 || line Income yearmonth if reg==2    ///
  || line Income yearm if reg==3, scheme(s1color) legend(label(1 "Santiago") ///
  label(2 "North") label(3 "South")) ytitle("Monthly Income in Pesos")       ///
  xtitle("Year")
graph export "$GRA/Income.eps", as(eps) replace


********************************************************************************
*** (4) Merging to make SAFP database with Arsenic data
********************************************************************************
use "$OUT/Affiliates.dta", clear
gen RegionSAFP=floor(JobComuna/1000)
merge 1:m ID using "$OUT/Incomes"
drop if _merge==1
drop _merge

rename ResComuna id
merge m:1 id using "$GEO/arsenicNames"
drop _merge
rename id ResComuna

foreach var of varlist c3057 c5870 c7177 c7879 c8087 c8894 { 
    bys region: egen m=mean(`var') 
    cap drop cflag
    gen cflag=m!=.&`var'==.
    replace `var'=m if `var'==.
    drop m

    replace `var'=0 if `var'==.&RegionSAFP!=4
}
lab var c3057 "Concentration of Arsenic in comuna from 1930-1957"
lab var c5870 "Concentration of Arsenic in comuna from 1958-1970"
lab var c7177 "Concentration of Arsenic in comuna from 1971-1977"
lab var c7879 "Concentration of Arsenic in comuna from 1978-1979"
lab var c8087 "Concentration of Arsenic in comuna from 1980-1987"
lab var c8894 "Concentration of Arsenic in comuna from 1988-1994"
lab var cflag "Replaced missing concentration of arsenic with comuna average"


********************************************************************************
*** (5) Cleaning up
********************************************************************************
lab data "SAFP data: all affiliates and payments, crossed with arsenic data"
save "$OUT/SAFParsenic.dta", replace
log close
