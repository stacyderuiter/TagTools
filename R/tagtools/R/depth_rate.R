#' Estimate the vertical velocity 
#' 
#' This function is used to estimate the vertical velocity by differentiating a depth or altitude time series. A low-pass filter reduces the sensor noise that is amplified by the differentiation.
#' 
#' @param p A vector or depth or altitude data, or an animaltags list object containing depth or altitude data.
#' @param fs (required only if p is a vector) is the sampling rate of p in Hz.
#' @param fc (optional) A smoothing filter cut-off frequency in Hz. If fc is not given, a default value is used of 0.2 Hz (5 second time constant).
#' @return v, The vertical velocity with the same sampling rate as p. v is a vector with the same dimensions as p. The unit of v depends on the unit of p. For example, if p is in meters, v is in meters/second
#' @note The low-pass filter is a symmetric FIR with length 4fs/fc. The group delay of the filters is removed.
#' @examples \dontrun{
#' v <- depth_rate(p = beaked_whale$P)
#' plott(list(beaked_whale$P$data, v), fs=beaked_whale$P$sampling_rate, 
#' r=c(1,0), panel_labels=c('Depth\n(m)', 'Vertical Velocity\n(m/s)')) 
#' #plot of dive profile and depth rate
#' }
#'@export

depth_rate <- function(p, fs, fc) {
  # input checking
  ##########################
  if (missing(p)) {
    stop("p (depth or altitude data) is a require input to depth_rate().")
  }
  
    if (is.list(p)) {
    p0 <- p
    fs <- p$sampling_rate
    p <- p$data
  }
  
  if(missing(fc)){
      fc <- 0.2
  }
  
  # set up filter
  ##############################
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