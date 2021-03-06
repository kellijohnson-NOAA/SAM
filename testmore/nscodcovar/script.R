library(stockassessment)
cn<-read.ices("cn.dat")
cw<-read.ices("cw.dat")
dw<-read.ices("dw.dat")
lf<-read.ices("lf.dat")
lw<-read.ices("lw.dat")
mo<-read.ices("mo.dat")
nm<-read.ices("nm.dat")
pf<-read.ices("pf.dat")
pm<-read.ices("pm.dat")
sw<-read.ices("sw.dat")
surveys<-read.ices("survey.dat")

## Estimate a correlation 
dat<-setup.sam.data(surveys=surveys,
                    residual.fleet=cn, 
                    prop.mature=mo, 
                    stock.mean.weight=sw, 
                    catch.mean.weight=cw, 
                    dis.mean.weight=dw, 
                    land.mean.weight=lw,
                    prop.f=pf, 
                    prop.m=pm, 
                    natural.mortality=nm, 
                    land.frac=lf)

conf<-defcon(dat)
conf$fbarRange <- c(2,4)
conf$obsCorStruct[] <- c("ID","ID","AR")
conf$keyCorObs[3,1:3] <- 0

conf$keyVarObs[3,] = c(2,3,4,5,-1,-1)
par<-defpar(dat,conf)
fit<-sam.fit(dat,conf,par)

## assign same correlation 
estcor<-cov2cor(fit$rep$obsCov[[3]])
surveys<-read.ices("survey.dat")
attr(surveys[[2]], "cor") <- lapply(1:23, function(i)estcor)

dat<-setup.sam.data(surveys=surveys,
                    residual.fleet=cn, 
                    prop.mature=mo, 
                    stock.mean.weight=sw, 
                    catch.mean.weight=cw, 
                    dis.mean.weight=dw, 
                    land.mean.weight=lw,
                    prop.f=pf, 
                    prop.m=pm, 
                    natural.mortality=nm, 
                    land.frac=lf)

conf<-defcon(dat)
conf$fbarRange <- c(2,4)
conf$obsCorStruct[] <- c("ID","ID","ID")
conf$keyVarObs[3,] = c(2,3,4,5,-1,-1)

par<-defpar(dat,conf)
fit2<-sam.fit(dat,conf,par)


## assign same covariance
estcov<-fit$rep$obsCov[[3]]
surveys<-read.ices("survey.dat")
attr(surveys[[2]], "cov") <- lapply(1:23, function(i)estcov)

dat<-setup.sam.data(surveys=surveys,
                    residual.fleet=cn, 
                    prop.mature=mo, 
                    stock.mean.weight=sw, 
                    catch.mean.weight=cw, 
                    dis.mean.weight=dw, 
                    land.mean.weight=lw,
                    prop.f=pf, 
                    prop.m=pm, 
                    natural.mortality=nm, 
                    land.frac=lf)

conf<-defcon(dat)
conf$fbarRange <- c(2,4)
conf$fixVarToWeight <- 1
conf$keyVarObs[3,] = c(2,2,2,2,-1,-1)
conf$obsCorStruct[] <- c("ID","ID","ID")
par<-defpar(dat,conf)

par$logSdLogObs = c(-0.35,-0.35,0)
map = list(logSdLogObs = as.factor(c(0,1,NA)))
fit3<-sam.fit(dat,conf,par,map = map)

## assign same with cov-weight. Here the corelation is fixed, but inverse variance is used as relative weight only.
estcov<-fit$rep$obsCov[[3]]
surveys<-read.ices("survey.dat")
attr(surveys[[2]], "cov-weight") <- lapply(1:23, function(i)estcov)

dat<-setup.sam.data(surveys=surveys,
                    residual.fleet=cn, 
                    prop.mature=mo, 
                    stock.mean.weight=sw, 
                    catch.mean.weight=cw, 
                    dis.mean.weight=dw, 
                    land.mean.weight=lw,
                    prop.f=pf, 
                    prop.m=pm, 
                    natural.mortality=nm, 
                    land.frac=lf)

conf<-defcon(dat)
conf$fbarRange <- c(2,4)
conf$keyVarObs[3,] = c(2,2,2,2,-1,-1)
conf$obsCorStruct[] <-  c("ID","ID","ID") 
par<-defpar(dat,conf)
fit4<-sam.fit(dat,conf,par)

sink("res.out")
print(modeltable(c("ESTMATED"=fit, "ASSIGNEDcor"=fit2,  "ASSIGNEDcov"=fit3,  "ASSIGNEDcov-weight"=fit4)))
sink()
