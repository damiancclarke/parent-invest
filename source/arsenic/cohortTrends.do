/* cohortTrends.do v0.00        damiancclarke             yyyy-mm-dd:2014-01-28
----|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

Examines trends in educational attainment, jobs by regions and birth cohort.


*/

vers 11
clear all
set more off
cap log close

********************************************************************************
*** (1) Globals and locals
********************************************************************************
global DAT "~/investigacion/2014/ParentalInvestments/data/census"
global OUT "~/investigacion/2014/ParentalInvestments/results/arsenic/trends"
global LOG "~/investigacion/2014/ParentalInvestments/log"

log using "$LOG/arsenicTrends.txt", text replace

local ant 1
local reg 0

********************************************************************************
*** (2) Generate variables
********************************************************************************
use "$DAT/census2002"

gen byear   = 2002-age
keep if byear>1950&byear<1980

gen bregion = floor(bplclComuna/1000)

gen antofa  = bplclName=="antofagasta"|bplclName=="mejillones"
replace antofa = . if antofa!=1&bregion<5|bregion==15

gen region = 1 if bregion==2
replace region = 2 if bregion==1|bregion==3|bregion==15
replace region = 3 if bregion>3&bregion<15



gen active= empstat<=2
gen employed= empstat==1

gen professional= occisco<=2
replace professional=. if occisco==99
gen technician_clark= occisco<=4
replace technician_clark=. if occisco==99

gen lessprim = edattan == 1
gen prim     = edattan == 2
gen seccomp  = edattan == 3
gen tercomp  = edattan == 4

local y active employed professional technicia yrschl lessprim prim secco tercom

********************************************************************************
*** (3) Collapse and graph
********************************************************************************
if `ant'==1 {
collapse `y', by(byear antofa)

foreach x of local y {
    twoway (connect `x' byear if antofa==1)||(connect `x' byear if antofa==0), ///
        title(`x') ytitle(`x') xtitle(Year of birth) xline(1971, lpat(dash))   ///
        xline(1958, lpat(dot)) legend(lab(1 "Antofagasta") lab(2 "South"))     ///
        scheme(s1mono)
    graph export "$OUT/`x'1971.eps", as(eps) replace
}
}

if `reg'==1 {
    collapse `y', by(byear region)
    foreach x of varlist `y' {
    twoway (connect `x' byear if region==1)||(connect `x' byear if region==2) ///
         ||(connect `x' byear if region==3), title(`x') ytitle(`x')           ///
         xtitle(Year of birth) xline(1971, lpat(dash)) xline(1958, lpat(dot)) ///
        legend(lab(1 "Region II") lab(2 "Regions I, III, XV") lab(3 "Other")) ///
        scheme(s1color)
    graph export "$OUT/`x'region.eps", as(eps) replace
    }
}
