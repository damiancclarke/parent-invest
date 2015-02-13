/* arsenicTrends.do v0.00        damiancclarke             yyyy-mm-dd:2014-02-12
----|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

This file plots trends in arsenic levels in Chile, as well as mapping the distr-
ibution of arsenic levels over space.  Arsenic data comes from the sheet shared
by Caterrina.

*/

vers 11
clear all
set more off
cap log close

********************************************************************************
*** (1) globals and locals
********************************************************************************
global AS  "~/investigacion/2014/ParentalInvestments/data/arsenic"
global MAP "~/database/ChileRegiones/GeoRefs/division_comunal"
global OUT "~/investigacion/2014/ParentalInvestments/results/arsenic/descriptives"
global LOG "~/investigacion/2014/ParentalInvestments/log"

log using "$LOG/arsenicTrends.txt", text replace


********************************************************************************
*** (2) Import, make concentration graph
********************************************************************************
use "$AS/arsenicExpanded"

replace arsenic=subinstr(arsenic,",",".", .)
destring arsenic, replace

gen area=codigo_ine==230|codigo_ine==231
replace area=2 if codigo_ine==220|codigo_ine==221|codigo_ine==225
replace area=3 if codigo_ine==202|codigo_ine==227
replace area=4 if area==0&region<5

lab define areas 0 "Rest of Chile" 1 "Antofagasta/Mejillones" 2 "Calama" 3 /*
*/ "San Pedro" 4 "Rest of I-IV region"
lab values area areas

preserve
collapse arsenic, by(area year)

sort area year
twoway line arsenic year if area==1 || line arsenic year if area==2, lpat(dash) || /*
*/ line arsenic year if area==3, lpat(dot) || line arsenic year if area==4, /*
*/ lpat(longdash) || line arsenic year if area==5, lpat(dash_dot) scheme(s1mono) /*
*/ xtitle("Arsenic Concentration") ytitle("Year") /*
*/ legend(lab(1 "Antofagasta/Mejillones") lab(2 "Calama") lab(3 "San Pedro") /*
*/ lab(4 "Rest of I-IV region") lab(5 "Rest of Chile")) /*
*/ note("Arsenic concentrations collected by authors based on tap water readings.")

graph export "$OUT/arsenicConcentrations.eps", as(eps) replace
restore

********************************************************************************
*** (3) Map Arsenic Concentrations (average)
********************************************************************************
rename codigo_ine id
bys id: egen maxAs=max(arsenic)
bys id: egen minAs=min(arsenic)
gen difAs = maxAs-minAs

collapse arsenic difAs, by(id)

merge 1:m id using "$AS/mapComuna"
drop if _merge!=3
drop _merge
merge 1:1 comuna_id using "$MAP/comuna_data"
drop if _merge==2
drop _merge

*spmap arsenic using "$MAP/comuna_coords", fcolor(Greens) id(ID)
*graph export "$OUT/ArsenicMap.eps", as(eps) replace

spmap difAs using "$MAP/comuna_coords", fcolor(Greens) id(ID)
graph export "$OUT/ArsenicChange.eps", as(eps) replace
