//GDP and debt data
clear

//Extract quarterly nominal GDP and real GDP for all countries,
//domestic currency from IFS database of IMF
sdmxuse data IMF, clear dataset(IFS) dimensions(Q..NGDP_XDC+NGDP_R_XDC) panel(ref_area)
save GDP_NRDC_IFS.dta, replace

//Extract quarterly nominal GDP for all countries,
//US dollar from SNA database of IMF
sdmxuse data IMF, clear dataset(SNA) dimensions(Q..NGDP_USD) panel(ref_area)
save GDP_NUS_SNA.dta, replace

use GDP_NUS_SNA.dta,clear

//Unify the unit of measure for GDP data to 10^6
gen gdpn_us = .
replace gdpn_us = value9*1000 if value9 != .
replace gdpn_us = value6 if value6 != .
replace gdpn_us = value3/1000 if value3 != .
replace gdpn_us = value0/1000000 if value0 != .
label var gdpn_us "Nominal GDP in USD, 10^6"

//Format the dataset into a panel
gen newtime = quarterly(time,"YQ")
format newtime %tq
drop time
rename newtime time
rename ref_area country
sort country time
keep country time gdpn_us
order time, b(gdpn_us)
order country, b(time)
save, replace

use GDP_NRDC_IFS.dta, clear //The unit of measure is already 10^6. No need to change

rename ngdp_r_xdc_p3m_ gdpr_dc
label var gdpr_dc "Real GDP in DC, 10^6" //DC stands for domestic currency
rename ngdp_xdc__p3m gdpn_dc
label var gdpn_dc "Nominal GDP in DC, 10^6"

//Format the dataset into a panel
gen newtime = quarterly(time,"YQ")
format newtime %tq
drop time
rename newtime time
rename ref_area country
sort country time
keep country time gdpn_dc gdpr_dc
order gdpn_dc, b(gdpr_dc)
order time, b(gdpn_dc)
order country, b(time)
save, replace

//Merge 2 datasets
use GDP_NRDC_IFS.dta, clear
merge 1:1 country time using GDP_NUS_SNA.dta
drop _merge
sort country time
save GDP.dta, replace

//I used the MATLAB program "BIS_format.m" to format the raw data from BIS
//The formatted data would continued to be processed in Stata

import delimited hh_ls_pgdp.csv, clear

//Format the dataset into a panel
gen temp1 = date(time,"DMY")
format temp1 %td
gen temp2 = qofd(temp1)
format temp2 %tq
drop temp1 time
rename temp2 time
label var hh_ls_pgdp "HH core debt, %GDP"
order time, b(hh_ls_pgdp)
sort country time
save hh_ls_pgdp.dta, replace

import delimited hh_ls_usd.csv, clear

//Format the dataset into a panel
gen temp1 = date(time,"DMY")
format temp1 %td
gen temp2 = qofd(temp1)
format temp2 %tq
drop temp1 time
rename temp2 time
label var hh_ls_usd "HH core debt in USD, 10^9"
order time, b(hh_ls_usd)
order country, b(time)
sort country time
save hh_ls_usd.dta, replace

import delimited hh_ls_dc.csv, clear

//Format the dataset into a panel
gen temp1 = date(time,"DMY")
format temp1 %td
gen temp2 = qofd(temp1)
format temp2 %tq
drop temp1 time
rename temp2 time
label var hh_ls_dc "HH core debt in DC, 10^9" //DC stands for domestic currency
order time, b(hh_ls_dc)
order country, b(time)
sort country time
save hh_ls_dc.dta, replace

//Merge all datasets
use hh_ls_pgdp.dta, clear
merge 1:1 country time using hh_ls_usd.dta
duplicates report country time
drop _merge
merge 1:1 country time using hh_ls_dc.dta
duplicates report country time
drop _merge
merge 1:1 country time using GDP.dta
duplicates report country time
drop _merge
encode country,gen(country_encoded)
merge n:1 country using country_fullname.dta
keep if _merge == 3
drop _merge
xtset country_encoded time

save GDP_debt.dta, replace


