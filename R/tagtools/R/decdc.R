#' Reduce the sampling rate of a time series by an integer factor.
#' 
#' @param x A vector or matrix containing the signal(s) to be decimated. If x is a matrix, each column is decimated separately.
#' @param df The decimation factor. The output sampling rate is the input sampling rate divided by df. df must be an integer greater than 1.
#' @return y The decimated signal vector or matrix. It has the same number of columns as x but has 1/df of the rows.
#' @note Decimation is performed by first low-pass filtering x and then keeping 1 sample out of every df. A symmetric FIR filter with length 12*df and cutoff frequency 0.4*fs/df is used. The group delay of the filter is removed. For large decimation factors (e.g., df>>50), it is better to perform several decimations with lower factors. For example to decimate by 120, use: decdc(decdc(x,10),12).
#' @export
#' @examples 
#' s <- matrix(sin(2 * pi / 100 * c(0:1000) - 1), ncol = 1) 
#' ds <- decdc(x = s, df = 4)   
#' #Returns: 0.0023

decdc <- function(x,df) {
  if (missing(df)) {
    stop("df is a required input")
  }
  if (nrow(x) < 2) {
    warning("make sure that you have input your data as a column vector or a matrix")
  }
  if (round(df) != df) {
    df <- round(df)
    warning("decdc needs integer decimation factor")
  }
  flen <- 12 * df
  h <- as.vector(signal::fir1(flen, 0.8 / df))
  xlen <- nrow(x)
  #ensures that the output samples coincide with every df of the input samples
  dc <- flen + floor(flen / 2) - round(df / 2) + seq(df, xlen, df)
  y <- matrix(0, nrow = length(dc),ncol = ncol(x))
  for (k in 1:ncol(x)) {
    abc <- (2 * x[1, k]) - x[1 + (seq((flen + 1), 1, -1)), k]
    bcd <- x[, k]
    cde <- (2 * x[xlen, k]) - (x[xlen - c(1:(flen + 1),k)])
    xx <- c(abc, bcd, cde)
    v <- pracma::conv(h,xx)
    y[,k] <- v[dc]
  }
  return(y)
}