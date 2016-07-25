function S1 = diveprofile(tag, p, fs, tagon, startcue, endcue)
%plot a basic dive profile
%S1 is an optional handle for the figure
%tag is the tag id string, e.g. 'zc11_267a'
%p and fs and the depth record and its sampling rate (from prh file)
%tagon is a vector indicating tagon time -- [yyyy mm dd hh mm ss]
%startcue is the time in seconds since tagon from which to start plotting
%endcue is the time in seconds since tagon at which to stop plotting
%
%should work for dtag2 and dtag 3 IFF there is a dtag2 style prh file and cal file, or if
%user supplies p and fs and there is a cal mat-file.
%modified to make HH:MM labels for axis -- stacy deruiter, june 2012

if ~exist('p','var') || nargin < 3
    loadprh(tag, 'p', 'fs');
end
if ~exist('startcue','var') || nargin < 3
    startcue = [];
end
if ~exist('endcue','var') || nargin < 3
    endcue = [];
end

if isempty(startcue)
    clear startcue;
end
if isempty(endcue)
    clear endcue;
end

if exist('startcue','var') && exist('endcue','var')  %a vector of the sample numbers (in p) to plot
    kk = floor(fs*startcue):floor(fs:endcue);
elseif exist('startcue','var')&& ~exist('endcue','var')
    kk = floor(fs*startcue):length(p);
elseif ~exist('startcue','var')&& exist('endcue','var')
else
    kk = 1:floor(endcue*fs);
end


if nargin < 4  %if tagon is not given, then plot in decimal hours
    S1 = plot((1:length(p))./fs./3600,p); axis ij
    ylabel('Depth (m)');
    xlabel('Time (hours since start of tag recording)');
elseif exist('tagon','var') %if tagon is given, plot x axis as time in HH:MM
    loadcal(tag)
    tagdate = [num2str(TAGON(2)) '/' num2str(TAGON(3)) '/' num2str(TAGON(1))];
    if floor(CAL.TAG/100) ~=2 %dtag3s as of 2012 have tag ids in the 100's...this will fail if that changes.
        TAGON(4) = TAGON(4) + GMT2LOC; %convert from gmt to local time
    end
    ttime = repmat(TAGON(:)', length(p(kk)), 1); %get a matrix of the right size
    ttime(:,6) = TAGON(6)+(1:length(p(kk)))./5 + (kk(1)-1)./5; %seconds since tagon in the last column
    ttimeser = datenum(ttime); %vector of time in serial date numbers
    S1 = plot(ttimeser, p(kk), 'k-', 'LineWidth', 2); axis ij
    ylabel('Depth (meters)'); xlabel('Local Time');
    title([num2str(tag(1:4)) '\_' num2str(tag(6:9)) ' - ' num2str(tagdate) ' - Dive Profile']);
    axis tight
    ylim([-5 max(p)+0.1*max(p)]);
    datetick('x',15, 'keeplimits'); %make date in the format HH:mm on the x axis
end
    