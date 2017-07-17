#' Compute heading, field intensity and inclination angle by gimballingthe magnetic field measurement matrix with the pitch and roll estimated from the accelerometer matrix.
#'
#' @param M A matrix, M=[mx,my,mz] in any consistent unit (e.g., in uT or Gauss) or magnetometer sensor list (e.g., from readtag.R).
#' @param A A matrix with columns [ax ay az] or acceleration sensor list (e.g., from readtag.R). Acceleration can be in any consistent unit, e.g., g or m/s^2.
#' @param fs The sampling rate of the sensor data in Hz (samples per second). This is only needed if filtering is required.
#' @param fc (optional) The cut-off frequency of a low-pass filter to apply to A and M before computing heading. The filter cut-off frequency is with in Hertz. The filter length is 4*fs/fc. Filtering adds no group delay. If fc is not specified, no filtering is performed.
#' @return h The heading in radians in the same frame as M. The heading is with respect to magnetic north (i.e., the north vector of the navigation frame) and so must be corrected for declination. 
#' @return v The estimated magnetic field intensity in the same units as M. This is just the 2-norm of M after filtering (if specified).
#' @return incl The estimated field inclination angle (i.e., the angle with respect to the horizontal plane) in radians. By convention, a field vector pointing below the horizon has a positive inclination angle. See note in the function if using incl.
#' @note Output sampling rate is the same as the input sampling rate (i.e. h, v, and incl are estimated with the same sampling rate as M and A and so are each nx1 vectors).
#' @note Frame: This function assumes a [north,east,up] navigation frame and a [forward,right,up] local frame. North and east are magnetic, not true. In these frames a positive heading is a clockwise rotation around the z-axis. 
#' @note The heading is computed with respect to the frame of M and is the magnetic heading NOT the true heading. M and A must have the same sampling rate, frame, and number of rows.
#' @export
#' @example list(h = h, v = v, incl = incl) <- m2h(M = matrix(c(22, -24, 14), nrow = 1), 
#'                                                 A = matrix(c(-0.3, 0.52, 0.8), nrow = 1), fc = NULL)
#' #Returns: h=0.89486 radians, v=34.117, incl=0.20181 radians.

m2h <- function(M, A, fs, fc = NULL) {
  if (nargs() < 2) {
    stop("inputs for both M and A are required")
  }
  if (is.list(M) & is.list(A)) {
    if (nargs() > 2) {
      fc <- fs
    }
    fs <- M$fs
    M <- M$data
    A <- A$data
    if (A$fs != M$fs) {
      stop("A and M must be at the same sampling rate")
    }
  } else {
    if (nargs() == 2) {
      fc <- c()
    } else {
      if (nargs() == 3) {
        stop("Need to specify fs and fc if calling m2h with matrix inputs")
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
    nf <- round(4 * fs / fc)
    fc <- fc / (fs / 2)
    if (nrow(M) > nf) {
      M <- fir_nodelay(M, nf, fc)
      A <- fir_nodelay(A, nf, fc)
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
    