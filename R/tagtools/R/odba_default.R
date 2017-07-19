#'#' Compute the 'Overall Dynamic Body Acceleration' sensu Wilson et al. 2006.
#' 
#' @description ODBA is the norm of the high-pass-filtered acceleration. Several methods for computing ODBA are in use which differ by which norm and which filter are used. In the Wilson paper, the 1-norm and a rectangular window (moving average) filter are used. The moving average is subtracted from the input accelerations to implement a high-pass filter. The 2-norm may be preferable if the tag orientation is unknown or may change and this is termed VeDBA. A tapered symmetric FIR  filter gives more efficient high-pass filtering compared to the rectangular window method and avoids lobes in the response.
#' @param A An nx3 acceleration matrix with columns [ax ay az]. Acceleration can be in any consistent unit, e.g., g or m/s^2. A can be in any frame but the result depends on the method used to compute ODBA. The default method and VeDBA method are rotation independent and so give the same result irrespective of the frame of A. The 1-norm method has a more complex dependency on frame.
#' @param fs The sampling rate in Hz of the acceleration signals.
#' @param fh The high-pass filter cut-off frequency in Hz. This should be chosen to be about half of the stroking rate for the animal (e.g., using dsf.m).
#' @return e A column vector of ODBA with the same number of rows as A. e has the same units as A.
#' @note If hoping to use the "vebda" or "wilson" method to calculate odba, use the function odba with inputs A, n, and method
#' @export
#' @example A <- matrix(c(1, -0.5, 0.1, 0.8, -0.2, 0.6, 0.5, -0.9, -0.7), byrow = TRUE, nrow = 3)
#'          e <- odba_default(A, fs = 5, fh = 0.7)

odba_default <- function(A, fs, fh) {
  if (nargs() < 3) {
    stop("inputs for A, fs, and fh are all required")
  }
  n <- 5 * round(fs / fh)
  Ah <- fir_nodelay(A, n, fh / (fs / 2), "high")
  e <- sqrt(rowSums(abs(Ah)^2))
  return(e)
}
