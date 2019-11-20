function    Y = trimmed_mean(X,n,nlow,nhigh)

%     Y = trimmed_mean(X,n,nlow,nhigh)
%     Computes the nth-order trimmed mean filter on each column of X. 
%		The filter output is the mean of each consecutive group 
%		of n samples when the nlow lowest and nhigh highest have been
%     removed. This is useful for smoothing signals with occasional
%		outliers. The filter does not introduce delay. The start and end 
%		values, i.e., within n samples of the start or end of the
%		input data, are computed using shorter means without trimming.
%
%		Inputs:
%		X is a sensor structure or a vector or matrix. If there are
%		 multiple columns in the data, each column is treated as a 
%		 separate signal to be filtered.
%		n is the filter length. If an even n is given, it is
%		 automatically incremented to make it odd. This ensures that
%		 the filter has no delay. Note that processing will
%		 be very slow if n is large.
%     nlow is the number of the lowest valued samples in each block
%      of n samples to trim. Default is 0.
%     nhigh is the number of the highest valued samples in each block
%      of n samples to trim. Default is 0.
%
%     Note: n must be greater than nlow+nhigh. The mean is conducted over
%     n-nlow-nhigh samples.
%
%		Returns:
%		Y is the output of the filter. It has the same size as X and
%		 has the same sampling rate and units as X. If X is a sensor 
%		 structure, Y will also be.
%
%		Example:
%		 v=[1 3 4 4 20 -10 5 6 -6 7 -9 -4]';
%		 w = trimmed_mean(v,5,1,2)
% 	    returns: w=[2.6667 3 3.5 3.5 4 4.5 -0.5 -0.5 -0.5 -5 -3 -2].
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     Last modified: 22 Dec 2018

if nargin<2,
	help trimmed_mean
	return
end

if nargin<3 || isempty(nlow)
  nlow = 0 ;
end

if nargin<4 || isempty(nhigh)
  nhigh = 0 ;
end

if n<=nlow+nhigh,
   fprintf('Filter length must be greater than number of samples trimmed\n') ;
   Y = [] ;
   return
end

if isstruct(X),
	x = sens2var(X,'regular') ;
else
	x = X ;
end
	
if size(x,1)==1,
   x = x(:) ;
end

nd2 = floor(n/2) ;
if 2*nd2==n,
   n = n+1 ;
end

kn = nlow+1:n-nhigh ;
Y = repmat(NaN,size(x)) ;

for k=1:nd2,
   Y(k,:) = nanmean(x(1:k+nd2,:)) ;
end
for k=1:nd2,
   Y(end-nd2+k,:) = nanmean(x(end-2*nd2+k:end,:)) ;
end

for k=1:size(x,2),
   [Z,z] = buffer(x(:,k),n,n-1,'nodelay') ;
   Z = sort(Z) ;
   Y(nd2+1:end-nd2,k) = nanmean(Z(kn,:))' ;
end

if isstruct(X),
	X.data = Y ;
	h = sprintf('trimmed_mean(%d,%d,%d)',n,low,high) ;
	if ~isfield(X,'history') || isempty(X.history),
		X.history = h ;
	else
		X.history = [X.history ',' h] ;
	end
	clear Y
	Y = X ;
end
