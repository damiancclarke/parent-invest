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
global OUT "~/investigacion/2014/ParentalInvestments/results/arsenic/census/graph"
global LOG "~/investigacion/2014/ParentalInvestments/log"

log using "$LOG/eventStudy.txt", text replace

********************************************************************************
*** (2) Open census, Generate variables
********************************************************************************
use "$DAT/census2002_north"

