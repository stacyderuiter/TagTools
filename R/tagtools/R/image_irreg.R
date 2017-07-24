#' Plot an image with an irregular grid.
#' 
#' This function is used to plot an image with an irregular grid. This is useful for plotting matrix data (i.e., sampled data that is a function of two parameters) in which one or both of the sampling schemes is not regularly spaced. image_irreg plots R(i,j) as a coloured patch centered on x(i),y(j) and with dimension determined by x[i]-x[i-1] and y[i]-y[i-1].
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
  graphics::plot(NA,xlim = c(min(X[,]), max(X[,])), ylim = c(min(ydiff[1] * Y[,  which(!is.na(R[, 1]))] + y[1]), max(ydiff[length(y)] * Y[, which(!is.na(R[, length(y)]))] + y[length(y)])))
  for (k in 1:length(y)) {
    zk <- which(!is.na(R[, k]))
    graphics::polygon(x =X[, zk], y = (ydiff[k] * Y[, zk] + y[k]), col = R[zk,k], lty = 0)
  }
}