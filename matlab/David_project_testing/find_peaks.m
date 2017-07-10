function peaks = find_peaks(A, fs, thresh, bktime, plot)
% This function detects peaks in jerk data that exceed a specfied 
%   threshold and returns each peak's start time, end time, maximum jerk
%   value, and time of the maximum jerk.
%
% INPUTS:
%   A = The acceleration matrix with columns [ax ay az]. Acceleration can
%       be in any consistent unit (e.g. g or m/s^2). This is used to
%       calculate the jerk using njerk().
%   fs = The sampling rate in Hz of the acceleration signals. This is used
%       to calculate the bktime in the case that the input for bktime
%       is missing.
%   thresh = The threshold level above which peaks in the jerk signal are
%       detected. If the input for thresh is missing/empty, the default 
%       level is the 0.99 quantile.
%   bktime = The specified length of time between jerk values detected 
%       above the threshold value that is required for each value to be 
%       considered a separate and unique peak. If the input for bktime is
%       missing/empty the default level for bktime is 5 times the sampling
%       rate (fs). This is equivalent to 5 seconds of time. 
%   plot = A conditional input. If the input is true or missing/empty, an 
%       interactive plot is generated, allowing the user to manipulate the 
%       thresh and bktime values and observe the changes in peak 
%       detection. If the input is false, the interactive plot is not
%       generated.
%
% OUTPUTS:
%   peaks = A structure containing vectors for the start times, end times,
%       peak times, and peak maxima. All times are presented as the
%       sampling value. Peak maxima are presented in the same units as A. 
%		If A is in m/s^2, the peak maxima have units of m/s^3. If the units
%       of A are in g, the peak maxima have unit g/s
%   As specified above under the description for the input of plot, an
%       interactive plot can be generated, allowing the user to manipulate
%       the thresh and bktime values and observe the changes in peak
%       detection. The plot output is only given if the input for plot is
%       specified as true or if the input is left missing/empty.

if nargin < 2
    help find_peak
end

%calculate jerk of A
j = njerk(A, fs);

if nargin < 4 || isempty(thresh)
    thresh = quantile(j, 0.99);
end

if nargin < 5 || isempty(bktime)
    bktime = 5 * fs;
end

if nargin < 6 || isempty(plot)
    plot = true;
end

%create matrix for jerk and corresponding sampling number
jerk = [(1:size(j, 1)); j']';

%determine peaks that are above the threshold
pt = jerk(:,2) >= thresh;
pk = jerk(pt,:);

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
    tj = j(start_time(a):end_time(a));
    [m, index] = max(tj);
    peak_time(a) = index + start_time(a);
    peak_max(a) = m;
end
      
%create structure of start times, end times, peak times, and peak maxima
field1 = 'start_time';  value1 = start_time;
field2 = 'end_time';  value2 = end_time;
field3 = 'peak_time';  value3 = peak_time;
field4 = 'peak_maxima';  value4 = peak_max;
peaks = struct(field1,value1,field2,value2,field3,value3,field4,value4);

end