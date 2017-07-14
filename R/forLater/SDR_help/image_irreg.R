#' Plot an image with an irregular grid.
#' 
#' @description This is useful for plotting matrix data (i.e., sampled data that is a function of two parameters) in which one or both of the sampling schemes is not regularly spaced. image_irreg plots R(i,j) as a coloured patch centered on x(i),y(j) and with dimension determined by x[i]-x[i-1] and y[i]-y[i-1].
#' @param x is a vector with the horizontal axis coordinates of each value in R.
#' @param y is a vector with the vertical axis coordinates of each value in R.
#' @param R is a matrix of measurements to display. The values in R are converted to colours in the current colormap and caxis. R must be length(x) by length(y). Use NaN to have a patch not display.
#' @export

image_irreg <- function(x, y, R) {
  if (missing(R)) {
    stop("inputs for all arguments are required")
  }
  if (length(x) != nrow(R) | length(y) != ncol(R)) {
    stop("Error: R must be length(x) by length(y)")
  }
  xdiff <- c(diff(x), x[length(x)] - x[length(x) - 1])
  X <- matrix(c(0, 0, 1, 1), ncol = 1) %*% xdiff + matrix(1, 4, 1) %*% x
  Y <- matrix(c(0, 1, 1, 0), ncol = 1) %*% matrix(1, 1, length(x)) 
  ydiff <- c(diff(y), y[length(y)] - y[length(y) - 1])
  for (k in 1:length(y)) {
    zk <- which(!is.na(R[, k]))
    x <- X[, zk]
    y <- (ydiff[k] * Y[, zk] + y[k])
    col <- R[zk, k]
    plot3D::polygon2D(x = X[, zk], y = (ydiff[k] * Y[, zk] + y[k]), plot = TRUE, fill = TRUE, col = R[zk, k])
  }
}