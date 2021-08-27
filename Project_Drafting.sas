/*Creating a permanent Library*/
libname kp "C:\Users\praka\OneDrive\Desktop\METRO\SAS\ADVANCE_SAS\PROJECT";

PROC OPTIONS OPTION = MACRO;
RUN;
/*Loading the dataset file*/
/*Infile Specifies an external file to read with an INPUT statement.*/
/*Input Returns the value that is produced when SAS converts an expression by using the specified informat.*/
/*Format specifies the format that is listed for writing the values of the variables.*/
/*Informat specifies a temporary default informat for reading values of the variables that are listed in the INFORMAT statement. */
data kp.test1;
	infile "C:\Users\praka\OneDrive\Desktop\METRO\SAS\ADVANCE_SAS\PROJECT\New_Wireless_Fixed.txt";
	input Acctno $ 1-13 
		  @15 Actdt mmddyy10.
		  @26 Deactdt mmddyy10. 
		  DeactReason $ 41-44
		  GoodCredit 53 
		  RatePlan $ 62  
	      DealerType $ 65-66
		  Age 74-75 
		  Province $ 80-81
		  Sales $ 82-92
;
	format Actdt date9. Deactdt date9.
;
	run;
proc print data = kp.test1(obs=50); run;

/*
Analysis requests:
1.1  Explore and describe the dataset briefly. For example, is the acctno unique? What
is the number of accounts activated and deactivated? When is the earliest and
latest activation/deactivation dates available? And so on…. */

/*Exploring the dataset */
title 'Description of Data';
PROC CONTENTS DATA=kp.test1;
RUN;
title;

/*SAS SYNTAX*/
proc sort data = kp.test1 nodupkey;
by Acctno;
run;
/*CONCLUSION : All the Account numbers are uunique*/

/*PROC SQL SYNTAX*/
/*To extract all the unique Account numbers*/
proc sql;
	select count(*) as obs, count( distinct Acctno) as Acc
	from kp.test1;
run;

/*MACRO SYNTAX*/
/*To extract all the unique Account numbers using macro*/
%macro unique_accno(DSN=, var1=);
proc sort data = &DSN. nodupkey;
by &var1;
run;
%mend;
%unique_accno(DSN=kp.test1,var1=Acctno);
/*CONCLUSION : All Acctno are unique*/


/*1.1 What is the number of accounts activated and deactivated? */
/*SAS SYNTAX*/
data kp.test2;
set kp.test1;
Sales = SUBSTR(Sales,2,7);
Sales_format = input(Sales, best12.);
if Deactdt='' then Account_Status='Active      ';
else Account_Status = 'Deactivated';
run;
proc print data= kp.test2(obs=10);run;
proc contents data=kp.test2;
/*To classify the accounts as Activated or Deactivated based on deactivation date*/

/*Number of Accounts Activated and Deactivated*/
proc freq data=kp.test2;
tables Account_Status;
run;

/*PROC SQL SYNTAX*/
PROC SQL;
SELECT Account_Status , count(Account_Status) as Acc_Count FROM kp.test2
group by Account_Status;
QUIT;


/*MACRO*/
%macro levels_variable(DSN=,var1=);
proc freq data= &DSN. ;
tables &var1;
run;
%mend;
%levels_variable(DSN=kp.test2,var1=Account_Status);
/*GRAPH*/
%include "C:\Users\praka\OneDrive\Desktop\METRO\SAS\ADVANCE_SAS\PROJECT\univariate_analysis.sas";
%UNI_ANALYSIS_CAT_FORMAT(kp.test2,Account_Status)

/*CONCLUSION : The number of Active accounts is 82620 and the number of Deactivated Accounts is 19635.*/


/*1.1 When is the earliest and latest activation/deactivation dates available?*/
/*SAS SYNTAX*/
title'Earliest and Latest date for Active & Deactive Account';
proc tabulate data=kp.test2 format=date9.;
var Actdt Deactdt;
table Actdt=Actdt*(min='min date' max='max date') Deactdt= Deactdt*(min='min date' max='max date') ;
run;

 /*PROC SQL*/

