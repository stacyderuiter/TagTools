function    Y = median_filter(X,n,noend)

%     Y = median_filter(X,n)
%     Computes the nth-order median filter each column of X. 
%		The filter output is the median of each consecutive group 
%		of n samples. This is useful for removing occasional
%		outliers in data that is otherwise fairly smooth. This
%		makes it appropriate for pressure, temperature and magnetometer
%		data (amongst other sensors) but not so suitable for
%		acceleration which can be highly dynamic.
%		The filter does not introduce delay. The start and end 
%		values, i.e., within n samples of the start or end of the
%		input data, are computed with decreasing order median filters 
%		unless the function is called as:
%
%     Y = median_filter(X,n,1)
%
%     In this case, start and end values are taken directly from X 
%     without short median filters.
%
%		Inputs:
%		X is a sensor structure or a vector or matrix. If there are
%		 multiple columns in the data, each column is treated as a 
%		 separate signal to be filtered.
%		n is the filter length. If an even n is given, it is
%		 automatically incremented to make it odd. This ensures that
%		 the median is well-defined (the median of an even length
%		 vector is usually defined as the mean of the middle two points
%		 but may differ in different programmes). Note that a short
%		 n (e.g., 3 or 5) is usually sufficient and that processing will
%		 be very slow if n is large.
%
%		Returns:
%		Y is the output of the filter. It has the same size as X and
%		 has the same sampling rate and units as X. If X is a sensor 
%		 structure, Y will also be.
%
%		Example:
%		 v=[1 3 4 4 20 -10 5 6 6 7]';
%		 w = median_filter(v,3,1)
% 	    returns: w=[1 3 4 4 4 5 5 6 6 7].
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     Last modified: 2 August 2017 by RJS

if nargin<2,
	help median_filter
	return
end

if nargin<3 %RJS updated 2017-08-02
  noend=1;
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

Y = repmat(NaN,size(x)) ;
if nargin==3 && noend==1, %RJS updated 2017-08-02
   Y(1:nd2,:) = x(1:nd2,:) ;
   Y(end+(-nd2+1:0),:) = x(end+(-nd2+1:0),:) ;
else
   for k=1:nd2,
      Y(k,:) = nanmedian(x(1:k+nd2,:)) ;
   end
   for k=1:nd2,
      Y(end-nd2+k,:) = nanmedian(x(end-2*nd2+k:end,:)) ;
   end
end

for k=1:size(x,2),
   [Z,z] = buffer(x(:,k),n,n-1,'nodelay') ; %MJ updated 2018-03-01
   Y(nd2+1:end-nd2,k) = nanmedian(Z)' ;
end

if isstruct(X),
	X.data = Y ;
	h = sprintf('median_filter(%d)',n) ;
	if ~isfield(X,'history') || isempty(X.history),
		X.history = h ;
	else
		X.history = [X.history ',' h] ;
	end
	clear Y
	Y = X ;
end
