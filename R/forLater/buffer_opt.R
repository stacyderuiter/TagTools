buffer_opt <- function(x, n, p, opt){
  if(!(p < n)){
    stop("p must be less than n")
  }
  if(!(length(opt) == p)){
    stop("length of opt must equal p")
  }
  m = floor(length(x)/(n-p))
  tmat <- matrix(0, nrow = m, ncol = n)
  vecindex <- 1
  for(i in 1:m){
    if(i == 1){
      tmat[i,1:p] <- opt
      for(f in (p+1):n){
        tmat[i,f] = x[vecindex]
        vecindex <- vecindex + 1
      }
    }
    else{
      tmat[i,1:p] <- tmat[i-1,(-(n-p):0)]
      for(c in (p+1):n){
        tmat[i,c] <- x[vecindex]
        vecindex <- vecindex + 1
      }
    }
  }
  z = c()
  if(vecindex < length(x)+1){
    z = x[vecindex: length(x)]
  }
  opt <- tmat[m, (-(n-p):0)]
  X <- t(tmat)
  return(list(X = X, z = z, opt = opt))
}