#' Rotate triaxial vector measurements from one frame to another. 
#' 
#' @param V is a 3-element vector or a 3-column matrix of vector measurements for example V could be from an accelerometer or magnetometer.
#' @param Q is the rotation matrix. If Q is a single 3x3 matrix, the same rotation is appled to all vectors in V. If Q is a 3x3xn matrix where n is the number of rows in V, a different transformation given by Q[,, k] is applied to each row of V.
#' @return V is the rotated vector or matrix with the same size as the input V.
#' @note Frame: This function makes no assumptions about frame.

rotate_vecs <- function(V, Q) {
  if (missing(Q)) {
    stop("inputs for all arguments are required")
  }
  if (ncol(V) == 1) {
    V <- t(V)
  }
  if (length(dim(Q))) {
    V <- V %*% t(Q)
  } else {
    for(k in 1:nrow(V)) {
      V[k, ] <- V[k, ] * t(Q[,, k])
    }
  }
  return(V)
}