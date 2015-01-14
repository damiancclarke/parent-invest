/* minePrep.do v0.00                DC / SZ                yyyy-mm-dd:2014-10-19
----|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

This file takes data output from GIS based on the distance from the midpoint of
each municipality to mines, and creates an indicator for whether each comuna is
X in {300,400,500} km away from a mine.  This is then interacted with tonnage a-
nd ore grade of the mine.  The following two files are required for this script:
  > ComunaMine_Distance.csv: Matrix of distance from comunas to all mines
  > MineTonnage.csv: Tonnage and ore grade of copper of each mine (2005)

The file can be controlled in section 1, which defines various globals and loca-
ls to determine where data is stored and where it should be output.

contact: mailto:damian.clarke@economics.ox.ac.uk

previous versions
v0.00: Binary indicator interacted with ore grade and tonnage

*/

vers 11
clear all
set more off
cap log close

global DAT "~/investigacion/2014/ParentalInvestments/data/Geo"
global OUT "~/investigacion/2014/ParentalInvestments/data/Copper"
global LOG "~/investigacion/2014/ParentalInvestments/log"
global GRA "~/investigacion/2014/ParentalInvestments/results/descriptives/mines"

log using "$LOG/minePrep.txt", text replace
local distance 25 50 75 100 200

********************************************************************************
*** (2) Import mine tonnage, save in local along with mine names
********************************************************************************
insheet using "$OUT/mineTonnage.csv", names delimiter(";")
replace grade=subinstr(grade, ",", ".", 1)
save "$OUT/mineTonnage", replace
replace mine="collahausi" if mine=="collahuasi"
replace mine="manzamina" if mine=="mansamina"

sort mine
destring grade, replace
replace grade=0.711 if mine=="ujina"
replace grade=1.001 if mine=="spence"
levelsof mine, local(minenames)
levelsof tonnage, local(tonnes)
levelsof grade, local(grades)

tokenize `tonnes'
local i=1
foreach m of local minenames {
	dis "Mine `m' has ``i'' tonnes"
	local ++i
}

********************************************************************************
*** (3) Import comuna distances, find number of mines within 300, 400, 500, 600
********************************************************************************
*insheet using "$DAT/ComunaMine_Distance.csv", delimit(";") names clear
*cap drop v28
use "$DAT/ComunaMine_Distance", clear

ds id, not
local mines `r(varlist)'
foreach var of local mines {
	replace `var'=`var'/1000
	foreach num of local distance {
		gen `var'`num'=`var'<`num'
	}
}

foreach num of local distance {
    egen Num`num'=rowtotal(*`num')
}

********************************************************************************
*** (4) Using locals from above, create interactions with Ore, and Ore*grade
********************************************************************************
tokenize `tonnes'
local i=1
foreach m of local minenames {
	dis "Mine is `m', tonnage is ``i''"
  foreach num of local distance {
      gen `m'`num'_Ore=`m'`num'*``i''
  }
	local ++i
}

foreach num of local distance {
    egen Ore`num'=rowtotal(*`num'_Ore)
}

tokenize `grades'
local i=1
foreach m of local minenames {
	dis "Mine is `m', Grade is ``i''"
  foreach num of local distance {
      gen `m'`num'_GradeOre=`m'`num'_Ore*``i''
  }
	local ++i
}

foreach num of local distance {
    egen GradeOre`num'=rowtotal(*`num'_GradeOre)
}

keep id Num* Ore* GradeOre*

********************************************************************************
*** (5) Descriptives
********************************************************************************
foreach num of local distance {
	histogram Num`num', saving(N`num') freq
	histogram Ore`num', saving(O`num') freq
	histogram GradeOre`num', saving(G`num') freq

	graph combine N`num'.gph O`num'.gph G`num'.gph, col(1) title("Distance=`num'") /*
	*/ note("Num is the number of mines, Ore is the tonnage, and GradeOre is tonnage by grade.")
	graph export "$GRA/MineSum`num'.eps", as(eps) replace
	rm N`num'.gph
	rm O`num'.gph
	rm G`num'.gph
}

********************************************************************************
*** (6) Save, clean up
********************************************************************************
foreach num of local distance {
	label var Num`num' "Number of mines within `num'km of the Comuna"
	label var Ore`num' "Ore removed in 2005 in mines within `num'km of Comuna"
	label var GradeOre`num' "Tonnage*grade in 2005 in mines within `num'km of Comuna"
}

bys id: gen n=_n
drop if n==2 // Aisen repeated
drop n

replace id=13106 if id==1310
gen JobComuna=id
label var JobComuna "Unique link to SAFP data"

label data "Copper intensity by comuna based on distance and USGS values"
save "$OUT/CopperTreatment", replace
