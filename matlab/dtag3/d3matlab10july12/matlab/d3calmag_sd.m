function    [M,CAL,fsm,Mz] = autocalmag(X,CAL,test)

%    [M,CAL,fsm,Mz] = d3calmag(X,CAL,test)
%    Automatically performs a calibration sequence on the raw
%    magnetometer data in raw sensor structure X. 
%    
%    mark johnson
%    markjohnson@st-andrews.ac.uk
%    last modified: July 2012

if nargin<2,
   help d3calmag
   return
end

[ch_names,descr,ch_nums,type] = d3channames(X.cn) ;
km = find(strcmp(type,'mag')) ;
if length(km>3),
   [s,Mz,fsm] = interpmag([X.x{km}],X.fs(km(1))) ;
else
   s = [X.x{km}] ;
   Mz = [] ;
   fsm = [X.fs(km(1)) 0] ;
end

kb = find(strcmp(type,'mag.bridge')) ;
t = apply_cal([X.x{kb}],CAL.MAG.BRIDGE) ;
if fsm(1)>X.fs(kb(1)),
   t = interp(t(:,2),fsm(1)/X.fs(kb(1))) ;
end
p = d3calpressure(X,CAL,'none') ; 
%a little messy fix in case interpolated t turns out to be a different size
%from p...
if length(t) < length(p)
    t((end+1):length(p)) = repmat(t(end),1,(length(p)-length(t)));
elseif length(p) < length(t)
    t = t(1:length(p));
end
%...and that's the end of the messy fix.  stacy deruiter july 2012


C = CAL.MAG ;

TEST = {'hard','t','sens','soft','p'} ;
TXT = {'Hard iron','Temperature','Gain','Soft iron','Pressure'} ;

if nargin==3 & ~isempty(test),
   if strcmp(test,'none'),
      M = apply_cal(s,C,p,t) ;
      return
   end
   TEST = {test} ;
   TXT = {''} ;
end

% skip the first 4 seconds which have the demag process
kk = round(4*fsm(1)):size(s,1) ;

% now perform test sequence
for k=1:length(TEST),
   if ~isempty(TXT{k}),
      fprintf(' %s calibration...\n',TXT{k}) ;
   end
   [M,C]=mag_cal(s(kk,:),C,p(kk),t(kk),TEST{k});
end

CAL = setfield(CAL,'MAG',C) ;
M = apply_cal(s,C,p,t) ;
vv = norm2(M(kk,:)) ;
mv = mean(vv) ; sv = std(vv) ;
fprintf('\n  Final Magnetic Field Intensity: %4.2f uT (%4.3f uT S.D.)\n',mv,sv) ;
return

function    [M,CAL] = mag_cal(s,CAL,p,t,test)

OLDCAL = CAL ;                      % save old cal in case we need to back up
M = apply_cal(s,CAL,p,t) ;          % implement initial calibration
svold = std(norm2(M)) ;
test = lower(test) ;

for k=1:2,
   % choose auxiliary variable
   switch test
      case 'hard'
         aux = [] ;
      case 't'
         aux = t ;
      case 'p'
         aux = p/1000 ;
      case 'soft'
         aux = M(:,[3 1 2]) ;
      case 'sens'
         aux = [M(:,1:2) randn(size(M,1),1)] ;
      otherwise
         fprintf(' Unknown test option %s\n', test) ;
   end

   v = minvar(M,aux,'q') ;      % run least-squares fit

   % update the calibration
   CAL.POLY(:,2) = CAL.POLY(:,2) + v(1:3) ;

   switch test
      case 't'
         CAL.TC.POLY = CAL.TC.POLY + v(4:6) ;
         CAL.TC.SRC = 'bridge' ;
      case 'p'
         CAL.PC = CAL.PC + v(4:6)/1000 ;
      case 'sens'
         CAL.POLY(1:2,1) = CAL.POLY(1:2,1).*(1+v(4:5)) ;
      case 'soft'
         CAL.XC(1,3) = CAL.XC(1,3)+v(4)/2 ;
         CAL.XC(2,1) = CAL.XC(2,1)+v(5)/2 ;
         CAL.XC(2,3) = CAL.XC(2,3)+v(6)/2 ;
         CAL.XC = triu(CAL.XC,0)+tril(CAL.XC'-1) ;
   end

   M = apply_cal(s,CAL,t,p) ;      % implement improved calibration
end

vv = norm2(M) ;
sv = std(vv) ;
mv = mean(vv) ;
if sv>=svold,
   fprintf('  No improvement\n') ;
   CAL = OLDCAL ;
   M = apply_cal(s,CAL,t,p) ;      % implement original calibration

else
   fprintf('  Mean Magnetic Field Intensity after calibration: %4.2f uT\n',mv) ;
   fprintf('  Standard deviation was: %4.3f uT, improved to %4.3f\n',...
   svold, sv) ;
   CAL.LASTCAL = clock ;
   CAL.METHOD = 'data' ;
end
return
