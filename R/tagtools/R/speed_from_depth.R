#' Estimate the forward speed of a diving animal 
#' 
#' This function is used to estimate the forward speed of a diving animal by first computing the depth-rate (i.e., the first differential of the depth) and then correcting for the pitch angle.  
#' 
#' @param p The depth vector (a regularly sampled time series) in meters. sampled at sampling_rate Hz. This can either be an animaltags sensor list, or a vector.
#' @param A (optional) A matrix or animaltags sensor data list containing acceleration data. If A is not provided then only vertical velocity is returend (same output as depth_rate()). Acceleration can be in any consistent unit, e.g., g or m/s^2. Acceleration data must have the same number of rows as p.
#' @param fs_p (optional) The sampling rate of p in Hz (samples per second). Required only if p is vector rather than sensor data list.
#' @param fs_A (optional) The sampling rate of A in Hz (samples per second). Required only if A is vector rather than sensor data list.
#' @param fc (optional) Specifies the cut-off frequency of a low-pass filter to apply to p after computing depth-rate and to A before computing pitch. The filter cut-off frequency is in Hz. The filter length is 4*sampling_rate/fc. Filtering adds no group delay. If fc is empty or not given, the default value of 0.2 Hz (i.e., a 5 second time constant) is used.
#' @param plim (optional) Minimum pitch angle, in radians, at which speed can be computed. Default: 0.3490659 radians = 20 degrees. Errors in speed estimation using this method increase strongly at low pitch angles. To avoid estimates with poor accuracy being used in later analyses, speed estimates at low pitch angles are replaced by NaN (not-a-number). The default threshold for this is 20 degrees.
#' @return Either forward speed or vertical speed:
#' \itemize{
#' \item{\strong{s: }} If both \code{p} and \code{A} are input, the forward speed estimate in m/s is returned
#' \item{\strong{v: }} If only \code{p} is input, the depth-rate (or vertical velocity) in m/s is returned
#' }
#' @note Output sampling rate is the same as the input sampling rate. If A and p are input and A has a higher sampling rate, then p and the output are interpolated to match A using \code{\link[tagtools]{interp2length}} .
#' @note Frame: This function assumes a [north,east,up] navigation frame and a [forward,right,up] local frame. In these frames, a positive pitch angle is an anti-clockwise rotation around the y-axis. A descending animal will have a negative pitch angle.
#' @examples 
#'   s <- speed_from_depth(harbor_seal$P, harbor_seal$A)    
#' @export

speed_from_depth <- function(p, A = NULL, fs_p = NULL, fs_A = NULL, fc = 0.2, plim = 20/180*pi) {
  # input checks-----------------------------------------------------------
  if (missing(p)) {
    stop("input p is required for speed_from_depth()")
  }
  
  if (is.list(A)){
    fs_A <- A$sampling_rate
    A <- A$data
  }
  
  if (is.list(p)){
    fs_p <- p$sampling_rate
    p <- p$data
  }
  
  if (is.null(fs_p)){
    stop('input fs_p is required for speed_from_depth(), if p is not a sensor data list.')
  }
  
  # make sure p and A data are same sampling rate and same size
  if (!is.null(A)){
    p <- interp2length(X = p, Z = A, fs_in = fs_p, fs_out = fs_A)
    sampling_rate <- fs_A
  }else{
    sampling_rate <- fs_p
  }

  v = depth_rate(p = p, 
                 fs = sampling_rate, 
                 fc = fc)    
  if (is.null(A)){
    # if only depth is input, get vertical speed
    return(v)
  }else{
    # if both depth and accel are input
    # compute pitch and get forward speed
    nf <- round(4 * sampling_rate / fc)
    A <- fir_nodelay(A, nf, fc / (sampling_rate / 2))
    pitch <- a2pr(A)$p
    pitch[abs(pitch) < plim] = NA
    s <- v / sin(pitch)
    return(s)
  }
}
