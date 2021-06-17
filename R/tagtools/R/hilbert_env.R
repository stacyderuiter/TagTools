#' Compute the envelope of X using Hilbert transform.
#'  
#' Compute the envelope of the signal matrix X using the Hilbert transform. To avoid long transforms, this function uses the overlap and add method.
#'   
#' @param X a vector or matrix of signals. If X is a matrix, each column is treated as a separate signal.  	
#' The signals must be regularly sampled for the result to be correctly interpretable as the envelope.
#' @param N (optional) specifies the transform length used. The default value is 1024 and this may be fine for most situations.
#' @return E, the envelope of X. E is the same size as X: it has the same number of columns and the same number of samples per signal. It has the same units as
#' X but being an envelope, all values are >=0.
#' @export
#' @examples \dontrun{
#' s <- matrix(sin(0.1 * c(1:10000)), ncol = 1) *
#'  matrix(sin(0.001 * c(1:10000)), ncol = 1)
#' E <- hilbert_env(s)
#' plot(c(1:length(s)), s, col = 'grey34')
#' lines(c(1:length(E)), E, col = 'black')
#' }


hilbert_env <- function(X, N = 1024) {
# note: N must be even

if (is.matrix(X)) {
  if(nrow(X) == 1) {		# make sure X is a column vector or matrix
	  X <- t(X)
  }
} else {
  X <- matrix(X, ncol = 1)
}

taper <- signal::triang(N)%*%matrix(1, nrow = 1, ncol = ncol(X))
nbuffs <- floor(nrow(X) / (N / 2) - 1)
iind <- c(1:N)
oind <- c(1:(N / 2))
lind <- c((N/ 2 + 1):N)
E <- matrix(0, nrow = nrow(X), ncol = ncol(X))

if (nbuffs == 0) {
   E <- Mod(hht::HilbertTransform(X))
   E <- check_mat(E)
   return(E)
}

# first buffer
H <- hht::HilbertTransform(X[c(1:N),])
H <- check_mat(H)
E[oind,] <- Mod(H[oind,]) 
lastH <- H[lind,] * taper[lind,]

# middle buffers
for (k in c(2:(nbuffs-1))){
   kk <- (k - 1) * N / 2
   H0 <- check_mat(hht::HilbertTransform(X[kk+iind,]))
   H <- H0*taper
   E[kk+oind,] <- Mod(H[oind,]+lastH)
   lastH = H[lind,]
}

# last buffer
kk <- (nbuffs - 1) * N / 2 
H <- hht::HilbertTransform(X[c((kk + 1):nrow(X)),])
H <- check_mat(H)
E[kk+oind,] <- Mod(H[oind,]*taper[oind,]+lastH)
E[c((kk + N / 2 + 1):nrow(E)),] <- Mod(H[c((N / 2 + 1):nrow(H)),])

}#end of function
check_mat <- function(xx) {
  if (!is.matrix(xx)) {
    xx <- matrix(xx, nrow = length(xx))
    return(xx)
  }
}