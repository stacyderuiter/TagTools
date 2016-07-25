%Wiley Time/Depth plot generation
%compare 2 dives

clear all;close all;clc;
tag = tagdataworkup(1); %make sure tagdataworkup is updated for correct tag
tag1 = 'mn07_198a';
tag2 = 'mn07_198b';

[c1,t1,s1,len1,fs1,id1]=tag2cue(tag1);
[c2,t2,s2,len2,fs2,id2]=tag2cue(tag2);
s1 = loadraw(tag1);
s2 = loadraw(tag2);

loadprh(tag1);CAL = tag210;
p1 = -p;
v1 = polyval(CAL.VB,s1(:,10));
tots1=t1(4)*3600+t1(5)*60+t1(6); %tag on time (seconds)
tlen1 = tots1 + ((1:length(p1))./fs)'; %time in seconds
time1 = tlen1/(3600*24); %scale to percentage of day - for excel 

loadprh(tag2);CAL = tag212;
p2 = -p;
v2 = polyval(CAL.VB,s2(:,10));
tots2=t2(4)*3600+t2(5)*60+t2(6); %tag on time (seconds)
tlen2 = tots2 + ((1:length(p2))./fs)'; %time in seconds
time2 = tlen2/(3600*24); %scale to percentage of day - for excel 

subplot(311);plot(time1,p1,time2,p2);grid;
subplot(312);plot(time1,p1,time2,p2);grid;
subplot(313);plot(time1,p1,time2,p2);grid;
figure;
plot(time1,v1,time2,v2);grid;
