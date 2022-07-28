function    [Y,t] = block_median(X,n,nov)

%     [Y,t] = block_median(X,n,nov)
%	   Compute the median of successive blocks of samples.
%		
%		Inputs: 
%		X is a vector or a matrix containing samples of a signal in each column.
%		n is the number of samples from X to use in each analysis block.
% 	   nov is the number of samples that the next block overlaps the previous block.
%
%		Returns:
%		Y is a vector or matrix containing the median value of each block. If X is a
%		mxn matrix, Y is pxn where p is the number of complete n-length blocks with 
%		nov that can be made out of m samples, i.e., n+(p-1)*(n-nov) < m
%		Example:
%		 TBD 
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     Last modified: 10 May 2017

if nargin<2,
	help block_median
	return
end
	
if nargin<3,
   nov = 0 ;
end

if size(X,1)==1,	% catch the case of a row vector input
	X = X' ;
end
	
nov = min(n,nov) ;
[ss,z] = buffer(X(:,1),n,nov,'nodelay') ;
Y = zeros(size(ss,2),size(X,2)) ;
Y(:,1) = mean(ss)' ;
for k=2:size(X,2),
   [ss,z] = buffer(X(:,k),n,nov,'nodelay') ;
   Y(:,k) = median(ss)' ;
end

t = round(n/2+(0:size(Y,1)-1)*(n-nov))' ;
