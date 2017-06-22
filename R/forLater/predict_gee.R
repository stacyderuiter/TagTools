#make a set of data frames to use for predictions from a GEE, and make the predictions

preddata <- list() #create a list to store all the prediction data frames in
for (v in 1:n.coefs){
  coef <- best.coefs[v]
  other.coefs <- best.coefs[best.coefs != coef & best.coefs != exclude.coef]
  #if it's a factor variable:
  if (is.factor(pwcalls[,coef])){
    if (coef != exclude.coef){
      ppred <- expand.grid(unique(pwcalls[,exclude.coef]), unique(pwcalls[,coef]))
      names(ppred) <- c(exclude.coef,coef)
    }else{
      ppred <- expand.grid(unique(pwcalls[,exclude.coef])) 
      names(ppred) <- exclude.coef
    }
  }else{#for continuous variables, 
    #prediction data should be a range of values spanning the observed values
    nvals <- 200 #number of values to use -- increase to increase resolution if needed
    ppred <- data.frame(rep(seq(from=min(pwcalls[,coef], na.rm=T),
                                to=max(pwcalls[,coef], na.rm=T),
                                length.out=nvals ), nlevels(pwcalls[,exclude.coef])) )
    ppred[,2] <- gl(nlevels(pwcalls[,exclude.coef]), nvals, nrow(ppred), labels=levels(pwcalls[,exclude.coef]))
    names(ppred) <- c(coef, exclude.coef)
  }
  extras <- bl[other.coefs]
  extras[2:nrow(ppred),] <- extras[1,]
  ppred <- cbind(ppred, extras)
  #use the fitted model to make predictions
  #Note: make sure these predictions and CIs are NOT on the link scale by using type="response"
  preddata[[v]] <- predict(best.model, newdata=ppred,type="response")
  #bind the category names/IDs 
  #and the predictions into a single data frame
  preddata[[v]] <-cbind(ppred, resp=preddata[[v]])
}