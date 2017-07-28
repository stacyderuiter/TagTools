#' Compute mean of sample blocks
#' 
#' This function is used to compute the means of successive blocks of samples.
#' @param X A vector or a matrix containing samples of a signal in each column.
#' @param n The number of samples from X to use in each analysis block.
#' @param nov (optional) The number of samples that the next block overlaps the previous block. The default value is 0.
#' @return A list with 2 elements:
#' \itemize{
#'  \item{\strong{Y: }} A vector or matrix containing the mean value of each block. If X is a mxn matrix, Y is pxn where p is the number of complete n-length blocks with nov that can be made out of m samples, i.e., n+(p-1)*(n-nov) < m
#'  \item{\strong{t: }} The time at which each output in Y is reported, in units of samples of X.  So if t[1] = 12, then the value Y[1] corresponds to the “time” 12 samples in X.
#' }
#' @return 
#' @export
#' @example samplematrix <- matrix(c(1,3,5,7,9,11,13,15,17), byrow = TRUE, ncol = 3)
#'          list <- block_mean(samplematrix, n = 3, nov = 1)
#'          list$Y = c(7, 9, 11)
#'          list$t = 2

block_mean <- function(X,n,nov) {
  if (missing(nov)) {
    nov <- 0
  }
  nov <- min(n, nov) 
  if(is.vector(X) & !is.list(X)){
    ss <- buffer(X[], n, nov, nodelay = TRUE)
    Y <- rep(0, ncol(ss))
    for (i in 1:ncol(ss)) {
      Y[i] <- t(mean(ss[, i]))
    }
    t <- as.matrix(round(n / 2 + (0:(length(Y) - 1)) * (n - nov)))
  }
  else{
    if (nrow(X) == 1) {
      X <- t(X)
    }

    ss <- buffer(X[, 1], n, nov, nodelay = TRUE)
    Y <- matrix(0, ncol(ss), ncol(X))
    for (i in 1:ncol(ss)) {
      Y[i, 1] <- t(mean(ss[, i]))
    }
    for (k in 2:ncol(X)) {
      ss <- buffer(X[, k], n, nov, nodelay = TRUE)
      for (j in 1:ncol(ss)) {
        Y[j, k] <- t(mean(ss[, j]))
      }
    }
    t <- as.matrix(round(n / 2 + (0:(nrow(Y) - 1)) * (n - nov)))
  }

  return(list(Y= Y, t = t))
}