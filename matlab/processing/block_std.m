function    [Y,t] = block_std(X,n,nov)

%     [Y,t] = block_std(X,n,nov)
%	   Compute the standard deviation of successive blocks of samples.
%		
%		Inputs: 
%		X is a vector or a matrix containing samples of a signal in each column.
%		n is the number of samples from X to use in each analysis block.
% 	   nov is the number of samples that the next block overlaps the previous block.
%
%		Returns:
%		Y is a vector or matrix containing the standard deviation of each block. 
%     If X is a mxn matrix, Y is pxn where p is the number of complete n-length 
%     blocks with nov that can be made out of m samples, 
%     i.e., n+(p-1)*(n-nov) < m
%
%		Example:
%		 sampleMatrix = [1 2 3; 4 5 6; 7 8 9]
%        block_std(sampleMatrix, 3, 1)
%        % ans = [3 3 3]
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     Last modified: 10 June 2018

if nargin<2
	help block_std
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
Y(:,1) = std(ss)' ;
for k=2:size(X,2),
   [ss,z] = buffer(X(:,k),n,nov,'nodelay') ;
   Y(:,k) = std(ss)' ;
end

t = round(n/2+(0:size(Y,1)-1)*(n-nov))' ;
