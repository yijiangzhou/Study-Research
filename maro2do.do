//Macro II Industry Data相关

//Import data
import excel "C:\Users\JackZHOU\Desktop\常用文件\Macro II\inddata.xlsx", sheet("Sheet1") firstrow
order newid year,b(cic2)
order va,b(soe)
label variable newid "Firm ID"
label variable year "Year"
label variable cic2 "Two-digit Industry Code"
label variable emp "Employment"
label variable rk "Capital"
label variable va "Value-add"
label variable soe "=1 SOE, =0 Private"
destring newid year cic2 emp rk va soe,replace
describe
save "C:\Users\JackZHOU\Desktop\常用文件\Macro II\inddata.dta"


//查找重复观测值，排列为panel data
egen id=group(newid)
sort id year
duplicates report id year
xtset id year

//截尾，scale (using median value in the industry)
sum va emp rk,detail
winsor2 va emp rk,replace trim cuts(1 99) by(year)
sum va emp rk,detail

bys year cic2: egen va_yimed=median(va)
bys year cic2: egen emp_yimed=median(emp)
bys year cic2: egen rk_yimed=median(rk)
label variable va_yimed "Year-Ind Median va"
label variable emp_yimed "Year-Ind Median emp"
label variable rk_yimed "Year-Ind Median rk"

gen va_sc=va/va_yimed
gen emp_sc=emp/emp_yimed
gen rk_sc=rk/rk_yimed
label variable va_sc "Scaled va"
label variable emp_sc "Scaled emp"
label variable rk_sc "Scaled rk"

//按照year生成aggregate output Y，注意此处使用了scaled va
bys year: egen y=sum(va_sc)
label variable y "Aggregate Output by Year (Scaled)"


//Ex 1

//计算Yi/Ki和Yi/Li，并单独生成取log的版本
gen yk=va_sc/rk_sc
gen yl=va_sc/emp_sc
label variable yk "Yi/Ki"
label variable yl "Yi/Li"
gen lnyk=ln(yk)
gen lnyl=ln(yl)
label variable lnyk "log of yk"
label variable lnyl "log of yl"
sort id year

//YK kernel density：所有年份一张表
kdensity lnyk if year==2001, addplot((kdensity lnyk if year==2002) ///
(kdensity lnyk if year==2003) (kdensity lnyk if year==2004) (kdensity lnyk if year==2005) ///
(kdensity lnyk if year==2006) (kdensity lnyk if year==2007)) ///
ytitle(Kernel Density) xtitle(Log of Y/K) title("") ///
legend(order(1 "2001" 2 "2002" 3 "2003" 4 "2004" 5 "2005" 6 "2006" 7 "2007") ///
cols(4)) scheme(s1color)

//YK kernel density：每年单独
histogram lnyk, bin(50) kdensity xtitle(Log of Y/K) ///
legend(order(2 "Kernel Density Line")) scheme(s1color) by(year)

//YK kernel density：pooled, SOE vs private
kdensity lnyk, recast(area) fcolor(gs13) lcolor(gs13) lpattern(solid) ///
addplot((kdensity lnyk if soe==1, lcolor(red)) (kdensity lnyk if soe==0, lcolor(navy))) ///
ytitle(Kernal Density) xtitle(Log of Y/K) title("") ///
legend(order(1 "All Firms" 2 "SOE" 3 "Private Firms") rows(1)) scheme(s1color)

//YK kernel density: SOE 2001 vs 2007
kdensity lnyk if soe==1 & year==2001, addplot((kdensity lnyk if soe==1 & year==2007)) ///
ytitle(Kernel Density) xtitle(Log of Y/K: SOE) title("") ///
legend(order(1 "2001" 2 "2007") row(1)) scheme(s1color)

//YL kernel density：所有年份一张表
kdensity lnyl if year==2001, addplot((kdensity lnyl if year==2002) ///
(kdensity lnyl if year==2003) (kdensity lnyl if year==2004) (kdensity lnyl if year==2005) ///
(kdensity lnyl if year==2006) (kdensity lnyl if year==2007)) ///
ytitle(Kernel Density) xtitle(Log of Y/L) title("") ///
legend(order(1 "2001" 2 "2002" 3 "2003" 4 "2004" 5 "2005" 6 "2006" 7 "2007") ///
cols(4)) scheme(s1color)

//YL kernel density：每年单独
histogram lnyl, bin(50) kdensity xtitle(Log of Y/L) ///
legend(order(2 "Kernel Density Line")) scheme(s1color) by(year)

//YL kernel density：pooled, SOE vs private
kdensity lnyl, recast(area) fcolor(gs13) lcolor(gs13) lpattern(solid) ///
addplot((kdensity lnyl if soe==1, lcolor(red)) (kdensity lnyl if soe==0, lcolor(navy))) ///
ytitle(Kernal Density) xtitle(Log of Y/L) title("") ///
legend(order(1 "All Firms" 2 "SOE" 3 "Private Firms") rows(1)) scheme(s1color)

