#' Compute the 'Overall Dynamic Body Acceleration' sensu Wilson et al. 2006.
#' 
#' @description ODBA is the norm of the high-pass-filtered acceleration. Several methods for computing ODBA are in use which differ by which norm and which filter are used. In the Wilson paper, the 1-norm and a rectangular window (moving average) filter are used. The moving average is subtracted from the inputaccelerations to implement a high-pass filter. The 2-norm may be preferable if the tag orientation is unknown or may change and this is termed VeDBA. A tapered symmetric FIR  filter gives more efficient high-pass filtering compared to the rectangular window method and avoids lobes in the response.
#' @param A An nx3 acceleration matrix with columns [ax ay az]. Acceleration can be in any consistent unit, e.g., g or m/s^2. A can be in any frame but the result depends on the method used to compute ODBA. The default method and VeDBA method are rotation independent and so give the same result irrespective of the frame of A. The 1-norm method has a more complex dependency on frame.
#' @param fs The sampling rate in Hz of the acceleration signals. 
#' @param fh fh The high-pass filter cut-off frequency in Hz. This should be chosen to be about half of the stroking rate for the animal (e.g., using dsf.R). 
#' @param method A character containing either "wilson" or "vedba" or "fir". This determines the ethod by which the ODBA is calculated. The default method is "fir".
#' @param n The rectangular window (moving average) length in samples. This is only needed if using the classic ODBA and VeDBA forms.
#' @return e A column vector of ODBA with the same number of rows as A. e has the same units as A.
#' @note When hoping to use the default (FIR filtering) method to calculate odba, use the inputs A, fs, and fh. When hoping to use the "vedba" or "wilson" method, use the inputs A, n, and method.
#' @export
#' @example A <- matrix(c(1, -0.5, 0.1, 0.8, -0.2, 0.6, 0.5, -0.9, -0.7), byrow = TRUE, nrow = 3)
#'          e <- odba(A, method = "vedba", n = 5)

odba <- function(A, fs, fh = NULL, method = "fir", n = NULL) {
  if (nargs() < 3) {
    stop("Three inputs are required")
  }
  if (method == "fir") {
    if (missing(fs) | is.null(fh)) {
      stop("fs and fh are required inputs to compute odba by the FIR method")
    }
    n <- 5 * round(fs / fh)
    Ah <- fir_nodelay(A, n, (fh / (fs / 2)), "high")$y
    e <- sqrt(rowSums(abs(Ah)^2))
  } else {
    if ((method == "vedba") | (method == "wilson")) {
      if (missing(n)) {
        stop("n is a required input to compute odba by the vedba or wilson methods")
      }
      if (missing(n)) {
        n <- 2 * floor(fs / 2) + 1 #make sure n is odd
      }
      nz <- floor(n / 2)
      Ah <- signal::filter(rep(1,n) / n, 1, x = rbind(A, matrix(0, nrow = nz, ncol = ncol(A))))
      Ah <- matrix(Ah, byrow = FALSE, ncol = 3)
      Ah <- Ah[nz + c(1:nrow(A)), ] 
      if (method == "vedba") {
        e <- sqrt(rowSums(abs(Ah)^2)) #use 2-norm
      } else {
        if (method == "wilson") {
          e <- rowSums(abs(Ah)) #use 1-norm
        }
      }
    }
  }
  return(e)
}
