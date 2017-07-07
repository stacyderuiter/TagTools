function    [fpk,q] = dsf(A,fs,fc,Nfft)

%     [fpk,q] = dsf(A,fs,fc,Nfft)
%		Estimate the dominant stroke frequency from accelerometer data.
%		Animals tend to produce propulsive movements with a narrow
%		frequency range. These movements cause cyclical changes in posture
%		and/or specific acceleration, both of which are measured by an
%		animal-attached accelerometer. Thus sections of accelerometer data
%		that largely contain propulsion should show a spectral peak in one
%		or more axes at the dominant stroke frequency.
%
%		Inputs:
%     A is a nx3 acceleration matrix with columns [ax ay az]. Acceleration can 
%		 be in any consistent unit, e.g., g or m/s^2. 
%     fs is the sampling rate of the sensor data in Hz (samples per second).
%	   fc (optional) specifies the cut-off frequency in Hz of a low-pass filter
%		 to apply to A before computing the spectra. This prevents high frequency
%		 transients e.g., in foraging, from dominating the spectra. The filter 
%		 length is 6*fs/fc. If fc is not specified, it defaults to 2.5 Hz.
%		 If fc>fs/2, the filtering operation is skipped.
%		Nfft (optional) specifies the FFT length and therefore the frequency
%		 resolution. The default value is the power of two closest to 20*fs, i.e.,
%		 an analysis block length of about 20 s and a frequency resolution of about
%		 0.05 Hz. A shorter FFT may be required if movement behaviour is very variable.
%		 A longer FFT may work well if propulsion is continuous and stereotyped.
%
%     Returns:
%		fpk is the dominant stroke frequency (i.e., the peak frequency in the
%		 sum of the acceleration power spectra) in Hz. Quadratic interpolation is used
%		 over the spectral peak to improve resolution.
%		q is the quality of the peak measured by the peak power divided by the mean
%		 power of the spectra. This is a dimensionless number which is large if there
%		 is a clear spectral peak.
%
%		Frame: This function makes no assumption about accelerometer frame. Data in
%		any frame can be used.
%		Data selection: This function works best if the sensor matrix, A, covers
%		an interval in which propulsion is the main activity. This could be a complete
%		dive or an interval of running or flapping flight. The interval length should 
%		be at least Nfft/fs seconds, i.e., 20 s for the default FFT length. 
%
%		Example:
%		 load...
%		 [fpk,q] = dsf(A,fs)
% 	    returns: .
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     Last modified: 10 May 2017

if nargin<3,
   fc = 2.5 ;  % default low-pass filter at 2.5 Hz
end

if nargin<4,
   Nfft = round(20*fs) ;	% default FFT length
end

PCNT = 20 ;
if fc>fs/2,
   fc = [] ;
end

% force Nfft to the nearest power of 2
Nfft = 2^round(log(Nfft)/log(2)) ;

if ~isempty(fc),
   Af=fir_nodelay(diff(A),6*fs/fc,fc/(fs/2));
else
   Af = diff(A) ;
end

[S,f]=speclev(Af,Nfft,fs,Nfft,Nfft/2);
v = sum(10.^(S/10),2) ;      % sum spectral power in the three axes
[m,n]=max(v) ;
p = polyfit(f(n+(-1:1))',v(n+(-1:1)),2) ;
fpk = -p(2)/(2*p(1)) ;
q = m/mean(v) ;
