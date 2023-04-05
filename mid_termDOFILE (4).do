clear all

import spss using "C:\Users\hp\Documents\paris1\janvier2022\Econometrics\Nigeria MICS5 Datasets\Nigeria MICS 2016-17 SPSS Datasets\hh.sav"
save cylindricdata, replace
////////////////////////////////////////////////////////////////////////////////
*Description of the orginal dataset
////////////////////////////////////////////////////////////////////////////////
describ
///////////////////////////////////////////////////////////////////////////////
*Removing some variable et keep just relevant variables for our project
keep HH12 HH13A HH14 SL1 CL9 CL12 HC1A HC8J HC9B HC9F HC12 HC15 WS4B helevel wscore

keep HH12 HH13A HH14 SL1 CL9 CL12 HC1A HC8J HC9B HC9F HC12 HC15 WS4A WS4B helevel wscore
////////////////////////////////////////////////////////////////////////////////
*Clearning the dataset from obseration which miss some value
////////////////////////////////////////////////////////////////////////////////
drop if CL9==99
drop if CL9==.
drop if CL12==99
drop if CL12==.
drop if HC8J==9
drop if HC8J==.
drop if HC9B==9
drop if HC9B==.
drop if HC9F==9
drop if HC9F==.
drop if HC12==99
drop if HC12==.
drop if HC15==9
drop if HC15==.
drop if helevel==9
drop if helevel==.
*drop if WS4A==999
*drop if WS4A>200
*drop if WS4A==.
sum HH12 HH13A HH14 SL1 CL9 CL12 HC1A HC8J HC9B HC9F HC12 HC15 WS4B helevel wscore

*Rename the variables to facilitate the analysis and reading
rename HH12 awomen
rename HH13A amen
rename HH14 under5
rename SL1 under17
rename CL9 hourspent
rename CL12 numberhour
rename HC1A religion
rename HC8J ordi
rename HC9B mobile
rename HC9F carr
rename HC12 land
rename HC15 bank
*rename WS4A time
rename WS4B distance
*Recoding some descret variable in O and 1 in stead of 1 and 2 as in the original dataset
gen computer=1
replace computer=0 if ordi==2
gen phone=1
replace phone=0 if mobile==2
gen bankacc=1
replace bankacc=0 if bank==2
gen car=1
replace car=0 if carr==2
gen christian=0
replace christian=1 if religion==1
gen muslim=0
replace muslim=1 if religion==2
///////////////////////////////////////////////////////////////////////////////
*Descriptive statistics of quantitative data
///////////////////////////////////////////////////////////////////////////////
sum awomen amen under5 under17 hourspent numberhour religion computer phone car land bankacc distance helevel wscore
*Box Plots
graph box wscore, name(bscore)
graph box awomen, name(bwomen)
graph box amen, name(bmen)
graph box under17, name(b17)
graph combine bscore bwomen bmen b17
graph box wscore, over(religion) name(bscorerel)
graph box wscore, over(computer) name(bscorecomp)
graph box wscore, over(phone) name(bscorephone)
graph box wscore, over(car) name(bscorecar)
graph box wscore, over(bankacc) name(bscorebank)
graph box wscore, over(helevel) name(bscorelevel)
graph combine bscorerel bscorelevel bscorecomp bscorephone bscorecar bscorebank

*Some frequence tables of qualitative variables
tab religion
*Correlation between variable
pwcorr wscore awomen amen under5 under17 religion computer phone car land bankacc distance helevel
*Histograms of 
histogram wscore, normal name(histscore)
histogram awomen, normal name(histwomen)
histogram amen, normal name(histmen)
histogram under17, normal name(hist17)
graph combine histscore histwomen histmen hist17
*Normality test
sktest wscore 
jb wscore 

////////////////////////////////////////////////////////////////////////////////
*PLOTS
////////////////////////////////////////////////////////////////////////////

*Scatters
twoway scatter wscore awomen || lfit wscore awomen, name(score_women)
twoway scatter wscore amen || lfit wscore amen, name(score_men)
twoway scatter wscore under17 || lfit wscore under17, name(score_17)
twoway scatter wscore under5 || lfit wscore under5, name(score_5)
twoway scatter wscore religion || lfit wscore religion, name(score_rel)
twoway scatter wscore helevel || lfit wscore helevel, name(score_he)
graph combine score_women score_men score_17 score_5 score_rel score_he

///////////////////////////////////////////////////////////////////////////////
*Regression
///////////////////////////////////////////////////////////////////////////////
reg wscore awomen 
est store reg1
reg wscore awomen amen 
est store reg2
reg wscore awomen amen under5 
est store reg3
reg wscore awomen amen under17 
est store reg4
reg wscore awomen amen under5 hourspent 
est store reg5
reg wscore awomen amen under5 hourspent  christian 
est store reg6
reg wscore awomen amen under5 hourspent  muslim 
est store reg7
reg wscore awomen amen under5 hourspent  christian computer 
est store reg8
reg wscore awomen amen under5 hourspent  christian computer phone 
est store reg9
reg wscore awomen amen under5 hourspent christian computer phone car 
est store reg10
reg wscore awomen amen under5 hourspent christian computer phone car bankacc
est store reg11
reg wscore awomen amen under5 hourspent christian computer phone car bankacc helevel
est store reg12
esttab reg*
estout reg* using "globalreg.tex", legend cells(b(star fmt(2)) t(par fmt(2))) stats(r2 F N, labels("R2-square" "F Stat" "N") star(F)) replace style(tex)


*SELECTED MODEL FOR NEXT ANALYSIS (REGRESSION 11)
reg wscore awomen amen under5 hourspent christian computer phone car bankacc
////////////////////////////////////////////////////////////////////////////////
*REGRESION DIAGNOSTIC
////////////////////////////////////////////////////////////////////////////////
*Omitted variables test
ovtest
*Generating residuals
predict uhat, resid
histogram uhat, normal
jb uhat
*descriptio of residuals
sum uhat, detail
swilk uhat
sktest uhat
*Model specification test
linktest
*HETEROSCEDASTICITY TEST
rvfplot, yline(0)
estat hettest
*OUTLAYERS
lvr2plot
predict lev, leverage
stem lev
predict studresid, rstudent
list studresid
reg wscore awomen amen under5 hourspent christian computer phone car bankacc if studresid<1.5 & studresid>-1.5, robust
*OMITED VARIABLE
ovtest
predict newuhat, resid 
histogram newuhat, normal
*Endogeneity
correlate uhat awomen amen under5 hourspent christian computer phone car bankacc
*Comparison of models with and without outliers
reg wscore awomen amen under5 hourspent christian computer phone car bankacc, robust
est store with_
*FINAL MODEL 
reg wscore awomen amen under5 hourspent christian computer phone car bankacc if studresid<1.5 & studresid>-1.5, robust
est store without
esttab with_ without
estout with_ without using "correctreg.tex", legend cells(b(star fmt(2)) t(par fmt(2))) stats(r2 F N, labels("R2-square" "F Stat" "N") star(F)) replace style(tex)








