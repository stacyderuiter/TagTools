function peaks = peak_finder(x,fs,thresh,blank,doplot)

%   peaks = peak_finder(X,thresh,blank,doplot)  % X is a sensor structure
%   or
%   peaks = peak_finder(X,fs,thresh,blank,doplot)  % x is a vector
%   This function detects peaks in a signal that exceed a specified 
%   threshold and returns each peak's start time, end time, maximum jerk
%   value, time of the maximum jerk, threshold level, and blanking time.
%
% INPUTS:
%   X   A sensor structure or vector containing data to be used 
%       in peak detection. If X has more than one column of data,
%       only the first column will be analysed.
%   fs  The sampling rate in Hz of the signal in x. This is only
%       required if X is not a sensor structure.
%   thresh  The threshold level above which peaks in x are detected. 
%       Input must be in the same units as x. If thresh is missing/empty,
%       the default level is the 99 percentile of x.
%   blank   The minimum time between detections in seconds. If blank is
%       missing/empty the default value for the blanking time is 1/10th of
%       the duration of signal x.
%   doplot Enable interactive plotting if doplot=1 or is missing or empty, 
%       allowing the user to manipulate the thresh and blank values and  
%       observe the changes in peak detection. Look at the command window  
%       for help on how to use the plot. If doplot is 0, no plot
%       is generated. 
%
% OUTPUTS:
%   peaks = A structure containing vectors for the start times, end times,
%       peak times, peak maxima, thresh, and blanking time. All times are in seconds.
%

if nargin < 1,
    help peak_finder
    return
end

if isstruct(x),
   if nargin>=4,
      doplot = blank ;
   else
      doplot = [] ;
   end
   if nargin>=3,
      blank = thresh ;
   else
      blank = [] ;
   end
   if nargin>=2,
      thresh = fs ;
   else
      thresh = [] ;
   end
   [x,fs] = sens2var(x) ;
else
   if nargin < 2,
      fprintf('Sampling rate is needed when input is a vector\n') ;
      return
   end
   if nargin<5,
      doplot = [] ;
   end
   if nargin<4,
      blank = [] ;
   end
   if nargin<3,
      thresh = [] ;
   end
end

if size(x,1)==1,
   x = x(:) ;
end

if size(x,2)>1,
   x = x(:,1) ;
end

% determine default threshold
if isempty(thresh),
   thresh = prctile(x, 99);
end

if isempty(blank),
   blanking = length(x)/10 ;
else
   blanking = blank*fs ;
end

if isempty(doplot),
   doplot = 1 ;
end

% make sure x is a single column vector
if size(x,1)==1 && size(x,2)>1,
   x = x(:) ;
else
   x = x(:,1) ;
end

peaks = getpeaks(x,fs,thresh,blanking) ;

if doplot == 0,
   return
end

% produce interactive plot, allowing you to alter thresh and bktime inputs
disp('GRAPH HELP:')
disp('The plot shows the peak value and duration of each detection in red.')
disp('To change the threshold, click at the desired threshold level in the plot.')
disp('Press enter to finish.')
figure

while 1,
   plot((0:length(x)-1)'/fs,x);
   hold on
   if ~isempty(peaks),
      plot(peaks.maxtime,peaks.max,'r.');
      plot([peaks.start_time(:) peaks.end_time(:)]',[1;1]*peaks.max','r-');
   end
   plot([0,(length(x)-1)/fs],thresh*[1,1],'k:')
   title(sprintf('Blanking time is %f s\n',blanking/fs));
   hold off
   [xx,yy] = ginput(1);
   if isempty(xx),
      return
   end
   thresh = yy(1) ;
   peaks = getpeaks(x,fs,thresh,blanking) ;
end
return


function    peaks = getpeaks(x,fs,thresh,blanking)
%
% determine start sample of peaks that are above the threshold
peaks = [] ;
dxx = diff(x>=thresh) ;
cc = find(dxx>0)+1 ;
if isempty(cc), return ; end

% find ending sample of each peak
coff = find(dxx<0)+1 ;    % find where peak returns below threshold
cend = size(x,1)*ones(length(cc),1) ;
for k=1:length(cc),
   kends = find(coff>cc(k),1) ;
   if ~isempty(kends),
      cend(k) = coff(kends) ;
   end
end

% eliminate detections which do not meet blanking criterion.
% blanking time is calculated after pulse returns below threshold
% merge pulses that are within blanking distance
done = 0 ;
while ~done,
   kg = find(cc(2:end)-cend(1:end-1)>blanking(1)) ;
   done = length(kg) == (length(cc)-1) ;
   cc = cc([1;kg+1]) ;
   cend = cend([kg;end]) ;
end

if cend(end)==length(x),
   cc = cc(1:end-1);
   cend = cend(1:end-1);
end

% remove short peaks
if length(blanking)>1,
   k = find(cend-cc>=blanking(2)) ;
   cc = cc(k) ;
   cend = cend(k) ;
   minlen = blanking(2)/fs ;
else
   minlen = 1/fs ;
end

% determine the time and maximum of each peak
peak_time = zeros(length(cc),1);
peak_max = zeros(length(cc),1);
for a = 1:length(cc),
    [m, index] = max(x(cc(a):cend(a))) ;
    peak_time(a) = index + cc(a)-1 ;
    peak_max(a) = m ;
end

if isempty(cc), return, end

% make output structure
peaks.start_time = (cc-1)/fs ;
peaks.end_time = (cend-1)/fs ;
peaks.maxtime = (peak_time-1)/fs ;
peaks.max = peak_max ;
peaks.thresh = thresh ;
peaks.bktime = blanking/fs ;
peaks.minlen = minlen ;
return
