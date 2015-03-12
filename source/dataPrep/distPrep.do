/* distPrep.do v0.00             damiancclarke             yyyy-mm-dd:2015-03-11
----|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

Generates data for the distance from Chuquicamata,El Salvador and Mantos Blancos
mines to each comuna.  The original distance matrix was generated from GIS.

*/

vers 11
clear all
set more off
cap log close

********************************************************************************
** (1) Globals and locals
********************************************************************************
global DAT "~/investigacion/2014/ParentalInvestments/data/Geo"
global OUT "~/investigacion/2014/ParentalInvestments/data/Copper"
global COM "~/database/ChileRegiones"

********************************************************************************
** (2) Open mine data, prepare
********************************************************************************
use "$DAT/ComunaMine_Distance"
keep id elsalvador chuquicamata lomasbayas
rename lomasbayas mantosblancos

replace id = 13106 if id == 1310
drop if id==0|id==11201&chuqui==.
rename id comunacode2010

********************************************************************************
** (3) Merge to comuna names
********************************************************************************
merge 1:1 comunacode2010 using "$COM/comunacodes"
drop v20 _merge

lab data "Distance in meters from mines to each comuna"
save "$OUT/Dist_ElSalvChuquiMantos", replace
