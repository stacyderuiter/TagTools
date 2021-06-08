#' Extract a sub-sample of data
#'
#' This function is used to extract a sub-sample of data from a vector or matrix.
#' @param x A vector or matrix of measurements. If x is a matrix, each column is treated as a separate measurement vector.
#' @param sampling_rate the sampling rate in Hz of the data in x.
#' @param tst Defines the start time in seconds of the interval to be extracted from x.
#' @param ted Defines the end time in seconds of the interval to be extracted from x.
#' @return A matrix containing a sub-sample of x. X has the same number of columns as x. The length of the sub-sample will be round(sampling_rate*(tend-tstart)) samples.
#' @note Output sampling rate is the same as the input sampling rate.
#' @note If either tst or ted are beyond the length of x, non-existing samples will be replaced with NaN in X.
#' @examples
#' BW <- beaked_whale
#' extract(x = BW$A$data, sampling_rate = BW$A$sampling_rate, tst = 3, ted = 100)
#' @export

extract <- function(x, sampling_rate, tst, ted) {
  if (missing(ted) | missing(x) | missing(sampling_rate) | missing(tst)) {
    stop("inputs for all arguments are required")
  }
  if (is.matrix(x) && nrow(x) == 1) {
    x <- t(x)
  }
  if (is.vector(x)) {
    x <- as.matrix(x)
  }
  npre <- NULL
  npst <- NULL
  kst <- round(sampling_rate * tst) + 1
  ked <- round(sampling_rate * ted)
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
    if (ncol(x) > 1) {
      X2 <- x[kst:ked, ]
    }
    else {
      X2 <- as.matrix(x[kst:ked])
    }
    if (!is.null(npre)) {
      X1 <- matrix(NaN, npre, ncol(x))
      X <- rbind(X1, X2)
    }
    if (!is.null(npst)) {
      X3 <- matrix(NaN, npst, ncol(x))
      if (!is.null(npre)) {
        X <- rbind(X, X3)
      }
      else {
        X <- rbind(X2, X3)
      }
    } else {
      X <- x[kst:ked, ]
    }
    return(X)
  }
}