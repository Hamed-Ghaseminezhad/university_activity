### Poisson regression with offset

### Installing packages

### car -> contains graphical tools for plotting residuals and LRT function


install.packages("car")



library(car)


### data description



### loading the workspace claims.RData, containing the data

load(file.choose())

ls()

str(claims)

# age, arranged in classes
# (<25, 25-29, 30-35, >35)
# dist: type of area where the policyholders live
# rural, small town, large towns, major cities
# car: engine capacity
# (<1 liter, 1-1.5 liter, 1.5-2 liter, >2 liter)

# n: number of policyholders for each covariate pattern (that is, each data entry of the cross-table built on [age,dist,rural,car]
# c: number of claims for each covariate pattern


# coding the qualitative regressors' contrasts
# how categorical predictors are turned into binary variables for levels

?contrasts
contrasts(claims$car)
contrasts(claims$age)
contrasts(claims$dist)

?glm

# generalized linear model for Poisson data with offset

m1<-glm(c~offset(log(n))+car+dist+age,data=claims,family=poisson)

### Using offset(log(n)) is equivalent to divide each "c" (number of claims) by the 
### corresponding "n" (number of policy-holders)

summary(m1)

# how to change the reference level when coding a qualitative regressor

?contr.treatment

# 4 <- number of levels in the original regressor
# base=4 <- which of these levels has to be considered the reference
contrasts(claims$dist)<-contr.treatment(4,base=4)

contrasts(claims$dist)

# this change will be effective only for the current R session

m1.b<-update(m1)

summary(m1.b)

# Deviance

summary(m1)$deviance
summary(m1.b)$deviance
summary(m1)$df.residual

# Goodness-of-fit 

# the offset term should be "big enough" to ensure asymptotic properties of the deviance

sort(claims$n)

?pchisq

pchisq(summary(m1)$deviance,summary(m1)$df.residual, lower.tail=FALSE)

# Extracting residuals 
# when using function residuals on a glm object we get additional options

?residuals.glm

# deviance residuals

resid.m1.dev<-residuals(m1,type="deviance")

# the sum of the squared deviance residuals coincides with  the 
# (residual) deviance of m1

sum(resid.m1.dev^2)

# Pearson's residuals

resid.m1.p<-residuals(m1,type="pearson")

sum(resid.m1.p^2)

# Pearson's test

pchisq(sum(resid.m1.p^2),summary(m1)$df.residual, lower.tail=FALSE)

# the model seems appropriate for the data


### Graphical inspection of the residuals

# linearity of the (log) Expected Value

plot(m1,which=1)


#Gaussianity of the standardized residuals

qqPlot(rstandard(m1))


#### Does the 'dist' regressor impact the model?

m2<-update(m1,.~.-dist)
summary(m2)
m2.b<-update(m1.b,.~.-dist)
summary(m2.b)

# Remark: we lose 3 regress. coefficients because dist has 4 levels

# the LRT (Likelihood Ratio Test) performed by anova() function
# has additional options once applied to glm objects

?anova.glm

# Remember: H0 is "the reduced model is not significantly worse"
anova(m2,m1,test="Chisq")
anova(m2.b,m1.b,test="Chisq")

### Are there significant differences among policyholders living in rural area,
### small towns and large towns?

### Considering the models fitted so far,
### two different hypotheses can be tested, depending on the reference level selected
### for the regressor dist

### Each of these hypotheses can be tested using two 
### (asymptotically equivalent) procedures

### First hypothesis

### Model with reference level of dist set to "major cities"

summary(m1.b)

# Hypothesis to be tested: H_0: beta_dist1=beta_dist2=beta_dist3

# which means no difference between policyholders living in areas other than Major Cities

# 1st procedure) Wald test statistics
# Define the hypothesis through a system of linear equations K*beta=t

K.b<-matrix(c(0,0,0,0,0,0,0,0,1,1,-1,0,0,-1,0,0,0,0,0,0),2,10)
K.b

t.b<-matrix(c(0,0),2,1)

t.b

lht(m1.b,K.b,rhs=t.b)

# 2nd way) LRT
# Build a constrained (smaller) model in which H0 is imposed through coding of "dist",
# using major cities as reference category

claims$distnocity<-factor(claims$dist!="major cities")
table(claims$distnocity,claims$dist)

m3.b<-update(m2,.~.+distnocity)
summary(m3.b)

anova(m3.b,m1.b,test="Chisq")




### Second hypothesis

### Model with baseline level for dist set to "rural"

summary(m1)

# Hypothesis to be tested: H_0: \beta_small towns = beta_large towns = 0

# 1st way) Wald test statistic
# Define the hypothesis through a system of linear equations K*beta=t

K<-matrix(c(0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,0),2,10)
K

t<-matrix(c(0,0),2,1)

t

lht(m1,K,rhs=t)

# same results as before

lht(m1.b,K.b,rhs=t.b)

# 2nd way) LRT
# Build a constrained (smaller) model in which H0 is imposed through coding of "dist",
# using as reference category a collapsed category including rural areas, small towns and 
# large towns

claims$distcity<-factor(claims$dist=="major cities")
table(claims$distcity,claims$dist)
levels(claims$distcity)<-c("Other","MajorCity")

m3<-update(m2,.~.+distcity)
summary(m3)

anova(m3,m1,test="Chisq")

# same result as before

anova(m3.b,m1.b,test="Chisq")

# In both cases, the result obtained with the likelihood ratio test statistic
# is approximately equivalent to the result with the Wald test statistic





### How to interpret coefficients

exp(coefficients(m3))

# given that we have an offset term (log(n))
# we are actually regressing onto a rate (akin to a "risk of")
#for example: the rate of claims from policyholders living in Major Cities
# (keeping everything else fixed) is 1.24 times the rate for the other areas (baseline)
# There's a 24% increment in the rate by changing "dist" from any other area to Major Cities

# Another example: the rate of claims from polichyholders older than 35
# (keeping everything else fixed) is 0.58 times the rate of claims from policyholders 
#younger than 25: moving from the baseline level for age 
# to the last class there's a 42% decrement in the rate of claims

### Crucial: including the offset

m4<-glm(c~car+age+distcity,data=claims,family=poisson)
summary(m4)

pchisq(summary(m4)$deviance,summary(m4)$df.residual, lower.tail=FALSE)

#  a) Deviance is worse (bigger)
# b) signs of some coefficients change due to correlation between the predictors
# and the offset
# i.e.

?by

by(claims$c,claims$distcity,sum)
by(claims$n,claims$distcity,sum)

# the lower value for claims in Major Cities is NOT due to a lower risk (rate of claims)
# there are simply less policyholders in Major Cities, and thus the exposure is lower

by(claims$c,claims$distcity,sum)/by(claims$n,claims$distcity,sum)

# the raw rate of claims is actually higher in Major Cities

#### Is it reasonable to treat log(n) as an offset, rather than
# as an additional regressor?


mod.offreg<-glm(c~log(n)+car+age+distcity,data=claims,family=poisson)
summary(mod.offreg)

### Hypothesis testing on H0: \beta_offset=1

K.offreg<-rep(0,9)
K.offreg[1+1]=1
K.offreg
t.offreg=1

lht(mod.offreg,K.offreg,rhs=t.offreg)

# the regression coefficient associated with log(n) is not significantly different from 1
