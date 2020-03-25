//2020年2月新表格汇总程序


//匹配部长来源市-非部长来源市 0.05卡尺
use "C:\Users\JackZHOU\Desktop\科研实践\政府支出的乘数与挤出效应\每周报告\2020.01.20\98-07不删商务.dta", clear
set seed 10101
gen ranorder = runiform()
sort ranorder
gen revenue_real=revenue/CPI
gen gdpper_real=gdpper_nom/CPI
psmatch2 minister revenue_real gdpper_real urbanrate population land, out(trans_real) logit ties ate neighbor(1) common caliper(.05)
pstest revenue_real gdpper_real urbanrate population land, both graph
drop if _support!=1


//匹配部长来源市-非部长来源市 0.01卡尺
use "C:\Users\JackZHOU\Desktop\科研实践\政府支出的乘数与挤出效应\每周报告\2020.01.20\98-07不删商务.dta", clear
drop if city=="绥化"
set seed 10101
gen ranorder = runiform()
sort ranorder
gen revenue_real=revenue/CPI
gen gdpper_real=gdpper_nom/CPI
psmatch2 minister revenue_real gdpper_real urbanrate population land, out(trans_real) logit ties ate neighbor(1) common
sum _pscore
dis 0.25*r(sd)
psmatch2 minister revenue_real gdpper_real urbanrate population land, out(trans_real) logit ties ate neighbor(1) common caliper(.01)
pstest revenue_real gdpper_real urbanrate population land, both graph
tab _support
drop if _support!=1


//Table 2 Summary Statistics after PSM 1998-2002
use "C:\Users\JackZHOU\Desktop\科研实践\政府支出的乘数与挤出效应\每周报告\2020.01.20\98-07不删商务_真实值match.dta", clear
cd C:\Users\JackZHOU\Desktop\科研实践\政府支出的乘数与挤出效应\每周报告\2020.01.20\！2020年2月新做所有表格
merge 1:1 adm_code year using tax
drop if _merge==2
drop _merge
count
sort cty year
gen gdp_real=gdp_nom/CPI
gen tottaxrate=(tottax/CPI)/(gdp_real)
gen reratio=revenue_real/exp_real
gen gr_gdpr=(gdp_real-l.gdp_real)/l.gdp_real
gen gr_exper=(exp_real-l.exp_real)/l.exp_real
keep if year<2003
keep adm_code city year minister trans_real population land gdpper_real urbanrate calcitrate vatrate tottaxrate reratio gr_gdpr gr_exper

bys minister:outreg2 using sumlog.tex,replace sum(log) eqkeep(mean sd N)


//Table 3 Ministerial Effects on Earmark Transfer
cd C:\Users\JackZHOU\Desktop\科研实践\政府支出的乘数与挤出效应\每周报告\2020.01.20\！2020年2月新做所有表格
use "C:\Users\JackZHOU\Desktop\科研实践\政府支出的乘数与挤出效应\每周报告\2020.01.20\98-07不删商务_真实值match.dta", clear
sort cty year
xtset cty year
xtreg trans_real ivf revenue_real gdpper_real urbanrate population land i.year if city!="绥化",fe r cluster(city)
est store t31
xtreg trans_real ivf revenue_real gdpper_real urbanrate population land i.year,fe r cluster(city)
est store t32
gen htwest=1 if province=="新疆" | province=="西藏" | province=="内蒙古" | province=="青海" | province=="甘肃" | province=="宁夏"
recode htwest (.=0)
tab province if htwest==1
xtreg trans_real ivf revenue_real gdpper_real urbanrate population land i.year if city!="绥化" & htwest==0,fe r cluster(city)
est store t33

//导出四列t33用于占位
esttab t31 t32 t33 t33 t33 t33 using table3.tex,se star(* 0.1 ** 0.05 *** 0.01) drop(1998.year 1999.year 2000.year 2001.year 2002.year 2003.year 2004.year 2005.year 2006.year 2007.year) scal(r2_w twowayfe clustvar)

