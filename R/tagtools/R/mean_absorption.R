#' Calculate the mean absorption in salt water over a frequency range. 
#' 
#' @param freq Specifies the frequency range, freq = c(fmin, fmax) in Hz. For a single frequency, use a scalar value for freq.
#' @param r The path (slant) length in metres.
#' @param depth The depths covered by the path. This can be a single value for a horizontal path or a two component vector i.e., depth=c(dmax,dmin) for a path that extends between two depths.
#' @param Ttab (optional) The temperature (a scalar) in degrees C or specifies a temperature profile Ttab = c(depth, tempr) where depth and tempr are equal-sized column vectors. Default value is an isothermal profile of 13 degrees.
#' @return a The mean sound absorption over the path in dB.
#' @note After Kinsler and Frey pp. 159-160.
#' @export
#' @example mean_absorption(c(25e3, 60e3), 1000, c(0, 700))
#'          #Returns: 7.728188 dB/m

mean_absorption <- function(freq, r, depth, Ttab = NULL) {
  if (missing(depth)) {
    stop("inputs for few, r, and depth are all required")
  }
  if (is.null(Ttab)) {
    tempr <- 13
  } else {
    if (length(Ttab) == 1) {
      tempr <- Ttab
    }
  }
  if (length(depth) > 1) {
    depth <- matrix(seq(min(depth), max(depth), len = 50), nrow = 1)
    if (!is.null(Ttab) & length(Ttab) > 1) {
      tempr <- pracma::interp1(Ttab[, 1], Ttab[, 2], depth)
    } else {
      tempr <- pracma::repmat(tempr, nrow(depth), ncol(depth))
    }
  }
  #handle case of a single frequency
  if (length(freq) == 1) {
    a <- r * mean(absorption(freq, tempr, depth))
    return(a)
  }
  #handle a range of frequencies
  f <- seq(min(freq), max(freq), len = 50) 
  aa = matrix(0, length(depth), length(f)) 
  for (k in 1:length(depth)) {
    aa[k, ] <- absorption(f, tempr[k], depth[k])
  }
  aaa <- matrix(0, 1, ncol(aa))
  for (i in 1:ncol(aa)) {
    aaa[i] <- mean(aa[, i])
  }
  a <- matrix(0, length(r), 1)
  for (kk in 1:length(r)) {
    a[kk] = -10 * log10(mean(10^(-aa * r[kk] / 10)))
  }
  return(a)
}