proc sql;  
select min(Actdt) as Earliest_Actdt format = date9. , max(Actdt) as Latest_Actdt format = date9. ,
min(Deactdt) as Earliest_Deactdt format = date9. , max(Deactdt) as Latest_Deactdt format = date9.  
from kp.test2;
quit;
/*MACRO*/
%macro earliest_latest_date(DSN=,var1=,var2=);
proc tabulate data=&DSN. format=date9.;
var &var1 &var2;
table &var1=&var1*(min='min date' max='max date') &var2= &var2*(min='min date' max='max date') ;
run;
%mend;
%earliest_latest_date(DSN=kp.test2 ,var1=Actdt,var2=Deactdt);
title;
/***************************************************************************************************************************************/


/*1.2  What is the age and province distributions of active and deactivated customers?*/
/*SAS Syntax*/
title'Age and Province distributions of active and deactivated customers';
proc tabulate data = kp.test2;
class Account_Status Province;
var Age;
Table Account_Status * Province,
Age * (Mean Median Mode) ;
run; 


proc freq data=kp.test2; 
tables Account_Status*Age*Province;
run;

proc sql; /*PROC SQL */
   title 'Age and province for Active and Deactivated Customers';
   select mean(Age) as Age, Province,Account_Status
      from kp.test2 
      group by Account_Status,Province;
quit;

title;

/*CONCLUSION : There not much of difference of age across different provinces for activated and deactivated customers.
It is observed that customers with age of 41 to 52 are occuring frequently in both the cases .ie. Active and Deactive*/
/***************************************************************************************************************************************/

/*1.3 Segment the customers based on age, province and sales amount:
Sales segment: < $100, $100---500, $500-$800, $800 and above.
Age segments: < 20, 21-40, 41-60, 60 and above.
Create analysis report */

/*SAS Syntax*/
/*GRAPH PENDING*/
title 'Age & Sales Segmentation and Report ';
proc format;  
value agefmt
low-20 = '<=20'
21-40 = '21-40' 
41-60 ='41-60'
61-high = 'above 60'
;

 proc format;
 value Salesfmt
  		Low - 100    = "Very Low Sales"
		100 - 500    = "Low Sales"
		500 - 800    = "Moderate Sales"
		800 - high    = "High Sales"  
		;
 run;
 proc print data= kp.test2(obs=10);
 format Age agefmt. Sales_format Salesfmt. ;
 run;

 /*Segmenting the data according to the bins given */
data kp.test0;
set kp.test2;
format Age agefmt. Sales_format Salesfmt. ;
run;
proc print data=kp.test0(obs=10);run;
/*To set the given format in data step so that we can use it as dataset to check the segments distribution for variable*/
proc freq data=kp.test0;
tables Age;
run;
/*CONCLUSION : Age group of 41-60 has highest number of customers*/
%UNI_ANALYSIS_CAT_FORMAT(kp.test0,Age,Agefmt.)

proc freq data=kp.test0;
tables Sales_format;
run;
%UNI_ANALYSIS_CAT_FORMAT(kp.test0,Sales_format,Salesfmt.)

/*CONCLUSION : Highest number of Sales is from Very low Sales group i.e. the amount of Sales is very low*/
proc freq data=kp.test0;
tables Sales_format*Age;
run;

PROC SGPLOT DATA = kp.test0;
VBAR Age / GROUP = Sales_format;
TITLE 'Sales & Customer Age Segments';
RUN;

title;


/*CONCLUSION : From age segment it is observed that people from age group 41-60s are in high percent (i.e. 39.64%) than other groups
Highest number of Sales is from Very low sales group . It is observed that very low sales is observed in high percentage in the age group of 41-60*/
/*
Null Hypothesis : There is no association between Age and Sales Segments.
Alternative Hypothesis : There is no association between Age and Sales Segments.
*/
%MACRO CHSQUARE (DSN = ,VAR1= , VAR2= );
PROC FREQ DATA = &DSN;
TITLE "RELATIONSHIP BETWEEN BETWEEN var1 AND var2";
 TABLE &VAR1. * &VAR2 /CHISQ OUT=OUT_&VAR1._&VAR2 ;
