function [m,ndx] = nanmax(a,b)
%NANMAX Maximum ignoring NaNs.
%   M = NANMAX(A) returns the maximum with NaNs treated as missing. 
%   For vectors, NANMAX(A) is the largest non-NaN element in A. For
%   matrices, NANMAX(A) is a row vector containing the maximum non-NaN
%   element from each column. 
%
%   [M,NDX] = NANMAX(A) also returns the indices of the maximum 
%   values in vector NDX.
%
%   M = NANMAX(A,B) returns the larger of A or B which must match in size.
%
%   See also NANMIN, NANMEAN, NANMEDIAN, NANMIN, NANSTD.

%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 2.12 $  $Date: 2002/01/17 21:31:12 $

if nargin < 1, 
   error('Requires at least one input.'); 
end
if nargin==1,
  if isempty(a), m =[]; i = []; return, end

  % Check for NaN's    
  d = find(isnan(a));

  if isempty(d), % No NaN's, just call max.
     [m,ndx] = max(a);
  else
     if min(size(a))==1, % Vector case
       la = length(a);
       a(d) = []; % Remove NaN's
        [m,ndx] = max(a);
        if nargout>1, % Fix-up ndx vector
           pos = 1:la; pos(d) = [];
           ndx = pos(ndx);
        end
    else % Matrix case
        e = any(isnan(a));
        m = zeros(1,size(a,2)); ndx = m;
        % Split into two cases
        [m(~e),ndx(~e)] = max(a(:,~e)); % No NaN's in column.
        e = find(e);
        for i=1:length(e), % NaN's in column
           d = isnan(a(:,e(i)));
           aa = a(:,e(i)); aa(d) = [];
           if isempty(aa),
             m(e(i)) = NaN; ndx(e(i)) = 1;
           else
              [m(e(i)),ndx(e(i))] = max(aa);
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
  if isempty(a), m =[]; i = []; return, end

  d = find(isnan(a));
  a(d) = b(d);
  d = find(isnan(b));
  b(d) = a(d);
  m = max(a,b);
else
  error('Not enough input arguments.');
end  
