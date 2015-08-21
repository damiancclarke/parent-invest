/* censusRegs.do v0.00           damiancclarke             yyyy-mm-dd:2015-08-20
----|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

Examines effect of arsenic in utero on various outcomes.  

Note that technician has been changed so now is occisco=3, not less than or equ-
al to 3. This allows for us to seperately examined the effect on Pr(professional
job) and Pr(technical job).
*/

vers 11
clear all
set more off
cap log close

********************************************************************************
*** (1) globals and locals
********************************************************************************
global DAT "~/investigacion/2014/ParentalInvestments/data/census"
global OUT "~/investigacion/2014/ParentalInvestments/results/arsenic/census/regression"
global LOG "~/investigacion/2014/ParentalInvestments/log"

log using "$LOG/censusRegs.txt", text replace

local Y schooling completeUniv* someUniv active employed professional technic
local estopt cells(b(star fmt(%-9.3f)) se(fmt(%-9.3f) par([ ]) )) stats      /*
*/           (N, fmt(%9.0g) label(Observations))                             /*
*/           starlevel ("*" 0.10 "**" 0.05 "***" 0.01) collabels(none) label



********************************************************************************
*** (2) Use and set-up
********************************************************************************
use "$DAT/census2002"
cap rename bplclName birthComuna
gen birthYear = 2002 - age
keep if birthYear >= 1952 & birthYear <= 1968
keep if geo1b_cl < 5

generat T1 = 0
replace T1 = 1 if birthComuna=="antofagasta"|birthComuna=="mejillones"
replace T1 = 2 if birthComuna=="tocopilla"|birthComuna=="maria Elena"|/*
               */ birthComuna=="calama"

gen Region2All     = geo1b_cl==2               if T1!=2
gen Region1_4All   = geo1b_cl<=4               if T1!=2
gen Region2NoMig   = geo1b_cl==2&noMigrator==1 if T1!=2
gen Region1_4NoMig = geo1b_cl>=4&noMigrator==1 if T1!=2
gen Arsenic = T1                               if T1!=2
replace Arsenic = 0 if birthYear<1959

gen schooling = yrschl if yrschl != 99
gen completeUniversity5= educcl==15 & p26b>=5
gen completeUniversity4= educcl==15 & p26b>=4
gen someUniversity= educcl==15

gen active= empstat<=2
gen employed= empstat==1

gen professional = occisco<=2 if occisco != 99
gen technician   = occisco==3 if occisco != 99

egen comunaYear=group(comunacode2000 birthYear)
gen female = sex==2
gen male   = sex==1

********************************************************************************
*** (3) Regressions
********************************************************************************
local se abs(comunacode2000) cluste(comunaYear)
local i=1

foreach samp in Region2All Region1_4All Region2NoMig Region1_4NoMig {
    if `i'==1 local snote "residents of region II"
    if `i'==2 local snote "residents of regions I-IV"
    if `i'==3 local snote "non-migrating residents of region II"
    if `i'==4 local snote "non-migrating residents of region I-IV"
    
    preserve
    keep if `samp'==1

    foreach y of local Y {
        eststo: areg `y' Arsenic i.birthYear , `se'
    }
    #delimit ;
    esttab est1 est2 est3 est4 est5 est6 est7 using "$OUT/`samp'FE.tex",
    replace `estopt' booktabs title("Arsenic and Long Run Outcomes")
    keep(Arsenic) mlabels(, depvar) style(tex)
    postfoot("\bottomrule \multicolumn{8}{p{18cm}}{\begin{footnotesize}    "
             "\textsc{Notes:} Sample consists of all `snote' born between  "
             "1952 and 1968 (aged between 34 and 50 at the time of the     "
             "census).  Birth comuna and year fixed effects are included.  "
             "Standard errors allow for arbitrary correlations within each "
             "comuna and birth cohort."
             "\end{footnotesize}}\end{tabular}\end{table}");
    #delimit cr
    estimates clear

    foreach y of local Y {
        eststo: areg `y' Arsenic i.birthYear i.T1#c.birthYear, `se'
    }
    #delimit ;
    esttab est1 est2 est3 est4 est5 est6 est7 using "$OUT/`samp'Trend.tex",
    replace `estopt' booktabs title("Arsenic and Long Run Outcomes")
    keep(Arsenic) mlabels(, depvar) style(tex)
    postfoot("\bottomrule \multicolumn{8}{p{18cm}}{\begin{footnotesize}   "
             "\textsc{Notes:} Sample consists of all `snote' born between "
             "1952 and 1968 (aged between 34 and 50 at the time of the    "
             "census).  Birth comuna and year fixed effects are included, "
             "as well as comuna-specific linear time trends. Standard     "
             "errors allow for arbitrary correlations within each comuna  "
             "and birth cohort."
             "\end{footnotesize}}\end{tabular}\end{table}");
    #delimit cr
    estimates clear
    restore
    local ++i
}

