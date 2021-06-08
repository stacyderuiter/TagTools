#' Estimate the dominant stroke frequency
#'
#' This function can be used to estimate the dominant stroke frequency from triaxial accelerometer data [ax,ay,az].
#'
#' Animals tend to produce propulsive movements with a narrow frequency range. These movements cause cyclical changes in posture and/or specific acceleration, both of which are measured by an animal-attached accelerometer. Thus sections of accelerometer data that largely contain propulsion should show a spectral peak in one or more axes at the dominant stroke frequency.
#' @param A A sensor data list or an nx3 acceleration matrix with columns [ax ay az]. Acceleration can be in any consistent unit, e.g., g or m/s^2.
#' @param sampling_rate The sampling rate of the sensor data in Hz (samples per second).
#' @param fc (optional) The cut-off frequency in Hz of a low-pass filter to apply to A before computing the spectra. This prevents high frequency transients e.g., in foraging, from dominating the spectra. The filter  length is 6*sampling_rate/fc. If fc is not specified, it defaults to 2.5 Hz. If fc>sampling_rate/2, the filtering operation is skipped.
#' @param Nfft (optional) The FFT length and therefore the frequency resolution. The default value is the power of two closest to 20*sampling_rate, i.e., an analysis block length of about 20 s and a frequency resolution of about 0.05 Hz. A shorter FFT may be required if movement behaviour is very variable. A longer FFT may work well if propulsion is continuous and stereotyped.
#' @return A list with 2 elements:
#' \itemize{
#' \item{\strong{fpk: }}The dominant stroke frequency (i.e., the peak frequency in the sum of the acceleration power spectra) in Hz. Quadratic interpolation is used over the spectral peak to improve resolution.
#' \item{\strong{q: }} The quality of the peak measured by the peak power divided by the mean power of the spectra. This is a dimensionless number which is large if there is a clear spectral peak.
#' }
#' @note Frame: This function makes no assumption about accelerometer frame. Data in any frame can be used.
#' @note Data selection: This function works best if the sensor matrix, A, covers an interval in which propulsion is the main activity. This could be a complete dive or an interval of running or flapping flight. The interval length should be at least Nfft/sampling_rate seconds, i.e., 20 s for the default FFT length.
#' @export
#' @examples
#' # coming soon!
dsf <- function(A, sampling_rate = NULL, fc = NULL, Nfft = NULL) {
  if (is.list(A) & hasName(A, "data") & hasName(A, "sampling_rate")) {
    AA <- A
    sampling_rate <- AA$sampling_rate
    A <- AA$data
  } else {
    if (missing(sampling_rate) | is.null(sampling_rate)) {
      stop("sampling_rate is a required input, unless A is a sensor data list")
    }
  }
  # default low-pass filter at 2.5 Hz
  if (is.null(fc)) {
    fc <- 2.5
  }
  # default FFT length
  if (is.null(Nfft)) {
    Nfft <- round(20 * sampling_rate)
  }
  PCNT <- 20
  if (fc > (sampling_rate / 2)) {
    fc <- c()
  }
  # force Nfft to the nearest power of 2
  Nfft <- 2^(round(log(Nfft) / log(2)))
  if (!is.null(fc)) {
    Af <- fir_nodelay(
      diff(A),
      6 * sampling_rate / fc,
      fc / (sampling_rate / 2)
    )
  } else {
    Af <- diff(A)
  }
  if (Nfft > nrow(Af)) {
    Nfft <- nrow(Af)
  }
  templist <- spec_lev(Af, Nfft, sampling_rate, Nfft, Nfft / 2)
  S <- templist$SL
  f <- templist$f
  # sum spectral power in the three axes
  v <- rowSums(10^(S / 10))
  m <- max(v)
  n <- which.max(v)
  if ((n > 1) & (n < length(f))) {
    p <- pracma::polyfit(t(f[n + (-1:1)]), v[n + (-1:1)], 2)
    fpk <- -p[2] / (2 * p[1])
  } else {
    fpk <- f[n]
  }
  q <- m / mean(v)
  return(list(fpk = fpk, q = q))
}
