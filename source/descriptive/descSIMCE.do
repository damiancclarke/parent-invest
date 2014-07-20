* descSIMCE.do v0.00                 DC/SZ                 yyyy-mm-dd:2014-07-19
*---|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8
*

/* File to make basic descriptives of SIMCE data (grade 4) for period 1999-2012.
Descripes year of birth of students along with parental investment questions fr-
om each wave.

To Do: Request data from 1998-1999, 2011-2012.

For optimal viewing set tab width = 2.

*/
vers 11
clear all
set more off
cap log close

********************************************************************************
*** (0) globals and locals
********************************************************************************
global DIR "~/investigacion/2014/ParentalInvestments"
global DAT "~/database/SIMCE"
global LOG "~/investigacion/2014/ParentalInvestments/log"

log using "$LOG/descSIMCE.txt", text replace

*local testYrs 1999 2002 2005 2006 2007 2008 2009 2010 2011 2012
local testYrs 2002 2005 2006 2007 2008 2009 2010

********************************************************************************
*** (1) Generate csvs from dbf format
***  This is all Unix shell code and can be ignored now that base csvs are made
********************************************************************************
foreach year of local testYrs {
	dis "`year'"
	mkdir csv
	cd "$DAT/SIMCE`year'"
	dis "Converting all DBF --> CSV."
	dis "Converting ... ..."
	!for f in *.dbf; do dbfdump $f --info | grep '^[0-9]*[\.]' | grep [A-Z_] | awk {'printf "%s;", $2'}  > ./csv/$f.csv; echo "" >> ./csv/$f.csv; dbfdump -fs=';' $f >> ./csv/$f.csv; done
	

}
