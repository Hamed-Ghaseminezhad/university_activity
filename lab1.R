### Gaussian linear regression models
### 
### Checking model assumpions via graphical displays of teh residuals
### Testing linear hypotheses/model comparisons

### install library "car" for some useful functions 

install.packages("car")

### Load data: file birtwt.csv

dati<-read.csv(file.choose(),sep=";")

str(dati)

# Dependent variable:
# bwt		weight of the baby at birth (grams) 

# candidate regressors:
# age 	mother's age
# lwt   mother's weight before pregnancy (in pounds, lbs)
# race 	ethnicity (1=white, 2=black, 3=other)
# smoke smoking habit of the mother (0=no, 1=yes)
# ptl 	number of premature pregnancies mother had before the recorded one
# ht 		hypertension? (0=no, 1=s?)
# ui		uterine irritability? (0=no, 1=s?)
# ftv		number of medical check-ups during the first 3 months of pregnancy

# recoding qualitative predictors

dati$race<-factor(dati$race,labels=c("white","black","other"))
dati$smoke<-factor(dati$smoke,labels=c("no","yes"))
dati$ht<-factor(dati$ht,labels=c("no","yes"))
dati$ui<-factor(dati$ui,labels=c("no","yes"))

str(dati)


# graphical bivariate plots

plot(bwt~age,data=dati)
plot(bwt~lwt,data=dati)
plot(bwt~race,data=dati)
plot(bwt~smoke,data=dati)
plot(bwt~ptl,data=dati)
plot(bwt~ht,data=dati)
plot(bwt~ui,data=dati)
plot(bwt~ftv,data=dati)

# fitting a Gaussian multiple linear regression model including all the regressors

?lm

model1<-lm(bwt~.,data=dati)
summary(model1)


### alternative function to fit gaussian linear regression models
### the glm function - we will use this fumction extensively in the second part 
### of the course

?glm

model1bis<-glm(bwt~.,family=gaussian,data=dati)

summary(model1bis)

### Checking the adequacy of the model assumptions via
### graphical displays of the residuals

?fitted

yih<-fitted(model1)

?residuals
?residuals.lm

e1<-residuals(model1)

?rstandard

r1<-rstandard(model1)

### Linearity of the conditional expected value

### residuals vs fitted plot

plot(yih,e1)

### or, alternatively

?plot.lm

plot(model1, which=1)


### Normality of the conditional distributions

### quantile-quantile plot

library(car)

?qqPlot

qqPlot(r1)

### or, alternatively

plot(model1,which=2)

### homoscedasticity (same variance) of the conditional distributions

### scale-location plot

plot(model1, which=3)

### additional check: Box-Cox transformation to stabilize the conditional variances
### (see forthcoming lecture)
library(MASS)

?boxcox

boxcox(model1)

### An optimal value for lambda close to 1 suggests that the conditional variances
### are approximately constant (independent of the conditional expected values)


## Hypothesis testing

## H0: linear independence between X_j and Y ---> \beta_j = 0 for all j

?lht 

# Define a system of linear equations describing the constraints
# K*beta=t

# K1 has to have 9 rows (number of linear constraints)
# and 10 columns (number of constrainable parameters)

K1<-cbind(rep(0,9),diag(9))

K1

t1<-rep(0,9)

lht(model1,K1,t1)
lht(model1,K1)

### F statistic with Anova function 

### Build first a nested model

?update
model2<-update(model1,.~1)

summary(model2)


#extracting RSS from the two models
deviance(model1)
deviance(model2)

?anova

anova(model2,model1)


summary(model1)


### H0: beta_age=0
# K2 : we take the first row of K1

K2<-K1[1,]
K2
t2<-0 

lht(model1,K2,t2)

### with Anova function 

model3<-update(model1,.~.-age)

anova(model3,model1)

# connection with the t test statistic

summary(model1)

# statistica test t

summary(model1)$coefficients[2,3]

# statistica test F

summary(model1)$coefficients[2,3]^2


### H0: beta_black=beta_other

model1

# K3 : modify third row of K1

K3<-K1[3,]
K3
K3[5]<--1
K3
t3<-0 

lht(model1,K3,t3)

# build a nested model by recoding the original 'race' variable
dati$nowhite<-dati$race!="white"
table(dati$race,dati$nowhite)
model4<-update(model1,.~.-race+nowhite,data=dati)

anova(model4,model1)
summary(model4)
summary(model1)


##### HOW TO: compare non-nested models

model3
model4

## Two functions in R to compute AIC

AIC(model3)
AIC(model4)

extractAIC(model3)
extractAIC(model4)

# values returned by the two functions
# differ only due to a constant depending on the sample size 

AIC(model3)-extractAIC(model3)[2]
AIC(model4)-extractAIC(model4)[2]


### when applied to an object created using the lm function,
### extractAIC computes a simplified expression, where terms 
### in the loglikelihood not depending on model parameters are ignored
### and sigma^2 is not taken into account when determining the complexity

?extractAIC

nrow(dati)*log(sum(residuals(model3)^2)/nrow(dati))+2*length(coefficients(model3))
nrow(dati)*log(sum(residuals(model4)^2)/nrow(dati))+2*length(coefficients(model4))

nrow(dati)*log(2*pi)+nrow(dati)+2

## since the two models have the same number of parameters/compelxity
## the model with  the lowest AIC is also the model with the smallest RSS

deviance(model3)
deviance(model4)



