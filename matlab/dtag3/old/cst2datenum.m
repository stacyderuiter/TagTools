function d = cst2datenum(tag,cst, d3, TAGON, GMT2LOC)
%d = cst2datenum(tag,cst, d3, TAGON, GMT2LOC)
%convert a time in CST to a matlab serial date number indicating local time.  (may be useful to
%plot with date number as y axis of plot, using datetick to label the axis
%in human-legible local time...)
% tag is tag id string eg zc11_267a
% cst is a scalar or a vector of times to convert, in seconds since start
%   of recording.
% d3 is 0 if the tag was a dtag2, or 1 if a d3 (if 1, then it will be
%   assumed that the TAGON in the cal file is in UTC and GMT2LOC will be used to covert to local).
% tagon is optional argument which should be a vector with tagon time as
%   [yyyy mm dd hh mm ss], in case there is no cal file for this tag avail.
% GMT2LOC is optional conversion factor for GMT to local time; if d3=1 and tagon is
%   given then GMT2LOC should be given as well.
%
% the output, d, is a vector of serial date numbers. 
% right now this function requires a tag path to be set so that the command
% "loadcal(tag)" will work; for future d3 cases where that is silly, edit
% the first lines of the code (or supply TAGON and GMT2LOC).
%
% stacy deruiter u of st andrews june 2012

if nargin < 4 || isempty(TAGON) || isempty(GMT2LOC)
    loadcal(tag);
end

if d3 == 1
    TAGON(4) = TAGON(4) + GMT2LOC; %convert GMT tagon time to local time
end

%calculate timing
ttime = repmat(TAGON(:)' , length(cst), 1); %get a matrix of the right size
ttime(:,6) = TAGON(6)+cst(:); %last col is seconds.  add cst, which is seconds since tagon, to get time of points in cst
d = datenum(ttime); %change to matlab datenums to allow...



