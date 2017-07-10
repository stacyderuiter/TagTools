#' Compute the mean of successive blocks of samples.
#' 
#' @param X A vector or a matrix containing samples of a signal in each column.
#' @param n The number of samples from X to use in each analysis block.
#' @param nov (optional) The number of samples that the next block overlaps the previous block. The default value is 0.
#' @return Y is a vector or matrix containing the mean value of each block. If X is a mxn matrix, Y is pxn where p is the number of complete n-length blocks with nov that can be made out of m samples, i.e., n+(p-1)*(n-nov) < m

mean_in_blocks <- function(X,n,nov) {
  if (missing(nov)) {
    nov <- 0
  }
  if (nrow(X) == 1) {
    X <- t(X)
  }
  nov <- min(n, nov) 
  ss <- buffer_nodelay(X[, 1], n, nov)
  Y <- matrix(0, ncol(ss), ncol(X))
  for (i in 1:ncol(ss)) {
    Y[i, 1] <- t(mean(ss[, i]))
  }
  for (k in 2:ncol(X)) {
    ss <- buffer_nodelay(X[, k], n, nov)
    for (j in 1:ncol(ss)) {
      Y[j, k] <- t(mean(ss[, j]))
    }
  }
  t <- t(round(n / 2 + (0:nrow(Y) - 1) * (n - nov)))
  return(Y)
}