function [ac, lags] = acf(y,max_lag, make_plot)
% Compute the autocorrelation function (for 0-max_lag lags).
%
% Inputs:
% y -           data -- a row- or column-vector for which to compute the ACF. If y contains any missing values, then the covariances are computed from the complete cases, so the resulting estimates might not be a valid autocorrelation sequence, and may contain missing values. 
% max_lag -     (optional) maximum lag for which ACF should be computed. If N=length(y), 
%               Defaults to 10*log10(N) or (N-1), whichever is smaller.
% make_plot -    If 1 (the default), make a plot of the results. If 0, no plot is created.
%
% Output:
% ac -          vector with (max_lag + 1) rows and 1 column containing autocorrelations
% lags -        vector the same length as ac indicating the lags for each entry of ac ([0:1:max_lag]).          
%
% Notes:    The values of the ACF are computed using definitions from:
%           Venables, W. N. and Ripley, B. D. (2002) Modern Applied Statistics with S. Fourth Edition. Springer-Verlag.
%           Results should match those of the R function stats::acf with input type='correlation' (the default).
%           The ACF at lag 1 is 1 by definition.
%           If a plot is created, it will include horizontal dotted lines at values at +/- (1.96)*(1/sqrt(N)), 
%           where N is the number of observations in y.  These are approximate 95% confidence intervals for the ACF,
%           in the (unrealistic) case of a time series composed of strictly independent data points. (So these confidence bounds should be taked with a grain of salt.)
%           (These confidence bounds are the same ones plotted by R's acf() function.)
%           
%
% Example:
% rng(1)
% acf(randn(100,1), 10)
% Returns: [1.0000; -0.1003; -0.0657; 0.0845; 0.0706; 0.0552; -0.2212; -0.0576; 0.2531; -0.0730; -0.0271]
%

% ===========================================
% INPUT CHECKS
% ===========================================

d = size(y) ;
N = max(d) ;
if min(d) ~=1
    error('Input series y must be an row or column vector')
end

if d(2)==1
  %if y is a row vec make it a column
  y=y(:) ;
end

if nargin < 2
  max_lag = min(10*log10(N), (N-1)) ;
end

[a1, a2] = size(max_lag) ;
if ~((a1==1 && a2==1) && (max_lag<N))
    error('Input max_lag must be a 1x1 scalar, and must be less than length of series y')
end

if nargin < 3
  make_plot=1 ;
end

% ===========================================
% compute ACF
% ===========================================

% loop over lags
lags = [0:1:max_lag]' ;
ac = ones((max_lag+1),1) ;
s0 = [1:1:N] ;
s0 = s0(~isnan(y)) ;
c0 = (1/N) * sum( (y(s0)-nanmean(y)).^2 ) ;
mu = nanmean(y) ;
for t = 1:max_lag
    clear st yt
    % indices of time points to use for acf calc
    st = [ max(1, -t) :1: min((N-t), N) ] ;
    % assemble the data points to use for acf calc
    yt = [y(st + t), y(st)] ;
    % get only the complete cases (no NaNs)
    yt = yt(~isnan(sum(yt,2)),:) ;
    % compute ac for lag t
    ac(t+1) = (1/N)*(1/c0)* sum(prod(yt - mu , 2)) ;   
end

% ===========================================
% plot ACF
% ===========================================

if make_plot==1
    plot_acf(lags,ac,N);
end