use "C:\Users\JackZHOU\Desktop\科研实践\政府支出的乘数与挤出效应\每周报告\2020.01.20\98-07不删商务_真实值match0.01卡尺.dta", clear
xtreg trans_real ivf revenue_real gdpper_real urbanrate population land i.year if city!="绥化",fe r cluster(city)
est store t34

esttab t34 using table3-2.tex,se star(* 0.1 ** 0.05 *** 0.01) drop(1998.year 1999.year 2000.year 2001.year 2002.year 2003.year 2004.year 2005.year 2006.year 2007.year) scal(r2_w twowayfe clustvar)

use "C:\Users\JackZHOU\Desktop\科研实践\政府支出的乘数与挤出效应\每周报告\2020.01.20\98-07不删商务.dta", clear
gen revenue_real=revenue/CPI
gen gdpper_real=gdpper_nom/CPI
xtreg trans_real ivf revenue_real gdpper_real urbanrate population land i.year if city!="绥化",fe r cluster(city)
est store t35
drop if city== "绥化"
keep if province=="吉林" | province=="山东" | province=="山西" | province=="江苏" | province=="河南" | province=="浙江" | province=="辽宁"
xtreg trans_real ivf revenue_real gdpper_real urbanrate population land i.year if city!="绥化",fe r cluster(city)
est store t36

esttab t35 t36 using table3-3.tex,se star(* 0.1 ** 0.05 *** 0.01) drop(1998.year 1999.year 2000.year 2001.year 2002.year 2003.year 2004.year 2005.year 2006.year 2007.year) scal(r2_w twowayfe clustvar)


//Table 4 Ministerial Effects on Earmark Transfer: Dynamic Effects
use "C:\Users\JackZHOU\Desktop\科研实践\政府支出的乘数与挤出效应\每周报告\2020.01.20\98-07不删商务_真实值match.dta", clear
tab year,gen(d)
gen ivf98=minister*d1
gen ivf99=minister*d2
gen ivf00=minister*d3
gen ivf01=minister*d4
gen ivf02=minister*d5
gen ivf03=minister*d6
gen ivf04=minister*d7
gen ivf05=minister*d8
gen ivf06=minister*d9
gen ivf07=minister*d10
gen ivf02drop=0
sort cty year

xtreg trans_real ivf98 ivf99 ivf00 ivf01 ivf03 ivf04 ivf05 ivf06 ivf07 revenue_real gdpper_real urbanrate population land i.year if city!="绥化",fe r cluster(city)
est store t41
xtreg trans_real ivf98 ivf99 ivf00 ivf01 ivf03 ivf04 ivf05 ivf06 ivf07 revenue_real gdpper_real urbanrate population land i.year if city!="绥化" & htwest==0,fe r cluster(city)
est store t42

esttab t41 t42 using table4.tex,se star(* 0.1 ** 0.05 *** 0.01) drop(1998.year 1999.year 2000.year 2001.year 2002.year 2003.year 2004.year 2005.year 2006.year 2007.year revenue_real gdpper_real urbanrate population land) scal(r2_w twowayfe citycontrol clustvar)


//Table 5 Effective Tax Rate
use "C:\Users\JackZHOU\Desktop\科研实践\政府支出的乘数与挤出效应\每周报告\2020.01.20\98-07不删商务_真实值match.dta", clear
cd C:\Users\JackZHOU\Desktop\科研实践\政府支出的乘数与挤出效应\每周报告\2020.01.20\！2020年2月新做所有表格
merge 1:1 adm_code year using tax
drop if _merge==2
drop _merge
count
sort cty year

gen ngdpper_real=gdpper_real/10000
gen npopul=population/1000
gen nland=land/10000
gen gdp_real=gdp_nom/CPI
xtreg vatrate ivf ngdpper_real npopul nland urbanrate i.year if city!="绥化",fe r cluster(city)
est store t51
xtreg calcitrate ivf ngdpper_real npopul nland urbanrate i.year if city!="绥化",fe r cluster(city)
est store t52

esttab t51 t52 using table5.tex,se star(* 0.1 ** 0.05 *** 0.01) drop(1998.year 1999.year 2000.year 2001.year 2002.year 2003.year 2004.year 2005.year 2006.year 2007.year) scal(r2_w twowayfe clustvar)


