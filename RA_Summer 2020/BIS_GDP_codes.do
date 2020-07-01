// Prepare quarterly data for lnGDP and household debt/GDP for Local projection
// Quarterly real GDP at constant price in local currency, SA and no SA, from IFS
// Household debt/GDP ratio from BIS
// By Prof. Sheng and Yijiang
// June 28, 2020

clear
set more off


************************************************************************************************
* Part I: Quarterly real GDP
************************************************************************************************

// Extract real GDP at constant price in local currency, SA and no SA, from IFS
// domestic currency from IFS database of IMF
sdmxuse data IMF, clear dataset(IFS) dimensions(Q..NGDP_R_K_IX+NGDP_R_K_SA_IX) panel(ref_area)
drop ngdp_r_k_ix__p3m
lab var ngdp_r_k_ix_p3m_     "Real GDP at constant price of 2010, local currency without SA"
lab var ngdp_r_k_sa_ix_p3m_  "Real GDP at constant price of 2010, local currency SA"

// Format the dataset into a panel
gen newtime = quarterly(time,"YQ")
format newtime %tq
drop time
rename newtime time
rename ref_area country
sort country time
order country time

// Check countries that have raw real GDP but no seasonal adjusted real GDP
tab country if ngdp_r_k_sa_ix_p3m_ ==. & ngdp_r_k_ix_p3m_!=.

// Check countries that have seasonal adjusted real GDP but no raw real GDP
tab country if ngdp_r_k_ix_p3m_==. & ngdp_r_k_sa_ix_p3m_!=.

// Generate lnGDP based on raw real GDP 
gen lnGDP=ln(ngdp_r_k_ix_p3m_)

// Use SA adjusted real GDP for countries that have SA real GDP 
// Please double check, this hand input of country list is not a good way to do, but a quick way. You can find a better way..

gen sa=0
replace sa=1 if cou=="CA" | cou=="CH" | cou=="IT"  ///
| cou=="JP"  | cou=="MX"  | cou=="NZ" | cou=="U2"  | cou=="US"  | cou=="ZA" 

lab var sa "1 indicates lnGDP is SA adjusted"
replace lnGDP=ln(ngdp_r_k_sa_ix_p3m_) if sa==1 
// For Sweden (SE), we use real GDP without SA as it has longer time series

lab var lnGDP "Ln real GDP in local currency IMF"
save realGDP.dta, replace

// Generate the time span for non-missing values in real GDP
use realGDP.dta, clear
keep if lnGDP != .

bys country: keep if _n == 1 | _n == _N
bys country: egen time_end = max(time)
format time_end %tq
label var time_end "End time of non-missing values"
order time_end,b(lnGDP)
rename time time_start
label var time_start "Start time of non-missing values"

bys country: keep if _n == 1

// Generate the duration of time range for each country
gen n= time_end-time_start
lab var n "duration of time range for each country"
drop ngdp* lnGDP

sum n, de

save realGDP_timespan.dta, replace


************************************************************************************************
* Part II: Household debt/GDP and Non-financial cooperates debt/GDP from BIS
************************************************************************************************

// The BIS raw data is re-formatted using the MATLAB program "BIS_format.m"
// It produces 4 csv files that would continued to be processed in Stata

// 1. hh_ls_pgdp
import delimited hh_ls_pgdp.csv, clear
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

// 2. hh_ls_usd
import delimited hh_ls_usd.csv, clear
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

// 3. hh_ls_dc
import delimited hh_ls_dc.csv, clear
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

// 4. nfc_pgdp
import delimited nfc_pgdp.csv, clear
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


************************************************************************************************
* Part III: Quarterly data of real GDP and debt
************************************************************************************************

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
merge 1:1 country time using realGDP.dta
duplicates report country time
drop _merge
encode country,gen(country_encoded)
merge n:1 country using country_fullname.dta
keep if _merge == 3
drop _merge
xtset country_encoded time

save BIS_GDP.dta, replace

//Convert country codes and time to numbers
use BIS_GDP.dta, clear
egen country_number = group(country) //generate country code number
label var country_number "country code number"
sum time
gen time_number = time + (100-r(min))
label var time_number "time number" //generate time number, with 1947q1 = 100
save, replace




