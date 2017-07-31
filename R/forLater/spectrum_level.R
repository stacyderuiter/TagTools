#' Spectrum level of a signal
#' 
#' This function determines the spectrum level of a signal x, i.e., the amount of power per 1Hz band. This replaces Matlab's deprecated psd function. The input signal is divided into overlapping pieces equal in length to the required Fast Fourier Transform (FFT) length. Each piece is windowed and the FFT computed. The spectral power is then estimated from the mean of the spectral magnitudes squared. Power is scaled to account for the scale factor of the FFT and the window. The power is also scaled by 10log10 of the bin width in Hz (i.e., the sampling rate divided by the FFT length) to convert the per-bin powers into approximate per-Hz powers. This scaling method is suitable for wideband signals (i.e., with bandwidth wider than the bin width) but is NOT suitable for narrow band and tonal signals.
#' @param X A vector or matrix containing the signal(s) to be processed. For signals with multiple channels, each channel should be in a column of x.
#' @param nfft The length of the FFt to use. Choose a power of two for fastest operation.
#' @param sampling_rate the sampling rate of the signals in x in Hz.
#' @param w the optional window length. The default value is nfft. If w < nfft, each segment of w samples is zero-padded to nfft.
#' @param nov The number of samples to overlap each segment. The default value is half of the window length.
#' @return A list with 2 elements:
#' \itemize{
#'  \item{\strong{SL: }} The specturm level at each frequency in dB RMS re root-Ha. The spectrum is single-sided and extends to sampling_rate/2. The reference level is 1.0 (i.e. white noise with unit variance will have a spectrum level of 3-10*log10(sampling_rate)). The 3dB is because both the negative and positive spectra are added together so that the total power in the signal is the same as the tota power in the spectrum
#'  \item{\strong{f: }} the vector of frequencies in Hz at which SL is calculated.
#' }
#' @export

spectrum_level <- function(x, nfft, sampling_rate, w = NULL, nov = NULL) {
  if (missing(sampling_rate)) {
    stop("inputs for x, nfft, and sampling_rate are all required")
  }
  if (is.null(w)) {
    w <- nfft
  }
  if (is.null(nov)) {
    if (length(w) == 1) {
      nov <- round(w / 2)
    } else {
      nov <- round(length(w) / 2)
    }
  }
  if (length(w) == 1) {
    w <- signal::hanning((w+2))
    w <- w[2:(length(w)-1)]
  }
  P <- matrix(0, (nfft/2), ncol(x))
  w <- matrix(w, nrow = length(w), ncol = 1)
  for (k in 1:ncol(x)) {
    X <- buffer(x[, k], length(w), nov, nodelay = TRUE)
    X <- pracma::detrend(X) * pracma::repmat(w, 1, ncol(X))
    F <- abs(stats::fft(X, nfft))^2
    P[, k] <- rowSums(F[1:(nfft/2), ])
  }
  ndt <- ncol(X)
  #these two lines give correct output for randn input
  #SL of randn should be -10*log10(sampling_rate/2
  slc <- 3 - 10 * log10(sampling_rate/nfft) - 10 * log10(sum(w^2)/nfft)
  #3 is to go from a double-sided spectrum to a single-sided (positive frequency) spectrum.
  #sampling_rate/nfft is to go from power per bin to power per Hz
  #sum(w^2)/nfft corrects for the window
  SL <- 10 * log10(P) - 10 * log10(ndt) - 20 * log10(nfft) + slc
  #10*log10(ndt) corrects for the number of spectra summed in P (i.e., turns the sum into a mean)
  #20*log10(nfft) corrects the nfft scaling in fft
  f <- c(0:nfft/2 - 1) / nfft * sampling_rate
  return(list(SL = SL, f = f))
}