//Table 6A The Multiplier Effect
use "C:\Users\JackZHOU\Desktop\科研实践\政府支出的乘数与挤出效应\每周报告\2020.01.20\98-07不删商务_真实值match.dta", clear
gen htwest=1 if province=="新疆" | province=="西藏" | province=="内蒙古" | province=="青海" | province=="甘肃" | province=="宁夏"
recode htwest (.=0)
sort cty year
gen gdp_real=gdp_nom/CPI
tab year,gen(year)
gen npopul=population/1000
gen nland=land/10000
gen d02=1 if year>=2002
recode d02 (.=0)
tab d02

gen neoivf=neominister*d03
gen neoivp02=neominister*d02
gen gr_gdpr=(gdp_real-l.gdp_real)/l.gdp_real
gen gr_exprg=(exp_real-l.exp_real)/l.gdp_real
gen termiv=neominister*term^2
gen termivp=neominister*pterm^2
gen ntrans_real=trans_real/10000

xtivreg2 gr_gdpr urbanrate npopul nland (gr_exprg=neoivf termiv l.ntrans_real) year3-year10 if city!="绥化",fe r cluster(city)
est store t61
xtivreg2 gr_gdpr urbanrate npopul nland (gr_exprg=neoivf termiv l.ntrans_real) year3-year10 if city!="绥化" & htwest==0,fe r cluster(city)
est store t62
xtivreg2 gr_gdpr (gr_exprg=neoivf termiv l.ntrans_real) year3-year10 if city!="绥化",fe r cluster(city)
est store t63
xtivreg2 gr_gdpr urbanrate npopul nland (gr_exprg=neoivf termiv l2.ntrans_real) year4-year10 if city!="绥化",fe r cluster(city)
est store t64

//导出三列t64占位
esttab t61 t62 t63 t64 t64 t64 using table6.tex,se star(* 0.1 ** 0.05 *** 0.01) keep(gr_exprg) scal(exexog twowayfe citycontrol idp widstat jp clustvar)

use "C:\Users\JackZHOU\Desktop\科研实践\政府支出的乘数与挤出效应\每周报告\2020.01.20\98-07不删商务_真实值match0.01卡尺.dta", clear
gen htwest=1 if province=="新疆" | province=="西藏" | province=="内蒙古" | province=="青海" | province=="甘肃" | province=="宁夏"
recode htwest (.=0)
sort cty year
gen gdp_real=gdp_nom/CPI
tab year,gen(year)
gen npopul=population/1000
gen nland=land/10000

gen neoivf=neominister*d03
gen gr_gdpr=(gdp_real-l.gdp_real)/l.gdp_real
gen gr_exprg=(exp_real-l.exp_real)/l.gdp_real
gen termiv=neominister*term^2
gen ntrans_real=trans_real/10000

xtivreg2 gr_gdpr urbanrate npopul nland (gr_exprg=neoivf termiv l.ntrans_real) year3-year10 if city!="绥化",fe r cluster(city)
est store t65

esttab t65 using table6-2.tex,se star(* 0.1 ** 0.05 *** 0.01) keep(gr_exprg) scal(exexog twowayfe citycontrol idp widstat jp clustvar)

use "C:\Users\JackZHOU\Desktop\科研实践\政府支出的乘数与挤出效应\每周报告\2020.01.20\98-07不删商务.dta", clear
sort cty year
gen gdp_real=gdp_nom/CPI
tab year,gen(year)
gen npopul=population/1000
gen nland=land/10000

gen neoivf=neominister*d03
gen gr_gdpr=(gdp_real-l.gdp_real)/l.gdp_real
gen gr_exprg=(exp_real-l.exp_real)/l.gdp_real
gen termiv=neominister*term^2
gen ntrans_real=trans_real/10000

xtivreg2 gr_gdpr urbanrate npopul nland (gr_exprg=neoivf termiv l.ntrans_real) year3-year10 if city!="绥化",fe r cluster(city)
est store t66

