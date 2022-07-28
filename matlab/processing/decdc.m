function      [y,h] = decdc(x,df)

%     y = decdc(x,df)
%     Reduce the sampling rate of a time series by an integer factor.
%	   This is similar to decimate() and resample() but is delay free 
%	   and DC accurate which are important for sensor data. 
%
%		Inputs:
%		x is a sensor structure or a vector or matrix containing the signal(s) 
%		 to be decimated. If x is a matrix (or the data in the sensor structure
%		 is a matrix), each column is decimated separately.
%		df is the decimation factor. The output sampling rate is the input
%		 sampling rate divided by df. df must be an integer greater than 1.
%
%		Returns:
%		y is the decimated signal vector or matrix. It has the same number
%		 of columns as x but has 1/df of the rows. If x is a sensor structure,
%		 y is also, in which case the metadata is copied except for the sampling
%		 rate which is adjusted to the new value.
%
%     Decimation is performed by first low-pass filtering x and then
%		keeping 1 sample out of every df. A symmetric FIR filter with length
%		12*df and cutoff frequency 0.4*fs/df is used. The group delay of the
%		filter is removed.
%		For large decimation factors (e.g., df>>50), it is better to perform
%		several decimations with lower factors. For example to decimate by 120,
%		use: decdc(decdc(x,10),12).
%
%		Example:
% 		s=sin(2*pi/100*(0:1000-1)');		% sine wave at full sampling rate
% 		s4=sin(2*pi*4/100*(0:250-1)');	% same sine wave at 1/4 of the sampling rate
% 		ds=decdc(s,4);							% decimate the full rate sine wave
%		plot([s4 ds])
%		max(abs(s4-ds))
%		Returns: 0.0023
% 		i.e., there is almost no difference between s4 and ds. 
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     modified: June 2021 - added check on column orientation (line 57)

y = [] ; h = [] ;
if nargin<2,
   help decdc ;
   return
end

if round(df)~=df,
   df = round(df) ;
   fprintf('Warning: decdc needs integer decimation factor. Using %d\n',df) ;
end

if isstruct(x),
	X = x ;
	x = sens2var(x,'regular') ;
end

if size(x,1)==1,  % make sure data is column-oriented
   x = x' ;
end

flen = 12*df ;
h = fir1(flen,0.8/df)' ;
xlen = size(x,1) ;
dc = flen+floor(flen/2)-round(df/2)+(df:df:xlen) ;
% above line ensures that the output samples coincide with every df of 
% the input samples.

y = zeros(length(dc),size(x,2)) ;
for k=1:size(x,2),
    xx = [2*x(1,k)-x(1+(flen+1:-1:1),k);x(:,k);2*x(xlen,k)-x(xlen-(1:flen+1),k)] ;
    v = conv(h,xx) ;
    y(:,k) = v(dc) ;
end

if exist('X','var'),
	X.data = y ;
	X.sampling_rate = X.sampling_rate/df ;
	hh = sprintf('decdc(%d)',df) ;
	if ~isfield(X,'history') || isempty(X.history),
		X.history = hh ;
	else
		X.history = [X.history ',' hh] ;
	end
	y = X ;
end
	
