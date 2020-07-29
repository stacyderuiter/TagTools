function    E = hilbert_env(X,N)

%		E = hilbert_env(X,N)
%    	Compute the envelope of the signal matrix X using the Hilbert transform.
%		To avoid long transforms, this function uses the overlap and add method.
%
%		Inputs:
%		X is a vector or matrix of signals. If X is a matrix, each column is treated 
%		 as a separate signal. The signals must be regularly sampled for the result
%		 to be correctly interpretable as the envelope.
%		N optionally specifies the transform length used. The default value is 1024
%		 and this may be fine for most situations.
%
%		Results:
%		E is the envelope of X. E is the same size as X: it has the same number of
%		 columns and the same number of samples per signal. It has the same units as
%		 X but being an envelope, all values are >=0.	
%
%		Example:
%		 s = sin(0.1*(1:10000)').*sin(0.001*(1:10000)') ;
%		 E = hilbert_env(s) ;
%		 plot([s E])
% 	    % E contains 3 positive half cycles of a sine wave that trace the upper limit
%		 % of signal s.
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     Last modified: 20 July 2017

if nargin<1,
	help hilbert_env
	return
end

if nargin<2 || isempty(N),
	N = 1024 ;                    % must be even
end

if size(X,1)==1,		% make sure X is a column vector or matrix
	X = X' ;
end
	
taper = triang(N)*ones(1,size(X,2)) ;
nbuffs = floor(size(X,1)/(N/2)-1) ;
iind = 1:N ;
oind = 1:N/2 ;
lind = N/2+1:N ;
E = zeros(size(X)) ;

if nbuffs==0,
   E = abs(hilbert(X)) ;
   return
end

% first buffer
H = hilbert(X(1:N,:)) ;
E(oind,:) = abs(H(oind,:)) ;
lastH = H(lind,:).*taper(lind,:) ;

for k=2:nbuffs-1,
   kk = (k-1)*N/2 ;
   H = hilbert(X(kk+iind,:)).*taper ;
   E(kk+oind,:) = abs(H(oind,:)+lastH) ;
   lastH = H(lind,:) ;
end

% last buffer
kk = (nbuffs-1)*N/2 ;
H = hilbert(X(kk+1:end,:)) ;
E(kk+oind,:) = abs(H(oind,:).*taper(oind,:)+lastH) ;
E(kk+N/2+1:end,:) = abs(H(N/2+1:end,:)) ;
