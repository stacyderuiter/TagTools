%Wiley Time/Depth plot generation

clear all;close all;clc;
tag = tagdataworkup(1); %make sure tagdataworkup is updated for correct tag
[c,t,s,len,fs,id]=tag2cue(tag);
loadprh(tag);
tots=t(4)*3600+t(5)*60+t(6); %tag on time (seconds)
p = decdc(p,5);fs = 1;  %decimate so small enough for excel to open (excel limit is 65536 lines) 
time = tots + ((1:length(p))./fs)'; %time in seconds
time = time/(3600*24); %scale to percentage of day - for excel 
fid = fopen(['d:\tag\data\mn07\TD Plots\' tag '_td.txt'],'w');
fprintf(fid,'%4.8f %4.8f\r\n',[time'; -p']);
fclose(fid);
plot(time,-p);grid;