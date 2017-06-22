#make predictions from the a  model that has splines in it.
#could this be generalized nicely?
#or replaced w/something from MRSea?

# for the previous plots, we plotted predictions for the actual,
#observed combinations of covariates.
#Here, we will vary one covariate at a time, and hold all the 
#others fixed at the following values
#(which are the ones most commonly seen in the data):
# Group Size = 1
# Dispersion = Solo (except if group size varies -- 
# then Tight for size > 1)
# Behaviour = Mill
# odba = 0.1
# pitch = -0.03
# depth = 4 

pd <- data.frame(odba=seq(from=0, by=0.01, to=4))
pd[, c("MidGrpSize", "GrpChange", 
       "MidBeh",  "depth", 
       "pitch", "roll", "head")] <- 
  pd.base[, c("MidGrpSize", "GrpChange", 
              "MidBeh",  "depth", 
              "pitch", "roll", "head")]
#to make cyclic splines work 
pd.adds <- pd[1:5,]
pd.adds$roll <- c(0, 0.01, 0.02, 0.001, -0.1)
pd.adds$head <- c(0, 1, 2, 0.6, -0.2)
pd <- rbind(pd, pd.adds)
#get the design-y matrix
splineParams <- s1d.out1$splineParams
xmat <- cbind(rep(1,nrow(pd)) , #intercept
              rep(0, nrow(pd)), #BehTravel
              rep(0, nrow(pd)), #group change
              bs(pd$pitch, knots = splineParams[[2]]$knots, 
                 degree = splineParams[[2]]$degree, 
                 Boundary.knots = splineParams[[2]]$bd),
              bs(pd$depth, knots = splineParams[[3]]$knots,
                 degree = splineParams[[3]]$degree, 
                 Boundary.knots = splineParams[[3]]$bd),
              as.matrix(data.frame(gam(rep(0,nrow(pd)) ~ 
                                         s(roll, bs = "cc", 
                                           k = (length(splineParams[[4]]$knots) + 
                                                  2)), knots = list(c(splineParams[[4]]$bd[1], 
                                                                      splineParams[[4]]$knots, 
                                                                      splineParams[[4]]$bd[2])), 
                                       fit = F, data=pd)$X[, -1])),
              as.matrix(data.frame(gam(rep(0,nrow(pd)) ~ 
                                         s(head, bs = "cc", k = (length(splineParams[[5]]$knots) + 
                                                                   2)), knots = list(c(splineParams[[5]]$bd[1], splineParams[[5]]$knots, 
                                                                                       splineParams[[5]]$bd[2])), 
                                       fit = F, data=pd)$X[, -1])),
              bs(pd$odba, knots = splineParams[[6]]$knots,
                 degree = splineParams[[6]]$degree, 
                 Boundary.knots = splineParams[[6]]$bd),
              rep(0,nrow(pd)), #MidGrpSize 2
              rep(0,nrow(pd)), #MidGrpSize 3
              rep(0,nrow(pd))) #MidGrpSize 4

#huzzah!

#note: we are re-using boot.coefs from before. :)

#now multiply the prediction-data 
#by the coefficients  (with the appropriate link function! to get 
#predicted numbers of lunges in each condition for each #iteration:
if (best.model1$family$link == "logit"){
  boot.pred <- inv.logit(xmat %*% boot.coefs)
}
if (best.model1$family$link == "identity"){
  boot.pred <- xmat %*% boot.coefs
}
if (best.model1$family$link == "log"){
  boot.pred <- exp(xmat %*% boot.coefs)  
}
# then to turn that into a CI, find percentile based CIs for 
#each row (each row is one combo of factor levels).
pd$upper=apply(boot.pred, 1,quantile, probs= 0.975)
pd$lower <- apply(boot.pred, 1, quantile, probs= 0.025)

#and get the best prediction:
if (best.model1$family$link == "log"){
  pd$pred <- exp(xmat %*% coef(best.model1))  
}
pd <- pd[1:(nrow(pd)-5),]