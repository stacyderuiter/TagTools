#' Estimate the forward speed of a diving animal 
#' 
#' This function is used to estimate the forward speed of a diving animal by first computing the depth-rate (i.e., the first differential of the depth) and then correcting for the pitch angle.  
#' 
#' @param p The depth vector (a regularly sampled time series) in meters. sampled at sampling_rate Hz. This can either be an animaltags sensor list, or a vector.
#' @param A (optional) A matrix or animaltags sensor data list containing acceleration data. If A is not provided then only vertical velocity is returend (same output as depth_rate()). Acceleration can be in any consistent unit, e.g., g or m/s^2. Acceleration data must have the same number of rows as p.
#' @param sampling_rate (optional) The sampling rate of p and A in Hz (samples per second). Required only if p and A are vectors/matrices rather than sensor data lists.
#' @param fc (optional) Specifies the cut-off frequency of a low-pass filter to apply to p after computing depth-rate and to A before computing pitch. The filter cut-off frequency is in Hz. The filter length is 4*sampling_rate/fc. Filtering adds no group delay. If fc is empty or not given, the default value of 0.2 Hz (i.e., a 5 second time constant) is used.
#' @param plim (optional) Minimum pitch angle, in radians, at which speed can be computed. Default: 0.3490659 radians = 20 degrees. Errors in speed estimation using this method increase strongly at low pitch angles. To avoid estimates with poor accuracy being used in later analyses, speed estimates at low pitch angles are replaced by NaN (not-a-number). The default threshold for this is 20 degrees.
#' @return A list with 2 elements:
#' \itemize{
#' \item{\strong{s: }}The forward speed estimate in m/s (only returned if acceleration input data is provided)
#' \item{\strong{v: }} The depth-rate (or vertical velocity) in m/s
#' }
#' @note Output sampling rate is the same as the input sampling rate so s and v have the same size as p.
#' @note Frame: This function assumes a [north,east,up] navigation frame and a [forward,right,up] local frame. In these frames, a positive pitch angle is an anti-clockwise rotation around the y-axis. A descending animal will have a negative pitch angle.
#' @export

speed_from_depth <- function(p, A, sampling_rate, fc = 0.2, plim = 20/180*pi) {
  # input checks-----------------------------------------------------------
  if (missing(p)) {
    stop("input p is required for speed_from_depth()")
  }
  
  if (is.list(p) && is.list(A)) {
    if (p$sampling_rate != A$sampling_rate){
      stop("p and A must have the same sampling rate for speed_from_depth().")
    }
    sampling_rate <- p$sampling_rate 
    p <- p$data
    A <- A$data
  } else {
    if (missing(sampling_rate)) {
      stop("sampling_rate required for vector/matrix sensor data inputs to speed_from_depth()")
    }
  }
  
  v = depth_rate(p=p, fs=sampling_rate, fc=fc)
  if (!missing(A)){ #if both p and A are input
    nf <- round(4 * sampling_rate / fc)
    A <- fir_nodelay(A, nf, fc / (sampling_rate / 2))$y
    pitch <- a2pr(A)$p
    pitch[abs(pitch) < plim] = NA
    s <- v / sin(pitch)
  } else {
    s <- NA
  }
  return(list(s = s, v = v))
}
