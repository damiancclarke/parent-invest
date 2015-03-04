/* eventStudy.do v0.00           damiancclarke             yyyy-mm-dd:2015-03-03
----|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

Uses raw census data to format and run event studies.

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

log using "$LOG/eventStudy.txt", text replace

********************************************************************************
*** (2) Open census, Generate variables
********************************************************************************
use "$DAT/census2002_north"

gen byear=2002-age
gen T1=birth_comuna=="antofagasta"|birth_comuna=="mejillones"
gen T2=birth_comuna=="tocopilla"|birth_comuna=="maria elena"|birth_comuna=="calama"


gen posSamp = byear>=1966 & byear<=1976 & T2!=1
gen negSamp = byear>=1954 & byear<=1964 | byear>=1966 & byear<=1976 & T1!=1

gen posTreat = T1==1&byear>=1971
gen negTreat = T1==1&byear>=1959|T2==1&byear>=1971

gen professional = occisco<=2 if occisco!=99

********************************************************************************
*** (2b) Generate positive shock event years
********************************************************************************
foreach num of numlist 0(1)5 {
    local yr = 1971+`num'
    gen time`num' = byear==`yr'&T1==1
    if `num'!= 0 {
        local yr = 1971-`num'
        gen time_`num' = byear==`yr'&T1==1
    }
}

********************************************************************************
*** (2c) Generate negative shock event years
********************************************************************************
foreach num of numlist 0(1)5 {
    local Ayr = 1958+`num'
    local Byr = 1971+`num'
    gen Ntime`num' = byear==`Ayr'&T1==1 | byear==`Byr'&T2==1
    if `num'!= 0 {
        local Ayr = 1958-`num'
        local Byr = 1971-`num'
        gen Ntime_`num' = byear==`Ayr'&T1==1 | byear==`Byr'&T2==1
    }
}



********************************************************************************
*** (3) Event study
********************************************************************************
local pos time_5 time_4 time_3 time_2 time0 time1 time2 time3 time4 time5
local neg Ntime_5 Ntime_4 Ntime_3 Ntime_2 Ntime0 Ntime1 Ntime2 Ntime3 Ntime4 Ntime5

local out $OUT/regression/EventStudy.xls
local trend i.comunacode2000#c.byear
local FE i.byear#i.regioncode2000
local se cluster(comunacode2000)

********************************************************************************
*** (3a) Good shock
********************************************************************************
preserve
keep if posSamp==1

areg professional posTreat `FE' `trend', ab(comunacode2000) `se'
outreg2 posTreat using "`out'", par excel replace lab bdec(3) se bracket nocons

areg professional `pos' `FE' `trend', ab(comunacode2000) `se'
outreg2 `pos' using "`out'", par excel append lab bdec(3) se bracket nocons

restore

********************************************************************************
*** (3b) Bad shock
********************************************************************************
preserve
keep if negSamp==1

areg professional negTreat `FE' `trend', ab(comunacode2000) `se'
outreg2 negTreat using "`out'", par excel replace lab bdec(3) se bracket nocons

areg professional `neg' `FE' `trend', ab(comunacode2000) `se'
outreg2 `neg' using "`out'", par excel append lab bdec(3) se bracket nocons
restore
