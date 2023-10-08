* a
import sasxport5 "C:/Users/sunjiaqi/Downloads/DEMO_D.XPT", clear
save "C:/Users/sunjiaqi/Downloads/DEMO_D.dta", replace
import sasxport5 "C:/Users/sunjiaqi/Downloads/VIX_D.XPT", clear

merge 1:1 seqn using "C:/Users/sunjiaqi/Downloads/DEMO_D.dta", keep(match)

count

* b
generate age_tens_digit = floor(ridageyr / 10)
generate age_bracket = ""
replace age_bracket = "10-19" if age_tens_digit == 1
replace age_bracket = "20-29" if age_tens_digit == 2
replace age_bracket = "30-39" if age_tens_digit == 3
replace age_bracket = "40-49" if age_tens_digit == 4
replace age_bracket = "50-59" if age_tens_digit == 5
replace age_bracket = "60-69" if age_tens_digit == 6
replace age_bracket = "70-79" if age_tens_digit == 7
replace age_bracket = "80-89" if age_tens_digit == 8
generate distance_wear = ""
replace distance_wear = "Yes" if viq220 == 1
replace distance_wear = "No" if viq220 == 2
replace distance_wear = "DoNotKnow" if viq220 == 9
* summarize(age_bracket)

tabulate age_bracket distance_wear, row
* tabulate age_bracket viq220, row
* missing data: 433

* c
keep if viq220 == 1 | viq220 == 2
replace viq220 = 0 if viq220 == 2

collect clear
collect create MyModels

collect _r_b _r_se,                  ///
        name(MyModels)                 ///
        tag(model[(1)])                ///
        : logistic viq220 c.ridageyr

collect AIC=r(S)[1,"AIC"],             ///
        name(MyModels)                 ///
        tag(model[(1)])                ///
        : estat ic


collect _r_b _r_se,                    ///
        name(MyModels)                 ///
        tag(model[(2)])                ///
        : logistic viq220 c.ridageyr i.ridreth1 i.riagendr

collect AIC=r(S)[1,"AIC"],             ///
        name(MyModels)                 ///
        tag(model[(2)])                ///
        : estat ic

		
keep if indfmpir >= 0 & indfmpir <= 5

collect _r_b _r_se,                         ///
        name(MyModels)                      ///
        tag(model[(3)])                     ///
        : logistic viq220 c.ridageyr i.ridreth1 i.riagendr c.indfmpir

collect AIC=r(S)[1,"AIC"],                  ///
        name(MyModels)                      ///
        tag(model[(3)])                     ///
        : estat ic

collect layout (colname#result result[N r2_p AIC]) (model), name(MyModels)

collect style showbase off
collect style row stack, spacer delimiter(" x ")
collect style cell, nformat(%5.2f)
collect style cell result[AIC BIC], nformat(%8.0f)
collect style cell result[_r_se], sformat("(%s)")
collect style header result[AIC BIC], level(label)

collect style cell cell_type[item column-header], halign(center)
collect style header result, level(hide)
collect style column, extraspace(1)

collect preview

putpdf clear
putpdf begin
putpdf paragraph, font("Calibri Light",26) halign(center)
putpdf text ("Respondent Who Wear Glass/Contact Lenses for Distance Vision")

collect style putpdf, width(60%) indent(1 in)          ///
        title("Table: Logistic Regression Models for Wearing of Glass/Contact Lenses for Distance Vision") 			   ///
        note("Note: Odds ratio (standard error)")
putpdf collect
putpdf save "C:/Users/sunjiaqi/Downloads/MyTable.pdf", replace


* d
logistic viq220 c.ridageyr i.ridreth1 i.riagendr c.indfmpir
logit viq220 c.ridageyr i.ridreth1 i.riagendr c.indfmpir


