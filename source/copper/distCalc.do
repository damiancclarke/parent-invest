/* distCalc.do v0.00             damiancclarke             yyyy-mm-dd:2014-09-26
----|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

  Imports distance matrix from qgis (distance from each comuna to each mine, and
  calculates summary stats including: minimum distance, number of mines within i
  in {400, 500, 600} km, and weighted distance to mines within 400, 500 and 600
  km.

  In order to create the distance matrix, the following steps are followed:
   > Import base layer as vector file (division_comunal)
   > Create comuna centroids (or import comuna_centroids.shp)
   > Import mine locations from USGS (this is in EPSG:4326)
   > Convert mine locations to EPSG:32719
   > Calculate matrix using Vector->Analysis Tools->Distance Matrix

contact: mailto:damian.clarke@economics.ox.ac.uk
*/

vers 11
clear all
set more off
cap log close

********************************************************************************
*** (1) Globals and Locals
********************************************************************************
global DAT "~/investigacion/2014/ParentalInvestments/data/Geo"
global RUN "~/investigacion/2014/ParentalInvestments/source/copper"

********************************************************************************
*** (2) Import data, express in km
********************************************************************************
insheet using "$DAT/DepositDistance.csv", names comma
ds id, not
foreach var of varlist `r(varlist)' {
	replace `var'=`var'/1000
}

********************************************************************************
*** (3) Generate variables
********************************************************************************
egen mindistance=rowmin(v2-v47)

foreach dist of numlist 400 500 600 {
	gen mine`dist'=mindistance<`dist'
	foreach var of varlist v2-v47 {
		gen d`var'=`var'
		replace d`var'=. if d`var'>`dist'
	}
	egen average`dist'=rowmean(dv2-dv47)
	drop dv*
}

********************************************************************************
*** (4) Save export
********************************************************************************
save "$DAT/ComunaDistances", replace
drop v2-v47
outsheet using "$DAT/ComunaDistances.csv", names comma replace
