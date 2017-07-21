function [A,M,p, caldata] = applyAcousondeCal(data, calfile, endon)
%Dave Cade, modified 11/2016 by SDR
%use "on" cal at start of file.
%after "endon" samples, switch to "off" cal

load([calfile])
caldata = data;

%G = [data.Gyr1 data.Gyr2 data.Gyr3];
A = [data.Acc1 data.Acc2 data.Acc3];
M = [data.Mx data.My data.Mz];

if nargin < 3 || isempty(endon)
    numrows = size(A,1);
    %gyro - are there acousonde with one?
    %Gt = (G-repmat(gyconst,numrows,1))*gycal;
    A = (A-repmat(aconst,numrows,1))*acal;
    M = (M-repmat(magconston,numrows,1))*magcalon;
    
    if exist('pcal','var')
        p = (data.Press-pconst)*pcal;
    else
        p = data.Press;
    end
    
    caldata.Acc1 = A(:,1); caldata.Acc2 = A(:,2); caldata.Acc3 = A(:,3);
    %caldata.Gyr1 = Gt(:,1); caldata.Gyr2 = Gt(:,2); caldata.Gyr3 = Gt(:,3);
    caldata.Mx = M(:,1); caldata.My = M(:,2); caldata.Mz = M(:,3);
    caldata.Press = p;
else
    numrows_on = endon;
    numrows_off = size(A,1) - endon;
    %gyro - are there acousonde with one?
    %Gt = (G-repmat(gyconst,numrows,1))*gycal;
    A = (A-repmat(aconst,size(A,1),1))*acal;
    Mon =  (M(1:endon,:)       - repmat(magconston , numrows_on ,1))*magcalon;
    Moff = (M((endon+1):end,:) - repmat(magconstoff, numrows_off,1))*magcaloff;
    M = [Mon;Moff];
    
    if exist('pcal','var')
        p = (data.Press-pconst)*pcal;
    else
        p = data.Press;
    end
    
    caldata.Acc1 = A(:,1); caldata.Acc2 = A(:,2); caldata.Acc3 = A(:,3);
    %caldata.Gyr1 = Gt(:,1); caldata.Gyr2 = Gt(:,2); caldata.Gyr3 = Gt(:,3);
    caldata.Mx = M(:,1); caldata.My = M(:,2); caldata.Mz = M(:,3);
    caldata.Press = p;
end