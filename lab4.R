### Regression for binary outcomes
### data structures and use of the glm function

# load data in the file Beetles1.txt

data1<-read.table(file.choose(),header=TRUE)
str(data1)
data1

# data1 contains data with a "covariate pattern" structure
# (one row for each unique covariate pattern)

# n: number of beetles exposed to a given dose of poison
# dead: number of beetles dead among those exposed to a given dose of poison
# logdose: logarithm of the dose of poison

# graphical representation of the relative frequencies

plot(data1$logdose,data1$dead/data1$n)

?glm

# in presence of a covariate pattern data structure, the dependent variable can be specified
# in two different ways:

# a) by defining a matrix containing one column for the number of "successes" (number of dead beetles)
# and one column for the "failures" (number of survived beetles) for each covariate pattern 



logistic1<-glm(cbind(dead,n-dead)~logdose,data=data1,family=binomial)

# note that in case of a constant number (example: a scalar value c) of units for each covariate pattern,
# the second column of the matrix can be obtained by substracting the number of successes from
# the constant (example: c-dead)



# b) by defining the relative frequency of successes for each covariate pattern
# AND by setting the argument "weights" equal to the number of units observed for each 
# covariate pattern

logistic2<-glm(dead/n~logdose,weights=n,data=data1,family=binomial)

summary(logistic1)
summary(logistic2)


# goodness of fit

deviance(logistic1)
deviance(logistic2)
summary(logistic1)$df.residual
summary(logistic2)$df.residual

# critical value

qchisq(0.05,summary(logistic1)$df.residual,lower.tail=FALSE)

# p-value

pchisq(deviance(logistic1),summary(logistic1)$df.residual,lower.tail=FALSE)

# there is no significant evidence against the fitted model


# load data in the file Beetles2.txt

data2<-read.table(file.choose(),header=TRUE)
str(data2)

# data2 contains data with a "0/1 - sample unit" structure
# (one row for each sample unit)

# x: logarithm of the dose of poison the beetle was exposed to
# y: Is the beetle dead (0=no, 1=yes)

# graphical representation  - uninformative plot

plot(data2$x,data2$y)

# detection of the unique covariate patterns in data2

?unique

unique(data2$x)

table(data2$x,data2$y)

data1

# data1 e data2 contain the same information structured in different ways



# In presence of individual data, the dependent variable can be specified
# in two different ways:

# a) by defining a matrix containing one column for the "success" (the beetle died)
# and one column for the "failure"(the beetle survived)

logistic3<-glm(cbind(y,1-y)~x,data=data2,family=binomial)

# b) by directly specifing a dummy/indicator variable as dependent variable

logistic4<-glm(y~x,data=data2,family=binomial)

# comparison among the summary outputs

summary(logistic1)

summary(logistic3)

summary(logistic4)

# WARNING:

# as far parameter inference is concerned, the choice of the data structure is irrelevant

# the difference is in the way in which deviances and model selection criteria
# are computed

# In particular, the correct values can be obtained 
# ONLY using a covariate pattern data structure
# (there is no internal check int the glm function to detect 
# the possible presence of repeated covariate patterns)


# Change in the link function

probit<-update(logistic1,family=binomial(probit))

deviance(probit)

pchisq(deviance(probit),summary(probit)$df.residual,lower.tail=FALSE)

cloglog<-update(logistic1,family=binomial(cloglog))

deviance(cloglog)

pchisq(deviance(cloglog),summary(cloglog)$df.residual,lower.tail=FALSE)

# All three models seem adequate (their deviances are not significantly larger than 0)
# the model with the cloglog link function has a smaller deviance


AIC(logistic1)
AIC(probit)
AIC(cloglog)

# according to the AIC, the cloglog link function should be preferred

# NOTE THAT: 
# 1) the three considered models are not nested
# 2) in this example, since the models have the same linear predictor 
# (that is, the same number of parameters)
# the ordering of the models according to the AIC coincides with  the ordering of the models
# according to the (residual) deviance


