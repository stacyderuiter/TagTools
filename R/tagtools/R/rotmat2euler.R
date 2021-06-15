#' Decompose a rotation (or direction cosine) matrix
#'
#' This function is used to decompose a rotation (or direction cosine) matrix into Euler angles, pitch, roll, and heading.
#' @param Q is a 3x3 rotation matrix.
#' @return A 1x3 vector containing: prh=[p,r,h] where p is the pitch angle in radians, r is the roll angle in radians, and h is the heading or yaw angle in radians.
#' @export

rotmat2euler <- function(Q) {
  prh <- c(asin(Q[3, 1]), atan2(Q[3, 2], Q[3, 3]), atan2(Q[2, 1], Q[1, 1]))
  return(prh)
}