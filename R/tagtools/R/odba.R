#' Compute ODBA
#'
#' This function is used to compute the 'Overall Dynamic Body Acceleration' sensu Wilson et al. 2006. ODBA is the norm of the high-pass-filtered acceleration. Several methods for computing ODBA are in use which differ by which norm and which filter are used. 
#' In the Wilson paper, the 1-norm and a rectangular window (moving average) filter are used. The moving average is subtracted from the input accelerations to implement a high-pass filter. 
#' The 2-norm may be preferable if the tag orientation is unknown or may change and this is termed VeDBA. A tapered symmetric FIR  filter gives more efficient high-pass filtering compared to the rectangular window method and avoids lobes in the response.
#' @param A A tag sensor data list containing tri-axial acceleration data or an nx3 acceleration matrix with columns [ax ay az]. Acceleration can be in any consistent unit, e.g., g or m/s^2. A can be in any frame but the result depends on the method used to compute ODBA. 
#' The default method and VeDBA method are rotation independent and so give the same result irrespective of the frame of A. The 1-norm method has a more complex dependency on frame.
#' @param sampling_rate The sampling rate in Hz of the acceleration signals. Required for 'fir' method if A is not a tag sensor data list.
#' @param fh The high-pass filter cut-off frequency in Hz. This should be chosen to be about half of the stroking rate for the animal (e.g., using dsf.R). Required for the default 'fir' method.
#' @param method A character containing either 'wilson' or 'vedba' or 'fir'. This determines the ethod by which the ODBA is calculated. The default method is 'fir'.
#' @param n The rectangular window (moving average) length in samples. This is only needed if using the classic ODBA and VeDBA forms (methods 'wilson' and 'vedba').
#' @return A column vector of ODBA with the same number of rows as A. e has the same units as A.
#' @note If applying the default (FIR filtering) method to calculate odba, use the inputs A, sampling_rate, and fh. When applying the 'vedba' or 'wilson' method, use the inputs A, n, and method.
#' @export
#' @examples
#' \dontrun{
#' BW <- beaked_whale
#' e <- odba(A = BW$A$data, sampling_rate = BW$A$sampling_rate, fh = 4)
#' ba <- list(e = e)
#' plott(ba, BW$A$sampling_rate)
#' }
#'
odba <- function(A, sampling_rate = NULL, fh = NULL, method = "fir", n = NULL) {
  if (is.list(A)) {
    sampling_rate <- A$sampling_rate
    A <- A$data
  }

  if (method == "fir") {
    if (is.null(sampling_rate) | is.null(fh)) {
      stop("sampling_rate (unless A is a tag sensor data list) and fh are required inputs to compute odba by the FIR method")
    }
    n <- 5 * round(sampling_rate / fh)
    Ah <- fir_nodelay(A, n, (fh / (sampling_rate / 2)), "high")
    e <- sqrt(rowSums(abs(Ah)^2))
  } else {
    if ((method == "vedba") | (method == "wilson")) {
      if (is.null(n)) {
        stop("n is a required input to compute odba by the vedba or wilson methods")
      }
      n <- 2 * floor(n / 2) + 1 # make sure n is odd
      nz <- floor(n / 2)
      h <- rbind(
        matrix(0, nrow = nz, ncol = 1),
        matrix(1, nrow = 1, ncol = 1),
        matrix(0, nrow = nz, ncol = 1)
      ) -
        matrix(1, nrow = n, ncol = 1) / n
      Ah <- signal::filter(h, 1, x = rbind(
        matrix(0, nrow = nz, ncol = ncol(A)),
        A,
        matrix(0, nrow = nz, ncol = ncol(A))
      ))
      Ah <- matrix(Ah, byrow = FALSE, ncol = 3)
      Ah <- Ah[nz + c(1:nrow(A)), ]
      if (method == "vedba") {
        e <- sqrt(rowSums(abs(Ah)^2)) # use 2-norm
      } else {
        if (method == "wilson") {
          e <- rowSums(abs(Ah)) # use 1-norm
        }
      }
    }
  }
  return(e)
}
