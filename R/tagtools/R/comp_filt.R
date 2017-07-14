#' Complimentary filtering of a signal. This breaks signal X into two or more frequency bands such that the sum of the signals in the separate bands is equal to the original signal.
#' 
#' @param  X A sensor vector or matrix (i.e., with a signal in each column) or sensor list (e.g., from readtag.R).
#' @param fs The sampling rate of the sensor data in Hz (samples per second).
#' @param fc Specifies the cut-off frequency or frequencies of the complimentary filters. Frequencies are in Hz. If one frequency is given, X will be split into a low- and a high-frequency component. If fc contains more than one value, X will be split into multiple complimentary bands. Each filter length is 4*fs/fc. Filtering adds no group delay.
#' @return Xf A list of filtered signals. There are n+1 sections of the list where n is the length of fc. List sections are ordered in Xf from lowest to highest frequency. Each list section contains a vector or matrix of the same size as X, and at the same sampling rate as X.
#' @export

comp_filt <- function(X, fs, fc) {
  if (missing(fs)) {
    stop("At least two inputs are required")
  }
  if (is.list(X)) {
    fc <- fs ;
    fs <- X$fs ;
    X <- X$data ;
  } else {
    if (missing(fc)) {
      stop("inputs X, fs, and fc are all required if X is not a list")
    }
  }
  nf <-  4 * fs / fc 
  Xf <- vector('list', length(fc) + 1) 
  for (k in 1:length(fc)) {
    Xf[[k]] <- fir_no_delay(X, nf[k], fc[k] / (fs / 2))$y 
    X <- X - Xf[[k]]
  }
  Xf[[k + 1]] <- X 
  return(Xf);
}