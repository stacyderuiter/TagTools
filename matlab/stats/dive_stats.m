function Y = dive_stats(P, dive_cues, X, fs, prop, angular, X_name)

% Compute summary statistics for dives or flights, given a depth/altitude profile and a series of dive/flight start and end times
% 
% In addition to the maximum excursion and duration, dive_stats} 
% divides each excursion into three phases:
% "to" (descent for dives, ascent for flights), "from" (ascent for dives, descent for flights),
% and "destination". 
% The "destination" (bottom for dives and top for flights) 
% phase of the excursion is identified using a "proportion of maximum 
% depth/altitude" method, whereby for example the bottom phase of a dive 
% lasts from the first to the last time the depth exceeds a stated 
% proportion of the maximum depth. Average vertical velocity is computed 
% for the to and from phases using a simple method: total depth/altitude 
% change divided by total time. If an angular data variable is also 
% supplied (for example, pitch, roll or heading),
% then the circular mean (computed via circ.mean from the CircStats package, 
% available at 
% https://www.mathworks.com/matlabcentral/fileexchange/10676-circular-statistics-toolbox--directional-statistics- .                          ) and variance (computed via \link(CircStats){circ.disp}} and reporting the var} output)
% are also computed for each dive phase and the dive as a whole.
% 
% Inputs:
% P             Depth data. A vector (or one-column matrix), or a tag sensor data list.
% dive_cues     A two-column data frame or matrix with dive/flight start 
%               times in the first column and dive/flight end times in the second. May be obtained from \link{find_dives}}. Units should be seconds since start of tag recording.
% X             (optional) Another data stream (as a vector 
%               (or a one-column matrix) or a tag sensor data list) for 
%               which to compute mean and variability. If angular is 1, 
%               interpreted as angular data (for example pitch, roll, or 
%               heading) and means and variances are computed accordingly.
%               The unit of measure must be radians (NOT degrees).
% fs            (optional if P is a tag sensor data list) Sampling rate of 
%               P (and X, if X is given).
% prop          The proportion of the maximal excursion to use for defining
%               the "destination" phase of a dive or flight. For example, 
%               if prop is 0.85 (the default), then the destination phase 
%               lasts from the first to the last time depth/altitude 
%               exceeds 0.85 times the within-dive maximum.
% angular       Is X angular data? Defaults to 0. 
% X_name        A short name to use for the X variable in the output data 
%               structure. For example, if X is pitch data, 
%               use X_name='pitch' to get outputs column names like 
%               mean_pitch, etc. Defaults to 'angle' for angular data and 
%               'aux' for non-angular data.
% 
% Returns:
% dt, A structure in which each element is a column vector with one row for each 
% dive/flight and columns as detailed below. All times are in seconds, 
% and rates in units of x/sec where x is the units of P. Elements include:
% max       The maximum depth or altitude
% dur       The duration of the excursion
% dest_st  The start time of the destination phase
% dest_et  The end time of the destination phase
% dest_dur  The duration in seconds of destination phase
% to_st  The start time of the to phase
% to_et  The end time of the to phase
% to_dur  The duration in seconds of to phase
% from_st The start time of the from phase
% from_et The end time of the from phase
% from_dur The duration in seconds of from phase
% mean_angle If angular=1 and X is input, the mean angle for the entire excursion. Values for each phase are also provided in columns mean_to_angle, mean_dest_angle, and mean_from_angle.
% angle_var If angular=1 and X is input, the angular variance for the entire excursion. Values for each phase are also provided individually in columns to_angle_var, dest_angle_var, and from_angle_var.
% mean_aux If angular=0 and X is input, the mean value of X for the entire excursion. Values for each phase are also provided in columns mean_to_aux, mean_dest_aux, and mean_from_aux.
% aux_sd If angular=0 and X is input, the standard deviation of X for the entire excursion. Values for each phase are also provided individually in columns to_aux_sd, dest_aux_sd, and from_aux_sd.
%
% Calling syntax examples:
% Y = dive_stats(P, dive_cues); % depth/altitude data only; data is a
%                                % tag sensor data structure
% Y = dive_stats(P, dive_cues, [], fs); % depth/altitude data only; data is 
%                                        % a vector sampled at fs Hz
% Y = dive_stats(P, dive_cues, X, [],[],1) % two sensor data structures,
%                                           % second one is angular data
%
% Standalone example:
% load_nc('testset7');           
% dive_cues = find_dives(P, 5); % get dive cues for dives deeper than 5 m
% dive_cues_matrix = [dive_cues.start'; dive_cues.end']
% Y = dive_stats(P, dive_cues_matrix'); % need to transpose the matrix
%                                       % since we put it in two rows
%                                       % but we need it in two columns
% Y
% Returns: the summary statistics for the dive
%
% valid: Matlab, Octave
% sld33@calvin.edu
% Last modified: 7 Aug 2017

if isstruct(P)
    p = P.data;
    fs = P.sampling_rate;
end

if nargin < 2
    fprintf('inputs P and dive_cues are required\n');
    help dive_stats
    return
end

if nargin < 3 
    X = [];
end

if isstruct(X)
    if X.sampling_rate == P.sampling_rate
       x = X.data;
    else
        fprintf('P and X must be sampled at the same rate\n');
        return
    end
else
    if ~isempty(X) && size(X,1) ~= size(p,1)
       fprintf('P and X must be sampled at the same rate\n');
       return
    else
       x = X;
    end
end

if nargin < 4 && ~isstruct(P)
    fprintf('fs input is required unless P is a sensor data structure\n');
    help dive_stats
    return
end

if nargin < 5 || isempty(prop)
    prop=0.85;
end

if nargin < 6 || isempty(angular)
    angular = 0;
end

if nargin < 7 || isempty(X_name)
    if angular==1
        X_name = 'angle';
    else
        X_name = 'aux';
    end
end

%preallocate space
di = round(dive_cues.*fs);
dur = zeros(size(dive_cues,1),1);
maxz = dur;
dest_st = dur; dest_et = dur; dest_dur = dur;
to_dur = dur; to_rate = dur;
from_dur = dur; from_rate = dur;
if angular == 1
    mean_angle = dur;
    angle_var = dur;
    mean_to_angle = dur;
    mean_dest_angle = dur;
    mean_from_angle = dur;
    to_angle_var = dur;
    dest_angle_var = dur;
    from_angle_var = dur;
else if angular~=1 && ~isempty(x)
    mean_aux=dur;
    aux_sd=dur;
    mean_to_aux=dur;
    mean_from_aux=dur;
    mean_dest_aux=dur;
    from_aux_sd=dur;
    to_aux_sd=dur;
    dest_aux_sd=dur;
end

for d = 1:size(dive_cues,1) %loop over dives
  z = p((di(d,1):di(d,2))) ;
  maxz(d) = nanmax(z);
  zz = find(z > (prop * max(z))) ;
  S = max(zz) ;
  L = min(zz) ;
  dur(d) = dive_cues(d,2) - dive_cues(d,1);
  dest_st(d) = S/fs;
  dest_et(d) = L/fs;
  dest_dur(d) = dest_et(d) - dest_st(d);
  to_dur(d) = S/fs;
  to_rate(d) = (z(S) - z(1))/to_dur(d);
  from_dur(d) = (1/fs)*(length(z)-L);
  from_rate(d) = (z(end) - z(L))/from_dur(d);
  if (~isempty(x))
    if angular==1 
        a = x(di(d,1):di(d,2)); 
        at = a(1:S);
        af = a(L:length(a));
        ad = a(S:L);
        mean_angle(d) = circ_mean(a);
        angle_var(d) = circ_var(a);
        mean_to_angle(d) = circ_mean(at);
        mean_dest_angle(d) = circ_mean(ad);
        mean_from_angle(d) = circ_mean(af);
        to_angle_var(d) = circ_var(at);
        dest_angle_var(d) = circ_var(ad);
        from_angle_var(d) = circ_var(af);
  else
    %not angular data
    a = X(di(d,1):di(d,2)); 
    at = a(1:S);
    af = a(L:end);
    ad = a(S:L);
    mean_aux(d) = nanmean(a);
    aux_sd(d) = std(a(~isnan(a)));
    mean_to_aux(d) = nanmean(at);
    mean_dest_aux(d) = nanmean(ad);
    mean_from_aux(d) = nanmean(af);
    to_aux_sd(d) = std(at(~isnan(at)));
    dest_aux_sd(d) = std(ad(~isnan(ad)));
    from_aux_sd(d) = std(af(~isnan(af)));
    end
  end % end processing X
end %end loop over dives
  %change output column names if needed
  Y = struct('dur', dur, 'maxz', maxz, 'dest_st', dest_st, 'dest_et', ...
      dest_et, 'dest_dur', dest_dur, 'from_dur', from_dur, 'from_rate', ...
      from_rate, 'to_rate', to_rate);
  if angular ~= 1 && ~isempty(x)
  Y.(['mean_' X_name]) = mean_aux;
  Y.(['mean_to_' X_name]) = mean_to_aux;
  Y.(['mean_dest_' X_name]) = mean_dest_aux;
  Y.(['mean_from_' X_name]) = mean_from_aux;
  Y.([X_name '_sd']) = aux_sd;
  Y.(['to_' X_name '_sd' ]) = to_aux_sd;
  Y.(['dest_' X_name '_sd']) = dest_aux_sd;
  Y.(['from_' X_name '_sd']) = from_aux_sd;
  elseif ~isempty(x)
      Y.(['mean_' X_name]) = mean_angle;
  Y.(['mean_to_' X_name]) = mean_to_angle;
  Y.(['mean_dest_' X_name]) = mean_dest_angle;
  Y.(['mean_from_' X_name]) = mean_from_angle;
  Y.([X_name '_var']) = aux_var;
  Y.(['to_' X_name '_var' ]) = to_aux_var;
  Y.(['dest_' X_name '_var']) = dest_aux_var;
  Y.(['from_' X_name '_var']) = from_aux_var;
  end
  return
end
