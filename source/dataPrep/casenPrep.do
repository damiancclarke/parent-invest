/* casenPrep.do v0.00            damiancclarke             yyyy-mm-dd:2014-12-11
----|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

This file takes raw CASEN data files from the years 1998-2011, and generates la-
bor variables, along with education and comuna identifiers.  This can then be m-
erged with data on distance to copper mines. The surveys used are 1998, 2000, 2-
003, 2006, 2009, 2011 (ie all surveys post-1996).  We do not use the surveys for
1990, 1992, 1994 or 1996, although these are available if desired (although with
less variables in some cases).


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
local svar e2 e3 e2 e4 e3 e3
local swhy e3 e5 e3 e6 e5 e5
local num  4  7  7  4  4  10

tokenize `svar'
foreach y of numlist 1998(2)2000 2003(3)2009 2011 {
    if `y'==2009 local ap "stata"
    if `y'==2011 local ap "stata_06092012"


    use "$DAT/`y'/casen`y'`ap'.dta"
    count
    local obs = `r(N)'
    levelsof comu
    local ncom : word count `r(levels)'
    dis "In `y' there are `obs' observations in `ncom' comunas."

    if `y'==1998 rename o21 activ
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
    *rename ytotaj     incomeTotal
    rename ecivil     maritalStat
    rename `1'        attendSchool
    
    cap gen hogar  = 1
    gen rural      = z-1
    gen employed   = activ==1 if activ<3
    gen unemployed = activ==2 if activ<3
    gen inactive   = activ==3 if activ<=3
    gen surveyYr   = `y'

    #delimit ;
    keep region comuna person WT* familySize educYrs jobArea jobType
    gender age incomeJob rural surveyYr maritalStat employed unemployed
    inactive household segmento attendSchool hogar;
    #delimit cr

    tempfile f`y'
    save `f`y''
    macro shift
}

clear
append using `f1998' `f2000' `f2003' `f2006' `f2009' `f2011'


********************************************************************************
*** (3) Label Variables
********************************************************************************
egen houseid = group(surveyYr region comuna segmento hogar household)

lab var region     "Region (highest level of geographic variation, 1-15)"
lab var comuna     "Comuna (lowest level of geographic variation, 1-346)"
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
lab var hogar      "House number in household group"
lab var rural      "Binary variable for rural (1 if rural)"
lab var employed   "1 if active, 0 if unemployed"
lab var unemployed "1 if unemployed, 0 if active"
lab var inactive   "1 if inactive in labor market, 0 if active/unemployed"
lab var surveyYr   "Year of CASEN survey"   
lab var household  "Household identifier (unique by year)"

********************************************************************************
*** (4) Correctly code comunas to merge with mine data
********************************************************************************
merge m:1 comuna surveyYr using "$COM/comunaNames"
drop if _merge==1
drop _merge

lab var cname      "Comuna Name (string)"
lab var comnew     "Comuna code for merge to mining data"
rename comnew id

if `copper'==1 {
    merge m:1 id using "$COP/CopperTreatment"
    drop if _merge==2
    drop _merge
}
if `arsenic'==1 {
    merge m:1 id using "$COM/arsenicNames"
    drop _merge
    foreach var of varlist c3057 c5870 c7177 c7879 c8087 c8894 {
        bys region: egen m=mean(`var')
        cap drop cflag
        gen cflag=m!=.&var==.
        replace `var'=m if `var'==.
        drop m

        replace `var'=0 if `var'==.&region!=4
    }
    lab var c3057 "Concentration of Arsenic in comuna from 1930-1957"
    lab var c5870 "Concentration of Arsenic in comuna from 1958-1970"
    lab var c7177 "Concentration of Arsenic in comuna from 1971-1977"
    lab var c7879 "Concentration of Arsenic in comuna from 1978-1979"
    lab var c8087 "Concentration of Arsenic in comuna from 1980-1987"
    lab var c8894 "Concentration of Arsenic in comuna from 1988-1994"
}

********************************************************************************
*** (X) Close
********************************************************************************
if `copper'==1 {
    lab dat "Pooled CASEN 1998-2011 merged with Mine intensity data (2005)"
    save "$OUT/CASENmerged", replace
}
if `arsenic'==1 {
    lab dat "Pooled CASEN 1998-2011 merged with arsenic data (Fereccio et al.)"
    save "$OUT/CASENarsenic", replace
}


log close
