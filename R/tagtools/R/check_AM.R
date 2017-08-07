#' Compute the field intensity and inclination
#' 
#' This function is used to compute the field intensity of acceleration and magnetometer data, and the inclination angle of the magnetic field. This is useful for checking the quality of a calibration, for detecting drift, and for validating the mapping of the sensor axes to the tag axes. 
#' 
#' Possible input combinations: check_AM(X) if X is a sensor list, check_AM(X, sampling_Rate) if X is a matrix, check_AM(A, M) if M and A are sensor lists, check_AM(A, M, sampling_rate) if M and A are matrices.
#' @param A An accelerometer sensor list or matrix with columns [ax, ay, az]. Acceleration can be in any consistent unit (e.g., g for m/s^2).
#' @param M is a magnetometer sensor list or matrix, M <- [mx, my, mz] in any consistent unit (e.g., uT or Gauss).
#' @param X can be either A or M data and is used if check_AM is called with only one type of data
#' @param sampling_rate The sampling rate of the sensor data in Hz (samples per second). This is only needed if A and M are not sensor lists and filtering is required.
#' @return A list with 2 elements:
#' \itemize{
#'  \item{\strong{fstr: }} The estimated field intensity of A and/or M in the same units as A and M. fstr is a vector or a two column matrix. If only one type of data is input, fstr will be a column vector. If both A and M are input, fstr will have two columns with the field strength of A in the 1st column and the field strength of M in the 2nd column. 
#'  \item{\strong{incl: }} The estimated field inclination angle (i.e., the angle with respect to the horizontal plane) in radians. incl is a column vector. By convention, a field vector pointing below the horizon has a positive inclination angle. This is only returned if the function is called with both A and M data.
#' }
#' @note The sampling rate of fstr and incl is the same as the input sampling rate.
#' @note This function automatically low-pass filters the data with a cut-off frequency of 5 Hz if the sampling rate is greater than 10 Hz.
#' @note Frame: This function assumes a [north,east,up] navigation frame and a [forward,right,up] local frame.
#' @examples 
#' \dontrun {
#' sm1 <- matrix(c(11:19), ncol = 3)
#' sm2 <- matrix(c(1:9), ncol = 3)
#' check_AM(sm2, sm1, sampling_rate = 1)
#' }
#' @export

check_AM <- function(A, M, sampling_rate) {
  fc <- 5
  if (nargs() <1) {
    stop("At least one input is required")
  }
  if (is.list(A)) {
    if (nargs() >= 2) {
      A <- A$data
      M <- M$data
      sampling_rate <- A$sampling_rate
    } else {
      A <- A$data
      M <- c()
      sampling_rate <- A$sampling_rate
    }
    if (is.null(A)) {
      stop("input data for A cannot be empty")
    }
  } else {
    if (nargs() < 2) {
      stop("sampling_rate is required if A or M data input is a matrix")
    }
    if (nargs() == 2) {
      if (pracma::numel(M) == 1) {
        sampling_rate <- M
        M <- c()
      } else {
        stop("Need to specify sampling frequency for matrix arguments")
      }
    }
  }
  #check for single vector inputs
  if (!is.null(M)) {
    if (ncol(M) == 3 | nrow(M) == 3) {
      if (nrow(M) * ncol(M) == 3) {
        M <- t(M)
      }
    } else {
      stop("M must be a 3 column matrix")
    }
  }
  if (ncol(A) == 3 | nrow(A) == 3) {
    if (nrow(A) * ncol(A) == 3) {
      A <- t(A)
    }
  } else {
    stop("A must be a 3 column matrix")
  }
  #check that sizes of A and M are compatible
  if (ncol(A) != ncol(M) & nrow(A) != nrow(M)) {
    n <- min(c(nrow(A), nrow(M)))
    A <- A[(1:n), ]
    M <- M[(1:n), ]
  }
  if (sampling_rate > 10) {
    nf <- round(4*sampling_rate/fc)
    if (nrow(A) > nf) {
      M <- fir_nodelay(M,nf,fc/(sampling_rate/2))
      A <- fir_nodelay(A,nf,fc/(sampling_rate/2))
    }
  }
  #compute mag field intensity and inclination
  fstr <- matrix(0, nrow(A), 2)
  fstr[, 1] <- sqrt(rowSums(A^2)) #compute field intensity of first input argument
  if (!is.null(M)) {
    fstr[, 2] <- sqrt(rowSums(M^2)) #compute field intensity of second input argument
  }
  if (fstr[1,2] == 0) {
    fstr <- fstr[, 1]
  }
  suppressWarnings(x <- asin(rowSums(A * M) / (fstr[, 1]*fstr[, 2])))
  signvector <- rowSums(A * M) / (fstr[, 1]*fstr[, 2])
  for(i in 1: length(x)){
    if(is.nan(x[i])){
      x[i]<-asin(1) * sign(signvector[i])
    }
  }
  incl <- -x
  return(list(fstr = fstr, incl = incl))
}