RUN;
%MEND CHSQUARE;
%CHSQUARE(DSN = kp.test0 , VAR1= Sales_format  , VAR2 = Age);

/*CONCLUSION : Bivariate Analysis between the two categorical variables using Chi-square probability value is greater than significance level hence we accept the null 
Hypothesis there is no association between the two variables*/


/***************************************************************************************************************************************/
/*
1.4.Statistical Analysis:
1) Calculate the tenure in days for each account and give its simple statistics.*/
/*SAS Syntax*/    
title'Calculating the Tenure'; 
 data kp.test3;
set kp.test2;
 dt=today();
 format dt date9.;
if Deactdt =. then Deactdt = dt;
Tenure = INTCK("day",Actdt,Deactdt);
run;
proc print data = kp.test3(obs=10);run;
/*Drop the dt variable for todays date*/
 data kp.test;
set kp.test3;
drop dt;
run;
proc print data = kp.test(obs=10);run;

/*PROC SQL SYNTAX*/
proc sql;
  select Actdt,Deactdt, intck('day', Actdt, Deactdt) as No_of_days
  from kp.test(obs=10);
quit;


/*MACRO*/
%macro tenure(DSN=,var1=,var2=,var3=);
proc sql;
  select &var1,&var2, intck('day', &var1, &var2) as No_of_days
  from &DSN(obs=10);
quit;
%mend;
%tenure(DSN=kp.test,var1=Actdt,var2=Deactdt);


proc means data=kp.test3 n mean median mode max min range std fw=8;
   var Tenure ;
   title 'Statistics for Tenure';
run;
title;
%UNI_ANALYSIS_NUM(kp.test,Tenure)

/*CONCLUSION : Outliers are mostly from deactivated account. If customers passes  a particular threshold then we can prevent the churn rate
for that we have to retain the customers either with good service(feedback etc) or good offers*/

/***************************************************************************************************************************************/
/*2) Calculate the number of accounts deactivated for each month.*/
/*SAS SYNTAX*/
title 'Deactivated accounts for each month.';
/*To classify Accounts based on months*/
data kp.test4;
set kp.test2;
if Deactdt =. then 
month = intnx('month',Actdt,0,'b');
format month monname3. ;
else
month = intnx('month',Deactdt,0,'b');
format month monname3. ;
run;

proc print data = kp.test4(obs=10);run;


proc  freq data = kp.test4;
tables Account_Status*month;
run;


/*CONCLUSION : proc freq gives distribution of both Active and Deactive accounts for each month*/

/*PROC SQL*/
/*CONCLUSION : Proc sql gives distribution of Deactive accounts for each month for every year hence there 
are 25 rows for 2 years data It won't give distinct for months as month is extracted from date*/
proc sql;
  select month, count(month)
  from kp.test4 
  where Account_Status = "Deactivated"
  group by month
  ;
quit;

/*MACRO*/
%macro levels_two_variable(DSN=,var1=,var2=);
proc freq data= &DSN. ;
tables &var1*&var2;
run;
%mend;
%levels_two_variable(DSN=kp.test4,var1=Account_Status,var2=month);


title;
/*CONCLUSION : Highest percent of churn rate is observed in the month of December & also in month of October November & January 
RECOMMENDATION : Retaining the customers before last quarter of the year by giving special offers or taking feedbacks for services.
*/

/***************************************************************************************************************************************/

/*3) Segment the account, first by account status Active・and Deactivated・ then by
Tenure: < 30 days, 31---60 days, 61 days--- one year, over one year. Report the
number of accounts of percent of all for each segment.*/

/*SAS SYNTAX*/
title'Tenure & Account status segmentation';

proc format;
value $account_status
     'Active'='Active'
     'Deactivated'='Deactive'
	; 

proc format;
value tenurefmt
 	low-30='<30'
	31-60='31-60'
	61-365='6mon-1yr'
	366-high='>1yr'
	; run;
data kp.test5;
set kp.test;

format Account_Status $account_status. Tenure tenurefmt. ;
run;

