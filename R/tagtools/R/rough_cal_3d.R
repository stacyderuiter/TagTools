#' Estimate scale factors and offsets
#'
#' This function is used to estimate scale factors and offsets for measurements from a triaxial field sensor. This function estimates the scale factor needed to make the magnitude of X close to the expected field strength. It then calls fix_offset_3d to correct any offset errors in X. This function does not try to optimize the results. See spherical_cal for a more powerful data-driven calibration method.
#' @param X A sensor structure or matrix containing measurements from a triaxial field sensor such as an accelerometer or magnetometer. X can be in any units and frame.
#' @param fstr The expected field strength at the measurement location in the same units as X
#' @return A list with 2 elements:
#' \itemize{
#'  \item{\strong{X: }} A sensor structure or matrix containing the adjusted triaxial sensor measurements. It is the same size and has the same sampling rate and units as the input data. If the input is a sensor structure, the output will be also.
#'  \item{\strong{G: }} A calibration structure containing one field: G.poly. The first column of G.poly is the three scale factors applied to the columns of X. The second column of G.poly is the offset added to each column of X after scaling.
#' }
#' @note This function requires a lot of data as it is looking for extreme values in each axis. A minimum data size of 1000 samples should be used. This function is only usable for field sensors. It will not work for gyroscope data.
#' @examples
#' \dontrun{
#' BW <- beaked_whale
#' plot(x = c(1:length(BW$M$data)), y = BW$M$data)
#' # see what the data looks like first
#' rcal <- rough_cal_3d(BW$M$data, fstr = 38.2)
#' # fstr matches records for field strength in
#' # El Hierro when the tag was used
#' cal <- list(x = c(1:length(rcal$X)), y = rcal$X)
#' plot(cal)
#' }
#' @export

rough_cal_3d <- function(X, fstr) {
  if (missing(X) || missing(fstr)) {
    stop("X and fstr necessary for the program to run")
  }
  if (is.list(X)) {
    x <- X$data
    # have to undo any matrix operations on x before applying scale and offset changes
    if ("cal_map" %in% names(X)) {
      x <- x %*% solve(X$cal_map)
    }
    if ("cal_cross" %in% names(X)) {
      x <- x %*% solve(X$cal_cross)
    }
  } else {
    x <- X
  }
  if (ncol(x) != 3) {
    stop("rough_cal_3d: input data must be from a 3-axis sensor")
  }
  pp <- max(0.1, 1000 / nrow(x))
  lims <- matrix(c(stats::quantile(x[, 1], c(0.1, 100 - 0.1) / 100), stats::quantile(x[, 2], c(0.1, 100 - 0.1) / 100), stats::quantile(x[, 3], c(0.1, 100 - 0.1) / 100)), nrow = 2)
  g <- 2 * fstr / diff(lims)
  offs <- -mean(lims) * g
  G <- list()
  G$poly <- cbind(t(g), t(offs))
  x <- x * pracma::repmat(g, nrow(x), 1) + pracma::repmat(offs, nrow(x), 1)
  xCList <- fix_offset_3d(x) # fine-tune the offsets
  x <- xCList$X
  C <- xCList$G
  G$poly[, 2] <- G$poly[, 2] + C$poly[, 2]
  scf <- fstr / mean(stats::na.omit(norm2(x)))
  G$poly <- G$poly * scf
  x <- x * scf
  if (!is.list(X)) {
    X <- x
    return(list(X = X, G = G))
  }
  X$cal_poly <- G$poly
  # redo any matrix operations on x after applying scale and offset changes
  if ("cal_map" %in% names(X)) {
    x <- x %*% X$cal_map
  }
  if ("cal_cross" %in% names(X)) {
    x <- x %*% X$cal_cross
  }
  X$data <- x
  if (!("history" %in% names(X)) || length(X$history) == 0 || is.null(X$history)) {
    X$history <- "rough_cal_3d"
  } else {
    X$history <- paste(X$history, ",rough_cal_3d")
  }
  return(list(X = X, G = G))
}
