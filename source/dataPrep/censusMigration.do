/* censusMigration.do v0.00     damiancclarke              yyyy-mm-dd:2014-03-01
----|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

Note that newnumber is comuna number from 2010 onwards from crosswalk file.
*/

vers 11
clear all
set more off
cap log close

********************************************************************************
*** (1) Globals and locals
********************************************************************************
global DAT "~/investigacion/2014/ParentalInvestments/data/census"
global LOG "~/investigacion/2014/ParentalInvestments/log"

log using "$LOG/censusMigration.txt", text replace

********************************************************************************
*** (2a) Open 70-82 census, generate 1970 birth comuna
********************************************************************************
use "$DAT/Census7082"
gen oldnumber = cl70a_bplmuni
merge m:1 oldnumber using "$DAT/censusNames1970", gen(_merge70)

gen birthComuna = newnumber if oldnumber<650&oldnumber!=1
gen birthCode = .
replace birthCode = 1 if birthComuna!=.
replace birthCode = 2 if oldnumber>650&oldnumber!=.
replace birthCode = 3 if oldnumber==650

drop oldnumber newnumber
gen  oldnumber = cl70a_muni5yr
merge m:1 oldnumber using "$DAT/censusNames1970b", gen(_merge70b)
replace birthComuna = newnumber if cl70a_mig5muni==1&cl70a_bplmuni==1
replace birthCode = 1 if cl70a_mig5muni==1&cl70a_bplmuni==1
replace birthCode = 2 if _merge70b==3&birthComuna==.

drop oldnumber oldname newnumber

********************************************************************************
*** (2b) Generate 1982 birth comuna
********************************************************************************
rename cl82a_bpl oldnumber
merge m:1 oldnumber using "$DAT/censusNames1982", gen(_merge82)

replace birthComuna = newnumber if _merge82==3
replace birthCode = 1 if newnumber!=.
replace birthCode = 3 if oldnumber>=702&oldnumber!=.

********************************************************************************
*** (3) Merge renamed comunas into crosswalk file
********************************************************************************
gen comunacode2010 = birthComuna
drop oldnumber newnumber _merge* oldname newname

merge m:1 comunacode2010 using "$DAT/oldComunas"
drop if _merge==2
drop _merge

lab def codes 1 "Know birth comuna" 2 "Unknown/unreported" 3 "Foreigh country"
lab val birthCode codes

********************************************************************************
*** (4) Save, clean
********************************************************************************
lab dat "IPUMS census (1970, 1982) merged to official birth comuna IDs"
save "$DAT/Census7082_birthcomuna", replace

log close
