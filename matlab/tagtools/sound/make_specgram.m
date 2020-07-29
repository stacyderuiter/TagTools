function [s,f,t]=make_specgram(x,nfft,fs,window,noverlap)

%   make_specgram(x)   % Plot a spectrogram with default settings
%   or
%   [s,f,t] = make_specgram(x,nfft,fs,window,noverlap) % Calculate
%    spectrogram & time & frequency vectors
% 
%   This is a wrapper function for the Matlab and Octave function specgram
%   & the Matlab function spectrogram. specgram will be replaced by Matlab
%   at sometime in the near future. This function provides legacy
%   functionality of specgram in Matlab using spectrogram, while supporting
%   legacy functionality for specgram in Octave. 
%
%   Inputs:
%   x signal vector. 
%   nfft specifies the number of frequency points used to calculate the
%     discrete Fourier transforms.
%   fs Frequency of sampling
%   window If you specify a scalar for WINDOW, make_specgram uses a Hanning 
%     window of that length. WINDOW must have length smaller than or equal 
%     to NFFT and greater than NOVERLAP.
%   noverlap NOVERLAP is the number of samples the sections of x overlap.
%
%   Results:
%   If make_specgram is called with no output arguments, it will plot the
%   spectrogram. If it is called with output arguments, it will not do the
%   plot but will return the following:
%   s Spectrogram values of signal x in dB. 
%   f Vector of Frequencies (Hz)
%   t Vector of times (seconds)
%
%   Default values
%   nfft=256;
%   fs=2;
%   window=hanning(nfft);
%   noverlap=length(window)/2;
%   
%   Example:
%   x = chirp([0:0.001:2],0,2,500);
%   fs = 2;
%   nfft = 256;
%   numoverlap = 128;
%   window = hanning(nfft);
%   make_specgram(x,nfft,fs,window,numoverlap) %Spectrogram plot
%   or 
%   [s,f,t]=make_specgram(x,nfft,fs,window,numoverlap); % Calculate
%   spectrogram
%
%  Valid: Matlab, Octave
%  rjs30@st-andrews.ac.uk and markjohnson@st-andrews.ac.uk
%  last modified: 04 August 2017

if nargin<1
    help make_specgram
    return
end

if ~exist('specgram','file') && ~exist('specgram','file')
    disp('Matlab users install: Signal processing toolbox, Octave users install packages: control & signal');
    help make_specgram
    return 
end

if nargin<2  % Set defaults to the same as specgram
    nfft=256;
    fs=2;
    window=hanning(nfft);
    noverlap=length(window)/2;
end

if nargin <3
    fs=2;
    window=hanning(nfft);
    noverlap=length(window)/2;
end

if nargin<4
    window=hanning(nfft);
    noverlap=length(window)/2;
end
    
if nargin<5
    noverlap=length(window)/2;
end


% Use spectrogam 
if ~exist('specgram','file')
    [s,f,t] = spectrogram(x,window,noverlap,nfft,fs)
end

% Use specgam
if ~exist('spectrogram','file')
    [s,f,t] = specgram(x,nfft,fs,window,noverlap);
end

% What to do if both installed
if exist('spectrogram','file') && exist('specgram','file')
    [s,f,t] = specgram(x,nfft,fs,window,noverlap);
end

if nargout == 0
    imagesc(t,f, 20*log10(abs(s)))
    set(gca,'ydir','normal');
    xlabel('Time')
    ylabel('Frequency')
    s=[]; f=[]; t=[];
end

if nargout == 1
    f=[]; t=[];
end

end
