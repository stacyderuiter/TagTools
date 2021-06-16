#' Generate the cardinal axes of an animal
#'
#' This function is used to generate the cardinal axes of an animal (i.e., the longitudinal, transverse, and ventro-dorsal) from accelerometer and magnetic field measurements. This functions generates an approximate orthonormal basis from each measurement of A and M by: (i) normalizing A and M to unit length, (ii) rotating the magnetometer measurement to the horizontal plane (Mh), (iii) computing the cross-product, N, of A and Mh to generate the third axis, (iv) transposing [Mh,N,A] to form the body axis basis.
#' @param A The acceleration matrix with columns [ax ay az], or a sensor data list. Acceleration can be in any consistent unit, e.g., g or $m/s^2$.
#' @param M The magnetometer signal matrix, M=[mx,my,mz], or a sensor data list, in any consistent unit (e.g., in uT or Gauss).
#' @param sampling_rate sampling rate of A and M in Hz (optional if A and M are sensor data lists)
#' @param fc (optional) The cut-off frequency of a low-pass filter to apply to A and M before computing the axes. The filter cut-off frequency is in Hz. The filter length is 4*fs/fc. Filtering adds no group delay. If fc is not specified, no filtering  is performed.
#' @return W, a list with entries \code{x}, \code{y}, and \code{z}; each is an nx3 matrix of body axes where n is the number of rows in M and A.
#' W$x is a nx3 matrix (or a length-3 vector if A and M have one row) containing the X or longitudinal (caudo-rostral) axes.
#' W$y is a nx3 matrix (or a length-3 vector if A and M have one row) containing the Y or transverse (left-right) axes.
#' W$z is a nx3 matrix (or a length-3 vector if A and M have one row) containing the Z or ventro-dorsal axes.
#' W$sampling_rate has the sampling rate of the A and M.
#' @note Output sampling rate is the same as the input sampling rate. Irregularly sampled data can be used, but then filtering must not be applied (\code{fc = NULL}).
#' @note Frame: This function assumes a [north,east,up] navigation frame and a [forward,right,up] local frame. This function will only return the animal's cardinal axes if the tag was attached so that the sensor axes aligned with the animal's axes OR if the tag A and M measurements are rotated to account for the orientation of the tag on the animal. Otherwise, the axes returned by this function will be the cardinal axes of the tag, not the animal.
#' @examples samplematrix1 <- matrix(c(7, 2, 3, 6, 4, 9), byrow = TRUE, ncol = 3)
#' samplematrix2 <- matrix(c(6, 5, 3, 4, 8, 9), byrow = TRUE, ncol = 3)
#' W <- body_axes(A = samplematrix1, M = samplematrix2, fc = NULL)
#' @export

body_axes <- function(A, M, sampling_rate = NULL, fc = NULL) {
  # input checks-----------------------------------------------------------
  if (missing(M) | missing(A)) {
    stop("A and M are required inputs")
  }

  if (is.list(A)) {
    sampling_rate <- A$sampling_rate
    A <- A$data
    toffs <- c(0, 0)
    if ('start_offset' %in% names(A)) {
      toffs[1] <- A$start_offset
    }
    if ('start_offset' %in% names(M)) {
      toffs[2] <- M$start_offset
    }
    if (toffs[1] != toffs[2]) {
      stop("body_axes: A and M must have the same start offset time\n")
    }
  } else {
    if (is.null(sampling_rate) & !is.null(fc)) {
      stop("body_axes: Sampling rate is required if A and M are matrices and filtering is required.\n")
    }
  }

  if (is.list(M)) {
    M <- M$data
    if (M$sampling_rate != sampling_rate) {
      stop("A and M must have the same sampling rate\n")
    }
  }

  if (nrow(M) * ncol(M) == 3) {
    M <- matrix(M, nrow = 1, ncol = 3)
  }
  if (nrow(A) * ncol(A) == 3) {
    A <- matrix(A, nrow = 1, ncol = 3)
  }

  if (nrow(A) != nrow(M)) {
    n <- min(nrow(A), nrow(M))
    A <- A[c(1:n), ]
    M <- M[c(1:n), ]
  }

  #********************************************
  # end of input checking
  #********************************************

  # apply filter if required
  if (!is.null(fc)) {
    nf <- round(4 * sampling_rate / fc)
    fc <- fc / (sampling_rate / 2)
    if (nrow(M) > nf) {
      M <- fir_nodelay(M, nf, fc)
      A <- fir_nodelay(A, nf, fc)
    }
  }

  b <- sqrt(rowSums(M^2))
  g <- sqrt(rowSums(A^2))

  # normalize M to unit magnitude
  M <- M * matrix(b^(-1), nrow = nrow(M), ncol = 3)
  # normalize A to unit magnitude
  A <- A * matrix(g^(-1), nrow = nrow(A), ncol = 3)
  # estimate inclination angle from the data
  I <- acos(rowSums(A * M)) - (pi / 2)
  Mh <- (M + matrix(sin(I), nrow = nrow(M), ncol = 3) * A) * matrix(cos(I)^(-1), nrow = nrow(M), ncol = 3)
  v <- sqrt(rowSums(Mh^2))
  # normalize Mh
  Mh <- Mh * matrix(v^(-1), nrow = nrow(M), ncol = 3)

  # for FRU axes
  N <- matrix(0, nrow(Mh), ncol(M))
  for (i in 1:nrow(N)) {
    N[i, ] <- c(Mh[i, 2] * A[i, 3] - Mh[i, 3] * A[i, 2], Mh[i, 3] * A[i, 1] - Mh[i, 1] * A[i, 3], Mh[i, 1] * A[
      i,
      2
    ] - Mh[i, 2] * A[i, 1]) * -1
  }

  w <- array(0, c(3, 3, nrow(A)))

  w[1, , ] <- t(Mh)
  w[2, , ] <- t(N)
  w[3, , ] <- t(A)

  W <- list(
    x = w[, 1, ],
    y = w[, 2, ],
    z = w[, 3, ],
    sampling_rate = sampling_rate
  )
  # if you wanted to force a nx3 matrix even if A/M have one row
  # if (length(W$x == 3)) {
  #     W$x <- matrix(W$x, nrow = 1)
  #     W$y <- matrix(W$y, nrow = 1)
  #     W$z <- matrix(W$y, nrow = 1)
  # }

  return(W)
}
