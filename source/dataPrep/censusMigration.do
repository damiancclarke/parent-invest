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
*** (2) Open 70-82 census, rename comuna
********************************************************************************
use "$DAT/Census7082"

gen oldnumber = cl70a_bplmuni
merge m:1 oldnumber using "$DAT/censusNames1970", gen(_merge70)
drop oldnumber

rename newnumber nnumber
rename cl82a_bpl oldnumber
merge m:1 oldnumber using "$DAT/censusNames1982", gen(_merge82)

replace newnumber=nnumber if _merge70==3
drop nnumber

rename newnumber comunacode2010

merge m:1 comunacode2010 using "$DAT/oldComunas"

exit
*d cl70a_bplmuni cl70a_habmuni cl70a_migbplprov cl70a_mig5muni
*cl82a_bpl cl82a_resprev

