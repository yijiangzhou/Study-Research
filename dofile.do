//Midterm Exercise for ECON5170_Stata Part
//Yijiang Zhou, M.Phil. Economics, ID:1155133829

use oecddata.dta,clear

//a.Mean and sd. of GDP and unemployment rate

sort ctry year
xtset ctry year
gen gdpper=gdp/population
bys country:egen mgdpper=mean(gdpper) if year>2004
bys country:egen munemploy=mean(unemploy) if year>2004
bys country:egen sdgdpper=sd(gdpper) if year>2004
bys country:egen sdunemploy=sd(unemploy) if year>2004

label var gdpper "GDP per capita"
label var mgdpper "Average GDP per capita 2005-2015"
label var munemploy "Average unemployment rate 2005-2015"
label var sdgdpper "sd of GDP per capita 2005-2015"
label var sdunemploy "sd of unemployment rate 2005-2015"

save,replace

statsby mean_GDPpercapita=r(mean) sd_GDPpercapita=r(sd) if year>2004, ///
by(country) saving(sumgdpper):sum gdpper
statsby mean_Unemployment=r(mean) sd_Unemployment=r(sd) if year>2004, ///
by(country) saving(sumunemploy):sum unemploy

preserve
use sumgdpper,clear
merge 1:1 country using sumunemploy
drop _merge
save summary.dta
restore


//b.Unemployment in high and low income countries

egen medmgdpper=median(mgdpper)
gen highincome=1 if mgdpper>=medmgdpper & mgdpper!=.
recode highincome (.=0) if mgdpper!=.

label var medmgdpper "Median of mgdpper"
label var highincome "=1 high, =0 low"
ttest munemploy,by(highincome) //Average unemployment rate is
//statistically different between high income and low income countries.


//c. Annual GDP growth for high and low income countries

sort ctry year
gen grgdp=(gdp-l.gdp)/l.gdp
bys year highincome:egen mgrgdp=mean(grgdp)

label var grgdp "GDP Growth"
label var mgrgdp "Average GDP growth by year and income group"

save,replace
preserve
statsby mean=r(mean) lower=r(lb) upper=r(ub),by(highincome year):ci grgdp

twoway (connected mean year if highincome==1,lcolor(navy) mcolor(navy)) ///
(line upper year if highincome==1, lcolor(ltblue) lpattern(dash)) ///
(line lower year if highincome==1, lcolor(ltblue) lpattern(dash)) ///
(connected mean year if highincome==0, mcolor(green) lcolor(green)) ///
(line upper year if highincome==0, lcolor(midgreen) lpattern(dash)) ///
(line lower year if highincome==0, lcolor(midgreen) lpattern(dash)) ///
if year!=2004, ytitle(Average GDP Growth) xtitle(Year) xlabel(2005(1)2015) ///
legend(on order(1 "High-income Countries" 2 "95% CI for High-income" ///
4 "Low-income Countries" 5 "95% CI for Low-income") rows(2)) ///
scheme(s1color) yline(0, lpattern(dash) lcolor(gs12))

graph export gdp_growth.pdf,as(pdf) replace
restore


//d.Fixed effect regressions

xtreg grgdp fdi unemploy i.year if year<2015,fe r cluster(country)
predict grgdp_2

ssc install modeldiag
ovfplot,ytitle("GDP Growth") xtitle(Linear Prediction) ///
scheme(s1color) msize(small) mcolor(blue)

graph export predicted_growth.pdf,as(pdf) replace


//e.Fixed effect regressions using reghdfe

ssc install reghdfe
ssc install ftools

reghdfe grgdp fdi unemploy if year<2015,absorb(country year) ///
vce(cluster country)
est store t1

esttab t1 using result.csv,se star(* 0.1 ** 0.05 *** 0.01) ///
scal(r2_within N_hdfe clustvar) label title("FE Regression") lines replace


