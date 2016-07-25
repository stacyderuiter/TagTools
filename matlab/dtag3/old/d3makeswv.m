function [press,acc,t200,temp,pb1,pb2,t33] = d3makeswv(numrec,fnamebase);

%generate 200Hz data
press = [];
ax = [];
ay = [];
az = [];
for k = 1:numrec
    fname = [fnamebase num2str(k,'%03d')];
    [x,fs,uchans] = d3parseswv(fname);
    p0 = decimate(x{10},20);press = [press; p0];
    ax0 = decimate(x{7},20);ax = [ax; ax0];
    ay0 = decimate(x{8},20);ay = [ay; ay0];
    az0 = decimate(x{9},20);az = [az; az0];
end
acc = [ax ay az];
t200 = (1:length(acc))./20;

%generate 33Hz data
temp = [];
pb1 = [];
pb2 = [];
for k = 1:numrec
    fname = [fnamebase num2str(k,'%03d')];
    [x,fs,uchans] = d3parseswv(fname);
    t0 = decimate(x{11},33);temp = [temp; t0];
    pb10 = decimate(x{12},33);pb1 = [pb1; pb10];
    pb20 = decimate(x{13},33);pb2 = [pb2; pb20];
end
t33 = (1:length(temp));
    
