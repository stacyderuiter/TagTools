#' Reduce the sampling rate of a time series by an integer factor. This is similar to decimate() and resample() but is delay freeand DC accurate which are important for sensor data. 
#' 
#' @param x A vector or matrix containing the signal(s) to be decimated. If x is a matrix, each column is decimated separately.
#' @param df The decimation factor. The output sampling rate is the input sampling rate divided by df. df must be an integer greater than 1.
#' @return y The decimated signal vector or matrix. It has the same number of columns as x but has 1/df of the rows.
#' Decimation is performed by first low-pass filtering x and then keeping 1 sample out of every df. A symmetric FIR filter with length 12*df and cutoff frequency 0.4*fs/df is used. The group delay of the filter is removed. For large decimation factors (e.g., df>>20), it is better to perform several decimations with lower factors. For example to decimate by 120, use: decdc(decdc(x,10),12).
#' @examples 
#' s <- sin(2 * pi / 100 * t(c(0:1000) - 1))   #sine wave at full sampling rate
#' s4 <- sin(2 * pi * 4 / 100 * t(c(0:250)-1))   #same sine wave at 1/4 of the sampling rate
#' ds <- decdc(s, 4)   #decimate the full rate sine wave
#' max(abs(s4 - ds))   #i.e, there is almost no difference between s4 and ds.
#' Returns: 0.0023

decdc <- function(x,df) {
  if (missing(df)) {
    help("decdc")
  }
  flen <- 12 * df
  require(signal) #for the fir1() and conv() functions
  h <- t(fir1(flen, 0.8 / df))
  xlen <- colSums(x)
  #ensures that the output samples coincide with every df of the input samples
  dc <- flen + floor(flen / 2) - round(df / 2) + (df:df:xlen)
  require(matlab) #for zeros() function
  y <- matlab::zeros(length(dc),rowSums(x))
  for (k in 1:rowSums(x)) {
    xx <-matrix(c(2 * x[1, k] - x[1 + (flen + 1:-1:1), k], x[, k], 2 * x[xlen, k] - x[xlen - (1:flen + 1), k]), ncol = 3, nrow = nrow(x), byrow = TRUE)
    v <- conv(h,xx)
    y[,k] <- v(dc)
  }
}
