/* casenEstimates.do v0.00       damiancclarke             yyyy-mm-dd:2014-12-11
----|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

This file takes data prepared in casenPrep.do, and runs estimates of the form:

y_ijt = 


   contact: damian.clarke@economics.ox.ac.uk

*/

vers 11
clear all
set more off
cap log close

********************************************************************************
*** (1) globals, locals
********************************************************************************
global DAT "~/investigacion/2014/ParentalInvestments/data/labor/CASEN"
global OUT "~/investigacion/2014/ParentalInvestments/results/labor/CASEN"

cap mkdir $OUT

