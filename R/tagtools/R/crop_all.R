#' Reduce the time span of a dataset
#' 
#' This function is used to reduce the time span of a dataset by cropping out any data that falls before and after two time cues.
#' 
#' Possible input combinations: crop_all(X) if X is a sensor list or set of sensor lists, crop_all(tcues, X, Y, ...) if X, Y, ... are sensor lists.
#' @param tcues A two-element vector containing the start and end time cue in seconds of the data segment to keep, i.e., tcues = c(start_time, end_time).
#' @param X A sensor list or a set of sensor lists (e.g., from load_nc).
#' @return A sensor list or set of sensor lists containing the cropped data segment. The output data have the same units, frame and sampling characteristics as the input. The list may have many sublists which are additional sensor structures as required to match the input.
#' @example test <- beaked_whale
#'          d <- find_dives(test$P,300)
#'          X <- crop_all(c(d$start[2], d$end[2]), test)	#crop all data to 2nd dive
#'          testdata <- list(P = X$P, A = X$A)
#'          plott(testdata)
#'          #plot shows the dive profile and acceleration of the second dive
#' @export

crop_all <- function(tcues, X) {
  if (missing(X)) {
    stop("inputs for tcues and X are both required")
  }
  if (!is.list(X)) {
    stop("input to crop_all must be a sensor list")
  }
  if ("info" %in% names(X) == TRUE) {    #X is a set of sensor lists
    f <- names(X)
    for (k in 1:length(f)) {
      if (f[k] == 'info') {
        next
      }  
      X[[k]] <- crop_to(X[[k]], tcues = tcues)$X
    }
    return(X)
  }
  for (k in 1:length(X)) {
    X[[k]] <- crop_to(X[[k]], tcues = tcues)$X
  }
  return(X)
}
