function [block_ac] = block_acf(resids, blocks, make_plot, max_lag)
% Compute autocorrelation function, respecting grouping by a categorical variable
%   
% This function allows calculation of an ACF for a dataset with multiple 
%    independent units (for example, data from several individuals, data 
%    from multiple dives by an individual animal, etc.). The groups 
%    (individual, dive, etc.) should be coded in a categorical variable. 
%    The function calculates correlation coefficients over all levels of 
%    the categorical variable, but respecting divisions between levels 
%    (for example, individual animals are kept separate).
%
% Inputs:
%    resids:    The variable for which the ACF is to be computed (often a 
%               vector of residuals from a fitted model)
%    blocks:    A variable indicating the groupings (must be the 
%               same length as resids). blocks can be a numeric vector (each unique
%               number is interpreted as a group identifier) or a vector or cell array of strings
%               (each unique entry interpreted as a group identifier).
%               The ACF will be computed only for data 
%               points within the same block.)
%    make_plot: (optional) 1 if a plot should be produced (the default), 0 if no plot.
%    max_lag:   (optional) ACF will be computed at 0-max_lag lags, ignoring all 
%               observations that span blocks. Defaults to the minimum number 
%               of observations in any block. The function will allow you to 
%               specify a max_lag longer than the shortest block if you so choose.
%
% Example:
% rng(1) % to control the seed
% resids = randn(150,1) 
% % in real life resids are normally residuals from a
% % fitted model, not random numbers
% blocks = [repmat('animal1', 25, 1); repmat('animal2', 70, 1); ...
%           repmat('animal3', (150-25-70), 1)] ;
% block_ac = block_acf(resids, blocks, 1, 10) ; %plot 1st 10 lags
% block_ac % and the first 10 lags ARE...
%          % [1.0000; -0.0292; 0.0253; 0.1040; 0.0042; 0.0414; -0.1767; -0.0472; 0.1063; -0.0906; -0.0132]
% 
%


if length(blocks) ~= length(resids)
    warning("blocks and resids must be the same length.")
end

if nargin < 3
    make_plot=1 ;
end

if ischar(blocks)
    blocks = cellstr(blocks);
end

% find number of elements in each block
y = zeros(size(unique(blocks)));
uniqueX = unique(blocks, 'stable');
for i = 1:length(uniqueX)
    if iscell(blocks)
        y(i) = sum(strcmp(uniqueX{i}, blocks));
    else
        y(i) = sum(blocks==uniqueX(i));
    end
end

if nargin < 4
   max_lag = min(y);
end
    
% get indices of last element of each block (excluding the last block)
i1 = y(1:(end-1));
% allocate space for results
block_ac = ones(max_lag + 1, 1);
r = resids ;

for k = 1:max_lag
    % insert NaN before first entry of each new block
    for b = 1:(length(y)-1)
        r = [r(1:y(b)); NaN; r((y(b)+1):end) ];
    end
    % adjust for the growing r
    i1 = i1 + [0:1:(length(uniqueX)-2)]' ;
    [ack,lagsk] = acf(r, max_lag, 0);
    block_ac(k + 1) = ack(k + 1);
end

if make_plot
    plot_acf([0:1:max_lag] , block_ac, length(resids)) ;
end