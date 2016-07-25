%Useful commands for plotting quick look analysis of a controlled exposure
%experiment
%prepare
clear all
%setmytagpath %or...
path = 'e:\tag\data'
settagpath('audio',path,'cal',[path '\cal'], 'raw',[path '\raw'],'prh',[path '\prh']);
StacysDefaultFigureOptions
%********************************************************************
%INFO IN THIS SECTION NEEDS TO BE CHANGED FOR EACH NEW TAGOUT
%********************************************************************
%enter needed info
tag = 'xx09_235a'; %tag string of experiment you want to plot
tagdate = '23 August 2008';
tagont = [17 13 45]; %tag on time in hh mm ss; 
%k = [1:end];%which part of the record to plot -- in sensor sample numbers -- tagon to tagoff, usually
%for this whale k is:  tagon to tag off as determined from plot of Aw (with
%input from p)
%**************************************************************************


%load in and calculate useful data
ton = tagont(1) + tagont(2)/60 + tagont(3)/60/60; %tag on time in hours of the day
loadprh(tag); 
load(['RLdata_' num2str(tag(1:2)) num2str(tag(6:9))]);
%make a pseudotrack
P = ptrack(pitch(k),head(k),p(k),fs);
%put peak RLs as the 4th column of P.  Between transmissions, nominal
%exposure level is that of the previous transmission (so that color
%indications will be visible on a colline plot).
h = round(peak_prn_level(:,1)*5);
h = h(~isnan(h));
h(:,2) = [h(2:end,1) - 1; h(end,1) + 60];
for i = 1:length(h)
    if ~isnan(h(i,1))
    P(h(i,1):h(i,2),4) = peak_prn_level(i,2);
    end
end

g = round(peak_mfa_level(:,1)*5);
g = g(~isnan(g));
g(:,2) = [g(2:end,1) - 1; g(end,1) + 60];
for i = 1:length(g)
    if ~isnan(g(i,1))
    P(g(i,1):g(i,2),4) = peak_mfa_level(i,2);
    end
end



%plot a dive profile
figure(1); clf;
plot((1:length(p(k)))./5./60./60 + ton, p(k)); axis ij
% plot((clicking(:,2))./60/60 + ton,-p(round(5*clicking(:,2))), 'ro'); 
% plot((clicking(:,1))./60/60 + ton,-p(round(5*clicking(:,1))), 'gs');
ylabel('Depth (meters)'); xlabel('Time (hours local time)');
title([num2str(tag(1:4)) '\_' num2str(tag(6:9)) ' - ' num2str(tagdate) ' - Dive Profile']);



%plot 2D ptrack
figure(2); clf;
plot(P(:,2)./1000,P(:,1)./1000);
xlabel('Easting (km)'); ylabel('Northing (km)');
title([num2str(tag(1:4)) '\_' num2str(tag(6:9)) ' - ' num2str(tagdate) ' - Uncorrected Pseudotrack']);

%plot 3D ptrack with color indicating depth
figure(3); clf;
Ps = downsample(P,100); %ptrack with a sample every 20 seconds - fewer data points to plot
colline3(Ps(:,2)./1000,Ps(:,1)./1000,Ps(:,3),Ps(:,3)),grid;
set(gca,'ZDir','reverse');
xlabel('Easting (km)'); ylabel('Northing (km)'); zlabel('Depth (m)');
title([num2str(tag(1:4)) '\_' num2str(tag(6:9)) ' - ' num2str(tagdate) ' - Uncorrected Pseudotrack']);
colorbar;

%plot 2D ptrack with color indicating RLs
figure(4); clf;
colline(P(:,2)./1000,P(:,1)./1000,P(:,4)),grid; zlabel('Depth (m)');
xlabel('Easting (km)'); ylabel('Northing (km)');
title([num2str(tag(1:4)) '\_' num2str(tag(6:9)) ' - ' num2str(tagdate) ' - Uncorrected Pseudotrack']);
colorbar %best to interactively adjust this so that the full range of colors is withing the exposure range and most of track is blue.

%plot 3D ptrack with color indicating RLs
figure(5); clf;
colline3(P(:,2)./1000,P(:,1)./1000, P(:,3), P(:,4)); grid;
set(gca,'ZDir','reverse');
xlabel('Easting (km)'); ylabel('Northing (km)'); zlabel('Depth (m)');
title([num2str(tag(1:4)) '\_' num2str(tag(6:9)) ' - ' num2str(tagdate) ' - Uncorrected Pseudotrack']);
colorbar %best to interactively adjust this so that the full range of colors is withing the exposure range and most of track is blue.


%plot dive profile with color indicating peak RL
figure(6); clf;
colline((1:length(p(k)))./5./60./60 + ton,p(k),P(:,4)),grid;axis ij
xlabel('Time (hours local time)'); ylabel('Depth (meters)');
title([num2str(tag(1:4)) '\_' num2str(tag(6:9)) ' - ' num2str(tagdate) ' - Dive Profile with RLs']);
colorbar

%plot 2-y-axis plot with dive profile and peak RLs
figure(7); clf;
plotyy((1:length(p(k)))./5./60./60 + ton ,-p(k),[peak_prn_level(:,1)./60./60 + ton ],[peak_prn_level(:,2)]);
hold on; 
plotyy((1:length(p(k)))./5./60./60 + ton ,-p(k),[peak_mfa_level(:,1)./60./60 + ton ],[peak_mfa_level(:,2)]);
hold off;
%hold on;
%plot((clicking(:,2))./60/60 + ton,-p(round(5*clicking(:,2))), 'ro'); 
%plot((clicking(:,1))./60/60 + ton,-p(round(5*clicking(:,1))), 'gs');
%legend
%hold off
xlabel('Time (hours local time)');


%plot received levels on their own plot
%MFA
figure(8); clf;
plot(1:length(peak_mfa_level) , peak_mfa_level(:,2), 'rs');
hold on;
plot(1:length(envpeak_mfa_level) , envpeak_mfa_level(:,2), 'r*');
plot(1:length(rms_mfa_level) , rms_mfa_level(:,2), 'ro');
plot(1:length(rms_noise_level_MFA) , rms_noise_level_MFA(:,2), 'bo');
xlabel('Transmission Number'); ylabel('Level (dB re 1 \muPa)');
title([num2str(tag(1:4)) '\_' num2str(tag(6:9)) ' - ' num2str(tagdate) ' - MFA Exposure Levels']);
legend
hold off;
%PRN
figure(9); clf; hold on;
plot(1:length(peak_prn_level) , peak_prn_level(:,2), 'ks');
plot(1:length(envpeak_prn_level) , envpeak_prn_level(:,2), 'k*');
plot(1:length(rms_prn_level) , rms_prn_level(:,2), 'ko');
plot(1:length(rms_noise_level_PRN) , rms_noise_level_PRN(:,2), 'bo');
xlabel('Transmission Number'); ylabel('Level (dB re 1 \muPa)');
title([num2str(tag(1:4)) '\_' num2str(tag(6:9)) ' - ' num2str(tagdate) ' - PRN Exposure Levels']);
legend

hold off;