esttab t66 using table6-3.tex,se star(* 0.1 ** 0.05 *** 0.01) keep(gr_exprg) scal(exexog twowayfe citycontrol idp widstat jp clustvar)


//Table 6B The Multiplier Effect: First-Stage Results
use "C:\Users\JackZHOU\Desktop\科研实践\政府支出的乘数与挤出效应\每周报告\2020.01.20\98-07不删商务_真实值match.dta", clear
gen htwest=1 if province=="新疆" | province=="西藏" | province=="内蒙古" | province=="青海" | province=="甘肃" | province=="宁夏"
recode htwest (.=0)
sort cty year
gen gdp_real=gdp_nom/CPI
tab year,gen(year)
gen npopul=population/1000
gen nland=land/10000
gen d02=1 if year>=2002
recode d02 (.=0)
tab d02

gen neoivf=neominister*d03
gen neoivp02=neominister*d02
gen gr_gdpr=(gdp_real-l.gdp_real)/l.gdp_real
gen gr_exprg=(exp_real-l.exp_real)/l.gdp_real
gen termiv=neominister*term^2
gen termivp=neominister*pterm^2
gen ntrans_real=trans_real/10000

xtivreg2 gr_gdpr urbanrate npopul nland (gr_exprg=neoivf termiv l.ntrans_real) year3-year10 if city!="绥化",fe r cluster(city) savefirst savefp(fs1)
est replay fs1gr_exprg
est restore fs1gr_exprg
xtivreg2 gr_gdpr urbanrate npopul nland (gr_exprg=neoivf termiv l.ntrans_real) year3-year10 if city!="绥化" & htwest==0,fe r cluster(city) savefirst savefp(fs2)
est replay fs2gr_exprg
est restore fs2gr_exprg
xtivreg2 gr_gdpr (gr_exprg=neoivf termiv l.ntrans_real) year3-year10 if city!="绥化",fe r cluster(city) savefirst savefp(fs3)
est replay fs3gr_exprg
est restore fs3gr_exprg
xtivreg2 gr_gdpr urbanrate npopul nland (gr_exprg=neoivf termiv l2.ntrans_real) year4-year10 if city!="绥化",fe r cluster(city) savefirst savefp(fs4)
est replay fs4gr_exprg
est restore fs4gr_exprg

//导出三列fs4gr_exprg用于占位
esttab fs1gr_exprg fs2gr_exprg fs3gr_exprg fs4gr_exprg fs4gr_exprg fs4gr_exprg using table6B.tex,se star(* 0.1 ** 0.05 *** 0.01) drop(urbanrate npopul nland year3 year4 year5 year6 year7 year8 year9 year10)

use "C:\Users\JackZHOU\Desktop\科研实践\政府支出的乘数与挤出效应\每周报告\2020.01.20\98-07不删商务_真实值match0.01卡尺.dta", clear
gen htwest=1 if province=="新疆" | province=="西藏" | province=="内蒙古" | province=="青海" | province=="甘肃" | province=="宁夏"
recode htwest (.=0)
sort cty year
gen gdp_real=gdp_nom/CPI
tab year,gen(year)
gen npopul=population/1000
gen nland=land/10000

gen neoivf=neominister*d03
gen gr_gdpr=(gdp_real-l.gdp_real)/l.gdp_real
gen gr_exprg=(exp_real-l.exp_real)/l.gdp_real
gen termiv=neominister*term^2
gen ntrans_real=trans_real/10000

xtivreg2 gr_gdpr urbanrate npopul nland (gr_exprg=neoivf termiv l.ntrans_real) year3-year10 if city!="绥化",fe r cluster(city) savefirst savefp(fs5)
est replay fs5gr_exprg
est restore fs5gr_exprg

esttab fs5gr_exprg using table6B-2.tex,se star(* 0.1 ** 0.05 *** 0.01) drop(urbanrate npopul nland year3 year4 year5 year6 year7 year8 year9 year10)

use "C:\Users\JackZHOU\Desktop\科研实践\政府支出的乘数与挤出效应\每周报告\2020.01.20\98-07不删商务.dta", clear
sort cty year
gen gdp_real=gdp_nom/CPI
tab year,gen(year)
gen npopul=population/1000
gen nland=land/10000

