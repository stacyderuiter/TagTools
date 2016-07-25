function y = nanmean(x)
%NANMEAN Average or mean ignoring NaNs.
%   NANMEAN(X) returns the average treating NaNs as missing values.  
%   For vectors, NANMEAN(X) is the mean value of the non-NaN
%   elements in X.  For matrices, NANMEAN(X) is a row vector
%   containing the mean value of each column, ignoring NaNs.
%
%   See also NANMEDIAN, NANSTD, NANMIN, NANMAX, NANSUM.

%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 2.13 $  $Date: 2002/12/18 20:05:13 $

if isempty(x) % Check for empty input.
    y = NaN;
    return
end

% Replace NaNs with zeros.
nans = isnan(x);
i = find(nans);
x(i) = zeros(size(i));

% count terms in sum over first non-singleton dimension
dim = find(size(x)>1);
if isempty(dim)
   dim = 1;
else
   dim = dim(1);
end
count = sum(~nans,dim);

% Protect against a column of all NaNs
i = find(count==0);
count(i) = 1;
y = sum(x,dim)./count;
y(i) = NaN;
