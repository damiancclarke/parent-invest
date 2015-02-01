/* descCASEN.do v0.00            damiancclark              yyyy-mm-dd:2015-01-31
----|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

Various descriptive statistics based on CASEN.  Focus here is on completion ages
of education, and labour market evolution.

*/

vers 11
clear all
set more off
cap log close

********************************************************************************
*** (1) globals locals
********************************************************************************
global DAT "~/investigacion/2014/ParentalInvestments/data/labor/CASEN"
global OUT "~/investigacion/2014/ParentalInvestments/results/descriptives/CASEN"
global LOG "~/investigacion/2014/ParentalInvestments/log"

cap mkdir $OUT
log using "$LOG/descCASEN.txt", text replace

********************************************************************************
*** (2) open, var generate
********************************************************************************
use "$DAT/CASENarsenic"

gen antofa = 1 if comuna==2101|comuna==2102
replace antofa = 0 if regionBirth>4&regionBirth<15
drop if antofa==.

gen yrBirth = surveyYr - age
keep if yrBirth>1950&yrBirth<1980

preserve
collapse educYrs, by(yrBirth antofa)
sort yrBirth

#delimit ;
twoway (connect educ yrB if antofa==1)||(connect educ yrB if antofa==0),
title(Yrs Educ) ytitle(Yrs Educ)  xtitle(Year of birth) xline(1971, lpat(dash))
xline(1958, lpat(dot)) legend(lab(1 "Antofagasta") lab(2 "South"))
scheme(s1mono);
graph export "$OUT/CASENyrs.eps", as(eps) replace;
#delimit cr
plot educYrs yrBirth if antofa==1
plot educYrs yrBirth if antofa==0
restore



********************************************************************************
*** (X) Close
********************************************************************************
log close
