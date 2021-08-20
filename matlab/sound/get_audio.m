function			[x,fs] = get_audio(fname,samples)

%		[x,fs] = get_audio(fname)		% read an entire WAV file
%		or
%		[x,fs] = get_audio(fname,samples)	% read a section of a WAV file
%		or
%		[x,fs] = get_audio(fname,'size')	% get the size and sampling rate
%
%		This is a wrapper function for the audioread and wavread
%		functions which have changed over versions of Matlab. This
%		function provides the legacy functionality of wavread but
%		calls audioinfo and audioread to achieve this if these
%		functions are available.
%
%		Inputs:
%		fname is the full filename (including path if the file is
%		 not in the current working directory or saved path) of the
%		 WAV file. Include the .wav suffix (or any other suffix that
%		 may be used.
%		samples is a two-element vector containing the start and end
%		 sample to read in. Samples in the file start at 1. If the
%		 string 'size' is specified instead of a 2-element vector,
%		 the size of the file is returned in x and the sampling rate
%		 in fs. x will be a two-element vector containing the number 
%		 of samples-per-channel and the number of channels.
%
%		Example:
%		 [x,fs]=get_audio('sound_sample1.wav','size')
% 	    returns: x=[576000,2], fs=192000
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     Last modified: 23 July 2017

if nargin<1,
	help get_audio
	return
end

if nargin<2,
	samples = [] ;
end

if ischar(samples) && strcmpi(samples,'size'),	
	try
		info = audioinfo(fname) ;
		x = [info.TotalSamples,info.NumChannels] ;
		fs = info.SampleRate ;
	catch
		[x,fs] = wavread(fname,'size') ;
	end
	
elseif isempty(samples),
	try
		[x,fs] = audioread(fname) ;
	catch
		[x,fs] = wavread(fname) ;
	end
	
else
	try
		[x,fs] = audioread(fname,samples) ;
	catch
		[x,fs] = wavread(fname,samples) ;
	end
end
