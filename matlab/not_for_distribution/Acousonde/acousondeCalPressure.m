function    [p,t,CAL] = acousondeCalPressure(p,t, fs, CAL)

%    [p,tempr,CAL] = calpressure(s,CAL,[test])
%    calibrate for press/temp effect
%
%    mark johnson
%    majohnson@whoi.edu
%    last modified: 29 August 2008

PRESSRANGE = 20 ;
NOTEMP = 0 ;

if nargin<2,
   help calpressure
   return
end

done = 0 ;
while ~done,
    CAL = time_select(p,fs,CAL) ;
    klims = round(fs*CAL.PRESS.CALTIMESPAN) ;
    k = klims(1)+1:klims(2) ;
    
%     ss = strtok(lower(extnd)) ;
%     if strcmp(ss,'extended'),
%         PRESSRANGE = PRESSRANGE * 2 ;
%     elseif strcmp(ss,'notemp'),
%         NOTEMP = 1 ;
%     end
    [CAL.PRESS,s] = calptc(p(k),t(k),CAL.PRESS,PRESSRANGE,NOTEMP) ; % gui for temperature compensation
    done = s~='r' ;
end


function    [CAL,s] = calptc(p,t,CAL,PRESSRANGE,NOTEMP)
%
%
PRESSDIFF = PRESSRANGE/1000 ;

% select starting set
k = find(p<(min(p)+PRESSRANGE) & abs(diff([0;p]))<PRESSDIFF) ;  

if isempty(k),
   fprintf(' Unable to find suitable p values for temperature characterization - check cal values\n') ;
   return
end

tt = t(k) ; pp = p(k) ;
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
zoom off

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

if NOTEMP==0,
   [ptc,S] = polyfit(tt(kk)-CAL.TREF,pp(kk),2) ;
   fprintf(' PTC 2nd order fit coefficients are %1.3f %1.3f\n', -ptc(1:2)) ;
   fprintf(' PTC 2nd order fitting error %1.3f m RMS\n', S.normr/sqrt(length(kk))) ;
else
   ptc = [0 mean(pp(kk))] ;
   fprintf(' PTC offset is %1.3f\n', -ptc(2)) ;
end

T = linspace(min(tt),max(tt),100) ;
plot(T,polyval(ptc,T-CAL.TREF),'r') ;

s = input('  Accept new calibration y/n? ','s') ;

if isempty(s) | lower(s(1))~='y'
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


function    CAL = time_select(p,fs, CAL)
%
%
figure(1),clf
plott(p,fs*3600)
xlabel('Time, hours')
zoom off
fprintf(' Select left and right limits in Fig 1 by positioning cursor and typing l or r\n') ;
fprintf(' Press any other key to end\n')

Tl = 0 ;
Tr = length(p)/fs ;
if isfield(CAL.PRESS,'CALTIMESPAN'),
   Tl = min(Tr,max(Tl,CAL.PRESS.CALTIMESPAN(1))) ;
   Tr = min(Tr,max(Tl,CAL.PRESS.CALTIMESPAN(2))) ;
end
hold on
hl = plot([1;1]*Tl/3600,get(gca,'YLim'),'g') ;
set(hl,'LineWidth',1.5) ;
hlm = plot(Tl/3600,mean(get(gca,'YLim')),'g>') ;
set(hlm,'MarkerSize',12,'MarkerFaceColor','g') ;

hr = plot([1;1]*Tr/3600,get(gca,'YLim'),'r') ;
set(hr,'LineWidth',1.5) ;
hrm = plot(Tr/3600,mean(get(gca,'YLim')),'r<') ;
set(hrm,'MarkerSize',12,'MarkerFaceColor','r') ;

done = 0 ;
while ~done,
   [x,y,s] = ginput(1) ;
   s = char(s) ;
   switch char(s),
      case 'l'
         Tl = min(Tr,max(0,x*3600)) ;
         set(hl,'XData',Tl/3600*[1 1]) ;
         set(hlm,'XData',Tl/3600) ;
      case 'r'
         Tr = min(length(p)/fs,max(Tl,x*3600)) ;
         set(hr,'XData',Tr/3600*[1 1]) ;
         set(hrm,'XData',Tr/3600) ;
      otherwise done = 1 ;
   end
end

CAL.PRESS.CALTIMESPAN = [Tl,Tr] ;
CAL.PRESS.CALTIMESPANUNIT = 'seconds' ;
return


