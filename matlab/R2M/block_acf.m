function [block_acf] = block_acf(resids, blocks, make_plot, max_lag)
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
%    resids: The variable for which the ACF is to be computed (often a 
%            vector of residuals from a fitted model)
%    blocks: A categorical variable indicating the groupings (must be the 
%            same length as resids. ACF will be computed only for data 
%            points within the same block.)
%    make_plot: Logical. Should a plot be produced?
%    max_lag: (optional) ACF will be computed at 0-max_lag lags, ignoring all 
%             observations that span blocks. Defaults to the minimum number 
%             of observations in any block. The function will allow you to 
%             specify a max_lag longer than the shortest block if you so choose.


if length(blocks) ~= length(resids)
    warning("blocks and resids must be the same length.")
end

if nargin < 3
    error('Input for make_plot is required (TRUE or FALSE)')
end

if nargin < 4
    y = zeros(size(unique(blocks)));
    uniqueX = unique(blocks);
    for i = 1:length(uniqueX)
        y(i) = sum(blocks==uniqueX(i));
    end
    max_lag = min(y);
end
    
%get indices of last element of each block (excluding the last block)
i1 = cumsum(sort(y));
i1 = i1(1:(end-1));
r = resids;
block_acf = ones(max_lag + 1, 1);

for k = 1:max_lag
    %%%%%%%%%%%%%%%%for b = i1(1:end)
    %%%%%%%%%%%%%%%%    r = [r(1:b), NaN, r((b+1):end)];
    %%%%%%%%%%%%%%%%end
    %adjust for the growing r
    vec = (unique(blocks) - 1);
    vec_end = vec(end);
    vect = (0:(vec_end));
    vect_end = vect(1:(end-1));
    i1 = i1 + vect_end;
    this_acf = [1; acf(r', max_lag)];
    block_acf(k + 1) = this_acf(k + 1, 1);
end

if make_plot,
    %insert coefficients from block_acf into A
    A = block_acf;
    %plot block_acf
    bar(A)
end