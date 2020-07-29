function    [P,f] = power_spectrum(x,nfft,fs,w,nov)

%    	[P,f] = power_spectrum(x,nfft,fs)
%		or
%    	[P,f] = spectrum_level(x,nfft,fs,w)
%		or
%    	[P,f] = spectrum_level(x,nfft,fs,w,nov)
%
%     Power spectrum of a signal x, i.e., the amount of power per FFT bin.
%     This replaces Matlab's deprecated psd function. The input
%		signal is divided into overlapping pieces equal in length to the
%		required Fast Fourier Transform (FFT) length. Each piece is
%		windowed and the FFT computed. The spectral power is then estimated
%		from the mean of the spectral magnitudes squared. Power is scaled
%		to account for the scale factor of the FFT and the window. 
%
%		Inputs:
%     x is a vector or matrix containing the signal(s) to be processed. 
%		 For signals with multiple channels, each channel should be in a 
%		 column of x.
%     nfft is the length of the FFT to use. Choose a power of two for
%      fastest operation.
%     fs is the sampling rate of the signals in x in Hz.
%     w is the optional window length. The default value is nfft. If w<nfft,
%      each segment of w samples is zero-padded to nfft. Use w=[] to use
%		 the default value if you want to specify nov. w can also be a vector
%      containing a window.
%     nov is the number of samples to overlap each segment. The default
%      value is half of the window length.
%
%     Returns:
%     P is the power in each bin. The spectrum is single-sided and extends 
%      to fs/2. The reference level is 1.0 (i.e., white noise with unit 
%      variance will have a power per bin of 2/nfft. The 2 is because
%      both the negative and positive spectra are added together so that
%      the power in the signal is the same as the total power in 
%      the spectrum.
%     f is the vector of frequencies in Hz at which P is calculated.
%
%		Example:
%		 TBD
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     Last modified: 13 June 2018

if nargin<3
   P = []; f = [] ;
	help power_spectrum
	return
end

if nargin<4 | isempty(w),
   w = nfft ;
end

if nargin<5,
   if length(w)==1,
      nov = round(w/2) ;
   else
      nov = round(length(w)/2) ;
   end
end

if length(w)==1,
   w = hanning(w) ;
end

P = zeros(nfft,size(x,2)) ;
for k=1:size(x,2),
   [X,z] = buffer(x(:,k),length(w),nov,'nodelay') ;
   X = detrend(X,'constant').*repmat(w,1,size(X,2)) ;
   F = abs(fft(X,nfft)).^2 ;
   P(:,k) = sum(F,2) ;
end

ndt = size(X,2) ;

% Add power in frequencies above the Nyquist to make a single-sided spectrum
% Note: this is only correct for real-valued signals.
P = P(1:floor(nfft/2),:)+P(nfft:-1:ceil(nfft/2)+1,:) ;

% scaling below give correct output for randn input
% P of randn should be 2/nfft per bin

P = P*(ndt*nfft*sum(w.^2))^(-1) ;

% sum(w.^2) corrects for the window
% ndt corrects for the number of spectra summed in P (i.e., turns the sum into a mean)
% nfft corrects the scaling in matlab's fft

f = (0:nfft/2-1)/nfft*fs ;
