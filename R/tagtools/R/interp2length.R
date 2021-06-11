#' Interpolate regularly sampled data to increase its sampling rate and match its length to another variable.
#' 
#' This function is used to reduce the time span of data by cropping out any data that falls before and after two time cues.
#' 
#' @param X A sensor list, vector, or matrix. If x is or contains  matrix, each column is treated as an independent signal.
#' @param Z is a sensor structure, vector or matrix whose sampling rate and length is to be matched.
#' @param fs_in is the sampling rate in Hz of the data in X. This is only needed if X is not a sensor structure.
#' @param fs_out is the required new sampling rate in Hz. This is only needed if Z is not given. 
#' @param n_out is an optional length for the output data. If n_out is not given, the output data length will be the input data length * fs_out/fs_in.
#' @return Y is a sensor structure, vector or matrix of interpolated data with the same number of columns as X.
#' @examples 
#'          plott(X = list(harbor_seal$P), fsx = 5) 
#'          # get an idea of what the data looks like
#'          P_dec <- decdc(harbor_seal$P, 5)
#'          
#'          # note: you would not really want to decimate and then linearly interpolate. 
#'          # only doing so here to create an example from existing datasets 
#'          # that have uniform sampling rates across sensors
#'          
#'          P_interp <- interp2length(X = P_dec, Z = harbor_seal$A)
#'          plott(X = list(P_interp$data), fsx = 1) 
#'          # compare to original plot. should be pretty close 
#' @export

interp2length <- function(X, Z, fs_in = NULL, fs_out = NULL, n_out = NULL) {
  # INPUT CHECKING ----------------------------
  if (missing(X) | missing(Z)) {
    stop("Inputs X and Z are required for interp2length().")
  }
  if (is.list(X)) {
    x <- X$data
    fs_in <- X$sampling_rate
  } else {
    if (missing(fs_in)){
      stop('Input fs_in is required if X is not a sensor data list.')
    }
    x <- X
  }
  
  if (!is.matrix(x)) {
    x <- matrix(x, ncol = 1)
  }
  if (nrow(x) == 1) {
    x <- t(x)
  }
  
  if (is.list(Z)) {
    z <- Z$data
    fs_out <- Z$sampling_rate
  } else {
    if (missing(fs_out)){
      stop('input fs_out is required if Z is not a sensor data list.')
    }
    z <- Z
  }
  
  if (!is.matrix(z)) {
    z <- matrix(z, ncol = 1)
  }
  if (nrow(z) == 1) {
    z <- t(z)
  }
  
  if (is.null(n_out)){
    n_out <- nrow(z)
  }
  
  # DO INTERPOLATION ---------------------------------
  
  if (fs_in == fs_out) {
    # if sampling rates are the same, no need to interpolate,
    # just make sure the length is right
    y <- check_size(x, n_out)
  } else {
    # if sampling rates are different
    y <- matrix(0, nrow = nrow(z), ncol = ncol(x))
    for (c in 1:ncol(x)) {
      y[ , c] <- approx(x = c(0:(nrow(x)-1)) / fs_in, 
                y = x[, c], 
                xout = c(0:(nrow(z)-1)) / fs_out,
                rule = 2 # return value at the closest data extreme when extrapolating (should be only a few samples)
                )$y
    }
    y <- check_size(y, n_out)
  }
  
# FORMAT OUTPUT (TO SENSOR LIST IF NEEDED) ----------
  
  if (is.list(X)) {
    Y <- X
    Y$data <- y
    Y$sampling_rate <- fs_out
    Y$history <- paste(Y$history, ' interp2length from', fs_in, 'Hz to ', fs_out, 'Hz')
  } else {
    Y = y
  }
  
  return(Y)
}

check_size <- function(y, n_out) {
  if (nrow(y) < n_out) {
    warning(paste('Data size mismatch: data is shorter than expected by ', n_out - nrow(y), ' rows.'))
    y <- rbind(y,
               matrix(data = y[nrow(y),],
                      nrow = n_out - nrow(y),
                      byrow = TRUE))
  }
  if (nrow(y) > n_out) {
    warning(paste('Data size mismatch: data is longer than expected by ', n_out - nrow(y), ' rows.'))
    y <- y[1:n_out,]
  }
  return(y)
}