#' Remove NAs from sensor data and return indices of (rows of) filled values
#' 
#' This is an internal function used by \code{\link{htrack}}
#' @param data a data vector or matrix
#' @return A list with entries \code{data} (the input data with NAs filled in) and \code{k} a logical vector indicating the position (if data was a vector) or rows (if data was a matrix) where NAs were filled in. Internal NAs are filled via linear interoplation, while leading and trailing ones are filled using the first following or last preceding good value.
#' @export
#' @examples \dontrun{
#' A <- matrix(c(NA, NA ,3, 4,5,6,7,8,9,10,NA,NA,13,14,15,16, NA, NA), ncol = 2)
#' result <- interp_nan(A)
#' }
interp_nan <- function(data){
  # find indices of NAs (for a vector) or of row with NAs (for a matrix)
  k <- apply(data, 1, function(x) any(is.na(x)))
  # remove internal NAs
  data <- zoo::na.approx(data, na.rm = FALSE)
  # remove leading NAs by filling from first good  value
  data <- zoo::na.locf(data, fromLast = TRUE)
  # remove trailing NAs by filling from last good value
  data <- zoo::na.locf(data)
  return(list(data = data, k = k))
}
