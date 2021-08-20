function D = m_dist(data,fs, smoothDur, overlap, consec, cumSum, expStart, expEnd, baselineStart, baselineEnd, BL_COV)
% Calculate Mahalanobis distance for a multivariate time series.
%
% Inputs: 
%  data: A data frame or matrix with one row for each time point.  
%     Note that the Mahalanobis distance calculation should be 
%     carried out on continuous data only, so if your data contain 
%     logical, factor or character data, proceed at your own 
%     risk...errors (or at least meaningless results) will probably ensue.
%  fs: The sampling rate in Hz (data should be regularly sampled). 
%     If not specified it will be assumed to be 1 Hz.
%  smoothDur: The length, in minutes, of the window to use for calculation 
%     of "comparison" values. If not specified or zero, there 
%     will be no smoothing (a distance will be calculated for each data observation).
%  overlap: The amount of overlap, in minutes, between consecutive "comparison" 
%     windows. smooth_dur - overlap will give the time resolution of the 
%     resulting distance time series. If not specified or zero, 
%     there will be no overlap.  Overlap will also be set to zero if 
%     smoothDur is unspecified or zero.
%  consec: Logical. If consec=true, then the calculated distances are between
%     consecutive windows of duration smoothDur, sliding forward over 
%     the data set by a time step of (smoothDur-overlap) minutes.  
%     If TRUE, baselineStart and baselineEnd inputs will be used to define
%     the period used to calculate the data covariance matrix. Default is consec=false.  
%  cumSum: Logical.  If cum_sum=true, then output will be the cumulative 
%     sum of the calculated distances, rather than the distances themselves. 
%     Default is cum_sum=false.
%  expStart: Start times (in seconds since start of the data set) of the experimental exposure period(s).  
%  expEnd: End times (in seconds since start of the data set) of the experimental exposure period(s).
%     If either or both of exp_start and exp_end are missing, the distance will be
%     calculated over whole dataset and full dataset will be assumed to be baseline.
%  baselineStart: Start time (in seconds since start of the data set) of the baseline period 
%     (the mean data values for this period will be used as the 'control' to which all 
%     "comparison" data points (or windows) will be compared. if not specified, 
%     it will be assumed to be 0 (start of record).
%  baselineEnd: End time (in seconds since start of the data set) of the baseline period.  
%     If not specified, the entire data set will be used (baseline_end will 
%     be the last sampled time-point in the data set).
%       
% Outputs:
%  D: Data structure containing results
%     t: Times, in seconds since start of dataset, at which Mahalanobis distances are 
%        reported. If a smoothDur was applied, then the reported times will be the 
%        start times of each "comparison" window.
%     dist: Mahalanobis distances between the specified baseline period and 
%        the specified "comparison" periods  
%
% Example:
%       load_nc('zc11_267a') % needs to be in your current folder, or
%                            % added to your path
%       To be completed later. See this practical for an idea of what we're
%       trying to do: http://animaltags.org/lib/exe/fetch.php?media=tagwiki:practicals:ttp004_practical4_stats.pdf
%       (especially pp.8-9)
%
%
%

if isempty(fs)
    fs = 1;
end

if isempty(smoothDur)
    smoothDur = 0;
end

if isempty(overlap)
    overlap = 0;
end

if isempty(consec)
    consec = false;
end

if isempty(cumSum)
    cumSum = false;
end

if isempty(expStart) || isempty(expEnd) 
    expStart = [];
    expEnd = [];
end

if isempty(baselineStart)
    baselineStart = 0;
end

if isempty(baselineEnd)
    baselineEnd = floor(size(data, 1)/fs);
end

if isempty(BL_COV)
    BL_COV = false;
end

% preliminaries - conversion, preallocate space, etc.
es = floor(fs.*expStart) + 1;                      %start of experimental period in samples
ee = ceil(fs.*expEnd);                             %end of experimental period in samples
bs = floor(fs.*baselineStart) + 1;                 %start of baseline period in samples
be = min( ceil(fs.*baselineEnd) , size(data,1));   %end of baseline period in samples
W = max(1,smoothDur.*fs.*60);                      %window length in samples
O = overlap.*fs.*60;                               %overlap between subsequent window, in samples
N = ceil(size(data,1)/(W-O));                      %number of start points at which to position the window -- start points are W-O samples apart
k = (1:N)';                                        %index vector
ss = (k-1)*(W-O) + 1;                              %start times of comparison windows, in samples
ps = ((k-1)*(W-O) + 1) + smoothDur.*fs.*60/2;      %mid points of comparison windows, in samples (times at which distances will be reported)
t = ps/fs;                                         %mid-point times in seconds
ctr = mean(data(bs:be,:), 1);                      %mean values during baseline period

if BL_COV
    %covariance matrix using all data in baseline period
    bcov = cov(data(bs:be, :));
else
    bcov = cov(data);
end

if consec == false
    by = W-O;
    comps = zeros(size(data,1), size(data,2));
    for n = 1:by:size(data,1)
        for i = 1:size(data, 2)
            if n+W-1 <= size(data,1)
                comps(n, i) = mean(data(n:(n + W-1), i));
            else
                comps(n, i) = mean(data(n:end, i));
            end
        end 
    end
    compsidx=all(comps==0,2);
    comps(compsidx,:)= [];
    d2 = zeros(size(comps,1),1);
    for I = 1:size(comps,1)
        d2(I) = (comps(I,:)-ctr)*inv(bcov)*(comps(I,:)-ctr)';
    end
else
    i_bcov = inv(bcov); %inverse of the baseline cov matrix
    by = W-O;
    ctls = zeros(size(data,1), size(data,2));
    for n = 1:by:size(data,1)
        for i = 1:size(data, 2)
            if n+W-1 <= size(data,1)
                ctls(n, i) = mean(data(n:(n + W-1), i));
            else
                ctls(n, i) = mean(data(n:end, i));
            end
        end 
    end
    ctlsidx=all(ctls==0,2);
    ctls(ctlsidx,:)= []; 
    comps = [ctls(2:size(ctls,1),:) ; NaN(1, size(data,2))]; %compare a given control window with the following comparison window.
    pair_diffs = [ctls-comps];
    d2 = zeros(size(pair_diffs,1),1);
    for q = 1:size(pair_diffs,1)
        d2(q) = Ma(pair_diffs(q,:), i_bcov);
    end
    d2 = [NaN; d2(1:(length(d2)-1))]; %first dist should be at midpoint of first comp window
end

%functions return squared Mahalanobis dist so take sqrt
dist = sqrt(d2);

dist(t > (size(data, 1)/fs - smoothDur.*60)) = NaN;

%Calculate cumsum of distances if requested
if cumSum == true
    dist = cumsum(dist);
end 

D = struct('t',t,'dist',dist);
end

%----------------------------------------------------------------------------------
function D = Ma(d, Sx)
% Calculate distances!
% Alternate way of calc m_dist
%
% Inputs:
%   d: a row vector of pairwise differences between the things you're comparing
%   Sx: the inverse of the cov matrix
%
% Outputs:
%   D: Data structure containing results
%     t: Times, in seconds since start of dataset, at which Mahalanobis distances are 
%        reported. If a smoothDur was applied, then the reported times will be the 
%        start times of each "comparison" window.
%     dist: Mahalanobis distances between the specified baseline period and 
%        the specified "comparison" periods

D = sum((d*Sx)*d');

end
