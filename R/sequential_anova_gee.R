geePvalues <- function(model1){
#model1 is the "full model" we are starting with. output object from geeglm (or other object that anova() will work on)
#note that terms are added sequentially if we use the anova() function. 
#We want a p-value for each term *assuming all the others are included in the model*
#so we can do that with anova() by placing 
#each term as the last term and applying anova() each time, keeping only the
#pvalue for the "last term". Then for model selection we 
#remove the term which has the highest p-value.
#this can be done manually (time-consuming), or using the following automated code
#note: the code below will not work if the names of the predictor variables are "nested"
#for example if one predictor is called "x" and the others are "x2" and "x3".
#make sure names are unique, for example even "x1", "x2", "x3" would be ok!

#create a data frame called "model.seln" to hold the model selection results
model.seln <- data.frame(coefs=labels(terms.formula(model1$formula)), p.vals=1, include=T)
#get a list of the names of all the coefficients in the full model model1
all.coefs <- labels(terms.formula(model1$formula))
alfa <- 0.05 #desired significance level for hypothesis testing
best.model <- model1 #start with the full model - we will reduce it via anova-based model selection
#the following loop will run until all non-significant predictors have been removed from the model
while (any(model.seln[model.seln$include,"p.vals"] > alfa)){
  #get a list of the predictors in the current best model
  best.coefs <- labels(terms.formula(best.model$formula))
  for (k in 1:length(best.coefs)){ #loop over all coefficients except intercept
    #for each predictor/coefficient, move it to the end of the model specification then run anova
    coef <- best.coefs[k]
    #create a string naming the predictor currently being tested, to feed to "update" function
    f<-paste(".~.-",coef, "+", coef,sep="") 
    #create "test.model", which has the current predictor as the last-term-added
    test.model <- update(best.model,as.formula(f) )
    #save the p-value (for the current predictor only) in the data frame "model.seln"
    model.seln[model.seln$coefs==coef,"p.vals"] <- 
      anova(test.model)$P[labels(terms.formula(test.model$formula))==coef]
  }
  #first check interaction terms significance
  ints <- grep(":", best.coefs) #indices of interaction terms in (current) best model coef list
  ints.full <- grep(":", all.coefs)#indices of interaction terms in full model coef list
  mains <- setdiff(c(1:length(best.coefs)),ints) #indices of main effect terms in current best model coef list
  mains.full <- setdiff(c(1:length(all.coefs)), ints.full) #indices of main effect terms in full model coef list
  maxp <- max(c(0.01,model.seln[intersect(ints.full, which(model.seln$include==T)),"p.vals"])) #the largest p-value for interaction terms
  if(maxp > alfa) { #if the largest interaction p-value is larger than the significance threshold, then:
    #find the index (in the full model coef list) for the interaction term with the biggest p value
    j <- which(model.seln[ints.full,"p.vals"]==maxp) 
    #mark the least-significant variable for exclusion
    model.seln[ints.full[j],"include"] <- F 
    #and remove it from "best.model"
    j2 <- which(best.coefs[ints] == model.seln[ints.full[j], "coefs"])
    f<-paste(".~.-",best.coefs[ints[j2]],sep="")
    best.model <- update(best.model,as.formula(f))
  }else{ #if all the interactions are significant, then can check the main effects
    #goal: find the least-significant one with p>alfa.
    #j is the indices of the main-effect p-values, ordered biggest to smallest
    px <- sort(model.seln[model.seln$coefs %in% best.coefs,"p.vals"],decreasing=T, index.return=T)$ix
    p.sort <- model.seln[which(model.seln$coefs %in% best.coefs)[px], c("coefs", "p.vals")]
    #exclude all the ones that are part of significant interactions
    for (kk in 1:nrow(p.sort)) { #this loop will remove entries from j until the first one is no longer part of a significant interaction.
      sig.int <- grep(pattern=p.sort[kk,"coefs"], best.coefs[ints])
      if (length(sig.int) > 0) {
        p.sort[kk,] <- NA
      }
    }
    p.sort <- na.omit(p.sort)
    #now update the model by removing the main effect with the biggest p value (among non-significant ones)
    if (nrow(p.sort) == 0){
      break # if there are no mains that are not in significant interactions, we're done
    }else{#if there are main effects that are non-significant and also not in a significant interaction, remove the least significant one
      if (model.seln[model.seln$coefs==p.sort[1,"coefs"],"p.vals"] > alfa){
        model.seln[model.seln$coefs==p.sort[1,"coefs"],"include"] <- F 
        f<-paste(".~.-",p.sort[1,"coefs"],sep="")
        best.model <- update(best.model,as.formula(f))
      }else{break}
    }
  }
}
return(list(best.model=best.model, pvals=model.seln))
}