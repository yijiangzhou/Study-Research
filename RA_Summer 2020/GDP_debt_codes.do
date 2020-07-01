//GDP and debt data
clear

//Original codes to produce the dataset
//by Yijiang Zhou
//June 12, 2020

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

import delimited nfc_pgdp.csv, clear

//Format the dataset into a panel
gen temp1 = date(time,"DMY")
format temp1 %td
gen temp2 = qofd(temp1)
format temp2 %tq
drop temp1 time
rename temp2 time
label var nfc_pgdp "NFC core debt, %GDP"
order time, b(nfc_pgdp)
sort country time
save nfc_pgdp.dta, replace

//Merge all datasets
use hh_ls_pgdp.dta, clear
merge 1:1 country time using hh_ls_usd.dta
duplicates report country time
drop _merge
merge 1:1 country time using hh_ls_dc.dta
duplicates report country time
drop _merge
merge 1:1 country time using nfc_pgdp.dta
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


//Convert country codes and time to numbers
//by Yijiang Zhou
//June 23, 2020
use GDP_debt.dta, clear
egen country_number = group(country) //generate country code number
label var country_number "country code number"
sum time
gen time_number = time + (100-r(min))
label var time_number "time number" //generate time number, with 1949q1 = 100
save, replace


//Getting real GDP (domestic currency) data from IMF-SNA database and
//merge it into the dataset
//by Yijiang Zhou
//June 23, 2020
clear
sdmxuse data IMF, clear dataset(SNA) dimensions(Q..NGDP_R_XDC) panel(ref_area)
keep ref_area time valuek_0_p3m_ valuek_3_p3m_ valuek_6_p3m_ valuek_9_p3m_

//Unify the unit of measure for GDP data to 10^6
gen gdpr_dc_SNA = .
replace gdpr_dc_SNA = valuek_9_p3m_*1000 if valuek_9_p3m_ != .
replace gdpr_dc_SNA = valuek_6_p3m_ if valuek_6_p3m_ != .
replace gdpr_dc_SNA = valuek_3_p3m_/1000 if valuek_3_p3m_ != .
replace gdpr_dc_SNA = valuek_0_p3m_/1000000 if valuek_0_p3m_ != .
label var gdpr_dc_SNA "Real GDP in DC from SNA, 10^6"

//Format the dataset into a panel
gen newtime = quarterly(time,"YQ")
format newtime %tq
drop time
rename newtime time
rename ref_area country
sort country time
keep country time gdpr_dc_SNA
order time, b(gdpr_dc_SNA)
order country, b(time)

save GDP_RDC_SNA.dta, replace

//Merge it into the dataset
use GDP_debt.dta, clear
merge 1:1 country time using GDP_RDC_SNA.dta
drop if _merge == 2
drop _merge
order gdpr_dc_SNA, b(gdpn_us)
drop country_encoded country_fullname country_number time_number
encode country,gen(country_encoded)
merge n:1 country using country_fullname.dta
keep if _merge == 3
drop _merge
egen country_number = group(country) //re-generate country code number
label var country_number "country code number"
sum time
gen time_number = time + (100-r(min))
label var time_number "time number" //re-generate time number, with 1949q1 = 100
sort country time
xtset country_encoded time

save, replace



//Describe the time span of non-missing values in gdpr_dc_SNA and hh_ls_pgdp
//by Yijiang Zhou
//June 23, 2020
// Revised by Liugang, 25/6/2020

use GDP_debt.dta, clear

gen lnGDP=ln(gdpr_dc_SNA)

lab var lnGDP "Ln real GDP in local currency from SNA, IMF"

keep if hh_ls_pgdp != . & lnGDP!= . //Keep the observations whose hh_ls_pgdp and
//gdpr_dc_SNA are both non-missing
bys country: keep if _n == 1 | _n == _N
bys country: egen time_end = max(time)
format time_end %tq
label var time_end "End time of non-missing values"
order time_end,b(hh_ls_pgdp)
rename time time_start
label var time_start "Start time of non-missing values"

