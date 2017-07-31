#' Estimate third octave levels from FFT power spectra.
#' 
#' This function is used to estimate the third octave levels from FFT power spectra.
#' @param SL A vector or matrix of power spectra in dB re U^2/Hz where U is any approppriate unit. SL can be produced by wavSL. If SL is a vector, it is treated as a single spectrum. If SL is a matrix, each column is treated as a separate spectrum.
#' @param f the centre frequency of each row in SL
#' @return A list with 2 elements:
#' \itemize{
#'  \item{\strong{TOL: }} A matrix of third octave levels in db re U^2 RMS
#'  \item{\strong{fc: }} A vector with the centre frequencies of the third octaves. Only the third octaves that can be estimated from SL are returned. These are determined by the frequency resolution and upper frequency limit of SL.
#' }
#' @export

spec2tol <- function(SL, f) {
  if (missing(f)) {
    stop("inputs for SL and f are both required")
  }
  if (nrow(SL) == 1) {
    SL <- t(SL)
  }
  Fc <- 1000 * ((2^(1 / 3))^(seq(from = -16, to = 30, by = 1)))
  f1 <- Fc / (2^(1 / 6))
  f2 <- Fc * (2^(1 / 6))
  fres <- f[2] - f[1]
  bw <- f2 - f1
  kf <- which(fres < bw & f2 <= max(f))
  P <- 10^(SL / 10)
  top <- NA * matrix(1, length(kf), ncol(P))
  for (k in 1:length(kf)) {
    kk <- which(f >= f1[kf[k]] & f < f2[kf[k]])
    if (length(kk) == 1) {
      top[k, ] <- P[kk, ]
    } else {
      top[k, ] <- mean(P[kk, ])
    }
  }
  TOL <- 10 * log10(top) + pracma::repmat(10 * log10(bw[t(kf)]), 1, ncol(top))
  fc <- Fc(kf)
  return(list(TOL = TOL, fc =fc))
}