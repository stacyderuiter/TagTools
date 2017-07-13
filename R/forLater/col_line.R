#' Plot coloured line(s) in 2 dimensions in the current figure.
#' 
#' @param x A vector or matrix of points on the horizontal axis.
#' @param y A vector or matrix of points on the vertical axis.
#' @param c A vector or matrix of values representing the colour to draw at each point.
#' @note x, y and c must all be the same size. If x, y, and c are matrices, one line is drawn for each column. The color axis will by default span the range of values in c, i.e., caxis will be c(min(min(c)), max(max(c))). This can be changed by calling caxis after colline.

col_line <- function(x, y, c) {
  if (length(x) == length(y) & length(x) == length(c)) {
     x <- matrix(x, nrow = 1)
     y <- matrix(y, nrow = 1)
     c <- matrix(c, nrow = 1)
     X <- matrix(0, length(x), 1)
     Y <- matrix(0, length(x), 1)
     C <- matrix(0, length(x), 1)
     for (k in 1:length(x)) {
       X[k] <- x[k]
       Y[k] <- y[k]
       C[k] <- c[k]
     }
     data <- list()
     for (j in 1:(length(X) - 1)) {
       for (l in (j + 1)) {
         data[[j]] <- data.frame(X[j:l], Y[j:l])
       }
     }
     plot(NA, xlim = c(0, max(x)), ylim = c(0, max(y)))
     for (i in 1:(length(X)-1)) {
       d <- data[[i]]
       lines(x = d[, 1], y = d[, 2], col = C[i], lwd = 3, xlab = NULL, ylab = NULL)
     }
  } else {
    if (nrow(x) == nrow(y) & nrow(x) == nrow(c) & ncol(x) == ncol(y) & ncol(x) == ncol(c)) {
      if (ncol(x) == 1) {
        x <- matrix(x, nrow = 1)
        y <- matrix(y, nrow = 1)
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
      graphics::matplot(NA, xlim = c(0, max(x)), ylim = c(0, max(y)))
      for (i in 1:(nrow(x)-1)) {
        dx <- datax[[i]]
        dy <- datay[[i]]
        graphics::matlines(x = dx, y = dy, col = c[i], lwd = 3, lty = 1, xlab = NULL, ylab = NULL)
      }
    }
  }
}