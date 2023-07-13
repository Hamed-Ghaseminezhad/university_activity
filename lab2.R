### Flexible (Gaussian) regression models

### crash test dataset is available in the package MASS

library(MASS)
data(mcycle)

?mcycle
str(mcycle)

### polynomial regression

?poly

### fitting a polynomial of order 12

### orthogonal polynomials

poly12ort<-lm(accel~poly(times,degree=12),data=mcycle)

### power bases

poly12<-lm(accel~poly(times,degree=12, raw=TRUE),data=mcycle)

summary(poly12)
summary(poly12ort)

### note that the two models are characterized by the same summary
### statistics, but by different coefficients (due to the differences
### in the bases

### comparisons between nested models

poly9ort<-lm(accel~poly(times,degree=9),data=mcycle)

poly9<-lm(accel~poly(times,degree=9, raw=TRUE),data=mcycle)

anova(poly9ort,poly12ort)
anova(poly9,poly12)

### the choice of the bases does not alter the results of the
### F test

### comparison of the first 10 estimated regression coefficients

round(coefficients(poly9ort),4)
round(coefficients(poly12ort),4)[1:10]

### when using orthogonal polynomials, the exclusion of some
### bases does not alter the estimates for the regression coeffficients
### associated with the remaining bases

round(coefficients(poly9),4)
round(coefficients(poly12),4)[1:10]


### regression splines

### B-spline basis expansion

library(splines)
?bs

### linear spline with K=9 knots at the quantiles

### location of the knots

K.l<-9

knots.l<-quantile(mcycle$times,probs=(1:K.l)/(K.l+1))

lspline<-lm(accel~bs(times,knots=knots.l, degree=1),data=mcycle)

summary(lspline)

### cubic spline with K=8 knots at the quantiles

### location of the knots

K.c<-8

knots.c<-quantile(mcycle$times,probs=(1:K.c)/(K.c+1))

cspline<-lm(accel~bs(times,knots=knots.c, degree=3),data=mcycle)

summary(cspline)


### smoothing splines

?smooth.spline

### WARNING: the argument sp does not correspond to the actual smoothing parameter lambda
### discussed in class

### by default, the optimal value of the smoothing parameter is selected 
### according to GCV

sspline<-smooth.spline(mcycle$times,mcycle$accel,all.knots=T)
sspline

### smoothing spline with fixed smoothing parameter

sspline1<-smooth.spline(mcycle$times,mcycle$accel,all.knots=T,spar=0.7671)
sspline1

### smoothing spline with (approximate) fixed Equivalent/Effective degrees of freedom
### (fixed trace for the smoothing parameter

sspline2<-smooth.spline(mcycle$times,mcycle$accel,all.knots=T,df=12.2553)
sspline2

### P-splines

library(mgcv)

?gam
### the gam function fits generalized additive models using splines and penalized 
### maximum likelihood approach

### also with this function, by default the smoothing parameters are selected automatically,
### but the user has the option to set them to pre-specified values

?s
?smooth.terms

### choice of the linear basis expansion and for the penalization term of each
### smooth terms

### by setting some arguments to proper values, one can fit
### Gaussian models with a single regressor using the P-splines approach

### in particular, when specifying the s() element in the formula:
### the argument bs must be set to "ps"

### the argument k must be set equal to the total number of bases (K+m+1, according to the notation 
### used in class)

### the argument m must be used to set two values: (m1,m2) 
### m1 determines the degree of the spline, but it refers to the maximum order 
### of its partial derivatives that must be continuous (m-1, according to the notation
### used in class. 
### For example: m1=0 for linear splines, m1=2 for cubic splines.
### m2 is the order of the (squared) differences used to define the penalty term.
### For example: m2=1 for first-order differences, m2=2 for second-order differences.


### linear splines with 20 equispaced knots  + penalty on the squared first-order differences

psplinel<-gam(accel~s(times,bs="ps",k=22,m=c(0,1)),data=mcycle)
summary(psplinel)

### cubic splines with 20 equispaced knots + penalty on the squared second-order differences

psplinec<-gam(accel~s(times,bs="ps",k=24,m=c(2,2)),data=mcycle)
summary(psplinec)

### default setting

gam1<-gam(accel~s(times),data=mcycle)
summary(gam1)

### plot of the estimated (centred) smooth function
?plot.gam

plot(gam1)

#### comparison among fitted models

AIC(poly12ort)
AIC(poly12)
AIC(lspline)
AIC(cspline)
AIC(psplinel)
AIC(psplinec)
AIC(gam1)

#### AIC is not available for smoothing splines computed with the smooth.spline function

### graphical comparison between observed and fitted values

### example: results from the gam function 

timesp<-seq(2,58,length.out=200)

?predict.gam

pred.gam1<-predict(gam1,newdata=data.frame(times=timesp),type="response")
pred.psplinel<-predict(psplinel,newdata=data.frame(times=timesp),type="response")
pred.psplinec<-predict(psplinec,newdata=data.frame(times=timesp),type="response")

plot(mcycle$times,mcycle$accel,xlab="times",ylab="accel",pch=19,main="Penalized splines - gam default")
lines(timesp,pred.gam1,lwd=3,col=2)

plot(mcycle$times,mcycle$accel,xlab="times",ylab="accel",pch=19,main="Penalized linear P-splines")
lines(timesp,pred.psplinel,lwd=3,col=3)

plot(mcycle$times,mcycle$accel,xlab="times",ylab="accel",pch=19,main="Penalized cubic P-splines")
lines(timesp,pred.psplinec,lwd=3,col=4)











