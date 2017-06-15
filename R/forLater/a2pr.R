#' Estimate pitch and roll from triaxial accelerometer data.
#' 
#' Pitch and roll estimation from triaxial accelerometer data. This is a non-iterative estimator with |pitch| constrained to <= 90 degrees. The pitch and roll estimates give the least-square-norm error between A and the A-vector that would be measured at the estimated pitch and roll. If A is in the animal frame, the resulting pitch and roll define the orientation of the animal with respect to its navigation frame. If A is in the tag frame, the pitch and roll will define the tag orientation with respect to its navigation frame.
#' @param A An nx3 acceleration matrix with columns [ax ay az]. Acceleration can be in any consistent unit, e.g., g or m/s^2. 
#' @param fc (optional) The cut-off frequency of a low-pass filter to apply to A before computing pitch and roll. The filter cut-off frequency is with respect to 1=Nyquist frequency. The filter length is 8/fc. Filtering adds no group delay. If fc is not specified, no filtering is performed.
#' @return p The pitch estimate in radians
#' @return r The roll estimate in radians
#' @return v The 2-norm of the acceleration measurements in the same units as A
#' Output sampling rate is the same as the input sampling rate.
#' Frame: This function assumes a [north,east,up] navigation frame and a [forward,right,up] local frame. In these frames, a positive pitch angle is an anti-clockwise rotation around the y-axis. A positive roll angle is a clockwise rotation around the x-axis. A descending animal will have a negative pitch angle while an animal rolled with its right side up will have a positive roll angle.
#' @examples 
#' samplematrix <- matrix(c(0.77, -0.6, -0.22, 0.45, -0.32, 0.99, 0.2, -0.56, 0.5), byrow = TRUE, nrow = 3)
#' list <- a2pr(samplematrix)
#' returns: list$p=c(0.8780579, 0.4082165, 0.2603593), 
#'          list$r=c(-1.9222411, -0.3126323, -0.8419416), 
#'          list$v=c(1.000650, 1.133578, 0.776917)

a2pr <- function(A, fc = NULL) {
  # input checks-----------------------------------------------------------
  if (missing(A)) {
    help("a2pr")
  }
  # catch the case of a single acceleration vector
  if (min(c(nrow(A), ncol(A))) == 1) {
    A <- t(A)
  }
  if (!is.null(fc)) {
    A = fir_nodelay(A, round(8 / fc), fc)
  }
  v = sqrt(rowSums(A^2))
  # compute pitch and roll
  p = asin(A[, 1] / v)
  r = Re(atan2(A[, 2], A[, 3]))
  return(list(p = p, r = r, v = v))
}
