function    X = remove_nan(X)

%    X = remove_nan(X)
%     Replace any NaNs in the columns of X with the nearest non-NaN
%     number in the same column. If an entire column is NaN, the first
%     non-NaN number in the matrix is used as a filler. If the entire
%     matrix is NaN, 1 is used as a filler.
%   
%    Example:
%     sampleNaNnyMatrix = [1 NaN 3 NaN; NaN 5 NaN NaN; 7 NaN 9 NaN]
%     sampleNaNnyMatrixTwo = [1 2 3; NaN NaN NaN; NaN NaN NaN]
%     notNaNnyAnymore = remove_nan(sampleNaNnyMatrix)
%     notNaNnyAnymoreEither = remove_nan(sampleNaNnyMatrixTwo)
%
%
%    Valid: Matlab, Octave
%    markjohnson@st-andrews.ac.uk
%    Last modified: 10 july 2018

if size(X,1)==1,
   X = X' ;
   trns = 1 ;
else
   trns = 0 ;
end

for k=1:size(X,2),
   v = isnan(X(:,k)) ;
   if all(v),
      kg = find(~isnan(X(:)),1) ;
      if isempty(kg),
         X(:,k) = 1 ;
      else
         X(:,k) = X(kg) ;
      end
      continue
   end
   kn = find(v) ;
   kg = unique([max(kn-1,1);min(kn+1,size(X,1))]) ;
   kg = kg(~ismember(kg,kn)) ;
   kk = nearest(kg,kn) ;
   X(kn,k) = X(kg(kk),k) ;
end

if trns,
   X = X' ;
end
