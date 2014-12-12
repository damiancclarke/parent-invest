/* casenPrep.do v0.00            damiancclarke             yyyy-mm-dd:2014-12-11
----|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

This file takes raw CASEN data files from

*/

vers 11
clear all
set more off
cap log close
    
********************************************************************************
*** (1) globals and locals
********************************************************************************
global DAT "~/database/Casen"
global OUT "~/investigacion/2014/ParentalInvestments/data/labor/CASEN"
global LOG "~/investigacion/2014/ParentalInvestments/log"

cap mkdir "$OUT"
log using "$LOG/casenPrep.txt", text replace


********************************************************************************
*** (2) Open files, generate variables
********************************************************************************
foreach y of numlist 1990(2)2000 2003(3)2009 2011 {
    if `y'==2009 local ap "stata"
    if `y'==2011 local ap "stata_06092012"
    
    use "$DAT/`y'/casen`y'`ap'.dta"
    count
    local obs = `r(N)'
    levelsof comu
    local ncom : word count `r(levels)'

    dis "In `y' there are `obs' observations in `ncom' comunas."
}
********************************************************************************
*** (X) Close
********************************************************************************
log close
