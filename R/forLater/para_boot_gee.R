#get the "design(ish) matrix"
#one row per desired combination of levels of interest.
xmats <- list()
for (v in 1:n.coefs){
  coef <- best.coefs[v]
  f <- as.character(formula(best.model))
  f <- paste("~", f[3], sep="")
  xmats[[v]] <- model.matrix(as.formula(f), preddata[[v]])
}


#parametric bootstrap to get CIs on the mean factor level effects
#Assume (this is reasonable given our model) that the 
#parameter estimates
#follow a multivariate normal distribution with means
#equal to the parameter estimated from the fitted model and
#variance-covariance matrix also from the fitted model
#(accessed via summary(model2)$cov.scaled)
# Use rmvnorm (from mvnorm library) to sample coefs from this 
#MVN (say maybe 5000 iterations) and multiply by the design matrix 
#to get predictions (make sure the 2 matrices are the right shapes 
#for matrix multiplication... ).  values should be a matrix with 
#nrows=number of parameters (factor combination levels) and 
#ncol=number of iterations). get the mvn values that will be the 
#bootstrap "output" for each iteration
library(mvtnorm)
library(boot) #for inverse logit function
# #note: if you don't want to use the boot package then you can uncomment and use this one
#(which should probably work. but may have less error checking/nice way of dealing with Inf/NA)
# inv.logit <- function(x) {
#   il <- exp(x)/(1+exp(x))
# }

n <- 10000 #number of bootstrap iterations
boot.coefs <- t(rmvnorm(n, mean=best.model$coef, 
                        sigma=summary(best.model)$cov.scaled, 
                        method="svd"))
boot.CI95 <- list()
for (v in 1:n.coefs){
  #now multiply the prediction-data 
  xmat <- xmats[[v]]
  #by the coefficients  (with the appropriate link function! to get 
  #predicted numbers of lunges in each condition for each #iteration:
  if (best.model$family$link == "logit"){
    boot.pred <- inv.logit(xmat %*% boot.coefs)
  }
  if (best.model$family$link == "identity"){
    boot.pred <- xmat %*% boot.coefs
  }
  if (best.model$family$link == "log"){
    boot.pred <- exp(xmat %*% boot.coefs)  
  }
  # then to turn that into a CI, find percentile based CIs for 
  #each row (each row is one combo of factor levels).
  boot.CI95[[v]] <- data.frame(upper=apply(boot.pred, 1, 
                                           quantile, probs= 0.975))
  boot.CI95[[v]]$lower <- apply(boot.pred, 1, quantile, probs= 0.025)
}
