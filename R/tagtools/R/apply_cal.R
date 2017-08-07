#' Implement a calibration on sensor data
#' 
#' @param X A sensor list or matrix or vector
#' @param cal A calibration list for the data in X. For example, this could come from spherical_cal.
#' @param T A sensor list or vector of temperature measurements for use in temperature compensation. If T is not a sensor list, it must be the same size and sampling rate as the data in X. T is only required if there is a tcomp field in the cal structure.
#' @return A sensor list with calibration implemented. Data size and sampling rate is the same as for the input data but units may have changed.
#' @note Cal fields currently supported are : poly, cross, map, tcomp, tref
#' @examples 
#' \dontrun {#Will come soon!}
#' @export

apply_cal <- function(X, cal, T) {
  if (nargs() < 2) {
    stop("inputs for X and cal are required")
  }
  if (!is.list(cal)) {
    stop("Calibration information must be in a cal list")
  }
  if (missing(T)) {
    T <- c()
  }
  if (is.list(X)) {
    x <- X$data
    if (is.null(x)) {
      stop("data input cannot be empty")
    }
  } else {
    x <- X
  }
  if ("poly" %in% names(cal) == TRUE) {
    p <- cal$poly
    if (nrow(p) != ncol(x)) {
      stop("Calibration polynomial must have the same number of rows as columns of data")
    }
    x <- x * pracma::repmat(t(p[, 1]), nrow(x), 1) + pracma::repmat(t(p[, 2]), nrow(x), 1)
    if (is.list(X)) {
      X$cal_poly <- cal$poly
    }
  }
  if (!is.null(T) & ("tcomp" %in% names(cal) == TRUE) & length(T) == nrow(x)) {
    #TODO interp T to match X
    if ("tref" %in% names(cal) == TRUE) {
      tref <- 20
    } else {
      tref <- cal$tref
    }
    if (length(cal$tcomp) == ncol(x)) {
      x <- x + (T-tref)*t(cal$tcomp)
    } else {
      if (ncol(X$data) == 1) {
        x <- x + signal::polyval(c(t(cal$tcomp), 0), T)
      }
    }
    if (is.list(X)) {
      X$cal_tcomp <- cal_tcomp
      X$cal_tref <- tref
    }
  }
  if ("cross" %in% names(cal) == TRUE) {
    x <- x * cal$cross
    if (is.list(X)) {
      X$cal_cross <- cal$cross
    }
  }
  if ("map" %in% names(cal) == TRUE) {
    x <- x * cal$map
    if (is.list(X)) {
      X$cal_map <- cal$map
    }
  }
  if (!is.list(X)) {
    X <- list()
  }
  X$data <- x
  X$frame <- "tag"
  if ("unit" %in% names(cal) == TRUE) {
    X$source_unit <- X$unit 
    X$source_unit_name <- X$unit_name 
    X$source_unit_label <- X$unit_label 
    X$unit <- C.unit 
    X$unit_name <- C.unit_name 
    X$unit_label <- C.unit_label
  }
  if ("name" %in% names(cal) == TRUE) {
    X$cal_name <- cal$name
  }
  if ("history" %in% names(X) == TRUE | is.null(X$history)) {
    X$history <- "apply_cal"
  } else {
    X$history <- c(X$history, ",apply_cal")
  }
  return(X)
}