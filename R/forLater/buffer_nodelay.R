buffer_nodelay <- function(vec,n,p){
  m <- abs(floor((length(vec) - n)/(n - p)) + 1)
  buffermatrix <-function(vec, m, n, p){
  retmat <- matrix(0, nrow = m, ncol = n)
  vecindex <- 1
  for(i in 1:m){
    if(i == 1){
    for(f in 1:n){
         retmat[i,f] <- vec[vecindex]
        vecindex <- vecindex + 1
      }
    }
    else{
      vecindex <- vecindex - p
      for(c in 1:n){
        retmat[i,c] <- vec[vecindex]
        vecindex <- vecindex + 1
      }
      }
  }
  return(retmat)
  }
  realretmat <- matrix(0, nrow = n, ncol = m)
  realretmat <- t(buffermatrix(vec, m,n,p))
  return(realretmat)
}