//YL kernel density：SOE 2001 vs 2007
kdensity lnyl if soe==1 & year==2001, addplot((kdensity lnyl if soe==1 & year==2007)) ///
ytitle(Kernel Density) xtitle(Log of Y/L: SOE) title("") ///
legend(order(1 "2001" 2 "2007") row(1)) scheme(s1color)

//计算TFP
gen tfp=((va_sc/y)^0.25)*((va_sc/rk_sc)^0.5)*((va_sc/emp_sc)^0.5)
label variable tfp "TFPQ"
bys year cic2: egen tfp_yimean=mean(tfp)
label variable tfp_yimean "Year-Ind Mean TFP"
sort id year
gen lntfp_idsc=ln(tfp/tfp_yimean)
gen tfp_idsc=tfp/tfp_yimean
label variable lntfp_idsc "Log of Industry-Scaled TFP"
label variable tfp_idsc "Industry-Scaled TFP"
winsor2 lntfp_idsc,trim cuts(1 99) s(tr) label //1%和99%截尾
winsor2 tfp_idsc,trim cuts(1 99) s(tr) label //1%和99%截尾
sort id year

//TFP kernel density: 所有年份一张表
kdensity lntfp_idsctr if year==2001, addplot((kdensity lntfp_idsctr if year==2002) ///
(kdensity lntfp_idsctr if year==2003) (kdensity lntfp_idsctr if year==2004) ///
(kdensity lntfp_idsctr if year==2005) (kdensity lntfp_idsctr if year==2006) ///
(kdensity lntfp_idsctr if year==2007)) ytitle(Kernal Density) ///
xtitle(Log of Industry-Adjuested TFP) title("") ///
legend(order(1 "2001" 2 "2002" 3 "2003" 4 "2004" 5 "2005" 6 "2006" 7 "2007") ///
cols(4)) scheme(s1color)
//只看2001和2007两年
kdensity lntfp_idsctr if year==2001, addplot((kdensity lntfp_idsctr if year==2007)) ///
ytitle(Kernal Density) xtitle(Log of Industry-Adjuested TFP) title("") ///
legend(order(1 "2001" 2 "2007") cols(4)) scheme(s1color)

//TFP kernel density: 每年单独
histogram lntfp_idsctr, bin(50) kdensity ytitle(Kernel Density) ///
xtitle(Log of Industry-Adjusted TFP) legend(order(2 "Kernel Density Line")) ///
scheme(s1color) by(year)

//TFP kernel density：pooled, SOE vs private
kdensity lntfp_idsctr, recast(area) fcolor(gs13) lcolor(gs13) ///
addplot((kdensity lntfp_idsctr if soe==1, lcolor(red)) ///
(kdensity lntfp_idsctr if soe==0, lcolor(navy))) ///
ytitle(Kernel Density) xtitle(Log of Industry-Adjusted TFP) title("") ///
legend(order(1 "All Firms" 2 "SOE" 3 "Private Firms") rows(1)) scheme(s1color)

//TFP kernel density：SOE 2001 vs 2007
kdensity lntfp_idsctr if soe==1 & year==2001, ///
addplot((kdensity lntfp_idsctr if soe==1 & year==2007)) ///
ytitle(Kernel Density) xtitle(Log of Industry-Adjusted TFP: SOE) title("") ///
legend(order(1 "2001" 2 "2007") rows(1)) scheme(s1color)


//Ex 2: set r=0.05, w=14000（经验证不影响Ex2和Ex3的结果）

//生成capital wedge和labor wedge
gen capwed=(0.5*0.8*yk)/0.05
gen labwed=(0.5*0.8*yl)/14000
sum capwed labwed,detail
label variable capwed "Capital Wedge"
label variable labwed "Labor Wedge"
gen lncapwed=ln(capwed)
gen lnlabwed=ln(labwed)
label variable lncapwed "Log of Capital Wedge"
label variable lnlabwed "Log of Labor Wedge"
sort id year
winsor2 lncapwed,trim cuts(1 99) s(tr) label //1%和99%截尾
winsor2 lnlabwed,trim cuts(1 99) s(tr) label //1%和99%截尾

//CW kernel density：每年单独
histogram lncapwedtr, bin(30) kdensity ytitle(Kernel Density) ///
xtitle(Log of Capital Wedge) legend(order(1 "Kernel Density Line")) ///
scheme(s1color) by(year)

