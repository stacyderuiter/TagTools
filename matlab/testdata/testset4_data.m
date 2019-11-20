load('C:\tag_data\metadata\gps\hs16_265ctrk.mat')
Ton=datenum([2016 9 21 7 55 20]);
T=(POS.T-Ton)*3600*24;
k=find(T>3600*24*16.769 & T<3600*24*17.176);
%k=find(T>3600*24*6.73 & T<3600*24*7.2);
[PP,TT]=mean_track([POS.lat(k) POS.lon(k)],T(k),30);
load('C:\tag_data\metadata\prh\hs16_265cprh.mat')
k = round(fs*TT(1)):round(fs*TT(end));
A=A(k,:);
M=M(k,:);
p=p(k,:);
T=TT-TT(1);
POS=PP;
save testset4.mat A M p T POS fs