function    Y = median_filter(X,n,noend)

%     Y = median_filter(X,n)
%     Computes the nth-order median filter on the columns
%     of X. The filter output is the median of each consecutive 
%		group of n samples in each column in X. The filter does
%		not introduce delay. The start and end values, i.e., within
%		n samples of the start or end of X, are computed with
%     decreasing order median filters unless the function is
%		called as:
%     Y = median_filter(X,n,1)
%     In this case, start and end values are taken directly from X 
%     without short median filters.
%
%		Inputs:
%		X is a vector or matrix. If it is a matrix, each column is
%		 treated as a separate signal to be filtered.
%		n is the median filter length. If an even n is given, it is
%		 automatically incremented to make it odd. This ensures that
%		 the median is well-defined (the median of an even length
%		 vector is usually defined as the mean of the middle two points
%		 but may differ in different programmes). Note that a short
%		 n (e.g., 3 or 5) is usually sufficient and that processing will
%		 be very slow if n is large.
%
%		Returns:
%		Y is the output of the filter. It has the same size as X and
%		 has the same sampling rate and units as X.
%
%		Example:
%		 v=[1 3 4 4 20 -10 5 6 6 7]';
%		 w = median_filter(v,3,1)
% 	    returns: w=[1 3 4 4 4 5 5 6 6 7].
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     Last modified: 3 June 2017


if size(X,1)==1,
   X = X(:) ;
end

nd2 = floor(n/2) ;
if 2*nd2==n,
   n = n+1 ;
end

Y = repmat(NaN,size(X)) ;
if nargin==3 & noend,
   Y(1:nd2,:) = X(1:nd2,:) ;
   Y(end+(-nd2+1:0),:) = X(end+(-nd2+1:0),:) ;
else
   for k=1:nd2,
      Y(k,:) = nanmedian(X(1:k+nd2,:)) ;
   end
   for k=1:nd2,
      Y(end-nd2+k,:) = nanmedian(X(end-2*nd2+k:end,:)) ;
   end
end

for k=1:size(X,2),
   Z = buffer(X,n,n-1,'nodelay') ;
   Y(nd2+1:end-nd2,k) = nanmedian(Z)' ;
end

