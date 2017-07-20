#' Compute the RMS (root-mean-square) of successive blocks of samples.
#' 
#' @param X A vector or a matrix containing samples of a signal in each column.
#' @param n The number of samples from X to use in each analysis block.
#' @param nov The number of samples that the next block overlaps the previous block.
#' @return Y A vector or matrix containing the RMS value of each block. If X is a mxn matrix, Y is pxn where p is the number of complete n-length blocks with nov that can be made out of m samples, i.e., n+(p-1)*(n-nov) < m
#' @note Output sampling rate is the same as the input sampling rate so s and v have the same size as p.
#' @note Frame: This function assumes a [north,east,up] navigation frame and a [forward,right,up] local frame. In these frames, a positive pitch angle is an anti-clockwise rotation around the y-axis. A descending animal will have a negative pitch angle.
#' @export
#' @example 
#' X <- matrix(c(1:20), byrow = TRUE, nrow = 4)
#' block_rms(X, n = 2, nov = NULL)
#'  #Results: y <- matrix(c(4.30, 5.14, 6.04, 6.96, 7.90, 13.72, 14.71, 15.70, 16.68, 17.67), byrow = TRUE, nrow = 2)
#'            t <- c(1, 3)

block_rms <- function(X, n, nov = NULL) {
  # input checks-----------------------------------------------------------
  if (is.null(nov) == TRUE) {
    nov <- 0
  }
  nov <- pmin(n, nov)

  if(is.vector(X) & !is.list(X)){
    S <- abs(X^2)
    ss <- buffer_nodelay(S[], n, nov)
    Y <- rep(0, ncol(ss))
    Y[] <- colSums(ss)
    Y <- sqrt(Y / n)
    t <- round(n / 2 + (0:(length(Y)-1)) * (n - nov))
  }
  else{
    #catch the case of a row vector input
    if (nrow(X) == 1) {
      X <- t(X)
    }
    S <- abs(X^2)
    ss <- buffer_nodelay(S[,1], n, nov)
    Y <- matrix(0, nrow = ncol(ss), ncol = ncol(X))
    Y[, 1] <- colSums(ss)
    for (k in 2:ncol(X)) {
      ss <- buffer_nodelay(S[,k], n, nov)
      Y[, k] <- colSums(ss)
    }
    Y <- sqrt(Y / n)
    t <- round(n / 2 + (0:(nrow(Y)-1)) * (n - nov))
  }
 
  return(list(Y = Y, t = t))
}
