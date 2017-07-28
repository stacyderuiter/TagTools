#' Compute RMS of sample blocks
#' 
#' This function is used to compute the RMS (root-mean-square) of successive blocks of samples.
#' @param X A vector or a matrix containing samples of a signal in each column.
#' @param n The number of samples from X to use in each analysis block.
#' @param nov The number of samples that the next block overlaps the previous block.
#' @return A list with 2 elements:
#' \itemize{
#'  \item{\strong{Y: }} A vector or matrix containing the RMS value of each block. If X is a mxn matrix, Y is pxn where p is the number of complete n-length blocks with nov that can be made out of m samples, i.e., n+(p-1)*(n-nov) < m
#'  \item{\strong{t: }} The time at which each output in Y is reported, in units of samples of X.  So if t[1] = 12, then the value Y[1] corresponds to the “time” 12 samples in X. The times at which Y values are reported are the centers of the averaging windows.
#' }
#' @note Output sampling rate is the same as the input sampling rate so s and v have the same size as p.
#' @note Frame: This function assumes a [north,east,up] navigation frame and a [forward,right,up] local frame. In these frames, a positive pitch angle is an anti-clockwise rotation around the y-axis. A descending animal will have a negative pitch angle.
#' @export
#' @example 
#' X <- matrix(c(1:20), byrow = TRUE, nrow = 4)
#' block_rms(X, n = 2, nov = NULL)

block_rms <- function(X, n, nov = NULL) {
  # input checks-----------------------------------------------------------
  if (is.null(nov) == TRUE) {
    nov <- 0
  }
  nov <- pmin(n, nov)

  if(is.vector(X) & !is.list(X)){
    S <- abs(X^2)
    ss <- buffer(S[], n, nov, nodelay = TRUE)
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
    ss <- buffer(S[,1], n, nov, nodelay = TRUE)
    Y <- matrix(0, nrow = ncol(ss), ncol = ncol(X))
    Y[, 1] <- colSums(ss)
    for (k in 2:ncol(X)) {
      ss <- buffer(S[,k], n, nov, nodelay = TRUE)
      Y[, k] <- colSums(ss)
    }
    Y <- sqrt(Y / n)
    t <- round(n / 2 + (0:(nrow(Y)-1)) * (n - nov))
  }
 
  return(list(Y = Y, t = t))
}
