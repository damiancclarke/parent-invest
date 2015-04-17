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

********************************************************************************
*** (2) Use and set-up
********************************************************************************
use "$DAT/census2002_north"



********************************************************************************
*** (X) Clear
********************************************************************************
log close
