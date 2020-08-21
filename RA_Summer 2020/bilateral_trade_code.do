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

//Check "positive" trade in 4-digit dataset (after dropping missing values)
clear
use bilateral_trade_4digit.dta,clear
egen totaltrade = rowtotal(sitc0_0011-sitc0_9610) //Add up all trade volumes. This
//step takes about 2 hrs
keep year importer_iso importer_name exporter_iso exporter_name totaltrade
save totaltrade.dta,replace

use totaltrade.dta,clear
label var totaltrade "Total trade volume by observation"
tab year
tab year if totaltrade == 0 //"Zero" observations
bys year importer_name: egen imptrade = sum(totaltrade) //Now we add trade volume by importer
label var imptrade "Total trade by importer"
bys year exporter_name: egen exptrade = sum(totaltrade) //Add trade volume by exporter
label var exptrade "Total trade by exporter"
save,replace

bys year importer_name: keep if _n == _N
drop totaltrade
tab year
tab year if imptrade == 0 //"Zero" importers
use totaltrade.dta,clear
bys year exporter_name: keep if _n == _N
drop totaltrade
tab year
tab year if exptrade == 0 //"Zero" exporters
clear


*******************************
* Resource abundant countries *
*******************************
use bilateral_trade_4digit.dta, clear

keep if importer_name == "BO" | importer_name == "EC" | importer_name == "MX" | ///
importer_name == "VE" | importer_name == "CL" | importer_name == "CO" | ///
importer_name == "PE" | importer_name == "AU" | importer_name == "CA"

save resource.dta

