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

ssc install labutil

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

gen x="x"
egen serial=concat(Portafolios x vn x hn)
bys serial: gen persons=_N
gen year = 2002

********************************************************************************
*** (3) Create birth comuna data
********************************************************************************
rename Comuna censusComunaCode
rename nombre censusComunaName
rename p22b   Comuna

merge m:1 Comuna using "$DAT/Comunas"

gen birthComunaKnown = _merge==3
replace birthComunaKnown= 2 if p22a == 2&_merge==1
replace birthComunaKnown= 3 if p22a == 3
replace birthComunaKnown= 9 if p22a == 9

gen bplclComuna = Comuna if _merge==3
drop _merge
rename Comuna birthAllCode
rename nombre bplclName

replace bplclComuna = 96 if p22a == 3
replace bplclComuna = 98 if p22a == 9
replace bplclComuna = 97 if bplclComuna == .

********************************************************************************
*** (4) Name other variables
********************************************************************************
rename pn pernum
rename p34 chborn
rename p35 chsurv
rename p19 age
rename p18 sex
rename p21 ethncl

rename p20_1 blind
rename p20_2 deaf
rename p20_3 mute
rename p20_4 paralysis
rename p20_5 mentalDeficiency
rename p20_6 noPhysicalProblems
rename p22c yearArrived
rename p23a normalResidence
rename p23b normalResidenceCode
rename p24a residence1997
rename p24b residence1997Code
rename p25 literate
rename p26a educLevel
rename p28 religion
rename p29 workLastWeek
rename p30 workCategory
rename p31 occupation
rename p32 workDetail
rename p33a normalWorkPlace
rename p33b normalWorkCode
rename p36a lastBirthMonth
rename p36b lastBirthYear

gen relate = p17==1
replace relate = 2 if p17==2|p17==3
replace relate = 3 if p17==4|p17==5
replace relate = 4 if p17>5&p17<=13
replace relate = 5 if p17>13

gen marst = p27==0|p27==3
replace marst = 2 if p27==1|p27==2
replace marst = 3 if p27==4|p27==5
replace marst = 4 if p27==6

gen consens = p27==2

gen nativity = 1 if p22a==1|p22a==2
replace nativity=2 if p22a==3
replace nativity=9 if p22a==9

gen bplctry = Comuna if nativity!=1
replace bblctry = 23040 if nativity==1

#delimit ;
lab def sex   1 "Male" 2 "Female";
lab def rel   1 "Head" 2 "Spouse/partner" 3 "Child" 4 "Other Relative" 5
"Non-relative";
lab def civ   1 "Single/never married" 2 "Married/in union" 3
"Separated/divorced/spouse absent" 4 "Widowed";
lab def nat   1 "Native-born" 2 "Foreign-born" 9 "Unknown";




lab def probl 1 "Blind" 2 "Deaf" 3 "Mute" 4 "Paralysis" 5 "Mental" 6 "None"
lab def lit   0 "Under 5 years" 1 "Yes" 2 "No"
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
#delimit cr

lab values sex sex
lab values relate rel
lab values nativity nat
lab values normalResidence born
lab values literate lit
lab values marst civ
lab values workLastWeek work
lab values workCategory cat
lab values occupation ocp
lab values normalWorkPlace born

lab var serial  "Household serial number"
lab var persons "Number of persons in household"
lab var pernum  "Person number"
lab var relate      "relation to household head"
lab var sex              "Gender (1=male, 2=female)"
lab var age                 "Age in years (0-108)"
lab var marst         "Marital status"
lab var consens       "Consensual union"
lab var nativity "Nativity status"
lab var bplctry "Country of birth"
lab var chborn          "Children ever born"
lab var chsurv          "Children surviving"
lab var bplclComuna     "Code of birth comuna"
lab var bplclName       "Name of birth comuna"
lab var ethncl     "Ethnicity, Chile"


lab var blind               "Total blindness (binary)"
lab var deaf                "Total Deafness (binary)"
lab var mute                "Mute (binary)"
lab var paralysis           "Paralysed (binary)"
lab var mentalDeficiency    "Mental deficiency (binary)"
lab var noPhysicalProblems  "No reported physical problems (binary)"
lab var yearArrived         "Year arrived to Chile (from overseas)"
lab var normalResidence     "Is this normal residence comuna?"
lab var normalResidenceCode "Code of normal residence comuna"
lab var residence1997       "Where residing in 1997?"
lab var residence1997Code   "Comuna code where residing in 1997?"
lab var literate            "Literacy"
lab var educLevel           "Level of education (categorical)"
lab var religion            "Religion"
lab var workLastWeek        "Working last week?"
lab var workCategory        "Category of work"
lab var occupation          "Occupation of work (20 levels)"
lab var workDetail          "Detailed occupation (80 levels)"
lab var normalWorkPlace     "Where works normally"
lab var normalWorkCode      "Comuna code for normal workplace"
lab var lastBirthMonth      "Time of last birth (month)"
lab var lastBirthYear       "Time of last birth (year)"
lab var birthAllCode        "Code of where born (comuna, country, etc)"
lab var censusComunaCode    "Comuna code of where interviewed at time of census"
lab var censusComunaName    "Comuna name of where interviewed at time of census"

********************************************************************************
*** (5) Generated variables
********************************************************************************

gen educRecode = .
local level 1 2 3 4 5 5 5 5 5 5 5 6 6 6 6

tokenize `level'
foreach num of numlist 1(1)15 {
    dis "Code is `num', level is ``num''"
    replace educRecode = ``num'' if educLevel==`num'
}

lab def educR 1 "None" 2 "Special Ed." 3 "Pre-Primary" 4 "Primary" 5 "Secondary" /*
*/ 6 "Tertiary"
lab values educRecode educR

gen educYrs=.
replace educYrs=0 if educLevel==1
replace educYrs=0.5 if educLevel==2
replace educYrs=p26b if educLevel==3|educLevel==4
replace educYrs=8+p26b if educRecode==5
replace educYrs=12 if educRecode==5&educYrs>12
replace educYrs=12+p26b if educRecode==6

lab var educYrs "Years of Education for all people over 5 (imputed)"
lab var educRecode "Education (recoded 1-6) for all people 5 and over"

********************************************************************************
*** (6) Save, close
********************************************************************************
drop vn hn Portafolios p17 p27 Comuna birthComunaKnown

lab dat "Chile 2002 Census, all people.  Cleaned and coded (Damian Clarke)"

save "$OUT/census2002", replace
log close
