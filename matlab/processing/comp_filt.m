function    Xf = comp_filt(X,fs,fc)

%    Xf=comp_filt(X,fs,fc)		% X is a vector or matrix
%	  or
%    Xf=comp_filt(X,fc)			% X is a sensor structure
%    Complementary filtering of a signal. This breaks signal X into two or more
%	  frequency bands such that the sum of the signals in the separate bands is equal
%	  to the original signal.
%
%	  Inputs:
%    X is a vector or matrix (i.e., with a signal in each column), or a sensor
%		structure.
%    fs is the sampling rate of the sensor data in Hz (samples per second). fs is only
%		needed if X is not a sensor structure.
%	  fc specifies the cut-off frequency or frequencies of the complimentary filters.
%		Frequencies are in Hz. If one frequency is given, X will be split into a low-
%		and a high-frequency component. If fc contains more than one value, X will be
%		split into multiple complimentary bands. Each filter length is 4*fs/fc.
%		Filtering adds no group delay.
%
%    Returns:
%	  Xf is a cell array of filtered signals. There are n+1 cells where n is the length of
%		fc. Cells are ordered in Xf from lowest to highest frequency. Each cell contains a
%		vector or matrix of the same size as X, and at the same sampling rate as X.
%
%	  Example:
%		loadnc('testset1')
%		Xf = comp_filt(A,[0.18 0.8]);
%		plott(P,'r',Xf{1},A.sampling_rate,Xf{2},A.sampling_rate,Xf{3},A.sampling_rate)
% 	   % plots a dive profile and three filtered versions of A: low, mid and high frequency.
%
%    Valid: Matlab, Octave
%    markjohnson@st-andrews.ac.uk
%    Last modified: 18 August 2021

Xf = [] ;
if nargin<2,
   help comp_filt
   return
end

if isstruct(X),
	fc = fs ;
	[X,fs] = sens2var(X,'regular') ;
	if isempty(X), return, end
else
	if nargin<3,
		help comp_filt
		return
	end
end

nf = 4*fs./fc ;
Xf = cell(1,length(fc)+1) ;
for k=1:length(fc),
	Xf{k} = fir_nodelay(X,nf(k),fc(k)/(fs/2)) ;
	X = X-Xf{k} ;
end
Xf{k+1} = X ;
