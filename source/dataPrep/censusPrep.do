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
rename p17 relationHHhead
rename p18 gender
rename p19 age
rename p20_1 blind
rename p20_2 deaf
rename p20_3 mute
rename p20_4 paralysis
rename p20_5 mentalDeficiency
rename p20_6 noPhysicalProblems
rename p21 indigenousGroup
rename p22c yearArrived
rename p23a normalResidence
rename p23b normalResidenceCode
rename p24a residence1997
rename p24b residence1997Code
rename p25 literate
rename p26 educLevel
rename p27 civilStatus
rename p28 religion
rename p29 workLastWeek
rename p30 workCategory
rename p31 occupation
rename p32 workDetail
rename p33a normalWorkPlace
rename p33b normalWorkCode
rename p34 liveBirths
rename p35 survivingBirths
rename p36a lastBirthMonth
rename p36ba lastBirthYear


lab def sex   1 "Male" 2 "Female"
lab def probl 1 "Blind" 2 "Deaf" 3 "Mute" 4 "Paralysis" 5 "Mental" 6 "None"
lab def lit   0 "Under 5 years" 1 "Yes" 2 "No"
lab def civ   0 "Under 15 yrs" 1 "Married" 2 "Lives with partner" 3 "Single" /*
*/ 4 "Anulled" 5 "Separated" 6 "Widdow(er)"
lab def work  0 "Under 15 yrs" 1 "Working for income" 2 "Employed, didn't work"/*
*/ 4 "Working for family, no pay" 5 "Searching work (1st time)" 6 "House work" /*
*/ 7 "Studying" 8 "Retired/rental income" 9 "Disabled/unable to work" 10 "Other"
lab def cat 0 "N/A (see workLastWeek)" 1 "Salary worker" 2 "Domestic services" /*
*/  3 "Self employed" 4 "Employer" 5 "Unpaid family work"
lab def ocp 0 "NA, or not informed" 1 "Armed forces, police" 11                /*
*/ "Public administration/executive govt" 12 "Directors of big companies" 14   /*
*/ "Directors, small companies" 21 "Engineer, scientist" 22 "medicine, health" /*
*/ 23 "Teachers" 24 "Other scientist, intellectual" 31                         /*
*/ "Technical workers, science" 32 "Technical workers, health" 33              /*
*/ "Technical teachers" 34 "Other technical worker" 41 "Office worker" 42      /*
*/ "Customer service" 51 "Security/protection" 52 "Salespeople, models" 61     /*
*/ "Qualified farming, forestry, fishing" 62 "Subsistence fishers" 71          /*
*/ "Construction/extraction" 72 "Metallurgy, contruction" 73                   /*
*/ "Qualified machinist, graphics artist" 74 "Other officials, mechanical" 81  /*
*/ "Operators, installation" 82 "Operators, machine" 83 "Vehicle drivers" 92   /*
*/ "Unqualified salespeople" 92 "Workers: fishing, forestry" 93 "Workers: mining"

lab values gender sex
lab values normalResidence born
lab values literate lit
lab values civilStatus civ
lab values workLastWeek work
lab values workCategory cat
lab values occupation ocp
lab values normalWorkPlace born

lab var relationHHhead "relation to household head"
lab var gender         "Gender (1=male, 2=female)"
lab var age            "Age in years (0-108)"



********************************************************************************
*** (5) Generated variables
********************************************************************************
gen educRecode = .
local level 1 2 3 4 5 5 5 5 5 5 5 6 6 6 6

tokenize `local'
foreach num of numlist 1(1)15 {
    replace educRecode = `num' if educLevel==``num''
}

lab def educR 1 "None" 2 "Special Ed." 3 "Pre-Primary" 4 "Primary" 5 "Secondary" /*
*/ 6 "Tertiary"
lab values educRecode educR
lab var educRecode "Education (recoded 1-6) for all people 5 and over"

gen educYrs=.

replace educYrs=0 if educLevel==1
replace educYrs=0.5 if educLevel==2
replace educYrs=p26b if educLevel==3|educLevel==4
replace educYrs=8+p26b if educRecode==5
replace educYrs=12 if educRecode==5&educYrs>12
replace educYrs=12+p26b if educRecode==6

lab var educYrs "Years of Education for all people over 5 (imputed)"
