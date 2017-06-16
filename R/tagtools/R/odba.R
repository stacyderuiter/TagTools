#' Compute the 'Overall Dynamic Body Acceleration' sensu Wilson et al. 2006.
#' 
#' @description ODBA is the norm of the high-pass-filtered acceleration. Several methods for computing ODBA are in use which differ by which norm and which filter are used. In the Wilson paper, the 1-norm and a rectangular window (moving average) filter are used. The moving average is subtracted from the inputaccelerations to implement a high-pass filter. The 2-norm may be preferable if the tag orientation is unknown or may change and this is termed VeDBA. A tapered symmetric FIR  filter gives more efficient high-pass filtering compared to the rectangular window method and avoids lobes in the response.
#' @param A An nx3 acceleration matrix with columns [ax ay az]. Acceleration can be in any consistent unit, e.g., g or m/s^2. A can be in any frame but the result depends on the method used to compute ODBA. The default method and VeDBA method are rotation independent and so give the same result irrespective of the frame of A. The 1-norm method has a more complex dependency on frame.
#' @param n The rectangular window (moving average) length in samples. This is only needed if using the classic ODBA and VeDBA forms.
#' @param fs The sampling rate in Hz of the acceleration signals.
#' @param method A string containing either "wilson" or "vedba". If the third argument to odba.m is a string, either the classic 1-norm ODBA ('wilson') or the 2-norm VeDBA ('vedba') is computed, in either case with an n-length rectangular window.
#' @return e A column vector of ODBA with the same number of rows as A. e has the same units as A.
#' @note If hoping to use the default (FIR filtering) method to calculate odba, use the function odba_default with inputs A, fs, and fh
#' @export
#' @example A <- matrix(c(1, -0.5, 0.1, 0.8, -0.2, 0.6, 0.5, -0.9, -0.7), byrow = TRUE, nrow = 3)
#'          e <- odba(A, n = 5, fs = 5, method = "vebda")

odba <- function(A, n, fs, method) {
  if (nargs() < 4) {
    stop("inputs for A, n, fs, and method are all required")
  }
  n <- 2 * floor(fs / 2) + 1 #make sure n is odd
  nz <- floor(n / 2)
  Ah <- signal::filter(rep(1,n) / n, 1, x = rbind(A, matrix(0, nrow = nz, ncol = ncol(A))))
  Ah <- matrix(Ah, byrow = FALSE, ncol = 3)
  Ah <- Ah[nz + c(1:nrow(A)), ] 
  if (method == "vebda") {
    e = sqrt(rowSums(abs(Ah)^2)) #use 2-norm
  } else {
    e = rowSums(abs(Ah)) #use 1-norm
    return(e)
  }
}
