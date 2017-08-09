function peaks = detect_peaks(data, sr, FUN, thresh, bktime, plot_peaks, varargin)
% This function detects peaks in jerk data that exceed a specified 
%   threshold and returns each peak's start time, end time, maximum jerk
%   value, time of the maximum jerk, threshold level, and blanking time.
%
% INPUTS:
%   data = A vector (of all positive values) or matrix of data to be used 
%       in peak detection.
%   sr = The sampling rate in Hz of the acceleration signals. This is the 
%       same as fs in other tagtools functions. This is used to calculate 
%       the bktime in the case that the input for bktime is missing.
%   FUN = A function to be applied to data before the data is run through 
%       the peak detector. Only specify the function name (i.e. 'njerk'). 
%       If left blank, the data input will be immediately passed through 
%       the peak detector.
%   thresh = The threshold level above which peaks in the jerk signal are
%       detected. Inputs must be in the same units as the units of jerk 
%       (see output peaks). If the input for thresh is missing/empty, the 
%       default level is the 99 percentile.
%   bktime = The specified length of time between jerk values detected 
%       above the threshold value that is required for each value to be 
%       considered a separate and unique peak. If the input for bktime is
%       missing/empty the default value for the blanking time is set as the
%       80 percentile of the vector of time differences for signal values 
%       above the specified threshold
%   plot_peaks = A conditional input. If the input is true or 
%       missing/empty, an interactive plot is generated, allowing the user 
%       to manipulate the thresh and bktime values and observe the changes 
%       in peak detection. If the input is false, a non-interactive plot is 
%       generated. Look to the command window for help on how to use the
%       plot upon running of this function.
%   varargin = Additional inputs to be passed to FUN
%
% OUTPUTS:
%   peaks = A structure containing vectors for the start times, end times,
%       peak times, peak maxima, thresh, and bktime. All times are 
%       presented as the sampling value.
%   As specified above under the description for the input of plot_peaks, 
%       an interactive plot can be generated, allowing the user to 
%       manipulate the thresh and bktime values and observe the changes in 
%       peak detection. The plot output is only given if the input for 
%       plot_peaks is specified as true or if the input is left 
%       missing/empty.

if nargin < 2
    help detect_peaks
end

%apply function specified in the inputs to data
if nargin > 2 && ~isempty(FUN)
    func = str2func(char(FUN));
    dnew = func(data, varargin{1:end});
else
    dnew = data;
end

%determine default threshold
if nargin < 4 || isempty(thresh)
    thresh = prctile(dnew, 99);
end

if nargin < 6 || isempty(plot_peaks)
    plot_peaks = true;
end

%create matrix for jerk and corresponding sampling number
if size(dnew, 1) == 1
    d = [(1:length(dnew)); dnew]';
else
    d = [(1:length(dnew)); dnew']';
end

%determine peaks that are above the threshold
pt = d(:,2) >= thresh;
pk = d(pt,:);

%determine default blanking time
if nargin < 5 || isempty(bktime)
    dpk = diff(pk(:,1));
    bktime = prctile(dpk, 80);
end

%determine start and end times for each peak
dt = diff(pk(:,1));
pkst = [1; (dt >= bktime)];
start = pkst == 1;
ending = find((pkst == 1)) - 1;
start_time = pk(start, 1);
end_time = [pk(ending(2:end), 1); pk(end, 1)];
%if the last peak does not end before the end of recording, the peak is
%   removed from analysis
if pkst(end) == 0
    start_time = start_time(1:end - 1);
    end_time = end_time(1:end - 1);
end

%determine the time and maximum of each peak
peak_time = zeros(size(start_time, 1), 1);
peak_max = zeros(size(start_time, 1), 1);
for a = 1:size(start_time, 1)
    td = dnew(start_time(a):end_time(a));
    [m, index] = max(td);
    peak_time(a) = index + start_time(a);
    peak_max(a) = m;
end
      
%create structure of start times, end times, peak times, peak maxima, 
%   thresh, and bktime
field1 = 'start_time';  value1 = start_time;
field2 = 'end_time';  value2 = end_time;
field3 = 'peak_time';  value3 = peak_time;
field4 = 'peak_maxima';  value4 = peak_max;
field5 = 'thresh';  value5 = thresh;
field6 = 'bktime';  value6 = bktime;

peaks = struct(field1,value1,field2,value2,field3,value3,field4,value4,...
    field5,value5,field6,value6);

%produce interactive plot, allowing you to alter thresh and bktime inputs
if plot_peaks == true
    plot(dnew);
    hold on 
    disp('GRAPH HELP:')
    disp('For changing only the thresh level, click once within the plot and then push enter')
    disp(' to specify the y-value at which your new thresh level will be.')
    disp('For changing just the bktime value, click twice within the plot and then push enter')
    disp(' to specify the length for which your bktime will be.')
    disp('To change both the bktime and the thresh, click three times within the plot:')
    disp(' the first click will change the thresh level,')
    disp(' the second and third clicks will change the bktime.')
    disp('To return your results without changing the thresh and bktime from their default')
    disp(' values, simply push enter.')
    for i = 1:length(start_time)
        plot(peak_time(i), peak_max(i), 'h', 'MarkerEdgeColor', [1 .5 0])
    end
    line([0,length(dnew)], [thresh, thresh], 'linestyle', '--', 'color', 'red')
    hold off
    [x, y] = ginput(3);
    if length(x) == 3
        thresh = y(1);
        bktime = max(x(2:3)) - min(x(2:3));
        peaks = detect_peaks(dnew, sr, [], thresh, bktime, false);
    elseif length(x) == 1
        thresh = y(1);
        peaks = detect_peaks(dnew, sr, [], thresh, [], false);
    elseif length(x) == 2
        bktime = max(x) - min(x);
        peaks = detect_peaks(dnew, sr, [], [], bktime, false);
    else
        peaks = detect_peaks(dnew, sr, [], thresh, bktime, false);
    end
elseif plot_peaks == false
    plot(dnew)
    hold on 
    for i = 1:length(start_time)
        plot(peak_time(i), peak_max(i), 'h', 'MarkerEdgeColor', [1 .5 0])
    end
    line([0,length(dnew)], [thresh, thresh], 'linestyle', '--', 'color', 'red')
    hold off
end

end