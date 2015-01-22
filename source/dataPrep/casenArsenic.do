/* casenPrep.do v0.00            damiancclarke             yyyy-mm-dd:2014-12-11
----|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

This file takes raw CASEN data files from the years 2006-2011, and generates la-
bor variables, along with education and comuna identifiers.  This can then be m-
erged with data on arsenic concentrations. The surveys used are 2006, 2009
and 2011 (ie all surveys post-2003). We do not use the surveys for earlier years
as these don't have identifiers for comuna of birth.

  Note: sufficient to generate individual person identifiers:
    bys segmento f (o): gen n=_n 
  now id would be: segmento f n, where n==o

* Still to do: look at enrolment of children, health of children


o8      = type of activity employer
o9/o10  = type of activity employee
o11-o13 = contract for work
o16     = how long employed
o20     = other incomes
o30     = what doing in Nov 2000 (or 3 yrs ago I suspect)

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
global COM "~/investigacion/2014/ParentalInvestments/data/Geo"
global COP "~/investigacion/2014/ParentalInvestments/data/Copper"

cap mkdir "$OUT"
log using "$LOG/casenPrep.txt", text replace

local copper  = 0
local arsenic = 1

********************************************************************************
*** (2) Open files, generate variables
********************************************************************************
local svar e4 e3 e3

tokenize `svar'
foreach y of numlist 2006 2009 2011 {
    if `y'==2009 local ap "stata"
    if `y'==2011 local ap "stata_06092012"


    use "$DAT/`y'/casen`y'`ap'.dta"
    count
    local obs = `r(N)'
    levelsof comu
    local ncom : word count `r(levels)'
    dis "In `y' there are `obs' observations in `ncom' comunas."

    if `y'==2006 rename t7 r1a
    if `y'==2006 rename c_t7e r1c_cod
    if `y'==2009 rename t8 r1a
    if `y'==2009 destring t8cod, replace    
    if `y'==2009 rename t8cod r1c_cod    
    if `y'==2009 rename o_2009 o
    if `y'==2009 egen folio=group(folio_2009)
    if `y'==2011 rename expr_r2 expr
    if `y'==2011 rename expc_r2 expc
    if `y'==2011 rename rama1 rama
    if `y'==2011 rename oficio1 oficio
    
    cap rename r      region
    cap rename comu   comuna
    cap rename f      household
    cap rename folio  household
    cap rename seg    segmento
    rename o          person
    rename expr       WTregion
    rename expc       WTcomuna
    rename numper     familySize
    rename esc        educYrs
    rename rama       jobArea
    rename oficio     jobType
    rename sexo       gender
    rename edad       age
    rename yopraj     incomeJob
    rename ytotaj     incomeTotal
    rename ecivil     maritalStat
    rename `1'        attendSchool

    gen comunaBirth=comuna if r1a==1
    replace comunaBirth=r1c_cod if r1a==2
    gen bornForeign=r1a==3
    gen bornUnknown=r1a==9
    
    cap gen hogar  = 1
    gen rural      = z-1
    gen employed   = activ==1 if activ<3
    gen unemployed = activ==2 if activ<3
    gen inactive   = activ==3 if activ<=3
    gen surveyYr   = `y'

    #delimit ;
    keep region comuna person WT* familySize educYrs jobArea jobType
    gender age incomeJob rural surveyYr maritalStat employed unemployed
    inactive household segmento attendSchool hogar incomeTotal comunaBirth
    bornForeign bornUnknown;
    #delimit cr

    tempfile f`y'
    save `f`y''
    macro shift
}

clear
append using `f2006' `f2009' `f2011'


********************************************************************************
*** (3) Label Variables
********************************************************************************
egen houseid = group(surveyYr region comuna segmento hogar household)

lab var region     "Region where person currently lives"
lab var comuna     "Comuna where person currently lives"
lab var segmento   "Segmento (necessary for unique household id)"
lab var person     "Person id (unique within houseid)"
lab var WTregion   "Regional sampling weight"
lab var WTcomuna   "Comunal sampling weight"
lab var familySize "Number of people in the household"
lab var gender     "1 if male, 2 if female"
lab var age        "Age in years"
lab var maritalS   "Marital Status"
lab var attendSch  "Person currently attends school"
lab var educYrs    "Years of education completed"
lab var incomeJob  "Income from principal occupation"
lab var incomeTota "Total income for person (includes pensions, etc)"
lab var hogar      "House number in household group"
lab var rural      "Binary variable for rural (1 if rural)"
lab var employed   "1 if active, 0 if unemployed"
lab var unemployed "1 if unemployed, 0 if active"
lab var inactive   "1 if inactive in labor market, 0 if active/unemployed"
lab var surveyYr   "Year of CASEN survey"   
lab var household  "Household identifier (unique by year)"
lab var bornForeig "1 if person reports born in a foreign country"
lab var bornUnknow "1 if person doesn't know comuna of birth or only reports reg"
lab var comunaBirt "Comuna of birth of person"

********************************************************************************
*** (4) Correctly code comunas to merge with mine data
********************************************************************************
rename comuna comunaNow
rename comunaBirth comuna

merge m:1 comuna surveyYr using "$COM/comunaNames"
*DROP MERGE VARIABLES FOR EARLIER YEARS (not required for these surveys)
drop if _merge==2 

replace bornForeign=1 if comuna>=199900&comuna<8888888
replace bornUnknown=1 if comuna>=8888888&bornForeign!=1
replace bornUnknown=1 if comuna<100000&_merge==1&bornForeign!=1

replace comuna=. if bornForeign==1|bornUnknown==1
drop _merge

lab var cname      "Comuna Name (string)"
lab var comnew     "Comuna code for merge to arsenic data"
rename comnew id

merge m:1 id using "$COM/arsenicNames"
drop _merge
lab var c3057 "Concentration of Arsenic in comuna from 1930-1957"
lab var c5870 "Concentration of Arsenic in comuna from 1958-1970"
lab var c7177 "Concentration of Arsenic in comuna from 1971-1977"
lab var c7879 "Concentration of Arsenic in comuna from 1978-1979"
lab var c8087 "Concentration of Arsenic in comuna from 1980-1987"
lab var c8894 "Concentration of Arsenic in comuna from 1988-1994"

gen regionBirth=floor(comuna/1000)
lab var regionBirth "Region where individual was born (1-15)"
********************************************************************************
*** (X) Close
********************************************************************************
lab dat "Pooled CASEN 1998-2011 merged with arsenic data (Fereccio et al.)"
save "$OUT/CASENarsenic", replace

log close
