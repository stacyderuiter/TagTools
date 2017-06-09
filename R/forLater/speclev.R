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
    #Warning about hanning function:
    #Hanning function is from the OCTAVE signal, not the MATLAB one
    #As a result, they give a different answer, mainly 
    #Octave and R signal hanning starts and ends with 0.
    #And matlab starts right away with a value, sometimes resulting very differently
    require(signal) #for hanning() function
    w <- signal::hanning(w)
  }
  require(matlab) #for zeros() and size()  and repmat() functions

  P = matrix(0,nrow = nfft / 2, ncol = 1)
  if(!is.null(ncol(x))){
    xdim <- ncol(x)
  }
  else{
    xdim <- 1
  }
  for (k in 1:xdim) {
    require(stats) #for fft() function
    require(pracma) #for detrend() function
    #following if else is partially commented out
    #Because R is strict on separating vectors and matrices,
    #and x[,number] is a matrix operation, not a vector operation
    #Will leave it just in case, but most likely to be erased in complete package
    #if(!is.null(xdim)){
    #  X <- buffer_nodelay(x[,k],length(w),nov)
    #}
    #else{
      X <-  buffer_nodelay(x[],length(w),nov)
    #}
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
    #list(X = X, z = z) = buffer(x[, k], length(w), nov, 'nodelay')                     #####################????buffer()
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
  f <- head((c(0 : (nfft / 2) )) / nfft* fs,-1) 
  return(list(SL= SL,  f=f))
}