gen neoivf=neominister*d03
gen gr_gdpr=(gdp_real-l.gdp_real)/l.gdp_real
gen gr_exprg=(exp_real-l.exp_real)/l.gdp_real
gen termiv=neominister*term^2
gen ntrans_real=trans_real/10000

xtivreg2 gr_gdpr urbanrate npopul nland (gr_exprg=neoivf termiv l.ntrans_real) year3-year10 if city!="绥化",fe r cluster(city) savefirst savefp(fs6)
est replay fs6gr_exprg
est restore fs6gr_exprg

esttab fs6gr_exprg using table6B-3.tex,se star(* 0.1 ** 0.05 *** 0.01) drop(urbanrate npopul nland year3 year4 year5 year6 year7 year8 year9 year10)


//Table 7 Anticipation
use "C:\Users\JackZHOU\Desktop\科研实践\政府支出的乘数与挤出效应\每周报告\2020.01.20\98-07不删商务_真实值match.dta", clear
gen htwest=1 if province=="新疆" | province=="西藏" | province=="内蒙古" | province=="青海" | province=="甘肃" | province=="宁夏"
recode htwest (.=0)
sort cty year
gen gdp_real=gdp_nom/CPI
tab year,gen(year)
gen npopul=population/1000
gen nland=land/10000
gen d02=1 if year>=2002
recode d02 (.=0)
tab d02

gen neoivf=neominister*d03
gen neoivp02=neominister*d02
gen gr_gdpr=(gdp_real-l.gdp_real)/l.gdp_real
gen gr_exprg=(exp_real-l.exp_real)/l.gdp_real
gen termiv=neominister*term^2
gen termivp=neominister*pterm^2
gen ntrans_real=trans_real/10000
drop if year>=2003

gen d00=1 if year>=2000
recode d00 (.=0)
tab d00
tab pterm_00
recode pterm_00 (.=0)
gen neoivp00=neominister*d00
gen termivp00=neominister*pterm_00^2
xtivreg2 gr_gdpr urbanrate npopul nland (gr_exprg=neoivp00 termivp00 l.ntrans_real) year3-year5 if city!="绥化",fe r cluster(city)
est store t71
xtivreg2 gr_gdpr urbanrate npopul nland (gr_exprg=neoivp02 l.ntrans_real) year3-year5 if city!="绥化",fe r cluster(city)
est store t72

esttab t71 t72 using table7.tex,se star(* 0.1 ** 0.05 *** 0.01) keep(gr_exprg) scal(exexog twowayfe citycontrol idp widstat jp clustvar)

xtivreg2 gr_gdpr urbanrate npopul nland (gr_exprg=neoivp00 termivp00 l.ntrans_real) year3-year5 if city!="绥化",fe r cluster(city) savefirst savefp(fs1)
est replay fs1gr_exprg
est restore fs1gr_exprg
xtivreg2 gr_gdpr urbanrate npopul nland (gr_exprg=neoivp02 l.ntrans_real) year3-year5 if city!="绥化",fe r cluster(city) savefirst savefp(fs2)
est replay fs2gr_exprg
est restore fs2gr_exprg

esttab fs1gr_exprg fs2gr_exprg using table7B.tex,se star(* 0.1 ** 0.05 *** 0.01) drop(urbanrate npopul nland year3 year4 year5)


//Table 8 Anticipation: Difference-in-Difference
use "C:\Users\JackZHOU\Desktop\科研实践\政府支出的乘数与挤出效应\每周报告\2020.01.20\98-07不删商务_真实值match.dta", clear
sort cty year
gen gdp_real=gdp_nom/CPI
gen lggdp_real=ln(gdp_real)
gen gr_gdpr=(gdp_real-l.gdp_real)/l.gdp_real
gen npopul=population/1000
gen nland=land/10000
gen nrevenue_r=revenue_real/10000