gen kap_sitc0_0011 = sitc0_0011/2
gen med_sitc0_0011 = sitc0_0011/2
rename sitc0_0012 med_sitc0_0012
gen kap_sitc0_0013 = sitc0_0013/2
gen med_sitc0_0013 = sitc0_0013/2
rename sitc0_0014 med_sitc0_0014
gen kap_sitc0_0015 = sitc0_0015/2
gen med_sitc0_0015 = sitc0_0015/2
gen med_sitc0_0019 = sitc0_0019/2
gen con_sitc0_0019 = sitc0_0019/2
gen med_sitc0_0111 = sitc0_0111/2
gen con_sitc0_0111 = sitc0_0111/2
gen med_sitc0_0112 = sitc0_0112/2
gen con_sitc0_0112 = sitc0_0112/2
gen med_sitc0_0113 = sitc0_0113/2
gen con_sitc0_0113 = sitc0_0113/2
rename sitc0_0114 con_sitc0_0114
rename sitc0_0115 med_sitc0_0115
rename sitc0_0116 con_sitc0_0116
rename sitc0_0118 con_sitc0_0118
rename sitc0_0121 con_sitc0_0121
rename sitc0_0129 con_sitc0_0129
rename sitc0_0133 med_sitc0_0133
rename sitc0_0134 con_sitc0_0134
rename sitc0_0138 con_sitc0_0138
gen con_sitc0_0221 = sitc0_0221/2
gen med_sitc0_0221 = sitc0_0221/2
gen con_sitc0_0222 = sitc0_0222/2
gen med_sitc0_0222 = sitc0_0222/2
gen con_sitc0_0223 = sitc0_0223/2
gen med_sitc0_0223 = sitc0_0223/2
rename sitc0_0230 con_sitc0_0230
rename sitc0_0240 con_sitc0_0240
gen con_sitc0_0250 = sitc0_0250/2
gen med_sitc0_0250 = sitc0_0250/2
rename sitc0_0311 con_sitc0_0311
gen med_sitc0_0312 = sitc0_0312/2
gen con_sitc0_0312 = sitc0_0312/2
rename sitc0_0313 con_sitc0_0313
gen med_sitc0_0320 = sitc0_0320/2
gen con_sitc0_0320 = sitc0_0320/2
rename sitc0_0410 med_sitc0_0410
rename sitc0_0421 med_sitc0_0421
rename sitc0_0422 con_sitc0_0422
rename sitc0_0430 med_sitc0_0430
gen con_sitc0_0440 = sitc0_0440/2
gen med_sitc0_0440 = sitc0_0440/2
rename sitc0_0451 med_sitc0_0451
rename sitc0_0452 med_sitc0_0452
rename sitc0_0459 med_sitc0_0459
rename sitc0_0460 med_sitc0_0460
rename sitc0_0470 med_sitc0_0470
rename sitc0_0481 con_sitc0_0481
rename sitc0_0482 med_sitc0_0482
rename sitc0_0483 con_sitc0_0483
rename sitc0_0484 con_sitc0_0484
gen con_sitc0_0488 = sitc0_0488/2
gen med_sitc0_0488 = sitc0_0488/2
rename sitc0_0511 con_sitc0_0511
rename sitc0_0512 con_sitc0_0512
rename sitc0_0513 con_sitc0_0513
rename sitc0_0514 con_sitc0_0514
rename sitc0_0515 con_sitc0_0515
gen con_sitc0_0517 = sitc0_0517/2
gen med_sitc0_0517 = sitc0_0517/2
rename sitc0_0519 con_sitc0_0519
rename sitc0_0520 con_sitc0_0520
rename sitc0_0532 con_sitc0_0532
rename sitc0_0533 con_sitc0_0533
rename sitc0_0535 con_sitc0_0535
gen con_sitc0_0536 = sitc0_0536/2
gen med_sitc0_0536 = sitc0_0536/2
rename sitc0_0539 con_sitc0_0539
gen med_sitc0_0541 = sitc0_0541/2
gen con_sitc0_0541 = sitc0_0541/2
rename sitc0_0542 con_sitc0_0542
rename sitc0_0544 con_sitc0_0544
rename sitc0_0545 con_sitc0_0545
rename sitc0_0546 con_sitc0_0546
gen med_sitc0_0548 = sitc0_0548/2
gen con_sitc0_0548 = sitc0_0548/2
rename sitc0_0551 con_sitc0_0551
rename sitc0_0554 med_sitc0_0554
rename sitc0_0555 con_sitc0_0555
rename sitc0_0611 med_sitc0_0611
gen med_sitc0_0612 = sitc0_0612/2
gen con_sitc0_0612 = sitc0_0612/2
rename sitc0_0615 med_sitc0_0615
rename sitc0_0616 con_sitc0_0616
gen med_sitc0_0619 = sitc0_0619/2
gen con_sitc0_0619 = sitc0_0619/2
rename sitc0_0620 con_sitc0_0620
gen med_sitc0_0711 = sitc0_0711/2
gen con_sitc0_0711 = sitc0_0711/2
rename sitc0_0713 con_sitc0_0713
rename sitc0_0721 med_sitc0_0721
rename sitc0_0722 med_sitc0_0722
rename sitc0_0723 med_sitc0_0723
gen con_sitc0_0730 = sitc0_0730/2
gen med_sitc0_0730 = sitc0_0730/2
rename sitc0_0741 con_sitc0_0741
rename sitc0_0742 con_sitc0_0742
rename sitc0_0751 con_sitc0_0751
rename sitc0_0752 con_sitc0_0752
rename sitc0_0811 med_sitc0_0811
rename sitc0_0812 med_sitc0_0812
rename sitc0_0813 med_sitc0_0813
rename sitc0_0814 med_sitc0_0814
gen med_sitc0_0819 = sitc0_0819/2
gen con_sitc0_0819 = sitc0_0819/2
rename sitc0_0913 med_sitc0_0913
rename sitc0_0914 con_sitc0_0914
gen med_sitc0_0990 = sitc0_0990/2
gen con_sitc0_0990 = sitc0_0990/2
rename sitc0_1110 con_sitc0_1110
gen con_sitc0_1121 = sitc0_1121/2
gen med_sitc0_1121 = sitc0_1121/2
rename sitc0_1122 con_sitc0_1122
rename sitc0_1123 con_sitc0_1123
rename sitc0_1124 con_sitc0_1124
rename sitc0_1210 med_sitc0_1210
rename sitc0_1221 con_sitc0_1221
rename sitc0_1222 con_sitc0_1222
gen con_sitc0_1223 = sitc0_1223/2
gen med_sitc0_1223 = sitc0_1223/2
rename sitc0_2111 med_sitc0_2111
rename sitc0_2112 med_sitc0_2112
rename sitc0_2114 med_sitc0_2114
rename sitc0_2116 med_sitc0_2116
rename sitc0_2117 med_sitc0_2117
rename sitc0_2118 med_sitc0_2118
rename sitc0_2119 med_sitc0_2119
rename sitc0_2120 med_sitc0_2120
rename sitc0_2211 med_sitc0_2211
rename sitc0_2212 med_sitc0_2212
rename sitc0_2213 med_sitc0_2213
rename sitc0_2214 med_sitc0_2214
rename sitc0_2215 med_sitc0_2215
rename sitc0_2216 med_sitc0_2216
rename sitc0_2217 med_sitc0_2217
rename sitc0_2218 med_sitc0_2218
rename sitc0_2219 med_sitc0_2219
rename sitc0_2311 med_sitc0_2311
rename sitc0_2312 med_sitc0_2312
rename sitc0_2313 med_sitc0_2313
rename sitc0_2314 med_sitc0_2314
rename sitc0_2411 med_sitc0_2411
rename sitc0_2412 med_sitc0_2412
rename sitc0_2421 med_sitc0_2421
rename sitc0_2422 med_sitc0_2422
rename sitc0_2423 med_sitc0_2423
rename sitc0_2424 med_sitc0_2424
rename sitc0_2429 med_sitc0_2429
rename sitc0_2431 med_sitc0_2431
rename sitc0_2432 med_sitc0_2432
rename sitc0_2433 med_sitc0_2433
rename sitc0_2440 med_sitc0_2440
rename sitc0_2511 med_sitc0_2511
rename sitc0_2512 med_sitc0_2512
rename sitc0_2515 med_sitc0_2515
rename sitc0_2516 med_sitc0_2516
rename sitc0_2517 med_sitc0_2517
rename sitc0_2518 med_sitc0_2518
rename sitc0_2519 med_sitc0_2519
rename sitc0_2611 med_sitc0_2611
rename sitc0_2612 med_sitc0_2612
rename sitc0_2613 med_sitc0_2613
rename sitc0_2621 med_sitc0_2621
rename sitc0_2622 med_sitc0_2622
rename sitc0_2623 med_sitc0_2623
rename sitc0_2625 med_sitc0_2625
rename sitc0_2626 med_sitc0_2626
rename sitc0_2627 med_sitc0_2627
rename sitc0_2628 med_sitc0_2628
rename sitc0_2629 med_sitc0_2629
rename sitc0_2631 med_sitc0_2631
rename sitc0_2632 med_sitc0_2632
rename sitc0_2633 med_sitc0_2633
rename sitc0_2634 med_sitc0_2634
rename sitc0_2640 med_sitc0_2640
rename sitc0_2651 med_sitc0_2651
rename sitc0_2652 med_sitc0_2652
rename sitc0_2653 med_sitc0_2653
rename sitc0_2654 med_sitc0_2654
rename sitc0_2655 med_sitc0_2655
rename sitc0_2658 med_sitc0_2658
rename sitc0_2662 med_sitc0_2662
rename sitc0_2663 med_sitc0_2663
rename sitc0_2664 med_sitc0_2664
rename sitc0_2670 med_sitc0_2670
rename sitc0_2711 med_sitc0_2711
rename sitc0_2712 med_sitc0_2712
rename sitc0_2713 med_sitc0_2713
rename sitc0_2714 med_sitc0_2714
rename sitc0_2731 med_sitc0_2731
rename sitc0_2732 med_sitc0_2732
rename sitc0_2733 med_sitc0_2733
rename sitc0_2734 med_sitc0_2734
rename sitc0_2741 med_sitc0_2741
rename sitc0_2742 med_sitc0_2742
rename sitc0_2751 med_sitc0_2751
rename sitc0_2752 med_sitc0_2752
rename sitc0_2761 med_sitc0_2761
rename sitc0_2762 med_sitc0_2762
rename sitc0_2763 med_sitc0_2763
rename sitc0_2764 med_sitc0_2764
rename sitc0_2765 med_sitc0_2765
rename sitc0_2766 med_sitc0_2766
rename sitc0_2769 med_sitc0_2769
rename sitc0_2813 med_sitc0_2813
rename sitc0_2814 med_sitc0_2814
rename sitc0_2820 med_sitc0_2820
rename sitc0_2831 med_sitc0_2831
rename sitc0_2832 med_sitc0_2832
rename sitc0_2833 med_sitc0_2833
rename sitc0_2834 med_sitc0_2834
rename sitc0_2835 med_sitc0_2835
rename sitc0_2836 med_sitc0_2836
rename sitc0_2837 med_sitc0_2837
rename sitc0_2839 med_sitc0_2839
rename sitc0_2840 med_sitc0_2840
rename sitc0_2850 med_sitc0_2850
rename sitc0_2860 med_sitc0_2860
rename sitc0_2911 med_sitc0_2911
gen med_sitc0_2919 = sitc0_2919/2
gen con_sitc0_2919 = sitc0_2919/2
rename sitc0_2921 med_sitc0_2921
rename sitc0_2922 med_sitc0_2922
rename sitc0_2923 med_sitc0_2923
rename sitc0_2924 med_sitc0_2924
rename sitc0_2925 med_sitc0_2925
rename sitc0_2926 med_sitc0_2926
gen med_sitc0_2927 = sitc0_2927/2
gen con_sitc0_2927 = sitc0_2927/2
rename sitc0_2929 med_sitc0_2929
rename sitc0_3214 med_sitc0_3214
rename sitc0_3215 med_sitc0_3215
rename sitc0_3216 med_sitc0_3216
rename sitc0_3217 med_sitc0_3217
rename sitc0_3218 med_sitc0_3218
rename sitc0_3310 med_sitc0_3310
rename sitc0_3321 med_sitc0_3321
rename sitc0_3322 med_sitc0_3322
rename sitc0_3323 med_sitc0_3323
rename sitc0_3324 med_sitc0_3324
gen med_sitc0_3325 = sitc0_3325/2
gen con_sitc0_3325 = sitc0_3325/2
rename sitc0_3326 med_sitc0_3326
rename sitc0_3329 med_sitc0_3329
rename sitc0_3411 med_sitc0_3411
rename sitc0_3412 med_sitc0_3412
rename sitc0_3510 med_sitc0_3510
rename sitc0_4111 med_sitc0_4111
rename sitc0_4113 med_sitc0_4113
gen med_sitc0_4212 = sitc0_4212/2
gen con_sitc0_4212 = sitc0_4212/2
gen med_sitc0_4213 = sitc0_4213/2
gen con_sitc0_4213 = sitc0_4213/2
gen con_sitc0_4214 = sitc0_4214/2
gen med_sitc0_4214 = sitc0_4214/2
gen med_sitc0_4215 = sitc0_4215/2
gen con_sitc0_4215 = sitc0_4215/2
gen con_sitc0_4216 = sitc0_4216/2
gen med_sitc0_4216 = sitc0_4216/2
gen med_sitc0_4217 = sitc0_4217/2
gen con_sitc0_4217 = sitc0_4217/2
gen con_sitc0_4221 = sitc0_4221/2
gen med_sitc0_4221 = sitc0_4221/2
gen med_sitc0_4222 = sitc0_4222/2
gen con_sitc0_4222 = sitc0_4222/2
gen med_sitc0_4223 = sitc0_4223/2
gen con_sitc0_4223 = sitc0_4223/2
gen con_sitc0_4224 = sitc0_4224/2
gen med_sitc0_4224 = sitc0_4224/2
gen med_sitc0_4225 = sitc0_4225/2
gen con_sitc0_4225 = sitc0_4225/2
gen med_sitc0_4229 = sitc0_4229/2
gen con_sitc0_4229 = sitc0_4229/2
rename sitc0_4311 med_sitc0_4311
gen med_sitc0_4312 = sitc0_4312/2
gen con_sitc0_4312 = sitc0_4312/2
rename sitc0_4313 med_sitc0_4313
rename sitc0_4314 med_sitc0_4314
rename sitc0_5121 med_sitc0_5121
rename sitc0_5122 med_sitc0_5122
rename sitc0_5123 med_sitc0_5123
rename sitc0_5124 med_sitc0_5124
rename sitc0_5125 med_sitc0_5125
rename sitc0_5126 med_sitc0_5126
rename sitc0_5127 med_sitc0_5127
rename sitc0_5128 med_sitc0_5128
rename sitc0_5129 med_sitc0_5129
rename sitc0_5131 med_sitc0_5131
rename sitc0_5132 med_sitc0_5132
rename sitc0_5133 med_sitc0_5133
rename sitc0_5134 med_sitc0_5134
rename sitc0_5135 med_sitc0_5135
rename sitc0_5136 med_sitc0_5136
rename sitc0_5141 med_sitc0_5141
rename sitc0_5142 med_sitc0_5142
rename sitc0_5143 med_sitc0_5143
rename sitc0_5149 med_sitc0_5149
rename sitc0_5151 med_sitc0_5151
rename sitc0_5152 med_sitc0_5152
gen con_sitc0_5153 = sitc0_5153/2
gen med_sitc0_5153 = sitc0_5153/2
rename sitc0_5211 med_sitc0_5211
gen med_sitc0_5213 = sitc0_5213/2
gen con_sitc0_5213 = sitc0_5213/2
rename sitc0_5214 med_sitc0_5214
rename sitc0_5310 med_sitc0_5310
rename sitc0_5321 med_sitc0_5321
rename sitc0_5323 med_sitc0_5323
rename sitc0_5324 med_sitc0_5324
rename sitc0_5325 med_sitc0_5325
rename sitc0_5331 med_sitc0_5331
rename sitc0_5332 med_sitc0_5332
gen med_sitc0_5333 = sitc0_5333/2
gen con_sitc0_5333 = sitc0_5333/2
rename sitc0_5411 med_sitc0_5411
rename sitc0_5413 med_sitc0_5413
rename sitc0_5414 med_sitc0_5414
rename sitc0_5415 med_sitc0_5415
gen med_sitc0_5416 = sitc0_5416/2
gen con_sitc0_5416 = sitc0_5416/2
gen med_sitc0_5417 = sitc0_5417/2
gen con_sitc0_5417 = sitc0_5417/2
gen con_sitc0_5419 = sitc0_5419/2
gen med_sitc0_5419 = sitc0_5419/2
rename sitc0_5511 med_sitc0_5511
gen med_sitc0_5512 = sitc0_5512/2
gen con_sitc0_5512 = sitc0_5512/2
gen con_sitc0_5530 = sitc0_5530/2
gen med_sitc0_5530 = sitc0_5530/2
rename sitc0_5541 con_sitc0_5541
gen med_sitc0_5542 = sitc0_5542/2
gen con_sitc0_5542 = sitc0_5542/2
rename sitc0_5543 con_sitc0_5543
rename sitc0_5611 med_sitc0_5611
rename sitc0_5612 med_sitc0_5612
rename sitc0_5613 med_sitc0_5613
rename sitc0_5619 med_sitc0_5619
rename sitc0_5711 med_sitc0_5711
rename sitc0_5712 med_sitc0_5712
rename sitc0_5713 med_sitc0_5713
rename sitc0_5714 med_sitc0_5714
gen med_sitc0_5811 = sitc0_5811/2
gen con_sitc0_5811 = sitc0_5811/2
gen med_sitc0_5812 = sitc0_5812/3
gen con_sitc0_5812 = sitc0_5812/3
gen kap_sitc0_5812 = sitc0_5812/3
gen med_sitc0_5813 = sitc0_5813/2
gen con_sitc0_5813 = sitc0_5813/2
gen con_sitc0_5819 = sitc0_5819/2
gen med_sitc0_5819 = sitc0_5819/2
rename sitc0_5992 con_sitc0_5992
gen med_sitc0_5995 = sitc0_5995/2
gen con_sitc0_5995 = sitc0_5995/2
gen med_sitc0_5996 = sitc0_5996/2
gen con_sitc0_5996 = sitc0_5996/2
rename sitc0_5997 med_sitc0_5997
gen con_sitc0_5999 = sitc0_5999/2
gen med_sitc0_5999 = sitc0_5999/2
rename sitc0_6112 med_sitc0_6112
rename sitc0_6113 med_sitc0_6113
rename sitc0_6114 med_sitc0_6114
rename sitc0_6119 med_sitc0_6119
gen med_sitc0_6121 = sitc0_6121/2
gen con_sitc0_6121 = sitc0_6121/2
rename sitc0_6122 con_sitc0_6122
rename sitc0_6123 con_sitc0_6123
gen med_sitc0_6129 = sitc0_6129/2
gen con_sitc0_6129 = sitc0_6129/2
rename sitc0_6130 med_sitc0_6130
rename sitc0_6210 med_sitc0_6210
rename sitc0_6291 med_sitc0_6291
gen con_sitc0_6293 = sitc0_6293/2
gen med_sitc0_6293 = sitc0_6293/2
rename sitc0_6294 med_sitc0_6294
gen med_sitc0_6299 = sitc0_6299/2
gen con_sitc0_6299 = sitc0_6299/2
rename sitc0_6311 med_sitc0_6311
gen med_sitc0_6312 = sitc0_6312/2
gen con_sitc0_6312 = sitc0_6312/2
rename sitc0_6314 med_sitc0_6314
gen med_sitc0_6318 = sitc0_6318/3
gen kap_sitc0_6318 = sitc0_6318/3
gen con_sitc0_6318 = sitc0_6318/3
rename sitc0_6321 med_sitc0_6321
rename sitc0_6322 med_sitc0_6322
rename sitc0_6324 med_sitc0_6324
gen con_sitc0_6327 = sitc0_6327/2
gen med_sitc0_6327 = sitc0_6327/2
gen con_sitc0_6328 = sitc0_6328/3
gen med_sitc0_6328 = sitc0_6328/3
gen kap_sitc0_6328 = sitc0_6328/3
gen med_sitc0_6330 = sitc0_6330/2
gen con_sitc0_6330 = sitc0_6330/2
rename sitc0_6411 med_sitc0_6411
gen med_sitc0_6412 = sitc0_6412/2
gen con_sitc0_6412 = sitc0_6412/2
gen con_sitc0_6413 = sitc0_6413/2
gen med_sitc0_6413 = sitc0_6413/2
gen con_sitc0_6414 = sitc0_6414/2
gen med_sitc0_6414 = sitc0_6414/2
gen con_sitc0_6415 = sitc0_6415/2
gen med_sitc0_6415 = sitc0_6415/2
rename sitc0_6416 med_sitc0_6416
gen med_sitc0_6417 = sitc0_6417/2
gen con_sitc0_6417 = sitc0_6417/2
gen med_sitc0_6419 = sitc0_6419/2
gen con_sitc0_6419 = sitc0_6419/2
rename sitc0_6421 med_sitc0_6421
gen med_sitc0_6422 = sitc0_6422/2
gen con_sitc0_6422 = sitc0_6422/2
gen med_sitc0_6423 = sitc0_6423/2
gen con_sitc0_6423 = sitc0_6423/2
gen con_sitc0_6429 = sitc0_6429/2
gen med_sitc0_6429 = sitc0_6429/2
gen med_sitc0_6511 = sitc0_6511/2
gen con_sitc0_6511 = sitc0_6511/2
gen med_sitc0_6512 = sitc0_6512/2
gen con_sitc0_6512 = sitc0_6512/2
gen med_sitc0_6513 = sitc0_6513/2
gen con_sitc0_6513 = sitc0_6513/2
rename sitc0_6515 med_sitc0_6515
gen med_sitc0_6516 = sitc0_6516/2
gen con_sitc0_6516 = sitc0_6516/2
gen med_sitc0_6517 = sitc0_6517/2
gen con_sitc0_6517 = sitc0_6517/2
rename sitc0_6518 med_sitc0_6518
rename sitc0_6519 med_sitc0_6519
gen med_sitc0_6521 = sitc0_6521/2
gen con_sitc0_6521 = sitc0_6521/2
gen con_sitc0_6522 = sitc0_6522/2
gen med_sitc0_6522 = sitc0_6522/2
gen med_sitc0_6531 = sitc0_6531/2
gen con_sitc0_6531 = sitc0_6531/2
gen con_sitc0_6532 = sitc0_6532/2
gen med_sitc0_6532 = sitc0_6532/2
gen med_sitc0_6533 = sitc0_6533/2
gen con_sitc0_6533 = sitc0_6533/2
gen con_sitc0_6534 = sitc0_6534/2
gen med_sitc0_6534 = sitc0_6534/2
gen con_sitc0_6535 = sitc0_6535/2
gen med_sitc0_6535 = sitc0_6535/2
gen med_sitc0_6536 = sitc0_6536/2
gen con_sitc0_6536 = sitc0_6536/2
gen con_sitc0_6537 = sitc0_6537/2
gen med_sitc0_6537 = sitc0_6537/2
rename sitc0_6538 med_sitc0_6538
gen med_sitc0_6539 = sitc0_6539/2
gen con_sitc0_6539 = sitc0_6539/2
gen med_sitc0_6540 = sitc0_6540/2
gen con_sitc0_6540 = sitc0_6540/2
gen con_sitc0_6551 = sitc0_6551/2
gen med_sitc0_6551 = sitc0_6551/2
gen con_sitc0_6554 = sitc0_6554/2
gen med_sitc0_6554 = sitc0_6554/2
rename sitc0_6555 med_sitc0_6555
rename sitc0_6556 med_sitc0_6556
rename sitc0_6557 med_sitc0_6557
gen con_sitc0_6558 = sitc0_6558/2
gen med_sitc0_6558 = sitc0_6558/2
rename sitc0_6559 med_sitc0_6559
rename sitc0_6561 med_sitc0_6561
gen con_sitc0_6562 = sitc0_6562/2
gen med_sitc0_6562 = sitc0_6562/2
rename sitc0_6566 con_sitc0_6566
gen con_sitc0_6569 = sitc0_6569/2
gen med_sitc0_6569 = sitc0_6569/2
gen con_sitc0_6574 = sitc0_6574/2
gen med_sitc0_6574 = sitc0_6574/2
rename sitc0_6575 con_sitc0_6575
rename sitc0_6576 con_sitc0_6576
rename sitc0_6577 con_sitc0_6577
gen con_sitc0_6578 = sitc0_6578/2
gen med_sitc0_6578 = sitc0_6578/2
rename sitc0_6611 med_sitc0_6611
rename sitc0_6612 med_sitc0_6612
gen med_sitc0_6613 = sitc0_6613/3
gen kap_sitc0_6613 = sitc0_6613/3
gen con_sitc0_6613 = sitc0_6613/3
gen kap_sitc0_6618 = sitc0_6618/2
gen med_sitc0_6618 = sitc0_6618/2
rename sitc0_6623 med_sitc0_6623
rename sitc0_6624 med_sitc0_6624
gen med_sitc0_6631 = sitc0_6631/2
gen con_sitc0_6631 = sitc0_6631/2
rename sitc0_6632 med_sitc0_6632
rename sitc0_6634 med_sitc0_6634
rename sitc0_6635 med_sitc0_6635
gen med_sitc0_6636 = sitc0_6636/2
gen con_sitc0_6636 = sitc0_6636/2
rename sitc0_6637 med_sitc0_6637
rename sitc0_6638 med_sitc0_6638
gen med_sitc0_6639 = sitc0_6639/2
gen con_sitc0_6639 = sitc0_6639/2
rename sitc0_6641 med_sitc0_6641
rename sitc0_6642 med_sitc0_6642
rename sitc0_6643 med_sitc0_6643
rename sitc0_6644 med_sitc0_6644
rename sitc0_6645 med_sitc0_6645
rename sitc0_6646 med_sitc0_6646
rename sitc0_6647 med_sitc0_6647
rename sitc0_6648 med_sitc0_6648
rename sitc0_6649 med_sitc0_6649
rename sitc0_6651 med_sitc0_6651
gen con_sitc0_6652 = sitc0_6652/2
gen med_sitc0_6652 = sitc0_6652/2
gen con_sitc0_6658 = sitc0_6658/2
gen med_sitc0_6658 = sitc0_6658/2
rename sitc0_6664 con_sitc0_6664
rename sitc0_6665 con_sitc0_6665
gen con_sitc0_6666 = sitc0_6666/3
gen kap_sitc0_6666 = sitc0_6666/3
gen med_sitc0_6666 = sitc0_6666/3
rename sitc0_6671 med_sitc0_6671
rename sitc0_6672 med_sitc0_6672
rename sitc0_6673 med_sitc0_6673
rename sitc0_6674 med_sitc0_6674
rename sitc0_6711 med_sitc0_6711
rename sitc0_6712 med_sitc0_6712
rename sitc0_6713 med_sitc0_6713
rename sitc0_6714 med_sitc0_6714
rename sitc0_6715 med_sitc0_6715
rename sitc0_6721 med_sitc0_6721
rename sitc0_6723 med_sitc0_6723
rename sitc0_6725 med_sitc0_6725
rename sitc0_6727 med_sitc0_6727
rename sitc0_6729 med_sitc0_6729
rename sitc0_6731 med_sitc0_6731
rename sitc0_6732 med_sitc0_6732
rename sitc0_6734 med_sitc0_6734
rename sitc0_6735 med_sitc0_6735
rename sitc0_6741 med_sitc0_6741
rename sitc0_6742 med_sitc0_6742
rename sitc0_6743 med_sitc0_6743
rename sitc0_6747 med_sitc0_6747
rename sitc0_6748 med_sitc0_6748
rename sitc0_6750 med_sitc0_6750
rename sitc0_6761 med_sitc0_6761
rename sitc0_6762 med_sitc0_6762
rename sitc0_6770 med_sitc0_6770
rename sitc0_6781 med_sitc0_6781
rename sitc0_6782 med_sitc0_6782
rename sitc0_6783 med_sitc0_6783
rename sitc0_6784 med_sitc0_6784
rename sitc0_6785 med_sitc0_6785
gen med_sitc0_6791 = sitc0_6791/2
gen kap_sitc0_6791 = sitc0_6791/2
gen kap_sitc0_6792 = sitc0_6792/2
gen med_sitc0_6792 = sitc0_6792/2
gen kap_sitc0_6793 = sitc0_6793/2
gen med_sitc0_6793 = sitc0_6793/2
rename sitc0_6811 med_sitc0_6811
rename sitc0_6812 med_sitc0_6812
rename sitc0_6821 med_sitc0_6821
rename sitc0_6822 med_sitc0_6822
rename sitc0_6831 med_sitc0_6831
rename sitc0_6832 med_sitc0_6832
rename sitc0_6841 med_sitc0_6841
rename sitc0_6842 med_sitc0_6842
rename sitc0_6851 med_sitc0_6851
rename sitc0_6852 med_sitc0_6852
rename sitc0_6861 med_sitc0_6861
rename sitc0_6862 med_sitc0_6862
rename sitc0_6871 med_sitc0_6871
rename sitc0_6872 med_sitc0_6872
rename sitc0_6880 med_sitc0_6880
rename sitc0_6893 med_sitc0_6893
rename sitc0_6894 med_sitc0_6894
rename sitc0_6895 med_sitc0_6895
rename sitc0_6911 med_sitc0_6911
rename sitc0_6912 med_sitc0_6912
gen kap_sitc0_6913 = sitc0_6913/3
gen con_sitc0_6913 = sitc0_6913/3
gen med_sitc0_6913 = sitc0_6913/3
gen con_sitc0_6921 = sitc0_6921/3
gen med_sitc0_6921 = sitc0_6921/3
gen kap_sitc0_6921 = sitc0_6921/3
rename sitc0_6922 kap_sitc0_6922
rename sitc0_6923 kap_sitc0_6923
rename sitc0_6931 med_sitc0_6931
rename sitc0_6932 med_sitc0_6932
gen kap_sitc0_6933 = sitc0_6933/3
gen con_sitc0_6933 = sitc0_6933/3
gen med_sitc0_6933 = sitc0_6933/3
gen med_sitc0_6934 = sitc0_6934/3
gen con_sitc0_6934 = sitc0_6934/3
gen kap_sitc0_6934 = sitc0_6934/3
rename sitc0_6941 med_sitc0_6941
rename sitc0_6942 med_sitc0_6942
rename sitc0_6951 kap_sitc0_6951
gen kap_sitc0_6952 = sitc0_6952/3
gen med_sitc0_6952 = sitc0_6952/3
gen con_sitc0_6952 = sitc0_6952/3
gen con_sitc0_6960 = sitc0_6960/3
gen kap_sitc0_6960 = sitc0_6960/3
gen med_sitc0_6960 = sitc0_6960/3
gen con_sitc0_6971 = sitc0_6971/2
gen med_sitc0_6971 = sitc0_6971/2
gen med_sitc0_6972 = sitc0_6972/3
gen con_sitc0_6972 = sitc0_6972/3
gen kap_sitc0_6972 = sitc0_6972/3
gen kap_sitc0_6979 = sitc0_6979/3
gen con_sitc0_6979 = sitc0_6979/3
gen med_sitc0_6979 = sitc0_6979/3
rename sitc0_6981 med_sitc0_6981
rename sitc0_6982 kap_sitc0_6982
rename sitc0_6983 med_sitc0_6983
rename sitc0_6984 med_sitc0_6984
gen con_sitc0_6985 = sitc0_6985/2
gen med_sitc0_6985 = sitc0_6985/2
gen con_sitc0_6986 = sitc0_6986/2
gen med_sitc0_6986 = sitc0_6986/2
gen con_sitc0_6988 = sitc0_6988/3
gen med_sitc0_6988 = sitc0_6988/3
gen kap_sitc0_6988 = sitc0_6988/3
gen con_sitc0_6989 = sitc0_6989/3
gen kap_sitc0_6989 = sitc0_6989/3
gen med_sitc0_6989 = sitc0_6989/3
gen kap_sitc0_7111 = sitc0_7111/2
gen med_sitc0_7111 = sitc0_7111/2
gen med_sitc0_7112 = sitc0_7112/2
gen kap_sitc0_7112 = sitc0_7112/2
gen med_sitc0_7113 = sitc0_7113/2
gen kap_sitc0_7113 = sitc0_7113/2
gen med_sitc0_7114 = sitc0_7114/2
gen kap_sitc0_7114 = sitc0_7114/2
gen kap_sitc0_7115 = sitc0_7115/3
gen med_sitc0_7115 = sitc0_7115/3
gen con_sitc0_7115 = sitc0_7115/3
rename sitc0_7116 med_sitc0_7116
gen kap_sitc0_7117 = sitc0_7117/2
gen med_sitc0_7117 = sitc0_7117/2
gen med_sitc0_7118 = sitc0_7118/2
gen kap_sitc0_7118 = sitc0_7118/2
gen kap_sitc0_7121 = sitc0_7121/2
gen med_sitc0_7121 = sitc0_7121/2
gen med_sitc0_7122 = sitc0_7122/3
gen kap_sitc0_7122 = sitc0_7122/3
gen con_sitc0_7122 = sitc0_7122/3
gen kap_sitc0_7123 = sitc0_7123/2
gen med_sitc0_7123 = sitc0_7123/2
rename sitc0_7125 kap_sitc0_7125
gen med_sitc0_7129 = sitc0_7129/2
gen kap_sitc0_7129 = sitc0_7129/2
rename sitc0_7141 kap_sitc0_7141
gen con_sitc0_7142 = sitc0_7142/2
gen kap_sitc0_7142 = sitc0_7142/2
gen kap_sitc0_7143 = sitc0_7143/2
gen con_sitc0_7143 = sitc0_7143/2
gen med_sitc0_7149 = sitc0_7149/2
gen kap_sitc0_7149 = sitc0_7149/2
rename sitc0_7151 kap_sitc0_7151
gen med_sitc0_7152 = sitc0_7152/3
gen kap_sitc0_7152 = sitc0_7152/3
gen con_sitc0_7152 = sitc0_7152/3
gen kap_sitc0_7171 = sitc0_7171/3
gen con_sitc0_7171 = sitc0_7171/3
gen med_sitc0_7171 = sitc0_7171/3
gen kap_sitc0_7172 = sitc0_7172/2
gen med_sitc0_7172 = sitc0_7172/2
gen kap_sitc0_7173 = sitc0_7173/3
gen med_sitc0_7173 = sitc0_7173/3
gen con_sitc0_7173 = sitc0_7173/3
gen med_sitc0_7181 = sitc0_7181/2
gen kap_sitc0_7181 = sitc0_7181/2
gen kap_sitc0_7182 = sitc0_7182/2
gen med_sitc0_7182 = sitc0_7182/2
gen med_sitc0_7183 = sitc0_7183/2
gen kap_sitc0_7183 = sitc0_7183/2
gen kap_sitc0_7184 = sitc0_7184/2
gen med_sitc0_7184 = sitc0_7184/2
gen med_sitc0_7185 = sitc0_7185/2
gen kap_sitc0_7185 = sitc0_7185/2
gen kap_sitc0_7191 = sitc0_7191/3
gen med_sitc0_7191 = sitc0_7191/3
gen con_sitc0_7191 = sitc0_7191/3
gen kap_sitc0_7192 = sitc0_7192/3
gen con_sitc0_7192 = sitc0_7192/3
gen med_sitc0_7192 = sitc0_7192/3
gen med_sitc0_7193 = sitc0_7193/3
gen kap_sitc0_7193 = sitc0_7193/3
gen con_sitc0_7193 = sitc0_7193/3
gen con_sitc0_7194 = sitc0_7194/3
gen med_sitc0_7194 = sitc0_7194/3
gen kap_sitc0_7194 = sitc0_7194/3
gen kap_sitc0_7195 = sitc0_7195/2
gen med_sitc0_7195 = sitc0_7195/2
gen med_sitc0_7196 = sitc0_7196/3
gen con_sitc0_7196 = sitc0_7196/3
gen kap_sitc0_7196 = sitc0_7196/3
rename sitc0_7197 med_sitc0_7197
gen con_sitc0_7198 = sitc0_7198/3
gen med_sitc0_7198 = sitc0_7198/3
gen kap_sitc0_7198 = sitc0_7198/3
gen med_sitc0_7199 = sitc0_7199/2
gen kap_sitc0_7199 = sitc0_7199/2
gen med_sitc0_7221 = sitc0_7221/2
gen kap_sitc0_7221 = sitc0_7221/2
rename sitc0_7222 med_sitc0_7222
rename sitc0_7231 med_sitc0_7231
rename sitc0_7232 med_sitc0_7232
gen con_sitc0_7241 = sitc0_7241/3
gen kap_sitc0_7241 = sitc0_7241/3
gen med_sitc0_7241 = sitc0_7241/3
gen con_sitc0_7242 = sitc0_7242/3
gen med_sitc0_7242 = sitc0_7242/3
gen kap_sitc0_7242 = sitc0_7242/3
gen med_sitc0_7249 = sitc0_7249/3
gen kap_sitc0_7249 = sitc0_7249/3
gen con_sitc0_7249 = sitc0_7249/3
gen con_sitc0_7250 = sitc0_7250/3
gen med_sitc0_7250 = sitc0_7250/3
gen kap_sitc0_7250 = sitc0_7250/3
rename sitc0_7261 kap_sitc0_7261
gen med_sitc0_7262 = sitc0_7262/2
gen kap_sitc0_7262 = sitc0_7262/2
gen med_sitc0_7291 = sitc0_7291/2
gen con_sitc0_7291 = sitc0_7291/2
gen med_sitc0_7292 = sitc0_7292/2
gen con_sitc0_7292 = sitc0_7292/2
gen med_sitc0_7293 = sitc0_7293/3
gen kap_sitc0_7293 = sitc0_7293/3
gen con_sitc0_7293 = sitc0_7293/3
rename sitc0_7294 med_sitc0_7294
rename sitc0_7295 kap_sitc0_7295
gen kap_sitc0_7296 = sitc0_7296/2
gen med_sitc0_7296 = sitc0_7296/2
gen kap_sitc0_7297 = sitc0_7297/3
gen con_sitc0_7297 = sitc0_7297/3
gen med_sitc0_7297 = sitc0_7297/3
gen med_sitc0_7299 = sitc0_7299/3
gen con_sitc0_7299 = sitc0_7299/3
gen kap_sitc0_7299 = sitc0_7299/3
rename sitc0_7311 kap_sitc0_7311
rename sitc0_7312 kap_sitc0_7312
rename sitc0_7313 kap_sitc0_7313
rename sitc0_7314 kap_sitc0_7314
rename sitc0_7315 kap_sitc0_7315
rename sitc0_7316 kap_sitc0_7316
gen med_sitc0_7317 = sitc0_7317/2
gen con_sitc0_7317 = sitc0_7317/2
rename sitc0_7322 kap_sitc0_7322
gen con_sitc0_7323 = sitc0_7323/2
gen kap_sitc0_7323 = sitc0_7323/2
rename sitc0_7324 kap_sitc0_7324
rename sitc0_7325 kap_sitc0_7325
rename sitc0_7326 med_sitc0_7326
rename sitc0_7327 med_sitc0_7327
gen med_sitc0_7328 = sitc0_7328/2
gen con_sitc0_7328 = sitc0_7328/2
gen med_sitc0_7329 = sitc0_7329/2
gen con_sitc0_7329 = sitc0_7329/2
gen con_sitc0_7331 = sitc0_7331/2
gen med_sitc0_7331 = sitc0_7331/2
gen con_sitc0_7333 = sitc0_7333/3
gen med_sitc0_7333 = sitc0_7333/3
gen kap_sitc0_7333 = sitc0_7333/3
rename sitc0_7334 con_sitc0_7334
gen kap_sitc0_7341 = sitc0_7341/2
gen con_sitc0_7341 = sitc0_7341/2
gen con_sitc0_7349 = sitc0_7349/3
gen med_sitc0_7349 = sitc0_7349/3
gen kap_sitc0_7349 = sitc0_7349/3
gen con_sitc0_7353 = sitc0_7353/2
gen kap_sitc0_7353 = sitc0_7353/2
rename sitc0_7358 med_sitc0_7358
gen kap_sitc0_7359 = sitc0_7359/3
gen con_sitc0_7359 = sitc0_7359/3
gen med_sitc0_7359 = sitc0_7359/3
gen kap_sitc0_8121 = sitc0_8121/2
gen med_sitc0_8121 = sitc0_8121/2
rename sitc0_8122 med_sitc0_8122
rename sitc0_8123 med_sitc0_8123
gen med_sitc0_8124 = sitc0_8124/2
gen con_sitc0_8124 = sitc0_8124/2
gen med_sitc0_8210 = sitc0_8210/3
gen con_sitc0_8210 = sitc0_8210/3
gen kap_sitc0_8210 = sitc0_8210/3
gen med_sitc0_8310 = sitc0_8310/2
gen con_sitc0_8310 = sitc0_8310/2
rename sitc0_8411 con_sitc0_8411
gen kap_sitc0_8412 = sitc0_8412/2
gen con_sitc0_8412 = sitc0_8412/2
rename sitc0_8413 con_sitc0_8413
gen med_sitc0_8414 = sitc0_8414/2
gen con_sitc0_8414 = sitc0_8414/2
gen med_sitc0_8415 = sitc0_8415/2
gen con_sitc0_8415 = sitc0_8415/2
gen med_sitc0_8416 = sitc0_8416/2
gen con_sitc0_8416 = sitc0_8416/2
gen med_sitc0_8420 = sitc0_8420/2
gen con_sitc0_8420 = sitc0_8420/2
rename sitc0_8510 con_sitc0_8510
gen con_sitc0_8611 = sitc0_8611/2
gen med_sitc0_8611 = sitc0_8611/2
gen med_sitc0_8612 = sitc0_8612/2
gen con_sitc0_8612 = sitc0_8612/2
gen con_sitc0_8613 = sitc0_8613/3
gen kap_sitc0_8613 = sitc0_8613/3
gen med_sitc0_8613 = sitc0_8613/3
gen med_sitc0_8614 = sitc0_8614/3
gen kap_sitc0_8614 = sitc0_8614/3
gen con_sitc0_8614 = sitc0_8614/3
gen kap_sitc0_8615 = sitc0_8615/3
gen con_sitc0_8615 = sitc0_8615/3
gen med_sitc0_8615 = sitc0_8615/3
gen con_sitc0_8616 = sitc0_8616/3
gen kap_sitc0_8616 = sitc0_8616/3
gen med_sitc0_8616 = sitc0_8616/3
gen kap_sitc0_8617 = sitc0_8617/2
gen med_sitc0_8617 = sitc0_8617/2
rename sitc0_8618 kap_sitc0_8618
gen kap_sitc0_8619 = sitc0_8619/2
gen med_sitc0_8619 = sitc0_8619/2
rename sitc0_8623 med_sitc0_8623
gen med_sitc0_8624 = sitc0_8624/2
gen con_sitc0_8624 = sitc0_8624/2
rename sitc0_8630 med_sitc0_8630
gen med_sitc0_8641 = sitc0_8641/2
gen con_sitc0_8641 = sitc0_8641/2
gen con_sitc0_8642 = sitc0_8642/3
gen kap_sitc0_8642 = sitc0_8642/3
gen med_sitc0_8642 = sitc0_8642/3
gen kap_sitc0_8911 = sitc0_8911/3
gen med_sitc0_8911 = sitc0_8911/3
gen con_sitc0_8911 = sitc0_8911/3
gen con_sitc0_8912 = sitc0_8912/3
gen med_sitc0_8912 = sitc0_8912/3
gen kap_sitc0_8912 = sitc0_8912/3
gen con_sitc0_8914 = sitc0_8914/2
gen med_sitc0_8914 = sitc0_8914/2
rename sitc0_8918 con_sitc0_8918
gen med_sitc0_8919 = sitc0_8919/2
gen con_sitc0_8919 = sitc0_8919/2
rename sitc0_8921 con_sitc0_8921
rename sitc0_8922 con_sitc0_8922
rename sitc0_8923 con_sitc0_8923
gen med_sitc0_8924 = sitc0_8924/2
gen con_sitc0_8924 = sitc0_8924/2
gen med_sitc0_8929 = sitc0_8929/2
gen con_sitc0_8929 = sitc0_8929/2
gen med_sitc0_8930 = sitc0_8930/3
gen kap_sitc0_8930 = sitc0_8930/3
gen con_sitc0_8930 = sitc0_8930/3
gen med_sitc0_8941 = sitc0_8941/2
gen con_sitc0_8941 = sitc0_8941/2
gen kap_sitc0_8942 = sitc0_8942/3
gen med_sitc0_8942 = sitc0_8942/3
gen con_sitc0_8942 = sitc0_8942/3
gen con_sitc0_8943 = sitc0_8943/3
gen kap_sitc0_8943 = sitc0_8943/3
gen med_sitc0_8943 = sitc0_8943/3
rename sitc0_8944 con_sitc0_8944
rename sitc0_8945 kap_sitc0_8945
gen med_sitc0_8951 = sitc0_8951/2
gen kap_sitc0_8951 = sitc0_8951/2
gen con_sitc0_8952 = sitc0_8952/2
gen med_sitc0_8952 = sitc0_8952/2
gen con_sitc0_8959 = sitc0_8959/2
gen med_sitc0_8959 = sitc0_8959/2
rename sitc0_8960 con_sitc0_8960
gen con_sitc0_8971 = sitc0_8971/2
gen kap_sitc0_8971 = sitc0_8971/2
rename sitc0_8972 con_sitc0_8972
gen con_sitc0_8991 = sitc0_8991/2
gen med_sitc0_8991 = sitc0_8991/2
gen con_sitc0_8992 = sitc0_8992/2
gen med_sitc0_8992 = sitc0_8992/2
gen con_sitc0_8993 = sitc0_8993/2
gen med_sitc0_8993 = sitc0_8993/2
gen con_sitc0_8994 = sitc0_8994/2
gen med_sitc0_8994 = sitc0_8994/2
gen med_sitc0_8995 = sitc0_8995/3
gen kap_sitc0_8995 = sitc0_8995/3
gen con_sitc0_8995 = sitc0_8995/3
rename sitc0_8996 con_sitc0_8996
gen con_sitc0_8999 = sitc0_8999/2
gen med_sitc0_8999 = sitc0_8999/2
gen med_sitc0_9410 = sitc0_9410/2
gen con_sitc0_9410 = sitc0_9410/2
gen med_sitc0_9510 = sitc0_9510/2
gen con_sitc0_9510 = sitc0_9510/2
drop sitc0_* v629

