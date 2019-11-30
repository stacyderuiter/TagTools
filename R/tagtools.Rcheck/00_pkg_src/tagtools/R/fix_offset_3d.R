#' Estimate the offset in each axis
#' 
#' This function is used to estimate the offset in each axis of a triaxial field measurement, e.g., from an accelerometer or magnetometer. This is useful for correcting drift or calibration errors in a sensor.
#' @param X A sensor list or matrix containing measurements from a triaxial field sensor such as an accelerometer of magnetometer. X can be in any units and frame.
#' @return A list with 2 elements:
#' \itemize{
#'  \item{\strong{X: }} A sensor list or matrix containing the adjusted triaxial sensor measurements. It is the same size and has the same sampling rate and units as the input data. If the input is a sensor list, the output will also.
#'  \item{\strong{G: }} A calibration list containing one field: G$poly. The first column of G$poly contains 1 as this function does not adjust the scale factor of X. The second column of G$poly is the offset added to each column of X.
#' }
#' @note This function is only usable for field sensors. It will not work for gyroscope data.
#' @export
#' @examples #Will come soon!

fix_offset_3d <- function(X) {
  poly1 <- matrix(1, 3, 1)
  poly2 <- matrix(0, 3, 1)
  poly <- cbind(poly1, poly2)
  G <- list(poly = poly)
  if (missing(X)) {
    stop("input for X is required")
  }
  if (is.list(X)) {
    x <- X$data
  } else {
    x <- X
  }
  if (ncol(x) != 3) {
    stop("input data must be from a 3-axis sensor")
  }
  k <- stats::complete.cases(x)
  bsq <- rowSums(x[k,]^2)
  mb <- sqrt(mean(bsq))
  XX <- cbind((2 * x[k,]), pracma::repmat(mb, length(k), 1))
  R <- t(XX) %*% XX
  if (kappa(R, exact = TRUE) > 1e3) {
    stop("condition too poor to get reliable solution")
  }
  P <- colSums(pracma::repmat(as.matrix(bsq), 1, 4) * XX)
  H <- -solve(R)%*%as.matrix(P)
  ones <- matrix(1, 3, 1)
  G$poly <- cbind(ones, H[1:3])
  x <- x + pracma::repmat(t(H[1:3]), nrow(x), 1)
  if (!is.list(X)) {
    X <- x
    return(list(X = X, G = G))
  }

  X$data <- x
  #check if a map or cross-term have been applied to X - if so, these need to
  #be removed from G.poly - the polynomial is always in the sensor frame. This
  #is easily done for offsets by multiplying the offset vector by the inverse
  #of the transformations.
  if ("cal_map" %in% names(X) == TRUE) {
    G$poly[,2] <- pracma::inv(X$cal_map) * G$poly[, 2]
  }
  if ("cal_cross" %in% names(X) == TRUE) {
    G$poly[,2] <- pracma::inv(X$cal_cross) * G$poly[, 2]
  }
  X$cal_poly <- G$poly
  if( ("history" %in% names(X) == TRUE) | (is.null(X$history))) {
    X$history <- "fix_offset_3d"
  } else {
    X$history <- c(X$history, "fix_offset_3d")
  }
  return(list(X = X, G = G))
}