********************************************************************************
*** (3a) Regressions (gender)
********************************************************************************
foreach sex in female male {
local i=1
foreach samp in Region2All Region1_4All Region2NoMig Region1_4NoMig {
    if `i'==1 local snote "residents of region II"
    if `i'==2 local snote "residents of regions I-IV"
    if `i'==3 local snote "non-migrating residents of region II"
    if `i'==4 local snote "non-migrating residents of region I-IV"
    
    preserve
    keep if `samp'==1&`sex'==1

    foreach y of local Y {
        eststo: areg `y' Arsenic i.birthYear , `se'
    }
    #delimit ;
    esttab est1 est2 est3 est4 est5 est6 est7 using "$OUT/`sex'`samp'FE.tex",
    replace `estopt' booktabs title("Arsenic and Long Run Outcomes (`sex')")
    keep(Arsenic) mlabels(, depvar) style(tex)
    postfoot("\bottomrule \multicolumn{8}{p{18cm}}{\begin{footnotesize}    "
             "\textsc{Notes:} Sample consists of all `sex' `snote' born    "
             "between 1952 and 1968 (aged between 34 and 50 at the time of "
             "the census).  Birth comuna and year fixed effects are        "
             "included. Standard errors allow for arbitrary correlations   "
             "within each comuna and birth cohort."
             "\end{footnotesize}}\end{tabular}\end{table}");
    #delimit cr
    estimates clear

    foreach y of local Y {
        eststo: areg `y' Arsenic i.birthYear i.T1#c.birthYear, `se'
    }
    #delimit ;
    esttab est1 est2 est3 est4 est5 est6 est7 using "$OUT/`sex'`samp'Trend.tex",
    replace `estopt' booktabs title("Arsenic and Long Run Outcomes (`sex')")
    keep(Arsenic) mlabels(, depvar) style(tex)
    postfoot("\bottomrule \multicolumn{8}{p{18cm}}{\begin{footnotesize}   "
             "\textsc{Notes:} Sample consists of all `sex' `snote' born   "
             "between 1952 and 1968 (aged between 34 and 50 at the time of"
             "the census).  Birth comuna and year fixed effects are       "
             "included, as well as comuna-specific linear time trends.    "
             "Standard errors allow for arbitrary correlations within each"
             "comuna and birth cohort."
             "\end{footnotesize}}\end{tabular}\end{table}");
    #delimit cr
    estimates clear
    restore
    local ++i
}
}




exit


********************************************************************************
*** (4a) Regressions generate variables
********************************************************************************
gen InUtero = birthYear>=1960&birthYear<=1972 & T1==1

foreach a of numlist 0(1)16 {
    local lYear = 1959-`a'
    local uYear = 1971-`a'
    dis "low year is `lYear', high year is `uYear'"

    gen Age`a' = birthYear>=`lYear' & birthYear<=`uYear' & T1==1
    tab Age`a'
}


********************************************************************************
*** (4b) Regressions
********************************************************************************
local se abs(birthComuna) cluster(birthComuna)
*local cd if birthYear>=1955

foreach var of varlist `Y' {
    areg `var' i.birthYear i.regioncode2000#c.birthYear InUtero Age* `cd', `se'
}

********************************************************************************
*** (X) Clear
********************************************************************************
log close
