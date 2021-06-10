#' Identify invariant axis in triaxial movement measurements.
#' 
#' This function processes tri-axial movement data (for example, from an accelerometer, magentometer or gyroscope) to identify the one axis that varies the least, i.e., the invariant axis. 
#' 
#' Rotational and linear movement in some types of propulsion largely occur in 2 dimensions e.g., body rotation in cetacean caudal propulsion occurs around the animal's transverse axis. Likewise sychronized wing flaps in flight or pectoral swimming may generate acceleration in the longitudinal and dorso-ventral axes but much less in the transverse axis. This function identifies the direction of the axis that moves the least in a movement matrix.
#' 
#' @param data The triaxial sensor measurement axis e.g., from on accelerometer or magnetometer. The frame and unit of A do not matter.
#' @return A list with two entries:
#' \itemize{
#'   \item{\code{V }} A 3x1 numeric vector defining the least varying axis in \code{data}. This vector is a direction vector so has a magnitude of 1 and is unit-less. The vector is defined in the same frame as A, so the first, second, and third entries correspond to the first, second and third columns of the data matrix, and axis orientation conventions are preserved.
#'   \item{\code{q }} The proportion of movement in the invariant axis. A small number (e.g., less than 0.05) implies that very little movement occurs in this axis and so the movement is largely planar (i.e., two-dimensional). If the fraction is much larger than 0.05, the motion in A is better described as three-dimensional. \code{q} is a proportion and so it is unitless.
#' }
#' @note This function returns one invariant axis that applies to the entire input signal so it is important to choose a relevant sub-sample of movement data, A, to analyse.
#' @export
#' @examples 
#'  \dontrun{
#'  s <- matrix(sin( 2 * pi * 0.1 * c(1:100)), ncol=1)
#'  A <- s %*% c(0.9, -0.4, 0.3) + s^2 %*% c(0, 0.2, 0.1)
#'  inv_axis_out <- inv_axis(A)
#'    }
#'  

inv_axis <- function(data) {
  #energy ratio between plane-of-motion and axis of rotation
  data <- stats::na.omit(data)
  #k <- matrix(which(stats::complete.cases(data)), byrow = FALSE, ncol = 1)
  QQ <- t(data) %*% data
  svd_out <- svd(QQ, nu=nrow(QQ), nv=ncol(QQ)) 
  V <- svd_out$u
  D <- svd_out$d
  V <- V[, 3]
  q <- D[3] / sqrt(D[1] * D[2])
  return(list(V = V, q = q))
}
