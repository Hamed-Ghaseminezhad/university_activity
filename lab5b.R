### Regression for binary outcomes
### dealing with sparse data - part II

### required packages
### ResourceSelection (contains an R function to compute
### the Hosmer-Lemeshow test statistic)
### car (contains functions to build quantile-quantile plots)

install.packages(c("ResourceSelection","car"))

library(ResourceSelection)
library(car)

### load the workspace lab5.RData, containing
### the R objects created during the first part

load(file.choose())

# computation of the aggregate Pearson residuals

testHL40<-hoslem.test(SwissLabor$participation=="yes",predict(model,type="response"),g=40)

testHL40$observed
testHL40$expected
y1<-testHL40$observed[,2]
n1<-testHL40$observed[,2]+testHL40$observed[,1]
yhat1<-testHL40$expected[,2]

resid.aggr<-(y1-yhat1)/sqrt((yhat1*(n1-yhat1)/n1))

sum(resid.aggr^2)
testHL40

### residuals vs linear predictors

plot(log(yhat1/(n1-yhat1)),resid.aggr)
abline(h=0,lty=2)

### quantile-quantile plot

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
