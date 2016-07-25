function txser = txdatenum(tag,yvec,fs,k)
%make a vector of x values to plot tag sensor data with x axis in the
%format HH:MM.  Use this function to get the x vector in datenum format,
%plot your data, and then use the command
% datetick('x',15,'keeplimits') 
%to change x axis labels to HH:MM format.
%tag is the tag ID string, e.g. 'zc10_267a'
%k is an optional 2-element vector indicating which samples to use.
%default is 1:length(sensordata) eg 1:length(p).
%stacy deruiter, nov 2011, whoi

if nargin<1
    error('No tag ID specified');
    help txdatenum
end
if nargin<2 | isempty(yvec) 
    loadprh(tag, 'p','fs');
end
if nargin<2 | isempty(fs)
    loadprh(tag,'fs');
if nargin < 4 | isempty(k)
    k = 1:length(p);
end

loadcal(tag)
tagont = TAGON(4:6)'; %tag on time in serial date string
ttime = repmat(TAGON', length(p(k)), 1); %get a matrix of the right size
ttime(:,6) = TAGON(6)+(1:length(p(k)))./fs + (k(1)-1)./fs; %seconds since tagon in the last column
txser = datenum(ttime); %vector of time in serial date numbers
