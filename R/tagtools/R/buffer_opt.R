#' Buffers a signal vector into matrix of data frames and specifies a vector of samples to precede x[1] in an overlapping buffer.
#' 
#' @param x The signal vector to be buffered
#' @param n The desired length of data segments (rows).
#' @param p The desired amount of overlap between consecutive frames (columns) in the output matrix
#' @param opt The vector of samples specified to precede x[1] in an overlapping buffer
#' @return X A matrix of the buffered signal vector "vec" with "n" data segments and an overlap between consecutive frames specified by "p". The matrix starts with "opt" values.
#' @return z The remainder of the vector which was not included in the matrix if the last column did not have a full number of rows.
#' @return opt The last values, length of "p", of the matrix "X".
#' @export

buffer_opt <- function(x, n, p, opt) {
  if (!(p < n)){
    stop("p must be less than n")
  }
  if (!(length(opt) == p)) {
    stop("length of opt must equal p")
  }
  m <- floor(length(x) / (n - p))
  tmat <- matrix(0, nrow = m, ncol = n)
  vecindex <- 1
  for (i in 1:m) {
    if (i == 1) {
      tmat[i, 1:p] <- opt
      for (f in (p + 1):n) {
        tmat[i, f] = x[vecindex]
        vecindex <- vecindex + 1
      }
    } else {
      tmat[i, 1:p] <- tmat[i - 1, (-(n - p):0)]
      for (c in (p + 1):n) {
        tmat[i, c] <- x[vecindex]
        vecindex <- vecindex + 1
      }
    }
  }
  z <- c()
  if (vecindex < length(x) + 1) {
    z <- x[vecindex:length(x)]
  }
  opt <- tmat[m, (-(n - p):0)]
  X <- t(tmat)
  return(list(X = X, z = z, opt = opt))
}