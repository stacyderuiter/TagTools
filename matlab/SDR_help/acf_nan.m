function ta = acf_nan(data,nlags)
% NANAUTOCORR, autocorrelation function (ACF) with NaNs 
% calculates the nlag autocorrelation coefficient for a data vector containing NaN.
% couples of data including NaNs are excluded from the computation.
% Here the ACF is calculated using the Pearson's correlation coefficient for each lag. 
% USAGE:
% out=nanautocorr(data,nlags) returns a 1xnlags vector of linear
% coefficients, caluclated on a 1xN or Nx1 data vector.
% [out,b]=nanautocorr(data,nlags,R) gives the confidence boundaries [b,-b]
% of the asymptotic normal distribution of the coefficient, using
% Bartlett's formula.
% version: 0.1 2013/02
% author : Fabio Oriani.1, fabio.oriani@unine.ch
%    (.1 Chyn,University of Neuchâtel)

if isrow(data)
    data=data';
elseif sum(isnan(data))>sum(not(isnan(data)))/3
    warning('AC:toomanynans','more than a third of data is NaN! autocorrelation is not reliable')
end

[n1, n2] = size(data) ;
if n2 ~=1
    error('Input series y must be an nx1 column vector')
end

[a1, a2] = size(nlags) ;
if ~((a1==1 && a2==1) && (nlags<n1))
    error('Input number of lags p must be a 1x1 scalar, and must be less than length of series y')
end

% -------------
% BEGIN CODE
% -------------

ta = zeros(nlags,1) ;
global N 
N = max(size(data)) ;
global ybar 
ybar = nanmean(data); 

% Collect ACFs at each lag i
for i = 1:nlags
   ta(i) = acf_k(data,i) ; 
end

% ---------------
% SUB FUNCTION
% ---------------
function ta2 = acf_k(data,nlags)
% ACF_K - Autocorrelation at Lag k
% acf(y,k)
%
% Inputs:
% y - series to compute acf for
% k - which lag to compute acf
% 
global ybar
global N
cross_sum = zeros(N-nlags,1) ;

% Numerator, unscaled covariance
for i = (nlags+1):N
    cross_sum(i) = (data(i)-nanmean(data(1:i)))*(data(i-nlags)-nanmean(data(1:i))) ;
end

% Denominator, unscaled variance
yvar = (data-ybar)'*(data-ybar) ;

ta2 = sum(cross_sum) / yvar ;