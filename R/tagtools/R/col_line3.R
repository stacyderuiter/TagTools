#' Plot coloured line(s) in 3 dimensions in the current figure.
#' 
#' @param x A vector or matrix of points on the horizontal axis.
#' @param y A vector or matrix of points on the vertical axis.
#' @param z A vector or matrix of points on the third axis.
#' @param c A vector or matrix of values representing the colour to draw at each point.
#' @param ... Additional inputs for rgl::plot3d()
#' @note x, y, z and c must all be the same size. If x, y, and c are matrices, one line is drawn for each column. The color axis will by default span the range of values in c, i.e., caxis will be c(min(min(c)), max(max(c))). This can be changed by calling caxis after colline.

col_line3 <- function(x, y, z, c, ...) {
  if (length(x) == length(y) & length(x) == length(c) & length(x) == length(z)) {
    x <- matrix(x, nrow = 1)
    y <- matrix(y, nrow = 1)
    z <- matrix(z, nrow = 1)
    c <- matrix(c, nrow = 1)
    X <- matrix(0, length(x), 1)
    Y <- matrix(0, length(x), 1)
    Z <- matrix(0, length(x), 1)
    C <- matrix(0, length(x), 1)
    for (k in 1:length(x)) {
      X[k] <- x[k]
      Y[k] <- y[k]
      Z[k] <- z[k]
      C[k] <- c[k]
    }
    data <- list()
    for (j in 1:(length(X) - 1)) {
      for (l in (j + 1)) {
        data[[j]] <- data.frame(X[j:l], Y[j:l], Z[j:l])
      }
    }
    rgl::plot3d(NA, NA, NA, xlim = c(0, max(x)), ylim = c(0, max(y)), zlim = c(0, max(z)), xlab = "x", ylab = "y", zlab = "z")
    for (i in 1:(length(X)-1)) {
      d <- data[[i]]
      rgl::lines3d(x = d[, 1], y = d[, 2], z = d[, 3], color = C[i], lwd = 3, ...)
    }
  } else {
    if (nrow(x) == nrow(y) & nrow(x) == nrow(c) & nrow(x) == nrow(z) & ncol(x) == ncol(y) & ncol(x) == ncol(c) & ncol(x) == ncol(z)) {
      if (ncol(x) == 1) {
        x <- matrix(x, nrow = 1)
        y <- matrix(y, nrow = 1)
        z <- matrix(z, nrow = 1)
        c <- matrix(c, nrow = 1)
      }
      datax <- list()
      for (j in 1:(nrow(x) - 1)) {
        for (l in (j + 1)) {
          datax[[j]] <- data.frame(x[j:l, ])
        }
      }
      datay <- list()
      for (j in 1:(nrow(y) - 1)) {
        for (l in (j + 1)) {
          datay[[j]] <- data.frame(y[j:l, ])
        }
      }
      dataz <- list()
      for (j in 1:(nrow(z) - 1)) {
        for (l in (j + 1)) {
          dataz[[j]] <- data.frame(z[j:l, ])
        }
      }
      rgl::plot3d(NA, NA, NA, xlim = c(0, max(x)), ylim = c(0, max(y)), zlim = c(0, max(z)), xlab = "x", ylab = "y", zlab = "z")
      for (i in 1:(nrow(x)-1)) {
        dx <- as.matrix(datax[[i]])
        dy <- as.matrix(datay[[i]])
        dz <- as.matrix(dataz[[i]])
        rgl::lines3d(x = dx, y = dy, z = dz, color = c[i], lwd = 3, ...)
      }
    }
  }
}