function [m, ndx] = nanmin(a,b)
%NANMIN NaN protected minimum.
%   M = NANMIN(A) returns the minimum with NaNs treated as missing values. 
%   For vectors, NANMIN(A) is the smallest non-NaN element in A. For
%   matrices, NANMIN(A) is a vector containing the minimum non-NaN
%   element from each column. 
%
%   [M, NDX] = NANMIN(A) also returns the indices of the minimum values
%   in vector NDX.
%
%   M = NANMIN(A,B) returns the smaller of A or B which must match in size.
%
%   See also NANMAX, NANMEAN, NANMEDIAN, NANSTD, NANSUM.

%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 2.12 $  $Date: 2002/01/17 21:31:13 $

if nargin<1, 
   error('Requires at least one input arguments'); 
end
if nargin==1,
   if isempty(a), m =[]; ndx = []; return, end

   % Check for NaNs    
   d = find(isnan(a));

   if isempty(d), % No NaNs, just call min.
      [m,ndx] = min(a);
   else
      if min(size(a))==1, % Vector case
	la = length(a);
	a(d) = []; % Remove NaNs
         [m,ndx] = min(a);
         if nargout>1, % Fix-up ndx vector
            pos = 1:la; pos(d) = [];
            ndx = pos(ndx);
         end
      else % Matrix case
         e = any(isnan(a));
         m = zeros(1,size(a,2)); ndx = m;
         % Split into two cases
         [m(~e),ndx(~e)] = min(a(:,~e));
         e = find(e);
         for i=1:length(e),
            d = isnan(a(:,e(i)));
            aa = a(:,e(i)); aa(d) = [];
            if isempty(aa),
               m(e(i)) = NaN; ndx(e(i)) = 1;
            else
               [m(e(i)),ndx(e(i))] = min(aa);
               if nargout>1, % Fix-up ndx vector
                  pos = 1:size(a,1); pos(d) = [];
                  ndx(e(i)) = pos(ndx(e(i)));
               end
            end
         end
      end
   end
elseif nargin==2,
   if any(size(a)~=size(b)), error('The inputs must be the same size.'); end
   if nargout>1, error('Too many output arguments.'); end
   if isempty(a), m =[]; ndx = []; return, end

   d = find(isnan(a));
   a(d) = b(d);
   d = find(isnan(b));
   b(d) = a(d);
   m = min(a,b);
else
   error('Not enough input arguments.');
end  
