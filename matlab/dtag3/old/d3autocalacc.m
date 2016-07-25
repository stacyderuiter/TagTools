function    [A,CAL, fs_A] = d3autocalacc(x,p,t,CAL,test)

%    [A,CAL] = autocalacc(x,p,t,CAL,[test])
%    Automatically performs a calibration sequence on the raw
%    accelerometer data in raw sensor cell array x.  Calls calacc.m
%    for the actual calibration steps.
%    
%    mark johnson
%    majohnson@whoi.edu
%    last modified: 24 May 2006
%    modified summer 2012 by stacy deruiter university of st andrews
%    for use with d3 data

if nargin<4,
   help autocalacc
   return
end

%?????????????????????????????????
%
%need to implement low-battery compensation here...
%returning kk, index to last sample to be used for calibration.
kk = length(x(uchans==4609));
%
%?????????????????????????????????

%get raw acc data from x
A0 = [x{uchans==4609}(:), x{uchans==4610}(:), x{uchans==4611}(:)]; 
fs_A = fs(uchans==4609);

if nargin==5 && ~isempty(test)
   [A,CAL, fs_A]=d3calacc(A0,p,t,CAL,test, fs, fs_A);

else  
   fprintf(' Bias calibration...\n') ;
   [A,CAL, fs_A]=d3calacc(A0,p,t,CAL,'bias', fs, fs_A);
   fprintf(' Pressure calibration...\n') ;
   [A,CAL, fs_A]=d3calacc(A0,p,t,CAL,'p', fs, fs_A);
   fprintf(' Temperature calibration...\n') ;
   [A,CAL, fs_A]=d3calacc(A0,p,t,CAL,'t', fs, fs_A);
   fprintf(' Sensitivity calibration...\n') ;
   [A,CAL, fs_A]=d3calacc(A0,p,t,CAL,'sens', fs, fs_A);
   fprintf(' Cross-axis calibration...\n') ;
   [A,CAL, fs_A]=d3calacc(A0,p,t,CAL,'cross', fs, fs_A);
end
