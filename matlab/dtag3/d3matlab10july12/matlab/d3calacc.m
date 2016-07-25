function    [A,CAL,fs] = d3calacc(X,CAL,test,ch)

%    [A,CAL,fs] = d3calacc(X,CAL,test,cn)
%    Automatically performs a calibration sequence on the
%    accelerometer data in raw sensor structure X. If no test
%    is specified, all the following tests are performed in
%    sequence. Otherwise, specify one of the following in test:
%     'bias'   remove bias
%     'p'      compensate for pressure effects
%     't'      compensate for temperature effects
%     'sens'   adjust sensitivity of each axis
%     'cross'  compensate for cross-axis coupling
%    Optional argument ch is used to identify the calibration
%    field of the correct accelerometer if there are multiple triaxial
%    accelerometers in the sensor set. For example, to calibrate
%    the gyro accelerometers, put ch='GACC'.
%
%    mark johnson
%    markjohnson@st-andrews.ac.uk
%    last modified: July 2012

if nargin<2,
   help d3calacc
   return
end

if nargin<4 | isempty(ch),
   ch = 'ACC' ;
end

[ch_names,descr,ch_nums,cal] = d3channames(X.cn) ;
ka = find(strcmp(cal,lower(ch))) ;

if length(ka)>3,
   fprintf(' Multiple accelerometers available. Calibrating %s...\n',ch_names{ka(1)}) ;
   ka = ka(1:3) ;
end

s = [X.x{ka}] ;
fs = X.fs(ka(1)) ;
kt = find(strcmp(cal,'tempr')) ;
t = apply_cal(X.x{kt(1)},CAL.TEMPR) ;
if fs>X.fs(kt),
   t = interp(t,fs/X.fs(kt)) ;
end
p = d3calpressure(X,CAL,'none') ; 
C = getfield(CAL,upper(ch)) ;

TEST = {'bias','p','t','sens','cross','norm'} ;
TXT = {'Bias','Pressure','Temperature','Gain','Cross-axis','Scaling'} ;

if nargin>2 & ~isempty(test),
   if strcmp(test,'none'),
      A = apply_cal(s,C,p,t) ;
      return
   end
   TEST = {test} ;
   TXT = {''} ;
end

% find the 25% of most stable acceleration measurements, i.e., with
% the lowest jerk
ds = norm2(diff(s)) ;
thr = prctile(ds,25) ;
kk = find(ds<thr) ;

% now perform test sequence
for k=1:length(TEST),
   if ~isempty(TXT{k}),
      fprintf(' %s calibration...\n',TXT{k}) ;
   end
   [A,C]=acc_cal(s(kk,:),C,p(kk),t(kk),TEST{k});
end

CAL = setfield(CAL,upper(ch),C) ;
A = apply_cal(s,C,p,t) ;
return


function    [A,CAL] = acc_cal(s,CAL,p,t,test)

OLDCAL = CAL ;
A = apply_cal(s,CAL,p,t) ;       % implement initial calibration
v = norm2(A) ;               % initial standard deviation
mv = mean(v) ;
vmold = std(v) ;
test = lower(test) ;

if strcmp(test,'none'),
   return
elseif strcmp(test,'norm'),
   sc = 1/mv ;
   CAL.POLY = sc*CAL.POLY ;
   CAL.PC = sc*CAL.PC ;
   CAL.TC.POLY = sc*CAL.TC.POLY ;
   fprintf(' Adjusted field strength from %1.3f to 1.000\n',mv) ;
   return
end

for k=1:2,
   % choose auxiliary variable
   switch test
      case 'bias'
         aux = [] ;
      case 'p'
         aux = p/1000 ;
      case 't'
         aux = t-CAL.TREF ;
      case 'cross'
         aux = A(:,[3 1 2]) ;
      case 'sens'
         aux = [A(:,1:2) randn(size(A,1),1)] ;
      otherwise
         fprintf(' Unknown test option %s\n', test) ;
   end

   v = minvar(A,aux,'q') ;     % run least-squares fit
   % update the calibration
   CAL.POLY(:,2) = CAL.POLY(:,2) + v(1:3) ;

   switch test
      case 'p'
         CAL.PC = CAL.PC + v(4:6)/1000 ;
      case 't'
         CAL.TC.POLY = CAL.TC.POLY + v(4:6) ;
      case 'sens'
         CAL.POLY(1:2,1) = CAL.POLY(1:2,1).*(1+v(4:5)) ;
      case 'cross'
         CAL.XC(1,3) = CAL.XC(1,3)+v(4)/2 ;
         CAL.XC(2,1) = CAL.XC(2,1)+v(5)/2 ;
         CAL.XC(2,3) = CAL.XC(2,3)+v(6)/2 ;
         CAL.XC = triu(CAL.XC,0)+tril(CAL.XC'-1) ;
   end

   A = apply_cal(s,CAL,p,t) ;      % implement improved calibration
end

vm = std(norm2(A)) ;
if vm>=vmold,
   fprintf('  No improvement\n') ;
   CAL = OLDCAL ;
else
   fprintf('  Standard deviation was: %4.3f g, improved to %4.3f g\n',...
      vmold,vm) ;

   CAL.LASTCAL = clock ;
   CAL.METHOD = 'data' ;
end
return
