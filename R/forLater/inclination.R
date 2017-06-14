#' Estimate the local magnetic field vector inclination angle directly from acceleration and magnetic field measurements.
#' 
#' @param A The accelerometer signal matrix, A=[ax,ay,az] in any consistent unit (e.g., in g or m/s2). A can be in any frame.
#' @param M The magnetometer signal matrix, M=[mx,my,mz] in any consistent unit (e.g., in uT or Gauss). M must be in the same frame as A.
#' @param fc (optional) The cut-off frequency of a low-pass filter to apply to A and M before computing the inclination angle. The filter cut-off frequency is with respect to 1=Nyquist frequency. Filtering adds no group delay. If fc is not specified, no filtering is performed.
#' @return incl  The magnetic field inclination angle in radians.
#' @note Output sampling rate is the same as the input sampling rate.
#' @note Frame: This function assumes a [north,east,up] navigation frame and a [forward,right,up] local frame. In these frames, the magnetic field vector has a positive inclination angle when it points below the horizon. Other frames can be used as long as A and M are in the same frame however the interpretation of incl will differ accordingly.
#' @example 
#' A <- c(0.77, -0.6, -0.22)
#' M <- c(22, -22, 14)
#' incl <- inclination(A, M)
#' #Results: incl = -0.91595 radians.

inclination <- function(A, M, fc = NULL) {
  if (missing(M)) {
    warning("matrices for both A and M must be defined")
  }
  #catch the case of a single acceleration vector
  if (min(c(nrow(A), ncol(A))) == 1) {
    A <- t(A)
  }
  #catch the case of a single magnetometer vector
  if (min(c(nrow(M), ncol(M))) == 1) {
    M <- t(M)
  }
  if (nrow(M) != nrow(A)) {
    warning("A and M must have the same number of rows\n")
    incl <- vector(mode = "numeric", length = 0)
  }
  if (is.null(fc) == FALSE) {
    A <- fir_nodelay(A, round(8 / fc), fc)
    M <- fir_nodelay(M, round(8 /fc), fc)
  }
  #compute magnetic field intensity
  v <- sqrt(rowSums(M^2))
  incl <- -Re(asin(rowSums(A * M) / v))
  return(incl)
}
