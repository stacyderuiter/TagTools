#' Find zero-crossings in a vector 
#' 
#' This function is used to find the zero-crossings in a vector using a hysteretic detector. This is useful, e.g., to locate cyclic postural changes due to propulsion.
#' @param x A vector of data. This can be from any sensor and with any sampling rate.
#' @param TH The magnitude threshold for detecting a zero-crossing. A zero-crossing is only detected when values in x pass from -TH to +TH or vice versa.
#' @param Tmax (optional) The maximum duration in samples between threshold crossings. To be accepted as a zero-crossing, the signal must pass from below -TH to above TH, or vice versa, in no more than Tmax samples. This is useful to eliminate slow transitions. If Tmax is not given, there is no limit on the number of samples between threshold crossings.
#' @return A list with 2 elements:
#' \itemize{
#' \item{\strong{K: }} A vector of cues (in samples) to zero-crossings in x.
#' \item{\strong{s: }} A vector containing the sign of each zero-crossing (1 = positive-going, -1 = negative-going). s is the same size as K. If no zero-crossings are found, K and s will be empty
#' }
#' @note  Frame: This function assumes a [north,east,up] navigation frame and a [forward,right,up] local frame. Both A and M must be rotated if needed to match the animal's cardinal axes otherwise the track will not be meaningful.
#' @note CAUTION: dead-reckoned tracks are usually very inaccurate. They are useful to get an idea of HOW animals move rather than WHERE they go. Few animals probably travel in exactly the direction of their longitudinal axis and anyway measuring the precise orientation of the longitudinal axis of a non-rigid animal is fraught with error. Moreover, if there is net flow in the medium, the animal will be advected by the flow in addition to its autonomous movement. For swimming animals this can lead to substantial errors. The forward speed is assumed to be  with respect to the medium so the track derived here is NOT the 'track-made-good', i.e., the geographic movement of the animal. It estimates the movement of the animal with respect to the medium. There are numerous other sources of error so use at your own risk!
#' @export
#' @example list( K = K, s = s) <- zero_crossings(sin(2 * pi * 0.033 * c(1:100)), 0.3)
#'          #Returns: K = c(15.143, 30.286, 45.429, 60.628, 75.771, 90.914)
#'                    s = c(-1, 1, -1, 1, -1, 1)

zero_crossings <- function(x, TH, Tmax = NULL) {
  # input checks-----------------------------------------------------------
  if (missing(TH)) {
    stop("inputs for both x and TH are required")
  }
  if (!is.vector(x)) {
    stop("the input for x must be a vector")
  }
  #find all positive and negative threshold crossings
  xtp = diff(x > TH) 
  xtn = diff(x < -TH) 
  kpl = which(xtp > 0) + 1   #leading edges of positive threshold crossings
  kpt = which(xtp < 0)       #trailing edges of positive threshold crossings
  knl = which(xtn > 0) + 1   #leading edges of negative threshold crossings
  knt = which(xtn < 0)       #trailing edges of negative threshold crossings
  #prepare space for the results
  K <- matrix(0, nrow = (length(kpl) + length(knl)), ncol = 3)  
  cnt <- 0
  #find which direction zero-crossing comes first
  if (min(kpl) < min(knl)) {
    SIGN <- 1
  } else {
    SIGN <- -1
  }
  while(1) {
    if (SIGN == 1) {
      if (is.na(kpl)[1]| length(kpl) == 0) {
        break
      }
      suppressWarnings(kk <- max(which(knt <= kpl[1])))
      if (abs(kk) != Inf) {
        cnt <- cnt + 1
        K[cnt,] <- c(knt[kk], kpl[1], SIGN)
        knt <- knt[(kk + 1):length(knt)]
        knl <- knl[knl > kpl[1]]
        kpl <- kpl[2:length(kpl)]
      }
      SIGN <- -1
    } else {
      if (is.na(knl)[1]| length(knl) == 0) {
        break
      }
      suppressWarnings(kk <- max(which(kpt <= knl[1])))
      if (abs(kk) != Inf) {
        cnt <- cnt + 1
        K[cnt,] <- c(kpt[kk], knl[1], SIGN)
        kpt <- kpt[(kk + 1):length(kpt)]
        kpl <- kpl[kpl > knl[1]]
        knl <- knl[2:length(knl)]
      }
      SIGN <- 1
    }
  }
  K <- K[(1:cnt),]
  if (!is.null(Tmax)) {
    k <- which(K[, 2] - K[, 1] <= Tmax)
    K <- K[k,]
  }
  s <- K[, 3]
  KK <- K[, 1:2]
  X <- matrix(c(x[K[, 1]], x[K[, 2]]), byrow = FALSE, ncol = 2) 
  K <- (X[, 2] * K[, 1] - X[, 1] * K[, 2]) / (X[, 2] - X[, 1])
  return(list(K = K, s = s, KK = KK))
}
