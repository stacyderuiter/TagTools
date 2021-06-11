#' Reduce the time span of data
#' 
#' This function is used to reduce the time span of data by cropping out any data that falls before and after two time cues.
#' 
#' @param X A sensor list, vector, or matrix. X can be regularly or irregularly samples data in any frame and unit.
#' @param sampling_rate The sampling rate of X in Hz. This is only needed if X is not a sensor structure.
#' @param T A vector of sampling times for X. This is only needed if X is not a sensor list and X is not regularly sampled. 
#' @param tcues A two-element vector containing the start and end time cues in seconds of the data segment to keep (i.e., tcues <- c(start_time, end_time)).
#' @return Cropped data in the same format as X, unless X is irregularly sampled and NOT a sensor list. In that case, the function returns a list with 2 elements:
#' \itemize{
#'  \item{\strong{X: }} A sensor list, vector or matrix containing the cropped data segment. If the input is a sensor list, the output will also be. The output has the same units, frame and sampling characteristics as the input.
#'  \item{\strong{T: }} A vector of sampling times for Y. This is only returned if X is irregularly sampled and X is not a sensor list. (If X is a sensor list, the sampling times are stored in the list.)
#' }
#' @examples 
#'          d <- find_dives(beaked_whale$P,300) 
#'          P2 <- crop_to(beaked_whale$P, tcues = c(d$start[1], d$end[1]))	#crop to 1st dive
#'          plott(list(P2$X), r=c(1), panel_labels=c('Depth'))
#'          #plot shows the dive profile of the selected dive
#' @export

crop_to <- function(X, sampling_rate = NULL, tcues, T = NULL) {
  T <- c()
  if (is.list(X)) {
    if (missing(tcues)) {
      stop("input for tcues is required for crop_to\n")
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
  tcues <- sort(tcues)
  
  if (!is.null(T)) {    #irregularly sampled data
    k <- which(T >= tcues[1] & T <= tcues[2])
    T <- T[k] - tcues[1]
  } else {
    k <- c(max(round(tcues[1] * sampling_rate), 1):min(round(tcues[2] * sampling_rate), nrow(x)))
  }
  
  if (length(k) == 0) {
    stop('No data points observed between requested time cues.\n')
  }
  if ((k[1] <= 1) & (k[length(k)] >= nrow(x))) {
    if (!is.null(T)){
      return(list(X = X, T = T))
    }else{
      return(X)
    }
  }
  
  if (!is.list(X)) {
    X <- x[k, ]
    if (!is.null(T)){
      return(list(X = X, T = T))
    }else{
      return(X)
    }
  }
  
  if (length(T) > 1) {
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
    X$history <- paste(X$history, "crop_to", sep = ',')
  }
  
  return(X)
}