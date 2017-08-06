#' Undo calibrations steps
#' 
#' This function is used to undo any calibration steps that have been applied to sensor data. This will reverse any re-mapping, scaling and offset adjustments that have been applied to the data, reverting the sensor data to the state it was when read in from the source (excluding any filtering or decimation steps).
#' @param X A sensor list or set of sensor lists in the tag frame, i.e., with calibrations applied.
#' @param T A vector of temperature measurements with the same number of samples and sampling rate as the data in the input sensor data structure X. T indicates the temperature experienced by the sensor during data collection (not necessarily the ambient temperature experienced by the animal), and may affect calibration because many sensors’ output values change depending on the temperature.
#' @return A sensor list or set of sensor lists reverted to the sensor frame, i.e., without calibrations.
#' @examples
#' \dontrun{ 
#' BW <- beaked_whale
#' undo_cal(BW)
#'          }
#' @export

undo_cal <- function(X, T) {
  if (missing(X)) {
   stop("Need X to continue") 
  }
  if (!is.list(X)) {
   stop("Input to undo_cal must be a list") 
  }
  if ("info" %in% names(X)) {
    f <- names(X)
    for (k in 1:length(f)) {
      if (identical(f[k], 'info')) {
        next
      } 
      X[[k]] <- undo_cal1(X[[k]], T) 
    }
  } else {
    X <- undo_cal1(X, T)
  }
  return(X)
}
undo_cal1 <- function(X, T) {
  if ("cal_map" %in% names(X)) {
    X$data <- X$data %*% solve(X$map) 
    X$cal_map <- diag(ncol(X$data)) 
  }
  if ("cal_cross" %in% names(X)) {
    X$data <- X$data %*% solve(X$cross)
    X$cal_cross <- diag(ncol(X$data))
  }
  if ((!missing(T) && !is.null(T) && length(T) != 0) && ("cal_tcomp"  %in% names(X) ) && (nrow(T)==nrow(X$data))) {
    if (!("cal_tref" %in% names(X))) {
      tref <- 0 
    } else {
      tref <- X$cal_tref
    }
    X$data <- X$data - (T - tref) %*% X$tcomp 
    X$cal_tcomp <- matrix(0, 1, ncol(X)) 
  }
  if ("cal_poly" %in% names(X)) {
    p <- X$cal_poly 
    X$data <- (X$data - pracma::repmat(t(p[,2]), nrow(X$data), 1)) * pracma::repmat(1 / t(p[, 1]), nrow(X$data), 1)
    X$cal_poly <- pracma::repmat(c(1, 0), ncol(X$data), 1) 
  }
  if ("source_unit" %in% names(X)) {
    X$unit <- X$source_unit 
    X$unit_name <- X$source_unit_name
    X$unit_label <- X$source_unit_label
  }
  X$frame <- 'raw' 
  if (!("history" %in% names(X)) | length(X$history) == 0 | is.null(X$history)) {
    X$history <- 'undo_cal' 
  } else {
    X$history <- paste(X$history, ",undo_cal", sep = " ")
  }
  return(X)
}    