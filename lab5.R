### Regression for binary outcomes
### dealing with sparse data

### required packages
### AER (contains the data)
### ResourceSelection (contains an R function to compute
### the Hosmer-Lemeshow test statistic)
### car (contains functions to build quantile-quantile plots)

install.packages(c("AER","ResourceSelection","car"))

library(AER)
library(ResourceSelection)
library(car)

?SwissLabor # see the description of the variables

data(SwissLabor)
str(SwissLabor)

# this dataset provides individual information 
# (sample units data structure)


# determining the unique covariate patterns

regressors<-SwissLabor[,-1]

cov.pattern.unique<-unique(regressors)

dim(cov.pattern.unique)
dim(SwissLabor)

# the number of covariate pattern coincides with the sample size
# this implies that n_i=1 for each covariate pattern



# Fitting a logistic regression model using a dichotomous factor as dependent variable
# by default R focuses on the second category (in alphabetical order
# in this example: participation_j=yes => Z_j=1

model<-glm(participation~.,data=SwissLabor,family=binomial)

summary(model)

# graphical analysis of the residuals

plot(model, which=1)
plot(model, which=2)
plot(model, which=3)

# goodness of fit test

# residual
deviance(model)

# degrees of freedom
summary(model)$df.residual

# critical value
qchisq(0.05,summary(model)$df.residual,lower.tail=FALSE)

# p-value 
pchisq(deviance(model),summary(model)$df.residual,lower.tail=FALSE)

# WARNING: n_i=1 for each i is a violation of the
# assumptions needed to perform a goodness of fit test based on the 
# residual deviance -> the goodness of fit test based on the deviance is unreliable

# Hosmer-Lemeshow test

?hoslem.test

?predict.glm

testHL<-hoslem.test(SwissLabor$participation=="yes",predict(model,type="response"))

testHL

# the model can be considered adequate

testHL$observed
testHL$expected

# computation of the aggregate Pearson residuals

testHL40<-hoslem.test(SwissLabor$participation=="yes",predict(model,type="response"),g=40)

y1<-testHL40$observed[,2]
n1<-testHL40$observed[,2]+testHL40$observed[,1]
yhat1<-testHL40$expected[,2]

resid.aggr<-(y1-yhat1)/sqrt((yhat1*(n1-yhat1)/n1))

sum(resid.aggr^2)
testHL40

plot(log(yhat1/(n1-yhat1)),resid.aggr)
abline(h=0,lty=2)

qqPlot(resid.aggr)

summary(model)

## interpretation of model parameters

round(exp(model$coefficients),5)

### examples: 

### the odds of a foreign woman being in the labor force are almost four times as
### great as for an Swiss woman, ater controlling for all the other regressors

### each additional decade in age causes a 40% decrease in the the odds of being 
### in the labor force, after controlling for all the other regressors


### Choice of teh link function

model.probit<-glm(participation~.,data=SwissLabor,family=binomial(probit))

testHL.probit<-hoslem.test(SwissLabor$participation=="yes",predict(model.probit,type="response"))

testHL.probit

model.cloglog<-glm(participation~.,data=SwissLabor,family=binomial(cloglog))

testHL.cloglog<-hoslem.test(SwissLabor$participation=="yes",predict(model.cloglog,type="response"))

testHL.cloglog

### all three models seem adequate, according to the Hosmer-Lemeshow goodness of fit test

### model comparison

AIC(model)
AIC(model.probit)
AIC(model.cloglog)





