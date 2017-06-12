#' Estimate the dominant stroke frequency from accelerometer data.
#' 
#' Animals tend to produce propulsive movements with a narrow frequency range. These movements cause cyclical changes in posture and/or specific acceleration, both of which are measured by an animal-attached accelerometer. Thus sections of accelerometer data that largely contain propulsion should show a spectral peak in one or more axes at the dominant stroke frequency.
#' @param A An nx3 acceleration matrix with columns [ax ay az]. Acceleration can be in any consistent unit, e.g., g or m/s^2. 
#' @param fs The sampling rate of the sensor data in Hz (samples per second).
#' @param fc (optional) The cut-off frequency in Hz of a low-pass filter to apply to A before computing the spectra. This prevents high frequency transients e.g., in foraging, from dominating the spectra. The filter  length is 6*fs/fc. If fc is not specified, it defaults to 2.5 Hz. If fc>fs/2, the filtering operation is skipped.
#' @param Nfft (optional) The FFT length and therefore the frequency resolution. The default value is the power of two closest to 20*fs, i.e., an analysis block length of about 20 s and a frequency resolution of about 0.05 Hz. A shorter FFT may be required if movement behaviour is very variable. A longer FFT may work well if propulsion is continuous and stereotyped.
#' @return fpk The dominant stroke frequency (i.e., the peak frequency in the sum of the acceleration power spectra) in Hz. Quadratic interpolation is used over the spectral peak to improve resolution.
#' @return q The quality of the peak measured by the peak power divided by the mean power of the spectra. This is a dimensionless number which is large if there is a clear spectral peak.
#' Frame: This function makes no assumption about accelerometer frame. Data in any frame can be used.
#' Data selection: This function works best if the sensor matrix, A, covers an interval in which propulsion is the main activity. This could be a complete dive or an interval of running or flapping flight. The interval length should be at least Nfft/fs seconds, i.e., 20 s for the default FFT length. 

dsf <- function(A, fs, fc = NULL, Nfft) {
  #default low-pass filter at 2.5 Hz
  fcnull <- FALSE
  if (is.null(fc)) {
    fc <- 2.5
    fcnull <- TRUE
  }
  #default FFT length
  if (missing(Nfft)) {
    Nfft <- round(20 * fs)
  }
  PCNT <- 20
  if (fc > (fs/2)) {
    fc <- vector(mode = "numeric", length = 0)
  }
  #force Nfft to the nearest power of 2
  Nfft <- 2^(round(log(Nfft)/log(2)))
  if (!fcnull) {
    Af <- fir_nodelay(diff(A), 6 * fs / fc, fc / (fs / 2))$y
  } else {
    Af <- diff(A)
  }
  templist <- speclev(Af, Nfft, fs, Nfft, Nfft / 2)
  S <- templist$SL
  f <- templist$f
  #sum spectral power in the three axes
  v = rowSums(10^(S/10))
  max_w_index <- function(v){
    max <- 0
    index <- 1
    for(i in length(v)){
      if(v[i] > max){
        max <- v[i]
        index <- i
      }
    }
    return(list(max= max, index = index))
  }
  maxtemplist <- max_w_index(v)
  m <- maxtemplist$max
  n <- maxtemplist$index
  require(pracma) # for polyfit() function
  p <- polyfit(t(f(n+(-1:1))), v(n+(-1:1)), 2)
  fpk <- -p[2] / (2 * p[1])
  q <- m / mean(v)
  return(list(fpk = fpk, q = q))
}