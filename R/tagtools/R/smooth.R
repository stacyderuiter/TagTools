#' Low pass filter a time series
#' 
#' This funciton is used to low pass filter (smooth) a regularly-sampled time series.
#' @param x The signal to be filtered. It can be multi-channel with a signal in each column, e.g., an acceleration matrix. The number of samples (i.e., the number of rows in x) must be larger than the filter length, n.
#' @param n The smoothing parameter - use a larger number to smooth more. n must be greater than 1. Signal components above 1/n of the Nyquist frequency are filtered out.
#' @return The input signal has the first and fifth harmonic. Applying the low-pass filter removes most of the fifth harmonic so the output appears as a sinewave except for the first few samples which are affected by the filter startup transient. Smooth uses fir_nodelay to perform the filtering and so introduces no delay.
#' @export
#' @examples 
#' \dontrun{ x <- sin((2*pi*0.05)%*%t(c(1:100)))+cos((2*pi*0.25)%*%t(c(1:100)))
#'          y <- smooth(x, n = 4)
#'          }

smooth <- function(x, n) {
    y <- vector(mode = "numeric", length = 0)
    # input checks-----------------------------------------------------------
    if (missing(n)) {
        stop("An input for the smoothing parameter, n, is required.")
    }
    nf <- 6 * n
    fp <- 1/n
    y <- fir_nodelay(x, nf, fp)
    return(y)
}
