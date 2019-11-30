#' Estimate the forward speed 
#' 
#' This function is used to estimate the forward speed of a flying or diving animal by first computing the altitude or depth-rate (i.e., the first differential of the pressure in meters) and then correcting for the pitch angle. This is called the Orientation Corrected Depth Rate. There are two major assumptions in this method: (i) the animal moves in the direction of its longitudinal axis, and (ii) the frame of A coincides with the animal's axes.
#' 
#' Possible input combinations: ocdr(p,A) if p and A are lists, ocdr(p,A,fc = fc) if p and A are lists, ocdr(p,A,fc = fc,plim = plim) if p and A are lists, ocdr(p,A,sampling_rate) if p and A are vectors/matrices, ocdr(p,A,sampling_rate,fc) if p and A are vectors/matrices, ocdr(p,A,sampling_rate,fc,plim) if p and A are vectors/matrices.
#' @param p The depth or altitude vector (a regularly sampled time series) or depth or altitude sensors list in meters, sampled at sampling_rate Hz.
#' @param A The nx3 acceleration matrix with columns [ax ay az] or acceleration sensor list (e.g., from readtag.R). Acceleration can be in any consistent unit, e.g., g or m/s^2. A must have the same number of rows as p.
#' @param sampling_rate The sampling rate of p and A in Hz (samples per second).
#' @param fc (optional) Specifies the cut-off frequency of a low-pass filter to apply to p after computing depth-rate and to A before computing pitch. The filter cut-off frequency is in Hz. The filter length is 4*sampling_rate/fc. Filtering adds no group delay. If fc is empty or not given, the default value of 0.2 Hz (i.e., a 5 second time constant) is used.
#' @param plim (optional) Specifies the minimum pitch angle in radians at which speed can be computed. Errors in speed estimation using this method increase strongly at low pitch angles. To avoid estimates with poor accuracy being used in later analyses, speed estimates at low pitch angles are replaced by NaN (not-a-number). The default threshold for this is 20 degrees.
#' @return The forward speed estimate in m/s
#' @note Output sampling rate is the same as the input sampling rate so s has the same size as p.
#' @note Frame: This function assumes a [north,east,up] navigation frame and a [forward,right,up] local frame. In these frames, a positive pitch angle is an anti-clockwise rotation around the y-axis. A descending animal will have a negative pitch angle.
#' @export
#' @examples 
#' \dontrun{
#' HS <- harbor_seal
#' s <- ocdr(p = HS$P$data, A = HS$A$data, sampling_rate = HS$P$sampling_rate, fc = NULL, plim = NULL)
#' speed <- list(s = s)
#' plott(speed, testset2$P$sampling_rate)
#' }

ocdr <- function(p, A, sampling_rate, fc, plim) {
  if (missing(A) | missing(p)) {
    stop("inputs for p and A are both required")
  }
  if (is.list(p) & is.list(A)) {
    if (nargs() < 3) {
      sampling_rate <- c()
    }
    if (nargs() < 4) {
      fc <- c()
    }
    plim <- fc 
    fc <- sampling_rate 
    sampling_rate <- p$sampling_rate 
    p <- p$data
    A <- A$data
  } else {
    if (missing(sampling_rate)) {
      stop("sampling_rate required for vector/matrix sensor data")
    }
    if (missing(fc)) {
      fc <- c()
    }
    if (missing(plim)) {
      plim <- c()
    }
  }
  if (is.null(fc)) {
    fc <- 0.2 #default filter cut-off of 0.2 Hz
  }
  if (is.null(plim)) {
    plim <- 20 / 180 * pi #default 20 degree pitch angle cut-off
  }
  nf <- round(4 * sampling_rate / fc) 
  #use central differences to avoid a half sample delay
  x1 <- p[2] - p[1]
  x2 <- (p[3:length(p)] - p[1:(length(p) - 2)]) / 2
  x3 <- p[length(p)] - p[length(p) - 1]
  X <- c(x1, x2, x3)
  diffp <- X * sampling_rate 
  v <- fir_nodelay(diffp, nf, fc / (sampling_rate / 2))
  A <- fir_nodelay(A, nf, fc / (sampling_rate / 2))
  pitch <- a2pr(A)$p
  pitch[which(abs(pitch) < plim)] <- NA 
  s <- v / sin(pitch) 
  return(s)
}