get_baseline <- function(dataframe){
  #get baseline values for model predictions from a data frame.
  # for factors, take the most common level
  # for continuous variables, take the median (could add other options like mean...)
  vals <- dataframe[1,]
  for (c in 1:ncol(dataframe)){
    if (is.factor(dataframe[,c])){
      #for factors, take the most commonly observed level
      tt <- table(vals[,c])
      vals[1,c] <- names(which.max(tt)) #as.factor(levels(dataframe[,c])[1]) #for factors, get the base level
      #levels(vals[,c]) <- levels(dataframe[,c])
    }else{
      #for continuous take the data median
      vals[1,c] <- median(dataframe[,c], na.rm=T)
    }
  }
  return(vals)
}