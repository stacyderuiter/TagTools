#' Buffers a signal vector into matrix 
#' 
#' This function is used to buffer a signal vector into a matrix of data frames. If the input for nodelay is TRUE, the the signal is buffered with no delay. If nodelay is FALSE, and specifies a vector of samples to precede x[1] in an overlapping buffer.
#' @param x The signal vector to be buffered
#' @param n The desired length of data segments (rows).
#' @param p The desired amount of overlap between consecutive frames (columns) in the output matrix
#' @param opt The vector of samples specified to precede x[1] in an overlapping buffer
#' @param nodelay A logical statement to determine if the vector should be buffered with or without delay. Default is FALSE (with delay)
#' @return A list with 2 elements:
#' \itemize{
#' \item{\strong{X: }} A matrix of the buffered signal vector "vec" with "n" data segments and an overlap between consecutive frames specified by "p". The matrix starts with "opt" values if nodelay is FALSE.
#' \item{\strong{z: }} (if nodelay = FALSE) The remainder of the vector which was not included in the matrix if the last column did not have a full number of rows.
#' }
#' @return opt (nodelay = FALSE) The last values, length of "p", of the matrix "X".
#' @export

buffer <- function(x, n, p, opt, nodelay = FALSE) {
  if(missing(x)|| missing(n) || missing(p)){
    stop("x, p or n is a required value")
  }
  if (!(p < n)){
    stop("p must be less than n")
  }
  if(!nodelay){
    if(!missing(opt)){
      if (length(opt) != p) {
        stop("length of opt must equal p")
      }
    }
    else{
      opt <- rep(0, p)
    }
    m <- floor(length(x) / (n - p))
    tmat <- matrix(0, nrow = m, ncol = n)
    vecindex <- 1
    for (i in 1:m) {
      if (i == 1) {
        tmat[i, 1:p] <- opt
        for (f in (p + 1):n) {
          tmat[i, f] = x[vecindex]
          vecindex <- vecindex + 1
        }
      } else {
        tmat[i, 1:p] <- tmat[i - 1, (-(n - p):0)]
        for (c in (p + 1):n) {
          tmat[i, c] <- x[vecindex]
          vecindex <- vecindex + 1
        }
      }
    }
    z <- c()
    if (vecindex < length(x) + 1) {
      z <- x[vecindex:length(x)]
    }
    ret_opt <- tmat[m, (-(n - p):0)]
    X <- t(tmat)
    return(list(X = X, z = z, opt = ret_opt))
  }
  else{
    X <- buffer_nodelay(x, n, p)
    return(X)
  }
}
buffer_nodelay <- function(vec, n, p){
  m <- floor((length(vec) - n)/(n - p)) + 1
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