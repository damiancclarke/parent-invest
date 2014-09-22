/* copperDisc.do v0.00           damiancclarke             yyyy-mm-dd:2014:09-21
----|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

This file displays geographical variation of copper resources by municipality in
Chile.  It displays majors mines, and (cartesian) distance to mines.

*/
vers 11
clear all
set more off
cap log close

********************************************************************************
*** (1) Globals and locals
********************************************************************************
global DAT "~/investigacion/2014/ParentalInvestments/data/Copper/USGS"
global MAP "~/investigacion/2014/ParentalInvestments/data/Geo/"
global OUT "~/investigacion/2014/ParentalInvestments/results/Copper/"
global LOG "~/investigacion/2014/ParentalInvestments/log"

cap mkdir "$LOG"
log using "$LOG/copperDisc.txt", text replace

local com comuna_coords
local nam comuna_data

********************************************************************************
*** (2) Insheet latitude and longitude data
********************************************************************************
insheet using "$DAT/ChileDepositLocation.csv", names delimit(";")

foreach l in latitude longitude {
	replace `l'=subinstr(`l', ",", ".", 1)
	destring `l', replace
}

label data "Copper deposits from USGS data used in Clarke and Zhuang (2014)"
save "$DAT/ChileDepositLocation.dta", replace

********************************************************************************
*** (3) Make plain map with points for mines
********************************************************************************
use "$MAP/comuna_data"
rename ID _ID
spmap using "$MAP/comuna_coords", point(data("$DAT/ChileDepositLocation.dta") /*
*/xcoord(latitude) ycoord(longitude)) id(_ID) title("Copper Deposits in Chile") /*
*/subtitle("Based on USGS Registry Data") osize(vvthin)
graph export "$OUT/mineLocsChile.eps", as(eps) replace

log close