//CW kernel density：2001 vs 2007
kdensity lncapwedtr if year==2001 & soe==0, lcolor(ltblue) ///
addplot((kdensity lncapwedtr if year==2007 & soe==0, lcolor(navy)) ///
(kdensity lncapwedtr if year==2001 & soe==1, lcolor(sand)) ///
(kdensity lncapwedtr if year==2007 & soe==1, lcolor(red))) ///
ytitle(Kernel Density) xtitle(Log of Capital Wedge) title("") ///
legend(order(1 "Private 2001" 2 "Private 2007" 3 "SOE 2001" 4 "SOE 2007") ///
cols(2)) scheme(s1color)

//CW kernel density: pooled, SOE vs Private
kdensity lncapwedtr, recast(area) fcolor(gs13) lcolor(gs13) ///
addplot((kdensity lncapwedtr if soe==1, lcolor(red)) ///
(kdensity lncapwedtr if soe==0, lcolor(navy))) ///
ytitle(Kernel Density) xtitle(Log of Capital Wedge) title("") ///
legend(order(1 "All Firms" 2 "SOE" 3 "Private Firms") rows(1)) scheme(s1color)

//LW kernel density：每年单独
histogram lnlabwedtr, bin(30) kdensity ytitle(Kernel Density) ///
xtitle(Log of Labor Wedge) legend(order(1 "Kernel Density Line")) ///
scheme(s1color) by(year)

//LW kernel density：2001 vs 2007
kdensity lnlabwedtr if year==2001 & soe==0, lcolor(ltblue) ///
addplot((kdensity lnlabwedtr if year==2007 & soe==0, lcolor(navy)) ///
(kdensity lnlabwedtr if year==2001 & soe==1, lcolor(sand)) ///
(kdensity lnlabwedtr if year==2007 & soe==1, lcolor(red))) ///
ytitle(Kernel Density) xtitle(Log of Labor Wedge) title("") ///
legend(order(1 "Private 2001" 2 "Private 2007" 3 "SOE 2001" 4 "SOE 2007") ///
cols(2)) scheme(s1color)

//LW kernel density: pooled, SOE vs Private
kdensity lnlabwedtr, recast(area) fcolor(gs13) lcolor(gs13) ///
addplot((kdensity lnlabwedtr if soe==1, lcolor(red)) ///
(kdensity lnlabwedtr if soe==0, lcolor(navy))) ///
ytitle(Kernel Density) xtitle(Log of Labor Wedge) title("") ///
legend(order(1 "All Firms" 2 "SOE" 3 "Private Firms") rows(1)) scheme(s1color)


//Ex 3

//计算efficiency losses
bys year: egen temp1=sum(tfp^4)
bys year: egen temp2=sum((tfp/(capwed^0.5*labwed^0.5))^4)
bys year: egen temp3=sum((1/capwed)*(tfp/(capwed^0.5*labwed^0.5))^4)
bys year: egen temp4=sum((1/labwed)*(tfp/(capwed^0.5*labwed^0.5))^4)

bys year: gen eloss=0.25*ln(temp1)-1.25*ln(temp2)+0.5*ln(temp3)+0.5*ln(temp4)
label var eloss "Efficiency Loss"
drop temp1 temp2 temp3 temp4
sort id year

//另一种计算方法
bys year: egen aggk=sum(rk_sc)
bys year: egen aggl=sum(emp_sc)
bys year: egen aggtfp=sum(tfp^4)
bys year: gen ystar=(aggtfp^0.25)*(aggk^0.5)*(aggl^0.5)

bys year: gen logdify=ln(ystar)-ln(y)
label var logdify "(Alternative Way) Efficiency Loss"
drop aggk aggl aggtfp ystar
sort id year


//Ex 4

//计算measurement error
gen diflnva=ln(va_sc)-ln(l.va_sc)
gen diflninputs=ln((rk_sc^0.5)*(emp_sc^0.5))-ln((l.rk_sc^0.5)*(l.emp_sc^0.5))
label variable diflnva "diff log va_sc"
label variable diflninputs "diff log inputs"

gen var_dlv=r(Var_1)
gen var_dli=r(Var_2)
gen cov_vainputs=r(cov_12)
sum var_dlv var_dli cov_vainputs
gen vy_sqr=0.5*(var_dlv-cov_vainputs)
gen vi_sqr=0.5*(var_dli-cov_vainputs)
label variable var_dlv "variance of diflnva"
label variable var_dli "variance of diflninputs"
label variable cov_vainputs "covariance"
label variable vy_sqr "vy^2"
label variable vi_sqr "vi^2"

gen lnva_sc=ln(va_sc)
sum lnva_sc,detail
display vy_sqr/r(Var)

gen vtfp_sqr=(1/16)*vy_sqr+vi_sqr
label variable vtfp_sqr "vtfp^2"
gen lntfp=ln(tfp)
sum lntfp,detail
display vtfp_sqr/r(Var)











