#' Estimate the vertical velocity 
#' 
#' This function is used to estimate the vertical velocity by differentiating a depth or altitude time series. A low-pass filter reduces the sensor noise that is amplified by the differentiation.
#' 
#' Possible input combinations: depth_rate(p) if p is a list, depth_rate(p,fc = fc) if p is a list, depth_rate(p,fs) if p is a vector, depth_rate(p,fs,fc) if p is a vector.
#' @param p A depth or altitude time series or a list of depth or altitude (e.g., from readtag.R). p can have any units and is in the form of a vector
#' @param fs is the sampling rate of p in Hz.
#' @param fc (optional) A smoothing filter cut-off frequency in Hz. If fc is not given, a default value is used of 0.2 Hz (5 second time constant).
#' @return The vertical velocity with the same sampling rate as p. v has the same dimensions as p. The unit of v depends on the unit of p. If p is in meters, v is in meters/second
#' @note The low-pass filter is a symmetric FIR with length 4fs/fc. The group delay of the filters is removed.
#' @export

depth_rate <- function(p, fs, fc) {
  if (missing(p)) {
    stop("input for p is required")
  }
  if (is.list(p)) {
    if (nargs() > 1) {
      fc <- fs 
    } else {
      fc <- c()
    }
    fs <- p$fs
    p <- p$data
  } else {
    if(missing(fc)){
      fc <- 0.2
    }
  }
  nf <- round(4 * fs / fc)
  #use central differences to avoid a half sample delay
  x1 <- p[2] - p[1]
  x2 <- (p[3:length(p)] - p[1:(length(p) - 2)]) / 2
  x3 <- p[length(p)] - p[length(p) - 1]
  X <- c(x1, x2, x3)
  diffp <- X * fs
  #low pass filter to reduce sensor noise
  v <- fir_nodelay(diffp, nf, fc / (fs / 2))$y
  return(v)
}