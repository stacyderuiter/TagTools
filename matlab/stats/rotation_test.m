function result = rotation_test(event_times, full_period, exp_period, n_rot, ts_fun, skip_sort, conf_level, return_rot_stats, varargin)
% Carry out a rotation randomization test
%
% Carry out a rotation test (as applied in Miller et al. 2004 and detailed in DeRuiter and Solow 2008). This test is a
%    variation on standard randomization or permutation tests that is appropriate for time-series of non-independent events 
%   (for example, time series of behavioral events that tend to occur in clusters). 
%
% This implementation of the rotation test compares a test statistic (some summary of
%   an "experimental" time-period) to its expected value during non-experimental periods. Instead of resampling random subsets of observations from the original dataset,
%   the rotation test samples many contiguous blocks from the original data, each the same duration as the experimental period. The summary statistic,
%   computed for these "rotated" samples, provides a distribution to which the test statistic from the data can be compared.
%
% Inputs: 
%   event_times is a vector of the times of events. Times can be given in any format.
%       If event_times should not be sorted prior to analysis (for example, if times 
%       are given in hours of the day and the times in the dataset span 
%       several days), be sure to specify skip_sort=true.
%   exp_period A two-column vector, matrix, or data frame specifying the start and end times of the "experimental" 
%       period for the test. If a matrix or data frame is provided, one column should be start time(s) and the other end 
%       time(s). Note that all data that falls into any experimental period will be concatenated and passed to ts_fun.
%       If finer control is desired, consider writing your own test using the underlying function rotate.
%   full_period is a length two vector giving the start and end times of the full period
%       during which events in event_times might have occurred. If missing, default is [min(event_times), max(event_times)].
%   n_rot the number of rotations (randomizations) to carry out. Default is n_rot=10000.
%   ts_fun is a function to compute the test statistic. Input provided to this function 
%       will be the times of events that occur during the "experimental" period.  The default function is length - in other 
%       words, the default test statistis is the number of events that happen during the experimental period.
%   skip_sort is a Logical statement. Should times be sorted in ascending order? Default is skip_sort=FALSE.
%   conf_level is the confidence level to be used for the bootstrap CI calculation, specified as a proportion. 
%       conf_level=0.95, or 95% confidence.
%   return_rot_stats is a Logical statement. Should output include the test statistics computed for each rotation 
%       of the data? Default is return_rot_stats=false.
%   varargin is additional inputs to be passed to ts_fun
%
% Outputs:
%   A structure with the following results:
%       statistic = Test statistic (from original data)
%       p_value = P-value of the test (2-sided)
%       n_rot = Number of rotations
%       CI_low = Lower bound on rotation-resampling percentile-based confidence interval
%       CI_up = Upper bound on rotation-resampling percentile-based confidence interval
%       conf_level = Confidence level, as a proportion
%       If return_rot_stats = true, a vector of n_rot statistics from the 
%           rotated datasets is also returned.
%
% References: 
%   Miller, P. J. O., Shapiro, A. D., Tyack, P. L. and Solow, A. R. (2004). Call-type matching in vocal exchanges of free-ranging resident killer whales, Orcinus orca. Anim. Behav. 67, 1099–1107.
%   DeRuiter, S. L. and Solow, A. R. (2008). A rotation test for behavioural point-process data. Anim. Behav. 76, 1103–1452.
%
% Note: Advanced users seeking more flexibility may want to use the underlying 
%   function rotate to carry out customized rotation resampling. rotate generates one 
%   rotated dataset from event_times and exp_period.
% 
% Output sampling rate is the same as the input sampling rate.
% Frame: This function assumes a [north,east,up] navigation frame and a [forward,right,up] local frame. 
%   In these frames, a positive pitch angle is an anti-clockwise rotation around the y-axis. A positive roll angle is a clockwise rotation around the x-axis. 
%   A descending animal will have a negative pitch angle while an animal rolled with its right side up will have a positive roll angle.
% This function output can be quite sensitive to the inputs used, namely those that define the relative weight given to the existing data, 
%   in particular regarding (x,y)=(lat,long); increasing q3p, the (x,y) state variance, will increase the weight given to independent observations of (x,y), say from GPS readings.
%
% Example:
% r = rotation_test((20*rand(500,1)), [], [10,200], [],'mean', [], [], true);
% Returns:
% r.result = structure with
%   statistic: 14.8841
%   CI_low: 15.1050
%   CI_up: 29.3135
%   n_rot: 10000
%   conf_level: 0.9500
%   p_value: .00019998


% Input checking
%============================================================================
if nargin < 2
    help rotation_test
end

if nargin < 3 || isempty(full_period)
    event_times(isnan(event_times)) = [];
    full_period = [min(event_times), max(event_times)];
end

if nargin < 4 || isempty(n_rot)
    n_rot = 10000;
end

if nargin < 5 || isempty(ts_fun)
    ts_fun = 'length';
end

if nargin < 6 || isempty(skip_sort)
    skip_sort = false;
end

if nargin < 7 || isempty(conf_level)
    conf_level = .95;
end

if nargin < 8 || isempty(return_rot_stats)
    return_rot_stats = false;
end

if sum(isnan(exp_period)) > 0
    error('start/end times cannot contain any missing (NaN) values')
end

if sum(isnan(event_times)) > 0
    warning('missing values in event_times will be ignored')
    event_times(isnan(event_times)) = [];
end
  
% arrange exp_period as a data frame with columns st and et (start and end time(s))
if length(exp_period) > 2
    exp_period = struct('st',exp_period(:,1),'et',exp_period(:,2));
else
    st = min(exp_period);
    et = max(exp_period);
    exp_period = struct('st',st,'et',et);
end
% sort times if skip_sort is FALSE
if skip_sort == false
    event_times = sortrows(event_times);
end

e_data = get_e_data(event_times, exp_period);
% compute test statistic for observed dataset
func = str2func(char(ts_fun));
if ~isempty(varargin)
    data_ts = func(e_data, varargin{1:end});
else
    data_ts = func(e_data);
end
    
%find TS for n_rot rotations
rot_stats = zeros(1,n_rot);
for b = 1:n_rot
    rot_events = rotate(event_times, full_period);
    rot_e_dat = get_e_data(rot_events,exp_period) ;
    if ~isempty(varargin)
        rot_stats(b) = func(rot_e_dat, varargin{1:end});
    else
        rot_stats(b) = func(rot_e_dat);
    end
end

%fill results data.frame
result = struct('statistic',data_ts);
result.CI_low = prctile(rot_stats, (((1-conf_level)/2)*100));
result.CI_up = prctile(rot_stats, ((1 -(1-conf_level)/2)*100));
result.n_rot = n_rot;
result.conf_level = conf_level;
result.p_value = 2*(sum(rot_stats >= data_ts)+1)/(n_rot+1);
if result.p_value > 1
    result.p_value = 2*(sum(rot_stats <= data_ts)+1)/(n_rot+1);
else
    result.p_value;
end

if return_rot_stats == true
    result = struct('result',result,'rot_stats',rot_stats);
else
    result = struct('result',result);
end

% Carry out rotation test
%==================================================================
%get event times from experimental time period
function e_data = get_e_data(event_times, exp_period)
    e_data = event_times(event_times >= exp_period.st & event_times <= exp_period.et);
    if length(exp_period.st) > 1  %if multiple experimental periods,
      for p = 2:length(exp_period.st) %loop over experimental periods.
        e_data = [e_data, event_times(event_times >= exp_period.st(p) & event_times <= exp_period.et(p))];
      end
    end
end
%====================================================================

end