bys country: keep if _n == 1


* gen the duration of time range for each country
gen n= time_end-time_start
lab var n "duration of time range for each country"

* recode country code for remaining countries
drop country_number
egen country_number=group(country)

keep country time_start time_end country_encoded country_fullname country_number n

save non_missing_timespan.dta, replace




* export to excel
* by Professor Sheng
use GDP_debt.dta, clear

gen lnGDP=ln(gdpr_dc_SNA)

lab var lnGDP "Ln real GDP in local currency from SNA, IMF"

keep country time  lnGDP hh_ls_pgdp nfc_pgdp

order country time  lnGDP hh_ls_pgdp nfc_pgdp

sort country time

export excel using "D:\Dropbox\idea\LP\data\examples\MSV\quarterlydata\household_q.xls", ///
firstrow(variables) replace



//Real GDP data from IFS, revised
//By Prof. Sheng and Yijiang
//June 27, 2020

sdmxuse data IMF, clear dataset(IFS) dimensions(Q..NGDP_R_K_IX+NGDP_R_K_SA_IX) panel(ref_area)
drop ngdp_r_k_ix__p3m
lab var ngdp_r_k_ix_p3m_ "real GDP at constant price of 2010, local currency no SA"
lab var ngdp_r_k_sa_ix_p3m_ "real GDP at constant price of 2010, local currency SA"

//Format the dataset into a panel
gen newtime = quarterly(time,"YQ")
format newtime %tq
drop time
rename newtime time
rename ref_area country
order time, a(country)
sort country time

* gen lnGDP based on raw real GDP 
gen lnGDP=ln(ngdp_r_k_ix_p3m_)

* use SA adjusted real GDP for countries that have SA real GDP 
* please double check, this hand input of country list is not a good way to do, but a quick way. You can find a better way..

replace lnGDP=ln(ngdp_r_k_sa_ix_p3m_) if cou=="CA" | cou=="CH" | cou=="IT"  ///
| cou=="JP"  | cou=="MX"  | cou=="NZ" | cou=="U2"  | cou=="US"  | cou=="ZA" 
* (2,008 real changes made, 96 to missing), check those 96 obs.

lab var lnGDP "Ln real GDP in local currency IMF"
save realGDP.dta, replace

keep if lnGDP!= .
bys country: keep if _n == 1 | _n == _N
bys country: egen time_end = max(time)
format time_end %tq
label var time_end "End time of non-missing values"
rename time time_start
label var time_start "Start time of non-missing values"

bys country: keep if _n == 1
keep country time_start time_end

* gen the duration of time range for each country
gen n= time_end-time_start
lab var n "duration of time range for each country"

save realGDP_timespan.dta, replace

//Merge the newly collected GDP into the original dataset
use GDP_debt.dta, clear
drop country_encoded country_fullname country_number time_number
merge 1:1 country time using realGDP
keep if _merge != 2
drop _merge
encode country,gen(country_encoded)
merge n:1 country using country_fullname.dta
keep if _merge == 3
drop _merge
egen country_number = group(country) //re-generate country code number
label var country_number "country code number"
sum time
gen time_number = time + (100-r(min))
label var time_number "time number" //re-generate time number, with 1949q1 = 100
sort country time
xtset country_encoded time
save, replace

//Generate time span for non-missing hh_ls_pgdp and lnGDP
use GDP_debt, clear
keep if hh_ls_pgdp != . & lnGDP!= .
bys country: keep if _n == 1 | _n == _N
bys country: egen time_end = max(time)
format time_end %tq
label var time_end "End time of non-missing values"
order time_end,b(hh_ls_pgdp)
rename time time_start
label var time_start "Start time of non-missing values"

bys country: keep if _n == 1

* gen the duration of time range for each country
gen n= time_end-time_start
lab var n "duration of time range for each country"

* recode country code for remaining countries
drop country_number
egen country_number=group(country)

keep country time_start time_end country_fullname country_number n
order n, b(country_fullname)

save non_missing_timespan.dta, replace















































