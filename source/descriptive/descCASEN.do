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
global DAT "~/database/Casen/2003/"
global OUT "~/investigacion/2014/ParentalInvestments/results/descriptives/CASEN"
global LOG "~/investigacion/2014/ParentalInvestments/log"

cap mkdir $OUT
log using "$LOG/descCASEN.txt", text replace

********************************************************************************
*** (2) open, var generate
********************************************************************************
use "$DAT/casen2003"

rename esc yrsEduc
gen employed   = activ==1&(activ!=3|activ!=.)
gen unemployed = activ==2&(activ!=3|activ!=.)

gen profesional = oficio == 2 if edad>=18
gen technician  = oficio == 3 if edad>=18
gen unqualified = oficio == 9 if edad>=18

gen attendEduc = e2 == 1


********************************************************************************
*** (3) make graphs
********************************************************************************
preserve
keep if edad<80
local var yrsEduc employed unemployed profesional technician unqualif attendE
collapse `var' [pw=expr], by(edad)
sort edad

foreach var of varlist `var' {
    #delimit ;
    twoway (connect `var' edad),  title("Percent `var' by Age")
    ytitle(`var') xtitle("Age") note("Based on CASEN 2003") scheme(s1mono);
    graph export "$OUT/CASEN2003`var'.eps", as(eps) replace;
    #delimit cr
}
restore

preserve
gen antofa = comu==2301|comu==2302
keep if edad<80
local var yrsEduc employed unemployed profesional technician unqualif attendE
collapse `var' [pw=expr], by(edad antofa)
sort edad

foreach var of varlist `var' {
    #delimit ;
    twoway (connect `var' edad if antofa==1) || (connect `var' edad if anto==0),
    title("Percent `var' by Age") ytitle(`var') xtitle("Age")
    note("Based on CASEN 2003") scheme(s1mono)
    legend(label(1 "Antofagasta/Mejillones") label(2 "Rest of Country"));
    graph export "$OUT/CASEN2003`var'Antofagasta.eps", as(eps) replace;
    #delimit cr
}
restore


********************************************************************************
*** (X) Close
********************************************************************************
log close
