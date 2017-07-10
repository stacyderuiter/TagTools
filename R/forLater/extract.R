#' Extract a sub-sample of data from a vector or matrix.
#' 
#' @param x A vector or matrix of measurements. If x is a matrix, each column is treated as a separate measurement vector.
#' @param fs the sampling rate in Hz of the data in x.
#' @param tst Defines the start time in seconds of the interval to be extracted from x.
#' @param ted Defines the end time in seconds of the interval to be extracted from x.
#' @return X A matrix containing a sub-sample of x. X has the same number of columns as x. The length of the sub-sample will be round(fs*(tend-tstart)) samples.
#' @note Output sampling rate is the same as the input sampling rate.
#' @note If either tst or ted are beyond the length of x, non-existing samples will be replaced with NaN in X.

extract <- function(x, fs, tst, ted) {
  X <- vector(mode="numeric", length=0)
  if (missing(ted)) {
    stop("inputs for all arguments are required")
  }
  if (nrow(x) == 1) {
    x <- t(x)
  }
  npre <- NULL
  npst <- NULL
  kst <- round(fs * tst) + 1
  ked <- round(fs * ted)
  if (kst > nrow(x)) {
    return(X)
  } else {
    if (kst < 0) {
      npre <- -kst
      kst <- 1
    }
    if (ked > nrow(x)) {
      npst <- ked - nrow(x)
      ked <- nrow(x)
    }
    if (!is.null(npre)) {
      X1 <- matrix(NaN, npre, ncol(x))
      X2 <- x[kst:ked, ]
      X3 <- matrix(NaN, npre, ncol(x))
      X <- rbind(X1, X2, X3)
    } else {
      X <- x[kst:ked, ]
    }
    return(X)
  }
}