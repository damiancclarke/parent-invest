/* eventStudy.do v0.00           damiancclarke             yyyy-mm-dd:2015-03-03
----|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

Uses raw census data to format and run event studies. This file requires the r-
aw microdata file "census2002_north".  All globals should be set in section (1).
All other discretionary choices are made in the locals in this section (ie tren-
ds, fixed effects, std errors).

I have changed the conditions from Shuang's code slightly.  They are exactly the
same, but remove some parentheses which made it a bit hard for me to read.  All
else should be the same, although perhaps with syntax altered as per Stata 11.


contact: damian.clarke@economics.ox.ac.uk

*/

vers 11
clear all
set more off
cap log close

********************************************************************************
*** (1) globals, locals
********************************************************************************
global DAT "~/investigacion/2014/ParentalInvestments/data/census"
global OUT "~/investigacion/2014/ParentalInvestments/results/arsenic/census"
global LOG "~/investigacion/2014/ParentalInvestments/log"
global GEO "~/investigacion/2014/ParentalInvestments/data/Geo"

cap mkdir "$OUT/graph"
cap mkdir "$OUT/regression"

log using "$LOG/eventStudy.txt", text replace

local yvars professional technician technician_clark schooling active employed 
local pos posN5 posN4 posN3 posN2 posP*
local neg negN5 negN4 negN3 negN2 negP*

local trend i.comunacode2000#c.byear
local FE i.byear
local se cluster(comunacode2000)

********************************************************************************
*** (2) Open census, Generate variables
********************************************************************************
use "$DAT/census2002"
keep if regioncode2000==2|regioncode2000==5


gen byear=2002-age
*gen T1=birth_comuna=="antofagasta"|birth_comuna=="mejillones"
*gen T2=birth_comuna=="tocopilla"|birth_comuna=="maria elena"|birth_comuna=="calama"
gen T1=name_noaccent=="Antofagasta"|name_noaccent=="Mejillones"
gen T2=name_noaccent=="Tocopilla"|name_noaccent=="Maria Elena"|name_noaccent=="Calama"



gen posSamp = byear>=1966 & byear<=1976 & T2!=1 | byear>=1974&byear<=1980
gen negSamp = byear>=1954 & byear<=1964 | byear>=1966 & byear<=1976 & T1!=1

gen posTreat = T1==1&byear>=1971
gen negTreat = T1==1&byear>=1959|T2==1&byear>=1971

gen professional     = occisco<=2 if occisco!=99
gen technician       = occisco<=3 if occisco!=99
gen technician_clark = occisco<=4 if occisco!=99
gen schooling        = yrschl     if yrschl!=99
gen active           = empstat<=2
gen employed         = empstat==1


gen completeUniversity5 = p26a==15&p26b>=5
gen completeUniversity4 = p26a==15&p26b>=4
gen someUniversity      = p26a==15
gen someCollege         =  p26a==12|p26a==13|p26a==14|p26a==15


********************************************************************************
*** (2b) Generate positive shock event years
********************************************************************************
foreach num of numlist 0(1)5 {
    local Ayr = 1978+`num'
    local Byr = 1971+`num'
    gen posP`num' = byear==`Byr'&T1==1 | byear==`Ayr'&T2==1
    if `num'!= 0 {
        local Ayr = 1978-`num'
        local Byr = 1971-`num'
        gen posN`num' = byear==`Byr'&T1==1 | byear==`Ayr'&T2==1
    }
}

********************************************************************************
*** (2c) Generate negative shock event years
********************************************************************************
foreach num of numlist 0(1)5 {
    local Ayr = 1959+`num'
    local Byr = 1971+`num'
    gen negP`num' = byear==`Ayr'&T1==1 | byear==`Byr'&T2==1
    if `num'!= 0 {
        local Ayr = 1959-`num'
        local Byr = 1971-`num'
        gen negN`num' = byear==`Ayr'&T1==1 | byear==`Byr'&T2==1
    }
}
drop negN1 posN1

********************************************************************************
*** (3) Event study
********************************************************************************
local out $OUT/regression/EventStudy.xls

cap rm "`out'"
cap rm "$OUT/regression/EventStudy.txt"


********************************************************************************
*** (3a) Good shock
********************************************************************************
preserve
keep if posSamp==1
gen time = _n-6 in 1/10


foreach y of varlist `yvars' someCollege someUniversity {
    areg `y' posTreat `FE' `trend', ab(comunacode2000) `se'
    outreg2 posTreat using "`out'", par excel lab bdec(3) se bracket nocons

    areg `y' `pos' `FE' `trend', ab(comunacode2000) `se'
    outreg2 `pos' using "`out'", par excel lab bdec(3) se bracket nocons

    local j=1
    qui gen est=0 in 5
    qui gen uCI=0 in 5
    qui gen lCI=0 in 5
    foreach var of varlist `pos' {
        if `j'==5 local ++j
        qui replace est = _b[`var'] in `j'
        qui replace uCI = _b[`var']+1.96*_se[`var'] in `j'
        qui replace lCI = _b[`var']-1.96*_se[`var'] in `j'
        local ++j
    }
    list est time uCI lCI in 1/10
    #delimit ;
    twoway line est time ||
           line uCI time, lpattern(dash) ||
           line lCI time, lpattern(dash)
           scheme(s1mono) ytitle("`y'") yline(0, lpattern(dot))
           legend(order(1 "Point Estimate" 2 "95% CI"))
           note("Year -1 is omitted as the base case.");
    graph export "$OUT/graph/PositiveEvent_`y'.eps", as(eps) replace;
    #delimit cr
    drop est uCI lCI
}
restore

********************************************************************************
*** (3b) Bad shock
********************************************************************************
preserve
keep if negSamp==1
gen time = _n-6 in 1/10

foreach y of varlist `yvars' someCollege someUniversity {
    areg `y' negTreat `FE' `trend', ab(comunacode2000) `se'
    outreg2 negTreat using "`out'", par excel lab bdec(3) se bracket nocons

    areg `y' `neg' `FE' `trend', ab(comunacode2000) `se'
    outreg2 `neg' using "`out'", par excel lab bdec(3) se bracket nocons

    local j=1
    qui gen est=0 in 5
    qui gen uCI=0 in 5
    qui gen lCI=0 in 5
    foreach var of varlist `neg' {
        if `j'==5 local ++j
        qui replace est = _b[`var'] in `j'
        qui replace uCI = _b[`var']+1.96*_se[`var'] in `j'
        qui replace lCI = _b[`var']-1.96*_se[`var'] in `j'
        local ++j
    }
    list est time uCI lCI in 1/10
    #delimit ;
    twoway line est time ||
           line uCI time, lpattern(dash) ||
           line lCI time, lpattern(dash)
           scheme(s1mono) ytitle("`y'") yline(0, lpattern(dot))
           legend(order(1 "Point Estimate" 2 "95% CI"))
           note("Year -1 is omitted as the base case.");
    graph export "$OUT/graph/NegativeEvent_`y'.eps", as(eps) replace;
    #delimit cr
    drop est uCI lCI
}
restore

