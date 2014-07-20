* descSIMCE.do v0.00                 DC/SZ                 yyyy-mm-dd:2014-07-19
*---|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8
*

/* File to make basic descriptives of SIMCE data (grade 4) for period 1999-2012.
Descripes year of birth of students along with parental investment questions fr-
om each wave.

The file can be controlled in section (0).  Here we set directory locations for
SIMCE data and the project, along with specifying which parts of this do file
should be run.  If switches are set to 1 then this section will be run, otherwi-
se it will not be run.  Note that section (1) will only work on Unix systems gi-
ven that it's based on the perl program dbfdump as well as shell commands grep
and awk.  In general this should not be run now that initial dbf data has been
converted to csv files.

To Do: Request data from 1998-1999, 2011-2012.

For optimal viewing set tab width = 2.

Contact: damian.clarke@economics.ox.ac.uk
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

** SWITCHES
local generate   0
local counter    0
local investment 1

cap which mat2txt
if _rc!=0 ssc install mat2txt

********************************************************************************
*** (1) Generate csvs from dbf format
***  This is all Unix shell code and can be ignored now that base csvs are made
********************************************************************************
if `generate'==1&c(os)=="Unix" {
	foreach year of local testYrs {
		dis "`year'"
		mkdir csv
		cd "$DAT/SIMCE`year'"
		dis "Converting all DBF --> CSV."
		dis "Converting ... ..."
		!for f in *.dbf; do dbfdump $f --info | grep '^[0-9]*[\.]' | grep [A-Z_] | awk {'printf "%s;", $2'}  > ./csv/$f.csv; echo "" >> ./csv/$f.csv; dbfdump -fs=';' $f >> ./csv/$f.csv; done	
	}
}

********************************************************************************
*** (2a) Basic descriptives (count)
********************************************************************************
if `counter'==1 {
	mat numObs = J(7,3,.)
	local jj=0
	
	foreach year of local testYrs {
		local ++jj
		mat numObs[`jj',1]=`year'

		if `year'<=2005 {
			insheet using $DAT/SIMCE`year'/csv/Student.csv, delim(";") clear
			qui count
			mat numObs[`jj',2]=`r(N)'
			dis "Number of students in `year'=`r(N)'"
			insheet using $DAT/SIMCE`year'/csv/Parents.csv, delim(";") clear
			qui count
			mat numObs[`jj',3]=`r(N)'
			dis "Number of parents in `year'=`r(N)'"
		}
		else {
			insheet using $DAT/SIMCE`year'/csv/4Student.csv, delim(";") clear
			qui count
			mat numObs[`jj',2]=`r(N)'
			dis "Number of students in `year'=`r(N)'"
			insheet using $DAT/SIMCE`year'/csv/4Parents.csv, delim(";") clear
			qui count
			mat numObs[`jj',3]=`r(N)'
			dis "Number of parents in `year'=`r(N)'"
		}
	}
	matrix colnames numObs=year students parents
	mat2txt , matrix(numObs) saving("$DIR/results/descriptives/NumObs.txt")
}
********************************************************************************
*** (2b) Basic descriptives (parental investment variables)
********************************************************************************
if `investment'==1 {
	insheet using "$DAT/SIMCE2002/csv/Parents.csv", delim(";") clear
	rename preg_g StudentAge
	rename preg5 MonthFees
	rename preg6 MonthInvestment
	rename preg7 TypeInvestment
	rename preg11 Preschool
	rename preg18_1 ComputerAvailability
	rename preg18_2 InternetAvailability
	rename preg18_3 PrinterAvailability
	rename preg18_4 BookAvailability
	rename preg18_5 StudySpaceAvailability
	rename preg18_6 TextAvailability
	rename preg18_7 NewspaperAvailability
	rename preg18_8 HelpAvailability
	rename preg20 Expectations
	rename preg23_1 SchoolGift
	rename preg23_2 ReviewHomework
	rename preg23_3 AccompanyHomework
	rename preg23_4 AccompanyStudy
	rename preg27_1 ReadTogether
	rename preg27_2 MathTogether
	rename preg27_3 TalkTogether
	rename preg27_4 SendTramites
	rename preg27_5 WriteTogether
	rename preg27_6 PlayTogether
	rename preg27_7 WriteMessages
	rename preg27_8 IncentiviseReading
	
	tab StudentAge
	sum MonthFees MonthInvestment
	sum *Together

	insheet using "$DAT/SIMCE2005/csv/Parents.csv", delim(";") clear
	rename preg4_1 ComputerAvailability
	rename preg4_2 InternetAvailability
	rename preg4_3 PrinterAvailability
	rename preg4_4 BookAvailability
	rename preg4_5 StudySpaceAvailability
	rename preg4_6 TextAvailability
	rename preg4_7 NewspaperAvailability
	rename preg4_8 HelpAvailability

	rename preg14 KinderAttendance
	rename preg15 KinderWhere
	rename preg20 Expectations
	rename preg23 MonthFees

	rename preg24_1 SpendSchoolMaterials
	rename preg24_2 SpendClasses
	rename preg24_3 SpendBuses
	rename preg24_4 SpendLunch
	rename preg24_5 SpendTransport
	rename preg24_6 SpendCourse
	rename preg24_7 SpendParentsCenter
	rename preg24_8 SpendOther
	rename preg25 MonthInvestment
 	

	insheet using "$DAT/SIMCE2006/csv/4Parents.csv", delim(";") clear
	rename preg4_1 ComputerAvailability
	rename preg4_2 InternetAvailability
	rename preg4_3 PrinterAvailability
	rename preg4_4 BookAvailability
	rename preg4_5 StudySpaceAvailability
	rename preg4_6 TextAvailability
	rename preg4_7 NewspaperAvailability
	rename preg4_8 HelpAvailability

	rename preg7 ReadTogether
	rename preg22 Expectations
	rename preg26 MonthFees
	rename preg27_1 SpendSchoolMaterials
	rename preg27_2 SpendClasses
	rename preg27_3 SpendBuses
	rename preg27_4 SpendLunch
	rename preg27_5 SpendTransport
	rename preg27_6 SpendCourse
	rename preg27_7 SpendParentsCenter
	rename preg27_8 SpendOther
	rename preg28 MonthInvestment


	insheet using "$DAT/SIMCE2007/csv/4Parents.csv", delim(";") clear
	rename p5_1 ReadThemStories
	rename p5_2 ReadTogether
	rename p5_3 TalkTogether
	rename p5_4 GiveBooks
	rename p5_5 TakeBookshop
	rename p5_6 TakeLibrary

	rename p13_1 PreschoolNever
	rename p13_2 Preschool0_2
	rename p13_3 Preschool2_4 
	rename p13_4 Preschool4_5
	rename p13_5 Preschool5_6
	rename p16 Expectations
	rename p19 MonthFees
	rename p20_1 SpendSchoolMaterials
	rename p20_2 SpendClasses
	rename p20_3 SpendBuses
	rename p20_4 SpendLunch
	rename p20_5 SpendTransport
	rename p20_6 SpendCourse
	rename p20_7 SpendParentsCenter
	rename p20_8 SpendOther
	rename p21 MonthInvestment


	insheet using "$DAT/SIMCE2008/csv/4Parents.csv", delim(";") clear
	rename preg10_1 PreschoolNever
	rename preg10_2 Preschool0_2
	rename preg10_3 Preschool2_3 
	rename preg10_4 Preschool3_4 
	rename preg10_5 Preschool4_5
	rename preg10_6 Preschool5_6

	insheet using "$DAT/SIMCE2009/csv/4Parents.csv", delim(";") clear
	insheet using "$DAT/SIMCE2010/csv/4Parents.csv", delim(";") clear

}
