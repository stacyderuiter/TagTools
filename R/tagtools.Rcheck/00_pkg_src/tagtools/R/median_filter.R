#' Computes the nth-order median filter
#' 
#' This function computes the nth-order median filter each column of X. The filter output is the median of each consecutive group of n samples. This is useful for removing occasional outliers in data that is otherwise fairly smooth. This makes it appropriate for pressure, temperature and magnetometer data (amongst other sensors) but not so suitable for acceleration which can be highly dynamic. The filter does not introduce delay. The start and end values, i.e., within n samples of the start or end of the input data, are computed with decreasing order median filters unless noend=TRUE. If noend=TRUE, start and end values are taken directly from X without short median filters.
#' @param X A sensor list or a vector or matrix. If there are multiple columns in the data, each column is treated as a separate signal to be filtered.
#' @param n The filter length. If an even n is given, it is automatically incremented to make it odd. This ensures that the median is well-defined (the median of an even length vector is usually defined as the mean of the middle two points but may differ in different programmes). Note that a short n (e.g., 3 or 5) is usually sufficient and that processing will be very slow if n is large.
#' @param noend If TRUE (the default), then start and end values are taken directly from X without short median filters.
#' @return The output of the filter. It has the same size as S and has the same sampling rate and units as X. If X is a sensor list, the return will also be.
#' @examples 
#' v <- matrix(c(1, 3, 4, 4, 20, -10, 5, 6, 6, 7), ncol = 1)
#' w <- median_filter(v, n=3)
#' #Returns : c(1, 3, 4, 4, 4, 5, 5, 6, 6, 7)
#' @export

median_filter <- function(X, n, noend=TRUE) {

  if (is.list(X)) {
    x <- X$data
    if (!is.matrix(x)){x <- matrix(x, ncol=1)}
  }else{
    x <- X
  }
  if (is.matrix(x)){
    if (nrow(x) == 1) {
    x <- t(x)
    }
  }
  
  nd2 <- floor(n/2)
  if ((2 * nd2) == n) {
    n <- n + 1
  }
  Y <- matrix(NA, nrow=nrow(x), ncol=ncol(x))
  if ( noend ) {
    Y[(1:nd2), ] <- x[(1:nd2), ]
    Y[(nrow(Y) + ((-nd2 + 1):0)), ] <- x[(nrow(x) + ((-nd2 + 1):0)), ]
  } else {
    for (k in 1:nd2) {
      Y[k, ] <- stats::median(x[(1:(k + nd2)), ], na.rm = TRUE)
    }
    for (k in 1:nd2) {
      Y[(nrow(Y) - nd2 + k), ] <- stats::median(x[((nrow(x) - 2) * nd2 + k), ], na.rm = TRUE)
    }
  }
  for (k in 1:ncol(x)) {
    Z <- buffer(x, n, (n-1), nodelay = TRUE)
    Y[(nd2 + 1):(nrow(Y) - nd2), k] <- apply(Z,MARGIN=2,FUN=stats::median, na.rm=TRUE)
  }
  if (is.list(X)) {
    X$data <- Y
    h <- sprintf("median_filter(%d)", n)
    if (("history" %in% names(X) == FALSE) | is.null(X$history)) {
      X$history <- h
    } else {
      X$history <- c(X$history, ",", h)
    }
    Y <- X   
  }
  return(Y)
}