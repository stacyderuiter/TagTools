#' Estimate the forward speed of a diving animal by first computing the depth-rate (i.e., the first differential of the depth) and then correcting for the pitch angle. or v=speed_from_depth(p,fs,fc) just estimate the depth-rate (i.e., the first differential of the depth). 
#' 
#' @param p The depth vector (a regularly sampled time series) in meters. sampled at fs Hz.
#' @param A An nx3 acceleration matrix with columns [ax ay az]. Acceleration can be in any consistent unit, e.g., g or m/s^2. A must have the same number of rows as p.
#' @param fs The sampling rate of p and A in Hz (samples per second).
#' @param fc (optional) Specifies the cut-off frequency of a low-pass filter to apply to p after computing depth-rate and to A before computing pitch. The filter cut-off frequency is in Hz. The filter length is 4*fs/fc. Filtering adds no group delay. If fc is empty or not given, the default value of 0.2 Hz (i.e., a 5 second time constant) is used.
#' @param plim (optional) Specifies the minimum pitch angle in radians at which speed can be computed. Errors in speed estimation using this method increase strongly at low pitch angles. To avoid estimates with poor accuracy being used in later analyses, speed estimates at low pitch angles are replaced by NaN (not-a-number). The default threshold for this is 20 degrees.
#' @return s The forward speed estimate in m/s
#' @return v The depth-rate (or vertical velocity) in m/s
#' @note Output sampling rate is the same as the input sampling rate so s and v have the same size as p.
#' @note Frame: This function assumes a [north,east,up] navigation frame and a [forward,right,up] local frame. In these frames, a positive pitch angle is an anti-clockwise rotation around the y-axis. A descending animal will have a negative pitch angle.
#' @export

speed_from_depth <- function(p, A, fs, fc = NULL, plim = NULL) {
  # input checks-----------------------------------------------------------
  if (nargs() < 3) {
    stop("inputs p, A, and fs must all be specified")
  }
  sizearray <- dim(A)
  # second call type - no A
  if (sizearray[1] == 1 & sizearray[2] == 1) {
    if (nargs() < 3 | is.null(fs) == TRUE) {
      fc <- 0.2 #default filter cut-off of 0.2 Hz
    } else {
      fc <- fs
    }
    fs <- A
    A <- vector(mode = "numeric", length = 0)
  } else {
    if (is.null(fc) == TRUE) {
      fc <- 0.2  #default filter cut-off of 0.2 Hz
    }
  }
  if (is.null(plim) == TRUE) {
    plim <- 20 / 180 * pi  #default 20 degree pitch angle cut-off
  }
  nf <- round(4 * fs / fc)
  abc <- p[2] - p[1]
  bcd <- diff(p)
  vec <- c(abc,bcd) * fs
  v <- fir_no_delay(vec, nf, fc / (fs / 2))
  if (length(A) == 0 & is.vector(A)) {
    A <- fir_no_delay(A, nf, fc / (fs / 2))
    pitch <- a2pr(A) ;
    pitch[abs(pitch) < plim] = NaN ;
    s <- v / sin(pitch)
  } else {
    s <- v
  }
  return(s)
}
