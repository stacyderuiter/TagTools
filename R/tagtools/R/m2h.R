#' Compute heading, field intensity, and inclination angle 
#' 
#' This function is used to compute the heading, field intensity, and the inclination angle by gimballing the magnetic field measurement matrix with the pitch and roll estimated from the accelerometer matrix.
#' 
#' Possible input combinations: m2h(M,A) if A and M are lists or matrices, m2h(M,A,fc = fc) if A and M are lists, m2h(M,A,sampling_rate,fc) if A and M are matrices.
#' @param M A matrix, M=[mx,my,mz] in any consistent unit (e.g., in uT or Gauss) or magnetometer sensor list (e.g., from readtag.R).
#' @param A A matrix with columns [ax ay az] or acceleration sensor list (e.g., from readtag.R). Acceleration can be in any consistent unit, e.g., g or m/s^2.
#' @param sampling_rate The sampling rate of the sensor data in Hz (samples per second). This is only needed if filtering is required.
#' @param fc (optional) The cut-off frequency of a low-pass filter to apply to A and M before computing heading. The filter cut-off frequency is with in Hertz. The filter length is 4*sampling_rate/fc. Filtering adds no group delay. If fc is not specified, no filtering is performed.
#' @return A list with 3 elements:
#' \itemize{
#' \item{\strong{h: }} The heading in radians in the same frame as M. The heading is with respect to magnetic north (i.e., the north vector of the navigation frame) and so must be corrected for declination. 
#' \item{\strong{v: }} The estimated magnetic field intensity in the same units as M. This is computed by taking the 2-norm of M, after filtering (if any filtering was specified).
#' \item{\strong{incl: }} The estimated magnetic field inclination angle (i.e., the angle with respect to the horizontal plane) in radians. By convention, a field vector pointing below the horizon has a positive inclination angle. See note in the function if using incl.
#' }
#' @note Output sampling rate is the same as the input sampling rate (i.e. h, v, and incl are estimated with the same sampling rate as M and A and so are each nx1 vectors).
#' @note Frame: This function assumes a [north,east,up] navigation frame and a [forward,right,up] local frame. North and east are magnetic, not true. In these frames a positive heading is a clockwise rotation around the z-axis. 
#' @note The heading is computed with respect to the frame of M and is the magnetic heading NOT the true heading. M and A must have the same sampling rate, frame, and number of rows.
#' @seealso \code{\link{a2pr}}
#' @export
#' @example list(h = h, v = v, incl = incl) <- m2h(M = matrix(c(22, -24, 14), nrow = 1), 
#'                                                 A = matrix(c(-0.3, 0.52, 0.8), nrow = 1), fc = NULL)
#' #Returns: h=0.89486 radians, v=34.117, incl=0.20181 radians.

m2h <- function(M, A, sampling_rate=NULL, fc = NULL) {
  if (is.list(M) & is.list(A)) {
    sampling_rate <- M$sampling_rate
    M <- M$data
    A <- A$data
    if (A$sampling_rate != M$sampling_rate) {
      stop("A and M must be at the same sampling rate")
    }
  } else {
    if (is.null(fc) | is.null(sampling_rate)) {
    stop("Need to specify sampling_rate and fc if calling m2h with matrix inputs")
      }
    }
  }
  if (nrow(M) * ncol(M) == 3) {
    M <- t(M)
  }
  if (nrow(A) * ncol(A) == 3) {
    A <- t(A)
  }
  if (nrow(A) != nrow(M)) {
    stop("A and M must have the same number of rows/n")
  }
  if (!is.null(fc)) {
    nf <- round(4 * sampling_rate / fc)
    fc <- fc / (sampling_rate / 2)
    if (nrow(M) > nf) {
      M <- fir_nodelay(M, nf, fc)$y
      A <- fir_nodelay(A, nf, fc)$y
    }
  }
  #get the pitch and roll from A
  listpr <- a2pr(A)
  p <- listpr$p
  r <-listpr$r
  cp <- cos(p)
  sp <- sin(p)
  cr <- cos(r)
  sr <- sin(r)
  Tx <- c(cp, (-sr * sp), (-cr * sp))
  Ty <- c(rep(0, length(cp)), cr, -sr)
  Tz <- c(sp, (sr * cp), (cr * cp))
  Mh <- cbind(rowSums(M * Tx), rowSums(M * Ty), rowSums(M * Tz))
  #heading estimate in FRU system
  h  <- atan2(-Mh[, 2], Mh[, 1])
  #compute mag field intensity and inclination
  v <- sqrt(rowSums(M^2))
  #compute inclination
  suppressWarnings(x <- asin(Mh[, 3] / v))
  signvector <- Mh[, 3] / v
  for(i in 1: length(x)){
    if(is.nan(x[i])){
      x[i]<-asin(1) * sign(signvector[i])
    }
  }
  incl <- -x
  #Mh[, ] is (sp * Mx + srcp * My + crcp * Mz) which is A.M if there is no specific acceleration. So the inclination angle computed here is the same as the angle computed directly from A and M by the function inclination.R if there is no specific acceleration. If there is specific acceleration, both methods produce inclination angle estimates with errors and the errors are different because of the different computational methods.
  return(list(h = h, v = v, incl = incl))
}
    