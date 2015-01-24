/* censusPrep.do v0.00           damiancclarke             yyyy-mm-dd:2015-01-24
----|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

This file takes raw census data from 2002, names variables, labels variables co-
nsistently, and produces an output file. This includes comuna names, names of c-
omuna of birth, job type, and so forth.

Note that all merges here are complete, and the total censal population (15,116,
435) is accounted for.

contact: mailto:damian.clarke@economics.ox.ac.uk

*/

vers 11
clear all
set more off
cap log close

********************************************************************************
*** (1) Globals and locals
********************************************************************************
global DAT "~/database/Censo/CENSO_2002/CENSO2002"
global OUT "~/investigacion/2014/ParentalInvestments/data/census"
global LOG "~/investigacion/2014/ParentalInvestments/log"


cap mkdir $OUT
log using "$LOG/censusPrep.txt", text replace

********************************************************************************
*** (2) Open file, merge comuna names
********************************************************************************
use "$DAT/persona.dta"
rename portafolio Portafolios
merge m:1 Portafolios using "$DAT/Portafolios"
drop if _merge==2
drop _merge

merge m:1 Comuna using "$DAT/Comunas"
drop _merge

********************************************************************************
*** (3) Create birth comuna data
********************************************************************************
rename p22a whereBorn
lab def born 1 "This comuna" 2 "Other comuna" 3 "Other country" 9 "Ignored"
lab values whereBorn born

rename Comuna censusComunaCode
rename nombre censusComunaName
rename p22b   Comuna

merge m:1 Comuna using "$DAT/Comunas"

gen birthComunaKnown = _merge==3
replace birthComunaKnown= 2 if whereBorn== 2&_merge==1
replace birthComunaKnown= 3 if whereBorn== 3
replace birthComunaKnown= 9 if whereBorn== 9

lab def know 1 "Known" 2 "Born other unkown comuna" 3 "Overseas" 9 "Ignored"
lab values birthComunaKnown know
gen birthComunaCode = Comuna if _merge==3
drop _merge
rename Comuna birthAllCode
rename nombre birthComunaName

********************************************************************************
*** (4) Name other variables
********************************************************************************

*14537060