drop if year>=2003
gen d00=1 if year>=2000
recode d00 (.=0)
tab d00
gen ivp00=minister*d00
xtreg lggdp_real ivp00 nrevenue_r urbanrate npopul nland i.year if city!="绥化",fe r cluster(city)
est store t81
xtreg gr_gdpr ivp00 nrevenue_r urbanrate npopul nland i.year if city!="绥化",fe r cluster(city)
est store t82

gen d02=1 if year>=2002
recode d02(.=0)
tab d02
gen ivp02=minister*d02
xtreg lggdp_real ivp02 nrevenue_r urbanrate npopul nland i.year if city!="绥化",fe r cluster(city)
est store t83
xtreg gr_gdpr ivp02 nrevenue_r urbanrate npopul nland i.year if city!="绥化",fe r cluster(city)
est store t84

esttab t81 t82 t83 t84 using table8.tex,se star(* 0.1 ** 0.05 *** 0.01) keep(ivp00 ivp02 nrevenue_r urbanrate npopul nland _cons) scal(r2_w twowayfe clustvar)


//Table 9 Multiplier Comparison
//这个表由老师制作


//Table 10 Spillover Effects: Transfer
cd C:\Users\JackZHOU\Desktop\科研实践\政府支出的乘数与挤出效应\每周报告\2020.01.20\！2020年2月新做所有表格
use "C:\Users\JackZHOU\Desktop\科研实践\政府支出的乘数与挤出效应\每周报告\2020.01.20\98-07一阶邻市真实值match（2020新）.dta", clear
gen ivn=neonearcity*d03
xtreg trans_real ivn revenue_real gdpper_real urbanrate population land i.year,fe r cluster(city)
est store t101
xtreg trans_real ivn revenue_real gdpper_real urbanrate population land i.year if neosameprovince!=0,fe r cluster(city)
est store t102
xtreg trans_real ivn revenue_real gdpper_real urbanrate population land i.year if neosameprovince!=1,fe r cluster(city)
est store t103

//导出三列t103占位
esttab t101 t102 t103 t103 t103 using table10.tex,se star(* 0.1 ** 0.05 *** 0.01) drop(1998.year 1999.year 2000.year 2001.year 2002.year 2003.year 2004.year 2005.year 2006.year 2007.year) scal(r2_w twowayfe clustvar)

use "C:\Users\JackZHOU\Desktop\科研实践\政府支出的乘数与挤出效应\每周报告\2020.01.20\98-07二阶邻市真实值match（2020新）.dta", clear
gen ivn_2=neonearcity_2*d03
xtreg trans_real ivn_2 revenue_real gdpper_real urbanrate population land i.year if neosameprovince_2!=0,fe r cluster(city)
est store t104

esttab t104 using table10-2.tex,se star(* 0.1 ** 0.05 *** 0.01) drop(1998.year 1999.year 2000.year 2001.year 2002.year 2003.year 2004.year 2005.year 2006.year 2007.year) scal(r2_w twowayfe clustvar)

sort cty year
xtset cty year
xtreg trans_real ivf revenue_real gdpper_real urbanrate population land i.year if city!="绥化",fe r cluster(city)
est store t105

esttab t105 using table10-3.tex,se star(* 0.1 ** 0.05 *** 0.01) drop(1998.year 1999.year 2000.year 2001.year 2002.year 2003.year 2004.year 2005.year 2006.year 2007.year) scal(r2_w twowayfe clustvar)


//Table 11 Spillover Effects: Spending and Multiplier
use "C:\Users\JackZHOU\Desktop\科研实践\政府支出的乘数与挤出效应\每周报告\2020.01.20\98-07single一阶邻市真实值match（2020新）.dta", clear
gen gdp_real=gdp_nom/CPI
tab year,gen(year)
gen npopul=population/1000
gen nland=land/10000
gen gr_gdpr=(gdp_real-l.gdp_real)/l.gdp_real
gen gr_exprg=(exp_real-l.exp_real)/l.gdp_real
gen hogr_exprg=(hoexp_real-l.hoexp_real)/l.gdp_real
gen ivn=neonearcity*d03
gen hotermiv=neonearcity*hoterm^2
xtivreg2 gr_gdpr urbanrate npopul nland hogr_exprg (gr_exprg=ivn hotermiv l.trans_real) year3-year10,fe r cluster(city)
est store t111
xtivreg2 gr_gdpr urbanrate npopul nland hogr_exprg (gr_exprg=ivn hotermiv l.trans_real) year3-year10 if sameprovince!=0,fe r cluster(city)
est store t112

