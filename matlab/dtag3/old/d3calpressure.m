function    [p,tempr,CAL, fs_p] = d3calpressure(x,CAL,test, uchans, fs)
%
%    [p,tempr,CAL] = calpressure(s,CAL,[test])
%    Apply calibration constants to raw tag pressure data.
%    test can be 'full', 'lowbat', 'tempr' or 'none' (the default is none).
%    A full test performs low battery compensation and characterizes
%    the temperature effect and the 0-pressure offset.
%    If a 'full extended' test is requested, a wider range of pressures
%    are analyzed for temperature effects. This is useful for data sets
%    with a wide range of temperature values.
%
%    Pressure result p is in m H20 (salt) per degree Celsius. Temperature
%    result tempr is in degrees Celsius. fs_p is the pressure sampling rate
%    in Hz
%
%    Constants fields used are CAL.TCAL, CAL.PCAL, and CAL.PTC.
%    If r is the raw pressure reading and t is the temperature, 
%    p = a*r^2 + b*r + c + tc*t for a 2nd order calibration.
%
% NOTES:
%   *search for ??????????? to find parts of this script that need editing
%       when d3 low-battery-comp and xml-input scripts are ready.
%    *CAL is expected to be a structure array of calibration constants
%    *x is expected to be a cell array of raw data, from d3parseswv
%    *uchans is the channel id numbers (used to index which vectors from x
%    to use as the pressure and temp sensor data)
%    *fs is a vector of sampling rates for the raw data array x
%   *alternatively, rather than having these inputs, input could be a tagID
%       string;  then the initial lines of the script should include reading in
%       the raw data and reading a cal xml file (resulting in CAL structure).
%
%    from dtag2 calpressure script
%    mark johnson
%    majohnson@whoi.edu
%    last modified: 20 May 2006
%    modified summer 2012 stacy deruiter university of st andrews

p = [] ; t = [] ;
PRESSRANGE = 20 ;

if nargin<2,
   help calpressure
   return
end

if ~isstruct(CAL),
   fprintf(' Second argument must be a calibration structure\n') ;
end

if nargin<3
   test = '' ;
end

[test,extnd] = strtok(lower(test)) ;
% ??????????????????????????????????????????????
%THE FOLLOWING NEEDS TO BE REPLACED WITH D3 SPECIFIC LOWBATT COMP.
% if strcmp(test,'full') | strcmp(test,'lowbat'),
%    x = lowbattpcomp(x,CAL) ;        % repair any low battery effect
% end

tempr = polyval(CAL.TCAL,x{uchans==5121}) ;      % temperature calibration

if strcmp(test,'full') | strcmp(test,'tempr'),
   p = polyval(CAL.PCAL,x{uchans==4869}) ;   % nominal pressure scaling
   if strcmp(strtok(lower(extnd)),'extended'),
      PRESSRANGE = PRESSRANGE * 2 ;
   end
   CAL = calptc(p,tempr,CAL,PRESSRANGE) ; % gui for temperature compensation
end

ptc = [CAL.PTC(:)' 0] ;
p = polyval(CAL.PCAL,x{uchans==4869}) + polyval(ptc,tempr-CAL.TREF) ;
fs_p = fs(uchans==4869);
return


function    CAL = calptc(p,tempr,CAL,PRESSRANGE)
%
%
PRESSDIFF = PRESSRANGE/1000 ;

% select starting set
k = find(p<(min(p)+PRESSRANGE) & abs(diff([0;p]))<PRESSDIFF) ;  

if isempty(k),
   fprintf(' Unable to find suitable p values for temperature characterization - check cal values\n') ;
   return
end

tt = tempr(k) ; pp = p(k) ;
figure(1),clf
subplot(211)
plot((1:length(p))/1000,p),grid,hold on
hu = plot(k/1000,pp,'r.') ;
set(hu,'MarkerSize',5) ;
hg = plot(-100,0,'g.') ;        % dummy plot to make a handle
set(hg,'MarkerSize',5) ;
axis([0 length(p)/1000 (min(pp)-5)+[0 PRESSRANGE*1.5]])
xlabel('samples (x10^3)'),ylabel('nominal depth, m')
title('dive profile. red points are available for calibration') ;

subplot(212)
hp = plot(tt,pp,'.'); grid, hold on
set(hp,'MarkerSize',5) ;
axis([min(tt)-1 max(tt)+1 min(pp)-1 max(pp)+1]) ;
xlabel('temperature, degrees C'),ylabel('nominal depth')
title('depth vs temperature. select points for calibration') ;

done = 0 ;
kk = [] ;
h = plot(-100,0,'g.') ;        % dummy plot to make a handle
set(h,'MarkerSize',5) ;

fprintf('\n Characterizing temperature effects...\n') ;
fprintf(' Select points by enclosing in rectangles using the left mouse button\n') ;
fprintf(' Press any key to end\n')

while ~done,
   if(~waitforbuttonpress),
      pt1 = get(gca,'CurrentPoint') ;        % button down detected
      finalRect = rbbox ;                    % return figure units
      pt2 = get(gca,'CurrentPoint') ;        % button up detected
      q = sort([pt1(1,1:2);pt2(1,1:2)]) ;    % extract x and y
      kk = union(kk,find(tt>q(1,1) & tt<q(2,1) & pp>q(1,2) & pp<q(2,2))) ;
      set(h,'XData',tt(kk),'YData',pp(kk)) ;
      subplot(211)
      set(hg,'XData',k(kk)/1000,'YData',pp(kk)) ;
      subplot(212)
   else
      done = 1 ;
   end
end

if length(kk)<=2,
   return
end

[ptc,SS] = polyfit(tt(kk)-CAL.TREF,pp(kk),2) ;
fprintf(' PTC 2nd order fit coefficients are %1.3f %1.3f\n', -ptc(1:2)) ;
fprintf(' PTC 2nd order fitting error %1.3f m RMS\n', SS.normr/sqrt(length(kk)))
T = linspace(min(tt),max(tt),100) ;
plot(T,polyval(ptc,T-CAL.TREF),'r') ;

s2 = input('  Accept new calibration y/n? ','s') ;

if lower(s2(1))~='y'
   fprintf('  Rejecting new PTC calibration - using old values\n') ;
else
   ptc = [ptc(1:2) 0] ;
   CAL.PTC = -ptc(1:2) ;
   CAL.PCAL(end) = CAL.PCAL(end)-mean(pp(kk)-polyval(ptc,tt(kk)-CAL.TREF)) ;
   CAL.LASTCAL = clock ;
end

subplot(211),hold off
subplot(212),hold off
return
