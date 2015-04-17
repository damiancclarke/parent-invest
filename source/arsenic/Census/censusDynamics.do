/* censusDynamics.do v0.00       damiancclarke             yyyy-mm-dd:2015-04-17
----|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

Takes census data to create trends and to examine the dynamic effects of the ar-
senic reform in Antofagasta in 1959/1971.

*/

vers 11
clear all
set more off
cap log close

********************************************************************************
*** (1) globals and locals
********************************************************************************
global DAT "~/investigacion/2014/ParentalInvestments/data/census"
global OUT "~/investigacion/2014/ParentalInvestments/results/arsenic/census/dynamics"
global LOG "~/investigacion/2014/ParentalInvestments/log"

cap mkdir $OUT
log using "$LOG/censusDynamics.txt", text replace

local Y schooling completeUniv* someUniv active employed professional technic
********************************************************************************
*** (2) Use and set-up
********************************************************************************
use "$DAT/census2002"
gen birthYear = 2002 - age
keep if birthYear >= 1945 & birthYear <= 1975


gen T1 =  birth_comuna=="antofagasta"|birth_comuna=="mejillones"
replace T1 = 2 if birth_comuna=="tocopilla"|birth_comuna=="maria Elena"|/*
               */ birth_comuna=="calama"

gen schooling = yrschl if yrschl != 99
gen completeUniversity5= p26a==15&p26b>=5
gen completeUniversity4= p26a==15&p26b>=4
gen someUniversity= p26a==15

gen active= empstat<=2
gen employed= empstat==1

gen professional = occisco<=2 if occisco != 99
gen technician   = occisco<=3 if occisco != 99


********************************************************************************
*** (3) Birth cohort trends
********************************************************************************
collapse `Y', by(birthYear T1)
foreach outcome of varlist `Y' {
    dis "Graphing `outcome'"
    #delimit ;
    twoway line `outcome' birthYear if T1==1, lpattern(dash) ||
           line `outcome' birthYear if T1==0, scheme(s1mono)
    legend(label(1 "Antofagasta/Mejillones") label(2 "Rest of Region I-IV"))
    xtitle("Birth Year") xlabel(minmax) xline(1958 1971);
    graph export "$OUT/Trend_`outcome'.eps", replace as(eps);
    #delimit cr
}

********************************************************************************
*** (X) Clear
********************************************************************************
log close