esttab t111 t112 using table11.tex,se star(* 0.1 ** 0.05 *** 0.01) keep(gr_exprg hogr_exprg) scal(exexog twowayfe citycontrol idp widstat jp clustvar)


//Figure 1: Parallel Trend
use "C:\Users\JackZHOU\Desktop\科研实践\政府支出的乘数与挤出效应\每周报告\2019.07.26\98-07不删商务_真实值match.dta", clear
tab year,gen(d)
gen ivf98=minister*d1
gen ivf99=minister*d2
gen ivf00=minister*d3
gen ivf01=minister*d4
gen ivf02=minister*d5
gen ivf03=minister*d6
gen ivf04=minister*d7
gen ivf05=minister*d8
gen ivf06=minister*d9
gen ivf07=minister*d10
gen ivf02drop=0

xtreg trans_real ivf98 ivf99 ivf00 ivf01 ivf03 ivf04 ivf05 ivf06 ivf07 revenue_real gdpper_real urbanrate population land i.year if city!="绥化",fe r cluster(city)

coefplot,keep(ivf98 ivf99 ivf00 ivf01 ivf03 ivf04 ivf05 ivf06 ivf07) coeflabels(ivf98=MD98 ivf99=MD99 ivf00=MD00 ivf01=MD01 ivf03=MD03 ivf04=MD04 ivf05=MD05 ivf06=MD06 ivf07=MD07) vertical yline(0) levels(90) ytitle("Estimated Coefficient") xtitle("Variable") addplot(line @b @at) ciopts(recast(rcap)) xline(5, lwidth(medium) lpattern(dash) lcolor(gray)) scheme(s1mono) ylabel(, grid glpattern(dash))


//Appendix Table 1
use "C:\Users\JackZHOU\Desktop\科研实践\政府支出的乘数与挤出效应\每周报告\2019.07.26\98-07不删商务_真实值match.dta", clear
tab year,gen(d)
gen ivf98=minister*d1
gen ivf99=minister*d2
gen ivf00=minister*d3
gen ivf01=minister*d4
gen ivf02=minister*d5
gen ivf03=minister*d6
gen ivf04=minister*d7
gen ivf05=minister*d8
gen ivf06=minister*d9
gen ivf07=minister*d10
gen ivf02drop=0
gen lnexp_real=ln(exp_real)

xtreg lnexp_real ivf98 ivf99 ivf00 ivf01 ivf03 ivf04 ivf05 ivf06 ivf07 revenue_real gdpper_real urbanrate population land i.year if city!="绥化",fe r cluster(city)
est store ta11
gen htwest=1 if province=="新疆" | province=="西藏" | province=="内蒙古" | province=="青海" | province=="甘肃" | province=="宁夏"
recode htwest (.=0)
xtreg lnexp_real ivf98 ivf99 ivf00 ivf01 ivf03 ivf04 ivf05 ivf06 ivf07 revenue_real gdpper_real urbanrate population land i.year if city!="绥化" & htwest==0,fe r cluster(city)
est store ta12

esttab ta11 ta12 using aptable1.tex,se star(* 0.1 ** 0.05 *** 0.01) drop(1998.year 1999.year 2000.year 2001.year 2002.year 2003.year 2004.year 2005.year 2006.year 2007.year revenue_real gdpper_real urbanrate population land) scal(r2_w twowayfe citycontrol clustvar)

