#' Reduce the time span of data
#' 
#' This function is used to reduce the time span of data by cropping out any data that falls before and after two time cues.
#' 
#' Possible input combinations: crop_to(X, tcues = tcues) if X is a sensor structure, crop_to(X, sampling_rate, tcues) if x is a vector or matrix.
#' @param X A sensor list, vector, or matrix. X can be regularly or irregularly samples data in any frame and unit.
#' @param sampling_rate The sampling rate of X in Hz. This is only needed if X is not a sensor structure. If X is regularly sampled, sampling_rate is one number. sampling_rate may also be a vector of sampling times for X. This is only needed if X is not a sensor list and X is not regularly sampled.
#' @param tcues A two-element vector containing the start and end time cues in seconds of the data segment to keep (i.e., tcues <- c(start_time, end_time)).
#' @return A list with 2 elements:
#' \itemize{
#'  \item{\strong{X: }} A sensor list, vector or matrix containing the cropped data segment. If the input is a sensor list, the output will also be. The output has the same units, frame and sampling characteristics as the input.
#'  \item{\strong{T: }} A vector of sampling times for Y. This is only returned if X is irregularly sampled and X is not a sensor list. If X is a sensor list, the sampling times are stored in the list.
#' }
#' @examples 
#'          data <- beaked_whale
#'          d <- find_dives(data$P,300)
#'          P2 <- crop_to(data$P, tcues = c(d$start[2], d$end[2]))	#crop to 2nd dive
#'          Xdata <- list(datatest = P2$X)
#'          plott(Xdata)
#'          #plot shows the dive profile and acceleration of the second dive
#' @export

crop_to <- function(X, sampling_rate = NULL, tcues = NULL) {
  T <- c()
  if (is.list(X)) {
    if (missing(tcues)) {
      stop("input for tcues is required if X is a sensor list")
    }
    x <- X$data
    sampling_rate <- X$sampling_rate
    if (!is.matrix(x)) {
      x <- matrix(x, ncol = 1)
    }
  } else {
    if (missing(tcues)) {
      stop("inputs for X, sampling_rate, and tcues are all required")
    }
    x <- X
    if (!is.matrix(x)) {
      x <- matrix(x, ncol = 1)
    }
    if (nrow(x) == 1) {
      x <- t(x)
    }
  }
  if (length(tcues) != 2) {
    stop("tcues must be a two-element vector of c(start_time,end_time)")
  }
  if (tcues[1] >= tcues[2]) {
    X <- c()
    return(list(X = X, T = T))
  }
  if (length(sampling_rate) > 1) {    #irregularly sampled data
    k <- which(sampling_rate >= tcues[1] & sampling_rate <= tcues[2])
    T <- sampling_rate[k] - tcues[1]
  } else {
    k <- c(max(round(tcues[1] * sampling_rate), 1):min(round(tcues[2] * sampling_rate), nrow(x)))
  }
  if (length(k) == 0) {
    X <- c()
    T <- c()
    return(X = X, T = T)
  }
  if ((k[1] <= 1) & (k[length(k)] >= nrow(x))) {
    return(list(X = X, T = T))
  }
  if (!is.list(X)) {
    X <- x[k, ]
    return(list(X = X, T = T))
  }
  if (length(sampling_rate) > 1) {
    X$data <- cbind(T, x[k, ])
  } else {
    X$data <- x[k, ]
  }
  X$crop <- tcues
  X$crop_units <- "seconds"
  X$start_time <- tcues[1]
  X$start_time_units <- "seconds"
  if (("history" %in% names(X) == FALSE) | is.null(X$history)) {
    X$history <- "crop_to"
  } else {
    X$history <- c(X$history, "crop_to")
  }
  return(list(X = X, T = T))
}