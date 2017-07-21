function    y = smooth(x,n)

%     y = smooth(x,n)
%     Low pass filter (smooth) a regularly-sampled time series.
%
%		Inputs:
%     x is the signal to be filtered. It can be multi-channel with a signal in
%      each column, e.g., an acceleration matrix. The number of samples (i.e., the
%		 number of rows in x) must be larger than the filter length, n.
%     n is the smoothing parameter - use a larger number to smooth more. n must be
%		 greater than 1. Signal components above 1/n of the Nyquist frequency are
%		 filtered out.
%
%		Result:
%		y is the filtered signal with the same size as x.
%
%     Smooth uses fir_nodelay to perform the filtering and so introduces no delay.
%
%		Example:
%		 % make a waveform with two harmonics - one at 1/20 and another at 1/4 of the sampling rate.
%		 x = sin(2*pi*0.05*(1:100)')+cos(2*pi*0.25*(1:100)');
%		 y = smooth(x,4);
%		 plot([x,y])
% 	    returns: The input signal has the first and fifth harmonic. Applying the low-pass filter
%		 removes most of the fifth harmonic so the output appears as a sinewave except for the first
%		 few samples which are affected by the filter startup transient.
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     Last modified: 10 May 2017

y = [] ;
if nargin<2,
   help smooth
   return
end

nf = 6*n ;
fp = 1/n ;
y = fir_nodelay(x,nf,fp);
