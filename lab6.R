### Gamma GLMs


### required packages
### MLGdata (contains the data)

install.packages("MLGdata")

library(MLGdata)

?Chimps

data(Chimps)

str(Chimps)

y: time needed to learn a word (minutes)
chimp: chimpanze (factor - 4 categories)
word: word to be learned ( factor - 10 categories)

# Gaussian linear model

m.normal.id <- glm(y ~ chimp + word, data = Chimps)

plot(m.normal.id,which=1,pch=19)
plot(m.normal.id,which=3,pch=19)
plot(m.normal.id,which=2,pch=19)

# there is a clear violation of the homoscedasticity assumption


# Gamma GLM with canonical link function

m.gamma.can <- glm(y ~ chimp + word, family = Gamma, data = Chimps)

plot(m.gamma.can,which=1,pch=19)
plot(m.gamma.can,which=3,pch=19)
plot(m.gamma.can,which=2,pch=19)

# the use og a gamma GLM with canonical link function leads to an improvement,
# even though some "strange" patterns are still present in the residual plots

# Gamma GLM with logarithmic link function

m.gamma.log <- glm(y ~ chimp + word, family = Gamma(link=log), data = Chimps)

plot(m.gamma.log,which=1,pch=19)
plot(m.gamma.log,which=3,pch=19)
plot(m.gamma.log,which=2,pch=19)

# residual plots for the gamma GLM with logarithmic function suggest that this third model is adequate

# Choice of the link function

AIC(m.gamma.can)
AIC(m.gamma.log)

# Also according to the AIC, the logarithmic link function should be preferred

summary(m.gamma.log)

# estimation of the nuisance parameter

nu<-summary(m.gamma.log)$df[2]/sum(residuals(m.gamma.log,type="pearson")^2)
nu
1/summary(m.gamma.log)$dispersion

# estimation of the conditional coefficient of variation

sqrt(summary(m.gamma.log)$dispersion)
cv.gamma.log<-1/sqrt(nu)
cv.gamma.log



# Hypothesis testing

# independence hypothesis

# null model

m.gamma.log0 <- glm(y ~ 1, family = Gamma(link=log), data = Chimps)

summary(m.gamma.log0)
anova(m.gamma.log0,m.gamma.log,test="Chisq")

# there are significant differences in the learning times

# Checking for differences among chimpanzes

m.gamma.log2 <- glm(y ~ word, family = Gamma(link=log), data = Chimps)

summary(m.gamma.log2)
anova(m.gamma.log2,m.gamma.log,test="Chisq")

# There are significant differnces in the learning times among (at least two) chimpanzes,
# after controlling for the word to be learned

# Checking for differences among word


m.gamma.log3 <- glm(y ~ chimp, family = Gamma(link=log), data = Chimps)

summary(m.gamma.log3)
anova(m.gamma.log3,m.gamma.log,test="Chisq")


# There are significant differnces in the learning times among (at least two) words,
# after controlling for the different ability of each chimnpanze


# Comparison with lognormal regression models


m.lognormal <- glm(log(y) ~ chimp+word, data = Chimps)

plot(m.lognormal,which=1,pch=19)
plot(m.lognormal,which=3,pch=19)
plot(m.lognormal,which=2,pch=19)


# residual plots for the lognormal regression model suggest that
# also this fourth model is adequate


# estimation of the conditional coefficient of variation


sigma2<-sum(residuals(m.lognormal,type="pearson")^2)/summary(m.lognormal)$df[2]
sigma2
summary(m.lognormal)$dispersion

sigma2.ml<-sum(residuals(m.lognormal,type="pearson")^2)/nrow(Chimps)
sigma2.ml


cv.lognormal<-sqrt(exp(sigma2)-1)
cv.lognormal
cv.lognormal.ml<-sqrt(exp(sigma2.ml)-1)
cv.lognormal.ml


# model comparisons

AIC(m.lognormal) 	

## WARNING: this AIC refers to the Gaussian linear model for ln(Y)
## it cannot be compared with the AIC for the gamma GLM for Y

AIC(m.gamma.log)

# Recomputing AIC for the lognormal regression model

?dlnorm

lik.lnorm<-rep(0,nrow(Chimps))
for (i in 1:nrow(Chimps)) lik.lnorm[i]<-dlnorm(Chimps$y[i],meanlog=predict(m.lognormal)[i],sdlog=sqrt(sigma2.ml))

-2*sum(log(lik.lnorm))+2*14

# or, equivalently

AIC(m.lognormal)+2*sum(log(Chimps$y))








