#' Interactive data cropping tool.
#' 
#' This function plots the input data # and allows the user to select start and end times for cropping.
#' 
#' Possible input combinations include: crop(X) if X is a sensor list, crop(X, sampling_rate) if X is a vector or matrix.
#' @param X A sensor list, vector or matrix. X can be regularly or irregularly sampled data in any frame and unit.
#' @param sampling_rate The sampling rate of X in Hz. This is only needed if X is not a sensor list. If X is regularly sampled, sampling_rate is one number. sampling_rate may also be a vector of sampling times for X. This is only needed if X is not a sensor list and X is not regularly sampled.
#' @return A list with 3 elements:
#' \itemize{
#'  \item{\strong{Y: }} A sensor list, vector or matrix containing the cropped data segment. If the input is a sensor list, the output will also be. The output has the same units, frame and sampling characteristics as the input.
#'  \item{\strong{T: }} A vector of sampling times for Y. This is only returned if X is irregularly sampled and X is not a sensor list. If X is a sensor list, the sampling times are stored in the list.
#'  \item{\strong{tcues: }} tcues is a two-element vector containing the start and end time cue in seconds of the data segment kept, i.e., tcues = c(start_time, end_time).
#' }
#' @example load_nc('testset3')
#'          Pc <- crop(P)		#interactively select a section of data
#'          plott(Pc)
#'          #plot shows the cropped section

crop <- function(X, sampling_rate) {
  if (missing(X)) {
    stop("X is a required input")
  }
  if (is.list(X)) {
    x <- list$data
    sampling_rate <- X$sampling_rate
    if (is.null(x)) {
      stop("data cannot be empty")
    }
  } else {
    if (missing(sampling_rate)) {
      stop("inputs for X and sampling_rate are required")
    }
    x <- X
    if (is.vector(x) | nrow(x) == 1) {
      x <- matrix(x, nrow = length(x), ncol = 1)
    }
  }
  graphics.off()
  if (length(sampling_rate) > 1) {
    plot(sampling_rate, x, type = "p", xlab = "Time (seconds)")
  } else {
    plot((c(1:nrow(x)) / sampling_rate), x, type = "l", xlab = "Time (seconds)")
  }
  print("Position your cursor and then click once followed by clicking FINISH to change the start, or click twice in the same spot followed by clicking FINISH to change the end")
  if (length(sampling_rate) > 1) {
    tcues <- c(min(sampling_rate), max(sampling_rate))
  } else {
    tcues <- c(0, (nrow(x) / sampling_rate))
  }
  LIMS <- tcues
  lines(matrix((c(1,1) * tcues[1]), ncol = 1), col = "green", lwd = 1.5)
  points(tcues[1], mean((par("usr")[3]+.04), (par("usr")[4]-.04)), col = "green", pch = 6, cex = 12)
  lines(matrix((c(1,1) * tcues[2]), ncol = 1), col = "red", lwd = 1.5)
  points(tcues[2], mean((par("usr")[3]+.04), (par("usr")[4]-.04)), col = "red", pch = 6, cex = 12)
  pts <- graphics::locator(2)
  if (length(pts$x) == 1) {
    t <- pts$x
    tcues[1] <- max(LIMS[1], min(t, tcues[2]))
    lines(matrix((c(1,1) * tcues[1]), nrow = 1), col = "green", lwd = 1.5)
    points(tcues[1], mean((par("usr")[3]+.04), (par("usr")[4]-.04)), col = "green", pch = 6, cex = 12)
    lines(matrix((c(1,1) * tcues[2]), ncol = 1), col = "red", lwd = 1.5)
    points(tcues[2], mean((par("usr")[3]+.04), (par("usr")[4]-.04)), col = "red", pch = 6, cex = 12)
  } else {
    t < pts$x[2]
    tcues[2] <- max(LIMS[2], min(t, tcues[1]))
    lines(matrix((c(1,1) * tcues[1]), ncol = 1), col = "green", lwd = 1.5)
    points(tcues[1], mean((par("usr")[3]+.04), (par("usr")[4]-.04)), col = "green", pch = 6, cex = 12)
    lines(matrix((c(1,1) * tcues[2]), nrow = 1), col = "red", lwd = 1.5)
    points(tcues[2], mean((par("usr")[3]+.04), (par("usr")[4]-.04)), col = "red", pch = 6, cex = 12)
  }
  if (is.list(X)) {
    Y <- crop_to(X, tcues)$X
    T <- tcues
  } else {
    list <- crop_to(x, sampling_rate, tcues)
    Y <- list$X
    T <- list$T
    if (length(sampling_rate) == 1) {
      T <- tcues
    }
  }
  return(list(Y = Y, T = T, tcues = tcues))
}
