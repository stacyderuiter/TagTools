#' Reduce the time span of a dataset
#' 
#' This function is used to reduce the time span of a dataset by cropping out any data that falls before and after two time cues.
#' 
#' Possible input combinations: crop_all(X) if X is a sensor list or set of sensor lists, crop_all(tcues, X, Y, ...) if X, Y, ... are sensor lists.
#' @param tcues A two-element vector containing the start and end time cue in seconds of the data segment to keep, i.e., tcues = c(start_time, end_time).
#' @param X A sensor list or a set of sensor lists (e.g., from load_nc). Y,... are additional sensor lists.
#' @return A sensor list or set of sensor lists containing the cropped data segment. The output data have the same units, frame and sampling characteristics as the input. The list may have many sublists which are additional sensor structures as required to match the input.
#' @example X <- load_nc('testset3')
#'          d <- find_dives(X$P,300)
#'          X <- crop_all(c(d$start[2], d$end[2]), X)	#crop all data to 2nd dive
#'          plott(X$P,X$A)
#'          #plot shows the dive profile and acceleration of the second dive

crop_all <- function(tcues, X, ...) {
  if (missing(X)) {
    stop("inputs for tcues and X are both required")
  }
  if (!is.list(X)) {
    stop("input to crop_all must be a sensor list")
  }
  if ("info" %in% names(X) == TRUE) {    #X is a set os sensor lists
    f <- names(X)
    for (k in 1:length(f)) {
      if (names(X$f[k]) == X$info) {
        X$f[k] <- crop_to(X$f[k], tcues)
      }
    }
  }
  X <- crop_to(X, tcues)
  n <- (nargin() - 1) - 1
  for (k in 1:n) {
    list <- list()
    list[[k]] <- crop_to(...[k], tcues)
  }
  return(list(X = X, list = list))
}