proc print data= kp.test5(obs=10);
run;
proc  freq data = kp.test5;
tables Tenure*Account_Status;
run;

/*MACRO SYNTAX*/
%levels_variable(DSN=kp.test5,var1=Tenure);

%UNI_ANALYSIS_CAT_FORMAT(kp.test5,TENURE,tenurefmt.)

PROC SGPLOT DATA = kp.test5;
VBAR Account_Status / GROUP = Tenure;
TITLE 'Tenure & AccountStatus';
RUN;
/*
CONCLUSION : There are high percentage of customers discontinuing the service within 6 months to one year,
if they are continuing beyond one year chances of churning out is very low.

*/
/****************************************************************************************************************************************/
/*4) Test the general association between the tenure segments and Good Credit・
RatePlan ・and DealerType.*/
/*TENURE SEGMENTS AND GOODCREDITS*/
/*SAS SYNTAX*/
/*Null Hypothesis : There is no  association between Tenure segments and Goodcredits
Alternate Hypothesis: There is association between Tenure segments and Goodcredits */
PROC FREQ DATA = kp.test5;
TITLE "RELATIONSHIP BETWEEN BETWEEN TENURE SEGMENTS AND GOODCREDITS";
TABLE  GoodCredit* TENURE/CHISQ OUT=OUT_BP_STATUS;
RUN;

/*MACRO*/


%MACRO CHSQUARE (DSN = ,VAR1= , VAR2= );
PROC FREQ DATA = &DSN;
TITLE "RELATIONSHIP BETWEEN BETWEEN var1 AND var2";
 TABLE &VAR1. * &VAR2 /CHISQ OUT=OUT_&VAR1._&VAR2 ;
RUN;
%MEND CHSQUARE;

%CHSQUARE(DSN = kp.test5 , VAR1= GoodCredit  , VAR2 =TENURE);

/*CONCLUSION:  Here the p-value is 0.001 which is less than significance level hence we reject the Null Hypothesis.
There is some association between tenure segments and Goodcredits*/

/*  RATEPLAN AND DEALERTYPE*/
/*SAS SYNTAX*/
/*Null Hypothesis : There is no  association between Rateplan and Dealertype
Alternate Hypothesis: There is association between Rateplan and Dealertype */

PROC FREQ DATA = kp.test5;
TITLE "RELATIONSHIP BETWEEN BETWEEN  RATEPLAN AND DEALERTYPE";
TABLE  RatePlan*DealerType /CHISQ OUT=OUT_BP_STATUS;
RUN;

/*MACRO*/

%MACRO CHSQUARE (DSN = ,VAR1= , VAR2= );
PROC FREQ DATA = &DSN;
TITLE "RELATIONSHIP BETWEEN BETWEEN var1 AND var2";
 TABLE &VAR1. * &VAR2 /CHISQ OUT=OUT_&VAR1._&VAR2 ;
RUN;
%MEND CHSQUARE;

%CHSQUARE(DSN = kp.test6 , VAR1= Rateplan  , VAR2 =DealerType);

/*CONCLUSION:  Here the p-value is 0.001 which is less than significance level hence we reject the Null Hypothesis.
There is some association between Rateplan and Dealertype*/


/***************************************************************************************************************************************/

/*5) Is there any association between the account status and the tenure segments?*/
/*SAS SYNTAX*/
/*Null Hypothesis : There is no  association between account status and tenure segments
Alternate Hypothesis: There is association between account status and tenure segments */
PROC FREQ DATA = kp.test6;
TITLE "RELATIONSHIP BETWEEN BETWEEN ACCOUNT STATUS AND TENURE SEGMENTS";
TABLE  Account_Status* TENURE/CHISQ OUT=OUT_BP_STATUS;
RUN;

/*MACRO*/
%MACRO CHSQUARE (DSN = ,VAR1= , VAR2= );
PROC FREQ DATA = &DSN;
TITLE "RELATIONSHIP BETWEEN BETWEEN var1 AND var2";
 TABLE &VAR1. * &VAR2 /CHISQ OUT=OUT_&VAR1._&VAR2 ;