foreach var of varlist _all {
	label var `var' ""
}

order *,sequential
order year importer_iso importer_name exporter_iso exporter_name,first
label var year "Year"
label var importer_iso "importer_ISO"
label var importer_name "ISO2-digit Alpha"
label var exporter_iso "exporter_ISO"
label var exporter_name "ISO2-digit Alpha"

//Add up trade volume by SNA categories
egen totcon = rowtotal(con_*)
egen totkap = rowtotal(kap_*)
egen totmed = rowtotal(med_*)

bys year importer_name: egen imp_con = sum(totcon) //Add trade volume by importer
label var imp_con "Total Imported Consumption Goods"
bys year importer_name: egen imp_kap = sum(totkap)
label var imp_kap "Total Imported Capital Goods"
bys year importer_name: egen imp_med = sum(totmed)
label var imp_med "Total Imported Intermediate Goods"

drop totcon totkap totmed
order imp_*,a(exporter_name)
drop con_* kap_* med_* exporter_*
bys year importer_name:keep if _n == 1

gen lnimp_con = ln(imp_con)
gen lnimp_kap = ln(imp_kap)
gen lnimp_med = ln(imp_med)
label var lnimp_con "ln(Total Imported Consumption Goods)"
label var lnimp_kap "ln(Total Imported Capital Goods)"
label var lnimp_med "ln(Total Imported Intermediate Goods)"
sort importer_name year
encode importer_name,gen(importer_namecd)
xtset importer_namecd year
gen grimp_con = (imp_con-l.imp_con)/l.imp_con
gen grimp_kap = (imp_kap-l.imp_kap)/l.imp_kap
gen grimp_med = (imp_med-l.imp_med)/l.imp_med
label var grimp_con "Growth of Total Imported Consumption Goods"
label var grimp_kap "Growth of Total Imported Capital Goods"
label var grimp_med "Growth of Total Imported Intermediate Goods"

save,replace

//Graphs of ln(total imported goods)
twoway (line lnimp_con year if importer_name == "BO") ///
(line lnimp_kap year if importer_name == "BO") ///
(line lnimp_med year if importer_name == "BO"), ///
ylabel(, grid glcolor(gs13) glpattern(dash)) xline(1973 1987, lpattern(dash) ///
lcolor(gray)) xlabel(1960(5)2015) title("Bolivia (BO)") legend(rows(3)) scheme(s1color)
graph export bo.pdf, as(pdf) replace

twoway (line lnimp_con year if importer_name == "EC") ///
(line lnimp_kap year if importer_name == "EC") ///
(line lnimp_med year if importer_name == "EC"), ///
ylabel(, grid glcolor(gs13) glpattern(dash)) xline(1972 1986, lpattern(dash) ///
lcolor(gray)) xlabel(1960(5)2015) title("Ecuador (EC)") legend(rows(3)) scheme(s1color)
graph export ec.pdf, as(pdf) replace

twoway (line lnimp_con year if importer_name == "MX") ///
(line lnimp_kap year if importer_name == "MX") ///
(line lnimp_med year if importer_name == "MX"), ///
ylabel(, grid glcolor(gs13) glpattern(dash)) xline(1978 1988, lpattern(dash) ///
lcolor(gray)) xlabel(1960(5)2015) title("Mexico (MX)") legend(rows(3)) scheme(s1color)
graph export mx.pdf, as(pdf) replace

twoway (line lnimp_con year if importer_name == "VE") ///
(line lnimp_kap year if importer_name == "VE") ///
(line lnimp_med year if importer_name == "VE"), ///
ylabel(, grid glcolor(gs13) glpattern(dash)) xline(1972 1986, lpattern(dash) ///
lcolor(gray)) xlabel(1960(5)2015) title("Venezuela (VE)") legend(rows(3)) scheme(s1color)
graph export ve.pdf, as(pdf) replace

twoway (line lnimp_con year if importer_name == "CL") ///
(line lnimp_kap year if importer_name == "CL") ///
(line lnimp_med year if importer_name == "CL"), ///
ylabel(, grid glcolor(gs13) glpattern(dash)) xline(1965 1977 2000, lpattern(dash) ///
lcolor(gray)) xlabel(1960(5)2015) title("Chile (CL)") legend(rows(3)) scheme(s1color)
graph export cl.pdf, as(pdf) replace

twoway (line lnimp_con year if importer_name == "CO") ///
(line lnimp_kap year if importer_name == "CO") ///
(line lnimp_med year if importer_name == "CO"), ///
ylabel(, grid glcolor(gs13) glpattern(dash)) xline(1975 1988, lpattern(dash) ///
lcolor(gray)) xlabel(1960(5)2015) title("Columbia (CO)") legend(rows(3)) scheme(s1color)
graph export co.pdf, as(pdf) replace

twoway (line lnimp_con year if importer_name == "PE") ///
(line lnimp_kap year if importer_name == "PE") ///
(line lnimp_med year if importer_name == "PE"), ///
ylabel(, grid glcolor(gs13) glpattern(dash)) xline(1975 1986, lpattern(dash) ///
lcolor(gray)) xlabel(1960(5)2015) title("Peru (PE)") legend(rows(3)) scheme(s1color)
graph export pe.pdf, as(pdf) replace

twoway (line lnimp_con year if importer_name == "AU") ///
(line lnimp_kap year if importer_name == "AU") ///
(line lnimp_med year if importer_name == "AU"), ///
ylabel(, grid glcolor(gs13) glpattern(dash)) xline(2000, lpattern(dash) ///
lcolor(gray)) xlabel(1960(5)2015) title("Australia (AU)") legend(rows(3)) scheme(s1color)
graph export au.pdf, as(pdf) replace

twoway (line lnimp_con year if importer_name == "CA") ///
(line lnimp_kap year if importer_name == "CA") ///
(line lnimp_med year if importer_name == "CA"), ///
ylabel(, grid glcolor(gs13) glpattern(dash)) xline(2000, lpattern(dash) ///
lcolor(gray)) xlabel(1960(5)2015) title("Canada (CA)") legend(rows(3)) scheme(s1color)
graph export ca.pdf, as(pdf) replace

//Graphs of growth of total imported goods
twoway (line grimp_con year if importer_name == "BO") ///
(line grimp_kap year if importer_name == "BO") ///
(line grimp_med year if importer_name == "BO"), ///
ylabel(, grid glcolor(gs13) glpattern(dash)) xline(1973 1987, lpattern(dash) ///
lcolor(gray)) xlabel(1960(5)2015) title("Bolivia (BO)") legend(rows(3)) scheme(s1color)
graph export bo.pdf, as(pdf) replace

twoway (line grimp_con year if importer_name == "EC") ///
(line grimp_kap year if importer_name == "EC") ///
(line grimp_med year if importer_name == "EC"), ///
ylabel(, grid glcolor(gs13) glpattern(dash)) xline(1972 1986, lpattern(dash) ///
lcolor(gray)) xlabel(1960(5)2015) title("Ecuador (EC)") legend(rows(3)) scheme(s1color)
graph export ec.pdf, as(pdf) replace

twoway (line grimp_con year if importer_name == "MX") ///
(line grimp_kap year if importer_name == "MX") ///
(line grimp_med year if importer_name == "MX"), ///
ylabel(, grid glcolor(gs13) glpattern(dash)) xline(1978 1988, lpattern(dash) ///
lcolor(gray)) xlabel(1960(5)2015) title("Mexico (MX)") legend(rows(3)) scheme(s1color)
graph export mx.pdf, as(pdf) replace

twoway (line grimp_con year if importer_name == "VE") ///
(line grimp_kap year if importer_name == "VE") ///
(line grimp_med year if importer_name == "VE"), ///
ylabel(, grid glcolor(gs13) glpattern(dash)) xline(1972 1986, lpattern(dash) ///
lcolor(gray)) xlabel(1960(5)2015) title("Venezuela (VE)") legend(rows(3)) scheme(s1color)
graph export ve.pdf, as(pdf) replace

twoway (line grimp_con year if importer_name == "CL") ///
(line grimp_kap year if importer_name == "CL") ///
(line grimp_med year if importer_name == "CL"), ///
ylabel(, grid glcolor(gs13) glpattern(dash)) xline(1965 1977 2000, lpattern(dash) ///
lcolor(gray)) xlabel(1960(5)2015) title("Chile (CL)") legend(rows(3)) scheme(s1color)
graph export cl.pdf, as(pdf) replace

twoway (line grimp_con year if importer_name == "CO") ///
(line grimp_kap year if importer_name == "CO") ///
(line grimp_med year if importer_name == "CO"), ///
ylabel(, grid glcolor(gs13) glpattern(dash)) xline(1975 1988, lpattern(dash) ///
lcolor(gray)) xlabel(1960(5)2015) title("Columbia (CO)") legend(rows(3)) scheme(s1color)
graph export co.pdf, as(pdf) replace

twoway (line grimp_con year if importer_name == "PE") ///
(line grimp_kap year if importer_name == "PE") ///
(line grimp_med year if importer_name == "PE"), ///
ylabel(, grid glcolor(gs13) glpattern(dash)) xline(1975 1986, lpattern(dash) ///
lcolor(gray)) xlabel(1960(5)2015) title("Peru (PE)") legend(rows(3)) scheme(s1color)
graph export pe.pdf, as(pdf) replace

twoway (line grimp_con year if importer_name == "AU") ///
(line grimp_kap year if importer_name == "AU") ///
(line grimp_med year if importer_name == "AU"), ///
ylabel(, grid glcolor(gs13) glpattern(dash)) xline(2000, lpattern(dash) ///
lcolor(gray)) xlabel(1960(5)2015) title("Australia (AU)") legend(rows(3)) scheme(s1color)
graph export au.pdf, as(pdf) replace

twoway (line grimp_con year if importer_name == "CA") ///
(line grimp_kap year if importer_name == "CA") ///
(line grimp_med year if importer_name == "CA"), ///
ylabel(, grid glcolor(gs13) glpattern(dash)) xline(2000, lpattern(dash) ///
lcolor(gray)) xlabel(1960(5)2015) title("Canada (CA)") legend(rows(3)) scheme(s1color)
graph export ca.pdf, as(pdf) replace










