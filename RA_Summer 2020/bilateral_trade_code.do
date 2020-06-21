//Bilarteral Trade Data
clear

//Import all .csv files and save them as .dta files
//The long series of codes are generated in MATLAB
import delimited dynamic_1962,clear
save 1962.dta,replace
import delimited dynamic_1963,clear
save 1963.dta,replace
import delimited dynamic_1964,clear
save 1964.dta,replace
import delimited dynamic_1965,clear
save 1965.dta,replace
import delimited dynamic_1966,clear
save 1966.dta,replace
import delimited dynamic_1967,clear
save 1967.dta,replace
import delimited dynamic_1968,clear
save 1968.dta,replace
import delimited dynamic_1969,clear
save 1969.dta,replace
import delimited dynamic_1970,clear
save 1970.dta,replace
import delimited dynamic_1971,clear
save 1971.dta,replace
import delimited dynamic_1972,clear
save 1972.dta,replace
import delimited dynamic_1973,clear
save 1973.dta,replace
import delimited dynamic_1974,clear
save 1974.dta,replace
import delimited dynamic_1975,clear
save 1975.dta,replace
import delimited dynamic_1976,clear
save 1976.dta,replace
import delimited dynamic_1977,clear
save 1977.dta,replace
import delimited dynamic_1978,clear
save 1978.dta,replace
import delimited dynamic_1979,clear
save 1979.dta,replace
import delimited dynamic_1980,clear
save 1980.dta,replace
import delimited dynamic_1981,clear
save 1981.dta,replace
import delimited dynamic_1982,clear
save 1982.dta,replace
import delimited dynamic_1983,clear
save 1983.dta,replace
import delimited dynamic_1984,clear
save 1984.dta,replace
import delimited dynamic_1985,clear
save 1985.dta,replace
import delimited dynamic_1986,clear
save 1986.dta,replace
import delimited dynamic_1987,clear
save 1987.dta,replace
import delimited dynamic_1988,clear
save 1988.dta,replace
import delimited dynamic_1989,clear
save 1989.dta,replace
import delimited dynamic_1990,clear
save 1990.dta,replace
import delimited dynamic_1991,clear
save 1991.dta,replace
import delimited dynamic_1992,clear
save 1992.dta,replace
import delimited dynamic_1993,clear
save 1993.dta,replace
import delimited dynamic_1994,clear
save 1994.dta,replace
import delimited dynamic_1995,clear
save 1995.dta,replace
import delimited dynamic_1996,clear
save 1996.dta,replace
import delimited dynamic_1997,clear
save 1997.dta,replace
import delimited dynamic_1998,clear
save 1998.dta,replace
import delimited dynamic_1999,clear
save 1999.dta,replace
import delimited dynamic_2000,clear
save 2000.dta,replace
import delimited dynamic_2001,clear
save 2001.dta,replace
import delimited dynamic_2002,clear
save 2002.dta,replace
import delimited dynamic_2003,clear
save 2003.dta,replace
import delimited dynamic_2004,clear
save 2004.dta,replace
import delimited dynamic_2005,clear
save 2005.dta,replace
import delimited dynamic_2006,clear
save 2006.dta,replace
import delimited dynamic_2007,clear
save 2007.dta,replace
import delimited dynamic_2008,clear
save 2008.dta,replace
import delimited dynamic_2009,clear
save 2009.dta,replace
import delimited dynamic_2010,clear
save 2010.dta,replace
import delimited dynamic_2011,clear
save 2011.dta,replace
import delimited dynamic_2012,clear
save 2012.dta,replace
import delimited dynamic_2013,clear
save 2013.dta,replace
import delimited dynamic_2014,clear
save 2014.dta,replace
//Append all .dta files into the 4-digit dataset
//This step is very time-consuming. Execution time about 2 hrs
//The long series of codes are generated in MATLAB
use 1962.dta,clear
append using 1963  1964  1965  1966  1967  1968  1969  1970  ///
1971  1972  1973  1974  1975  1976  1977  1978  1979  1980  ///
1981  1982  1983  1984  1985  1986  1987  1988  1989  1990  ///
1991  1992  1993  1994  1995  1996  1997  1998  1999  2000  ///
2001  2002  2003  2004  2005  2006  2007  2008  2009  2010  ///
2011  2012  2013  2014
save bilateral_trade_4digit.dta,replace

//Add country abbreviation codes to exporter and importer
clear
import delimited CountryCodeNameISO2ISO3.csv,clear
duplicates report countrycode iso2digitalpha
keep countrycode iso2digitalpha

rename countrycode importer_iso
rename iso2digitalpha importer_name
save importer.dta,replace
rename importer_iso exporter_iso
rename importer_name exporter_name
save exporter.dta,replace

use bilateral_trade_4digit.dta,clear
merge n:1 importer_iso using importer.dta
keep if _merge == 3
drop _merge
order importer_name,b(exporter_iso)
merge n:1 exporter_iso using exporter.dta
keep if _merge == 3
drop _merge
order exporter_name,b(sitc0_0011)

sort year
save,replace

//Formating the 1-digit dataset
clear
import delimited sitc1_df.csv,clear
merge n:1 importer_iso using importer.dta
keep if _merge == 3
drop _merge
order importer_name,b(exporter_iso)
merge n:1 exporter_iso using exporter.dta
keep if _merge == 3
drop _merge
order exporter_name,b(sitc0)

sort year
save bilateral_trade_1digit.dta,replace

//Examining the datasets and dealing with missing values
clear
use bilateral_trade_4digit.dta,clear
tab year if sitc0_0011 == -30
tab year if importer_name == "NULL" | exporter_name == "NULL"

drop if sitc0_0011 == -30 //Drop all "-30" observations
drop if importer_name == "NULL" | exporter_name == "NULL" //Drop all "NULL" observations
save,replace

clear
use bilateral_trade_1digit.dta,clear
tab year if importer_name == "NULL" | exporter_name == "NULL"
drop if importer_name == "NULL" | exporter_name == "NULL" //Drop all "NULL" observations
save,replace





