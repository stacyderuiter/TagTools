#' Compute the spectrum level of a signal x. This replaces Matlab's psd function and returns units in dB re root-Hz.
#' 
#' @param x A vector containing the signal to be processed. For signals with multiple channels, each channel should be in a column of x.
#' @param nfft The length of the fft to use. Choose a power of two for fastest operation. Default value is 512.
#' @param fs The sampling rate of x in Hz. Default value is 1. fs is the vector of frequencies at which SL is calculated.
#' @param w The window length. The default value is nfft. If w<nfft, each segment of w samples is zero-padded to nfft.
#' @param nov The number of samples to overlap each segment. The default value is half of the window length.
#' @return SL The spectrum level at each frequency in dB RMS re root-Hz.
#' The spectrum is single-sided and extends to fs/2. The reference level is 1.0 (i.e., white noise with unit variance will have a spectrum level of 3-10*log10(fs). The 3dB is because both the negative and positive spectra are added together so that the total power in the signal is the same as the total power in the spectrum.

speclev <- function(x, nfft, fs, w, nov) {
  if (missing(nfft)) {
    nfft <- 512
  }
  if (missing(fs)) {
    fs <- 1
  }
  if (missing(w)) {
    w <- nfft
  }
  if (missing(nov)) {
    if (length(w) == 1) {
      nov <- round(w / 2)
    } else {
      nov <- round(length(w) / 2)
    }
  }
  if (length(w) == 1) {
    #Fixed the hanning problem, by adding 2 to w before function
    #Then taking out the 1st and last row
    w <- signal::hanning((w+2))
    w <- w[2:(length(w)-1)]
  }
  ismatrix <- FALSE
  require(matlab) #for zeros() and size()  and repmat() functions
  if(!is.null(ncol(x))){
    xdim <- ncol(x)
  }
  else{
    xdim <- 1
  }
  P = matrix(0,nrow = nfft / 2, ncol = xdim)
  for (k in 1:xdim) {
    require(stats) #for fft() function
    require(pracma) #for detrend() function
    if(!is.matrix(x)){
      X <-  buffer_nodelay(x[],length(w),nov)
    } 
    else{
      X <- buffer_nodelay(x[,k],length(w),nov)
    }
    #There is a problem with repmat and hanning, mainly due to the zero padding of hanning
      #which becomes an entire row of 0
    X <- detrend(X) * matlab::repmat(w, 1, ncol(X))
    #This is a simple function that copies fft in matlab, and 
    #basically applies fft to every column in the matrix
    fftmatrix <- function(mat, n){
      newmat <- matrix(0L, nrow = nrow(mat), ncol = ncol(mat))
      for(h in 1:ncol(mat)){
        newmat[,h]<- fft(mat[,h])
      }
      return(newmat)
    }
    Freq <- abs(fftmatrix(X,nfft))^2
    #F <- rollapply(data = x[, k], width = length(w), by = nov, FUN = abs(fft((detrend(X) * repmat(w, 1, ncol(X)))[1 : nfft]))^2, by.column = TRUE )
    #list(X = X, z = z) = buffer(x[, k], length(w), nov, 'nodelay')                     
    #X <- detrend(X) * repmat(w, 1, ncol(X))
    #F <- abs(fft(X[1 : nfft]))^2
    P[, k] <- rowSums(Freq[1 :(nfft/2),])
  } 
  ndt <- ncol(X)
  #these two lines give correct output for randn input
  #SL of randn should be -10*log10(fs/2)
  slc <- 3 - 10 * log10(fs / nfft) - 10 * log10(sum(w^2) / nfft)
  #3 is to go from a double-sided spectrum to a single-sided (positive frequecy) spectrum.
  #fs/nfft is to go from power per bin to power per Hz
  #sum(w.^2)/nfft corrects for the window
  SL <- 10 * log10(P) - 10 * log10(ndt) - 20 * log10(nfft) + slc
  #10*log10(ndt) corrects for the number of spectra summed in P (i.e., turns the sum into a mean)
  #20*log10(nfft) corrects the nfft scaling in matlab's fft
  f <- (c(0 : ((nfft / 2)- 1) )) / nfft * fs 
  return(list(SL= SL,  f=f))
}
