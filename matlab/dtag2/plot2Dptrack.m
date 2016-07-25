function plot2Dptrack(tag, k)

%plot a 2D pseudotrack for a Dtag-ed whale.
%dtag analysis paths must already be set, and you must have a prh file for
%the tag in question.
%k is an optional vector containing the start and end times of the time window you wish to plot, in seconds since tagon

%sdr, sept 2008

if nargin<2
    k = 1:length(p);%plot the whole tagout if k is unspecified
else
    k = 5*k(1):1:5*k(2);%if start and end times are specified, plot them
end

P = ptrack(pitch(k),head(k),p(k),fs); %generate the pseudotrack
plot(P(:,2)./1000,P(:,1)./1000)
xlabel('Easting (km)'); ylabel('Northing (km)')
title([tag(1:4) ' ' tag(6:9)]); %label with the tag ID