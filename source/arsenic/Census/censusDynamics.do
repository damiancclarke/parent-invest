/* censusDynamics.do v0.00       damiancclarke             yyyy-mm-dd:2015-04-17
----|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

Takes census data to create trends and to examine the dynamic effects of the ar-
senic reform in Antofagasta in 1959/1971.

Currently, this is a 30% sample of the rest of the country, rather than all peo-
ple (see sampler variable)
*/

vers 11
clear all
set more off
cap log close

********************************************************************************
*** (1) globals and locals
********************************************************************************
global DAT "~/investigacion/2014/ParentalInvestments/data/census"
global OUT "~/investigacion/2014/ParentalInvestments/results/arsenic/census/dynamics/r1_4"
global LOG "~/investigacion/2014/ParentalInvestments/log"

cap mkdir $OUT
log using "$LOG/censusDynamics.txt", text replace

local Y schooling completeUniv* someUniv active employed professional technic
********************************************************************************
*** (2) Use and set-up
********************************************************************************
use "$DAT/census2002"
cap rename bplclName birth_comuna
gen birthYear = 2002 - age
keep if birthYear >= 1945 & birthYear <= 1975
keep if geo1b_cl < 5
*keep if geo1b_cl==2

generat T1 = 0
replace T1 = 1 if  birth_comuna=="antofagasta"|birth_comuna=="mejillones"
replace T1 = 2 if birth_comuna=="tocopilla"|birth_comuna=="maria Elena"|/*
               */ birth_comuna=="calama"
*gen sampler = runiform() if T1 == 0
*keep if sampler>=0.7
*drop sampler

gen schooling = yrschl if yrschl != 99
gen completeUniversity5= educcl==15 & p26b>=5
gen completeUniversity4= educcl==15 & p26b>=4
gen someUniversity= educcl==15

gen active= empstat<=2
gen employed= empstat==1

gen professional = occisco<=2 if occisco != 99
gen technician   = occisco<=3 if occisco != 99


********************************************************************************
*** (3) Birth cohort trends
********************************************************************************
preserve
collapse `Y', by(birthYear T1)
foreach outcome of varlist `Y' {
    dis "Graphing `outcome'"
    #delimit ;
    twoway connected `outcome' birthYear if T1==1, lpattern(dash) ||
           connected `outcome' birthYear if T1==0, scheme(s1mono)
    legend(label(1 "Antofagasta/Mejillones") label(2 "Rest of Regions I-IV"))
    xtitle("Birth Year") xlabel(1945[5]1975, angle(55)) xline(1958 1971);
    graph export "$OUT/Trend_`outcome'.eps", replace as(eps);
    #delimit cr
}

restore
preserve
cap mkdir "$OUT/gender"
gen gender = "F" if sex==2
replace gender = "M" if sex==1

collapse `Y', by(birthYear T1 gender)
foreach g in F M {
    foreach outcome of varlist `Y' {
        dis "Graphing `outcome'"
        #delimit ;
        twoway connected `outcome' birthYear if T1==1&gend=="`g'", lpattern(dash) ||
               connected `outcome' birthYear if T1==0&gend=="`g'", scheme(s1mono)
        legend(lab(1 "Antofagasta/Mejillones") lab(2 "Rest of Regions I-IV"))
        xtitle("Birth Year") xlabel(1945[5]1975, angle(55)) xline(1958 1971);
        graph export "$OUT/gender/Trend_`outcome'_`g'.eps", replace as(eps);
        #delimit cr
    }
}
restore
exit
********************************************************************************
*** (4a) Regressions generate variables
********************************************************************************
gen InUtero = birthYear>=1960&birthYear<=1972 & T1==1

foreach a of numlist 0(1)16 {
    local lYear = 1959-`a'
    local uYear = 1971-`a'
    dis "low year is `lYear', high year is `uYear'"

    gen Age`a' = birthYear>=`lYear' & birthYear<=`uYear' & T1==1
    tab Age`a'
}


********************************************************************************
*** (4b) Regressions
********************************************************************************
local se abs(birth_comuna) cluster(birth_comuna)
*local cd if birthYear>=1955

foreach var of varlist `Y' {
    areg `var' i.birthYear i.regioncode2000#c.birthYear InUtero Age* `cd', `se'
}

********************************************************************************
*** (X) Clear
********************************************************************************
log close
