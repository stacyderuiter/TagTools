# The following is an attempt to translate Mark Johnson's speclev.m matlab script, from the dtag tool box, to an R script. Note that we made no
# effort to vectorize or use apply...just changed matlab to R code keeping the same general structure. DAS and YJO, June 2017

# function  list(SL = SL, f = f) = speclev(x,nfft,fs,w,nov)

#    [SL,f]=speclev(x,nfft,fs,w,nov)

#     Spectrum level of a signal x.
#     This replaces Matlab's psd function and returns units in dB re
#     root-Hz.
#     x is a vector containing the signal to be processed. For signals with
#     multiple channels, each channel should be in a column of x.
#     nfft is the length of the fft to use. Choose a power of two for
#     fastest operation. Default value is 512.
#     fs is the sampling rate of x in Hz. Default value is 1.
#     w is the window length. The default value is nfft. If w<nfft, each
#     segment of w samples is zero-padded to nfft.
#     nov is the number of samples to overlap each segment. The default
#     value is half of the window length.
#     Use [] in any argument to access the default value or just don't
#     specify the trailing arguments if all of the defaults are to be used, e.g.,
#       list(SL = SL, f = f) = speclev(x,1024) ;
#       list(SL = SL, f = f) = speclev(x,[],48e3) ;
#     Returns:
#      SL is the spectrum level at each frequency in dB RMS re root-Hz.
#       The spectrum is single-sided and extends to fs/2.
#       The reference level is 1.0 (i.e., white noise with unit variance
#       will have a spectrum level of 3-10*log10(fs). The 3dB is because
#       both the negative and positive spectra are added together so that
#       the total power in the signal is the same as the total power in 
#       the spectrum.
#      fs is the vector of frequencies at which SL is calculated.

#   markjohnson@st-andrews.ac.uk, 2013
 
speclev <- function(x,nfft,fs,w,nov) {
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
    w <- 
  }
}

                                     if length(w)==1,
                                     w = hanning(w) ;
                                     end
                                     
                                     P = zeros(nfft/2,size(x,2)) ;
                                     for k=1:size(x,2),
                                     [X,z] = buffer(x(:,k),length(w),nov,'nodelay') ;
                                     X = detrend(X).*repmat(w,1,size(X,2)) ;
                                     F = abs(fft(X,nfft)).^2 ;
                                     P(:,k) = sum(F(1:nfft/2,:),2) ;
                                     end
                                     
                                     ndt = size(X,2) ;
                                     
                                     % these two lines give correct output for randn input
                                     % SL of randn should be -10*log10(fs/2)
                                     
                                     slc = 3-10*log10(fs/nfft)-10*log10(sum(w.^2)/nfft) ;
                                     
                                     % 3 is to go from a double-sided spectrum to a single-sided (positive frequecy) spectrum.
                                     % fs/nfft is to go from power per bin to power per Hz
                                     % sum(w.^2)/nfft corrects for the window
                                     
                                     SL = 10*log10(P)-10*log10(ndt)-20*log10(nfft)+slc ;
                                     
                                     % 10*log10(ndt) corrects for the number of spectra summed in P (i.e., turns the sum into a mean)
                                     % 20*log10(nfft) corrects the nfft scaling in matlab's fft
                                     
                                     f = (0:nfft/2-1)/nfft*fs ;
                                     