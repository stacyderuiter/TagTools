#' Plot a spectrogram with default settings
#'
#' This is a wrapper function for \link[signal]{specgram} to draw a spectrogram with
#' the same input argument names and defaults as the tag tools Matlab/Octave function make_specgram.
#'
#' @param x The input signal
#' @param nfft specifies the number of frequency points used to calculate the discrete Fourier transforms.
#' @param fs The sampling frequency in Hz
#' @param window If you specify a scalar for \code{window},
#' make_specgram uses a Hanning window of that length.
#' \code{window} must have length smaller than or equal to \code{nfft} and greater than \code{noverlap}.
#' @param noverlap The number of samples the sections of \code{x} overlap.
#' @param draw_plot (logical) Should a plot be drawn? Defaults to TRUE.
#'
#' @return if \code{draw_plot} is TRUE, a plot is produced. If it is FALSE, a list is returned, with as follows. Each element is a matrix and all three matrices are the same size.
#' \itemize{
#'   \item{\code{s, }} {A matrix of spectrogram values of signal x in dB. }
#'   \item{\code{f, }} {Frequencies (Hz) corresponding to the rows of s}
#'   \item{\code{t, }} {Time indices corresponding to the columns of s}
#' }
#'
#' @examples
#' \dontrun{
#' x <- signal::chirp(seq(from = 0, by = 0.001, to = 2),
#'   f0 = 0,
#'   t1 = 2,
#'   f1 = 500
#' )
#' fs <- 2
#' nfft <- 256
#' numoverlap <- 128
#' window <- signal::hanning(nfft)
#' # Spectrogram plot
#' make_specgram(x, nfft, fs, window, numoverlap)
#' # or calculate and don't plot
#' S <- make_specgram(x, nfft, fs, window, numoverlap, draw_plot = FALSE)
#' }
#' @export
make_specgram <- function(x, nfft = 256, fs = 2,
                          window = signal::hanning(nfft),
                          noverlap = length(window) / 2,
                          draw_plot = TRUE) {
  S <- signal::specgram(
    x = x, n = nfft, Fs = fs, window = window,
    overlap = noverlap
  )
  if (draw_plot) {
    print(S)
  } else {
    return(S)
  }
}
