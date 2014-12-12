/* casenPrep.do v0.00            damiancclarke             yyyy-mm-dd:2014-12-11
----|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

This file takes raw CASEN data files from


* Note: sufficient to generate individual person identifiers:
    bys segmento f (o): gen n=_n 
  now id would be: segmento f n, where n==o

* Still to do: look at enrolment of children, health of children


o8      = type of activity employer
o9/o10  = type of activity employee
o11-o13 = contract for work
o16     = how long employed
o20     = other incomes
o30     = what doing in Nov 2000 (or 3 yrs ago I suspect)

activ = o21 in 1990

check (recode) rama year by year. In 2011 rama1 seems to be the relevant option.


contact: damian.clarke@economics.ox.ac.uk
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
*foreach y of numlist 2003 {
    if `y'==2009 local ap "stata"
    if `y'==2011 local ap "stata_06092012"

        
    use "$DAT/`y'/casen`y'`ap'.dta"
    count
    local obs = `r(N)'
    levelsof comu
    local ncom : word count `r(levels)'
    dis "In `y' there are `obs' observations in `ncom' comunas."

    if `y'==2009 rename o_2009 o
    if `y'==2011 rename expr_r2 expr
    if `y'==2011 rename expc_r2 expc
    if `y'==2011 rename rama1 rama
    if `y'==2011 rename oficio1 oficio
    
    cap rename r      region
    *cap rename p      provincia
    cap rename comu   comuna
    rename o          person
    rename expr       WTregional
    rename expc       WTcomunal
    rename numper     familySize
    rename esc        educYrs
    rename rama       jobArea
    rename oficio     jobType
    rename sexo       gender
    rename edad       age
    rename yopraj     incomeJob
    
    
    gen rural      = z-1
    *gen employed   = activ==1 if activ<3
    *gen unemployed = activ==2 if activ<3
    gen surveyYr    = `y'

    *lab var employed   "1 if active, 0 if unemployed"
    *lab var unemployed "0 if unemployed, 1 if active"
    
    #delimit ;
    keep region comuna person WT* familySize educYrs jobArea jobType
    gender age incomeJob rural surveyYr;
    #delimit cr

    tempfile f`y'
    save `f`y''
}

clear
append using `f1990' `f1992' `f1994' `f1996' `f1998' `f2000' `f2003' `f2006' /*
*/ `f2009' `f2011'


********************************************************************************
*** (X) Close
********************************************************************************
save "$OUT/CASENmerged", replace
log close
