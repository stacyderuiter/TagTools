#' Complimentary filtering of a signal. 
#' 
#' This function breaks signal X into two or more frequency bands such that the sum of the signals in the separate bands is equal to the original signal.
#' 
#' Possible input combinations: comp_filt(X,sampling_rate,fc) if X is a vector or matrix, comp_filt(X,fc = fc) if X is a list
#' @param  X A sensor vector or matrix (i.e., with a signal in each column) or sensor list (e.g., from readtag.R).
#' @param sampling_rate The sampling rate of the sensor data in Hz (samples per second).
#' @param fc Specifies the cut-off frequency or frequencies of the complimentary filters. Frequencies are in Hz. If one frequency is given, X will be split into a low- and a high-frequency component. If fc contains more than one value, X will be split into multiple complimentary bands. Each filter length is 4*sampling_rate/fc. Filtering adds no group delay.
#' @return A list of filtered signals. There are n+1 sections of the list where n is the length of fc. List sections are ordered in Xf from lowest to highest frequency. Each list section contains a vector or matrix of the same size as X, and at the same sampling rate as X.
#' @export

comp_filt <- function(X, sampling_rate=NULL, fc) {
  if (is.list(X)) {
    sampling_rate <- X$sampling_rate ;
    X <- X$data ;
  } else {
    if (missing(fc) | is.null(sampling_rate)) {
      stop("inputs X, sampling_rate, and fc are all required if X is not a list")
    }
  }
  nf <-  4 * sampling_rate / fc 
  Xf <- vector('list', length(fc) + 1) 
  for (k in 1:length(fc)) {
    Xf[[k]] <- fir_nodelay(X, nf[k], fc[k] / (sampling_rate / 2))$y 
    X <- X - Xf[[k]]
  }
  Xf[[k + 1]] <- X
  names(Xf) <- c('lowpass', 'highpass')
  return(Xf);
}