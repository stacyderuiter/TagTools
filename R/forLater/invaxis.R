#' Identify the axis in triaxial movement measurements that varies the least, i.e., the invariant axis. 
#' 
#' @description Rotational and linear movement in some types of propulsion largely occur in 2 dimensions e.g., body rotation in cetacean caudal propulsion occurs around the animal's transverse axis. Likewise sychronized wing flaps in flight or pectoral swimming may generate acceleration in the longitudinal and dorso-ventral axes but much less in the transverse axis. This function identifies the direction of the axis that moves the least in a movement matrix.
#' @param A The triaxial sensor measurement axis e.g., from on accelerometer or magnetometer. The frame and unit of A do not matter.
#' @return V A 3x1 vector defining the least varying axis in A. V is a direction vector so has a length of 1 and is unit-less. V is defined in the same frame as A.
#' @return q The fraction of movement in the invariant axis. A small number (e.g., <0.05) implies that very little movement occurs in this axis and so the movement is largely planar (i.e., two-dimensional). If the fraction is >> 0.05, the motion in A is better described as three-dimensional. q is a fraction and so does not have a unit.
#' @note This function returns one invariant axis that applies to the entire input signal so it is important to choose a relevant sub-sample of movement data, A, to analyse.
#' @example invaxis(sin(2*pi*0.1*(1:100)')*[0.9 -0.4 0.3])
#' #Returns: V=[-0.2140
#'               0.2305
#'               0.9493], 
#'      #answer for q is very small

invaxis <- function(A) {
  #energy ratio between plane-of-motion and axis of rotation
  k <- matrix(which(complete.cases(A)), byrow = FALSE, ncol = 1)
  QQ <- t(A[k, ]) %*% A[k, ]
  list <- svd(QQ)
  V <- list$v
  D <-list$d
  V <- V[, 3]
  q <- D[3] / sqrt(D[1] * D[2])
  return(list(V = V, q = q))
}