RUN;
%MEND CHSQUARE;

%CHSQUARE(DSN = kp.test6 , VAR1= Account_Status  , VAR2 =TENURE);

/*CONCLUSION:  Here the p-value is 0.001 which is less than significance level hence we reject the Null Hypothesis.
There is some association between AccountStatus and Tenure*/


/* 6) Does Sales amount differ among different account status, GoodCredit, and
customer age segments?*/
/*SAS SYNTAX*/
/*SALES & ACCOUNT STATUS*/

/*
Null Hypothesis : There is no association between Sales and Accout Status
Alternative Hypothesis: There is some association between Sales and Accout Status
*/
ods graphics on;
proc ttest data=kp.test2;
      class Account_Status;
      var Sales_format;
   run;
   
   ods graphics off;
   /*MACRO SYNTAX*/
%macro ttest_var_class(DSN=,var1=,var2=);
ods graphics on;
proc ttest data=&DSN.;
      class &var1;
      var &var2;
   ods graphics off;
%mend;
%ttest_var_class(DSN=kp.test2,var1=Account_Status,var2=Sales_format);
/*CONCLUSION: Here the p-value is 0.0475 which is less than significance level hence we reject the Null Hypothesis.
There is some association between Sales and Account Status(but weak association as value ia very close to 0.05)*/


/*SAS SYNTAX*/
/*SALES & GOODCREDIT*/

/*
Null Hypothesis : There is no association between Sales and Goodcredit
Alternative Hypothesis: There is association between Sales and Goodcredit
*/  
ods graphics on;
proc ttest data=kp.test2;
      class GoodCredit;
      var Sales_format;
   run;
 ods graphics off;
%ttest_var_class(DSN=kp.test2,var1=GoodCredit,var2=Sales_format);

/*CONCLUSION: Here the p-value is 0.2878 which is greater than significance level hence we fail to reject the Null Hypothesis.
There is no association between Sales and Goodcredit*/

/*SAS SYNTAX*/
/*SAles and CUSTOMER_AGE_SEGMENTS*/
/*
Null Hypothesis : There is no association between Sales and customer age segments
Alternative Hypothesis: There is association between Sales and customer age segments
*/ 
/*Appling the age format on age column*/

data kp.test7;
set kp.test2;
format Age agefmt.;
run;
proc print data=kp.test7(obs=10);run;

PROC ANOVA DATA = kp.test7;
 CLASS Age;
 MODEL Sales_format = Age;
 MEANS Age/Scheffe;/*we can consider that at least two group means are statistically signicant from each other if p-value is less than 0.05. So far, the ANOVA only tells you all group means are not statistically significant equal. It does not tell you where the difference lies. For further multiple comparison, we still need Scheffe痴 or Tukey test.*/
 TITLE "Sales for different customer age groups";
RUN;
QUIT;


/*CONCLUSION: Here the p-value is 0.7179 which is greater than significance level hence we fail to reject the Null Hypothesis.
There is no association between Sales and Customer age segments*/

proc glm data=kp.test7;
class Age;
model Sales_format = Age;
means Sales_format / hovtest=levene(type=abs) welch;
run;

/***************************************************************************************************************************************/

%include "C:\Users\praka\OneDrive\Desktop\METRO\SAS\ADVANCE_SAS\PROJECT\univariate_analysis.sas";
%UNI_ANALYSIS_CAT_FORMAT(kp.test2,Account_Status)
%UNI_ANALYSIS_CAT_FORMAT(kp.test0,Age,Agefmt.)
%UNI_ANALYSIS_CAT_FORMAT(kp.test0,Sales_format,Salesfmt.)
%UNI_ANALYSIS_CAT_FORMAT(kp.test5,TENURE,tenurefmt.)

%UNI_ANALYSIS_NUM(kp.test2,Sales_format)
%UNI_ANALYSIS_NUM(kp.test,Tenure)
%FREQ_AND_Visual_cat(kp.test4,Account_Status)
%BI_ANALYSIS_NUMs_CAT (DSN =kp.test6 ,CLASS=Account_Status , VAR=TENURE );