coefplot,keep(ivf98 ivf99 ivf00 ivf01 ivf03 ivf04 ivf05 ivf06 ivf07) coeflabels(ivf98=MD98 ivf99=MD99 ivf00=MD00 ivf01=MD01 ivf03=MD03 ivf04=MD04 ivf05=MD05 ivf06=MD06 ivf07=MD07) vertical yline(0) levels(90) ytitle("Estimated Coefficient") xtitle("Variable") addplot(line @b @at) ciopts(recast(rcap)) xline(5, lwidth(medium) lpattern(dash) lcolor(gray)) scheme(s1mono) ylabel(, grid glpattern(dash))


//Appendix Table 2
use "C:\Users\JackZHOU\Desktop\科研实践\政府支出的乘数与挤出效应\每周报告\2019.07.26\98-07不删商务_真实值match.dta", clear
gen lnexp_real=ln(exp_real)
gen ngdpper_real=gdpper_real/10000
gen nrevenue_real=revenue_real/10000
gen npopul=population/1000
gen nland=land/10000

xtreg lnexp_real ivf nrevenue_real ngdpper_real urbanrate npopul nland i.year if city!="绥化",fe r cluster(city)
est store ta21
xtreg lnexp_real ivf nrevenue_real ngdpper_real urbanrate npopul nland i.year if city!="绥化" & htwest==0,fe r cluster(city)
est store ta22

esttab ta21 ta22 using aptable2.tex,se star(* 0.1 ** 0.05 *** 0.01) drop(1998.year 1999.year 2000.year 2001.year 2002.year 2003.year 2004.year 2005.year 2006.year 2007.year) scal(r2_w twowayfe clustvar)

//Appendix Table 3
cd C:\Users\JackZHOU\Desktop\科研实践\政府支出的乘数与挤出效应\每周报告\2020.01.20\！2020年2月新做所有表格
use "C:\Users\JackZHOU\Desktop\科研实践\政府支出的乘数与挤出效应\每周报告\2020.01.20\98-07不删商务.dta", clear
drop if city=="绥化"
set seed 10101
gen ranorder = runiform()
sort ranorder
gen revenue_real=revenue/CPI
gen gdpper_real=gdpper_nom/CPI
psmatch2 minister revenue_real gdpper_real urbanrate population land, out(trans_real) logit ties ate neighbor(2) common caliper(.05)
pstest revenue_real gdpper_real urbanrate population land, both graph
tab _support
drop if _support!=1

xtreg trans_real ivf revenue_real gdpper_real urbanrate population land i.year if city!="绥化",fe r cluster(city)
est store ta31

sort cty year
gen gdp_real=gdp_nom/CPI
tab year,gen(year)
gen npopul=population/1000
gen nland=land/10000
gen neoivf=neominister*d03
gen gr_gdpr=(gdp_real-l.gdp_real)/l.gdp_real
gen gr_exprg=(exp_real-l.exp_real)/l.gdp_real
gen termiv=neominister*term^2

xtivreg2 gr_gdpr urbanrate npopul nland (gr_exprg=neoivf termiv l.trans_real) year3-year10 if city!="绥化",fe r cluster(city)
est store ta32

esttab ta31 ta32 using aptable3.tex,se star(* 0.1 ** 0.05 *** 0.01) keep(ivf gr_exprg) scal(r2_w exexog twowayfe citycontrol idp widstat jp clustvar)

//在正式的表格里没有包含以下一阶段结果
xtivreg2 gr_gdpr urbanrate npopul nland (gr_exprg=neoivf termiv l.trans_real) year3-year10 if city!="绥化",fe r cluster(city) savefirst savefp(fs1)
est replay fs1gr_exprg
est restore fs1gr_exprg

esttab fs1gr_exprg fs1gr_exprg using aptable3-2.tex,se star(* 0.1 ** 0.05 *** 0.01) drop(urbanrate npopul nland year3 year4 year5 year6 year7 year8 year9 year10)


//Figure X Years in Position
use "C:\Users\JackZHOU\Desktop\科研实践\政府支出的乘数与挤出效应\每周报告\2019.07.26\！11月底新做所有表格\任职年限.dta", clear
histogram yearsinposition, discrete width(1) frequency ytitle(Number of Ministers) ylabel(#7, grid glpattern(dash) gmin) xtitle(Years in Position) xlabel(1(1)12, gmin) scheme(s1mono)

