function     [RES,AXs,hhh] = whistle_tagaudit(tag,tcue,RES)
%     modified version of dtag audit to check whistle contour tracing
%     Stacy DeRuiter, April 2009
%
%     R = tagaudit(tag,tcue,R)
%     Audit tool for tag 1 and 2.
%     tag is the tag deployment string e.g., 'sw03_207a'
%     tcue is the time in seconds-since-tag-on to start displaying from
%     R is an optional audit structure to edit or augment
%     Output:
%        R is the audit structure made in the session. Use saveaudit
%        to save this to a file.
%
%     OPERATION
%     Type or click on the display for the following functions:
%     - type 'f' to go to the next block
%     - type 'b' to go to the previous block
%     - click on the graph to get the time cue, depth, time-to-last
%       and frequency of an event. Time-to-last is the elapsed time 
%       between the current click point and the point last clicked. 
%       Results display in the matlab command window.
%     - type 's' to select the current segment and add it to the audit.
%       You will be prompted to enter a sound type on the matlab command
%       window. Enter a single word and type return when complete.
%     - type 'l' to select the currect cursor position and add it to the 
%       audit as a 0-length event. You will be prompted to enter a sound 
%       type on the matlab command window. Enter a single word and type 
%       return when complete.
%     - type 'x' to delete the audit entry at the cursor position.
%       If there is no audit entry at the cursor, nothing happens.
%       If there is more than one audit entry overlapping the cursor, one
%       will be deleted (the first one encountered in the audit structure).
%     - type 'p' to play the displayed sound segment 
%       through the computer speaker/headphone jack.
%     - type 'q' or press the right hand mouse button to finish auditing.
%     - type 'a' to report the angle of arrival of the selected segment
%
%     mark johnson, WHOI
%     majohnson@whoi.edu
%     last modified March 2005
%     added buttons and updated audit structure

%load([tag '_whistles'])

NS = 2 ;          % number of seconds to display
BL = 2048 ;         % specgram (fft) block size
CLIM = [-90 0] ;   % color axis limits in dB for specgram
CH = 1 ;           % which channel to display if multichannel audio
THRESH = 0 ;       % click detector threshold, 0 to disable
volume = 200 ;      % amplification factor for audio output - often needed to
                   % hear weak signals (if volume>1, loud transients will
                   % be clipped when playing the sound cut
SOUND_FH = 0 ;     % high-pass filter for sound playback - 0 for no filter
SOUND_FL = 0 ;     % low-pass filter for sound playback - 0 for no filter
SOUND_DF = 1 ;     % decimation factor for playing sound
AOA_FH = 2e3 ;     % high-pass filter for angle-of-arrival measurement
AOA_SCF = 1500/0.025 ;     % v/h

MAXYONCLICKDISPLAY = 0.01 ;

% high-pass filter frequencies (Hz) for click detector 
switch tag(1:2),
   case 'zc',      % for ziphius use:
      FH = 20000 ;       
   case 'md',      % for mesoplodon use:
      FH = 20000 ;       
   case 'pw',      % for pilot whale use:
      FH = 10000 ;       
   case 'sw',      % for sperm whale use:
      FH = 3000 ;       
   otherwise,      % for others use:
      FH = 5000 ;       
end

if nargin<3 | isempty(RES),
   RES.cue = [] ;
   RES.comment = [] ;
end

k = loadprh(tag,'p','fs') ;           % read p and fs from the sensor file
if k==0,
   fprintf('Unable to find a PRH file - continuing without\n') ;
   p = [] ; fs = [] ;
end

% check sampling rate
[x,afs] = tagwavread(tag,tcue,0.01) ;
if SOUND_FH > 0,
   [bs as] = butter(6,SOUND_FH/(afs/2),'high') ;
elseif SOUND_FL > 0,
   [bs as] = butter(6,SOUND_FL/(afs/2)) ;
else
   bs = [] ;
end

[baoa aaoa] = butter(4,AOA_FH/(afs/2),'high') ;

current = [0 0] ;
figure(1),clf
% if ~isempty(p),
%    kb = 1:floor(NS*fs) ;
%    AXm = axes('position',[0.11,0.76,0.78,0.18]) ;
%    AXc = axes('position',[0.11,0.70,0.78,0.05]) ;
%    AXs = axes('position',[0.11,0.34,0.78,0.35]) ;
%    AXp = axes('position',[0.11,0.11,0.78,0.2]) ;
% else
%    AXm = axes('position',[0.11,0.60,0.78,0.34]) ;
%    AXc = axes('position',[0.11,0.52,0.78,0.07]) ;
%    AXs = axes('position',[0.11,0.11,0.78,0.38]) ;
% end
% 
% bc = get(gcf,'Color') ;
% set(AXc,'XLim',[0 1],'YLim',[0 1]) ;
% set(AXc,'Box','off','XTick',[],'YTick',[],'XColor',bc,'YColor',bc,'Color',bc) ;

while 1,
   [x,afs] = tagwavread(tag,tcue,NS) ;
   if isempty(x), return, end    
   [B F T] = specgram(x(:,CH),BL,afs,hamming(BL),BL/2) ;
   [cl xx] = findclicks(x(:,CH),THRESH,afs,FH) ;
% 
%    kk = 1:5:length(xx) ;
%    axes(AXm), plot(tcue+kk/afs,xx(kk),'k') ; grid
%    set(AXm,'XAxisLocation','top') ;
%    yl = get(gca,'YLim') ;
%    yl(2) = min([yl(2) MAXYONCLICKDISPLAY]) ;
%    axis([tcue tcue+NS yl]) ;
%    
%    plotRES(AXc,RES,[tcue tcue+NS]) ;

%    if ~isempty(p),
%       ks = kb + round(tcue*fs) ;
%       axes(AXp),plot(ks/fs,p(ks)), grid
%    	set(gca,'YDir','reverse') ;
%       axis([tcue tcue+max(T) get(gca,'YLim')]) ;
%       xlabel('Time, s')
%       ylabel('Depth, m')
%    end
   
   BB = adjust2Axis(20*log10(abs(B))) ;
   figure(1), imagesc(tcue+T,F/1000,BB,CLIM) ;
   axis xy, grid ;
%    if ~isempty(p),
%       set(AXs,'XTickLabel',[]) ;
%    else
      xlabel('Time, s')
%    end
   ylabel('Frequency, kHz')
   
   hold on
   hhh = plot([0 0],0.8*afs/2000*[1 1],'k*-') ;    % plot cursor
   %****************************************************************
   %modification (toute petite)
   ylim([0, 35]);
   % hhhs = plot(allt,allcontours./1000, 'k.') ; %plot traced contours
   % hhhst = plot(tse(:,1),12*ones(length(tse(:,1))), 'ko', 'MarkerFaceColor', 'g');%start times of whistles tried to trace 
   % hhhet = plot(tse(:,2),12*ones(length(tse(:,2))), 'ko', 'MarkerFaceColor', 'r');%start times of whistles tried to trace 
   %****************************************************************
   hold off
   if THRESH==0,
      hold on
      plot(cl+tcue,0.4*afs*ones(length(cl),1),'wo') ;
      hold off
   end

   done = 0 ;
   while done == 0,
      figure(1) ; pause(0) ;
      [gx gy button] = ginput(1) ;

      if button==3 | button=='q',
         save tagaudit_RECOVER RES
         return

      elseif button=='s',
         ss = input(' Enter comment... ','s') ;
         cc = sort(current) ;
         RES.cue = [RES.cue;[cc(1) diff(cc)]] ;
         RES.stype{size(RES.cue,1)} = ss ;
         save tagaudit_RECOVER RES
%          plotRES(AXc,RES,[tcue tcue+NS]) ;

      elseif button=='a',
         cc = sort(current)-tcue ;
         kcc = round(afs*cc(1)):round(afs*cc(2)) ;
         xf = filter(baoa,aaoa,x(kcc,:)) ;
         [aa,qq] = xc_tdoa(xf(:,1),xf(:,2)) ;
         fprintf(' Angle of arrival %3.1f, quality %1.2f\n',asin(aa*AOA_SCF/afs)*180/pi,qq) ;

      elseif button=='l',
         ss = input(' Enter comment... ','s') ;
         RES.cue = [RES.cue;[gx 0]] ;
         RES.stype{size(RES.cue,1)} = ss ;
         save tagaudit_RECOVER RES
%          plotRES(AXc,RES,[tcue tcue+NS]) ;

      elseif button=='x',
         kres = min(find(gx>=RES.cue(:,1)-0.1 & gx<sum(RES.cue')'+0.1)) ;
         if ~isempty(kres),
            kkeep = setxor(1:size(RES.cue,1),kres) ;
            RES.cue = RES.cue(kkeep,:) ;
            RES.stype = {RES.stype{kkeep}} ;
%             plotRES(AXc,RES,[tcue tcue+NS]) ;
         else
            fprintf(' No saved cue at cursor\n') ;
         end

      elseif button=='f',
            tcue = tcue+floor(NS)-0.5 ;
            done = 1 ;

      elseif button=='b',
            tcue = max([0 tcue-NS+0.5]) ;
            done = 1 ;

      elseif button=='p',
            if ~isempty(bs),
               xf = filter(bs,as,x) ;
               sound(volume*xf,afs/SOUND_DF,16) ;
            else
               sound(volume*x,afs/SOUND_DF,16) ;
            end

      elseif button==1,
         if gy<0 | gx<tcue | gx>tcue+NS
            fprintf('Invalid click: commands are f b s l p x q\n')

         else
            current = [current(2) gx] ;
            set(hhh,'XData',current) ;
            if ~isempty(p),
               fprintf(' -> %6.1f\t\tdiff to last = %6.1f\t\tp = %6.1f\t\tfreq. = %4.2f kHz\n', ...
                 gx,diff(current),p(round(gx*fs)),gy) ;
			   else
               fprintf(' -> %6.1f\t\tdiff to last = %6.1f\t\tfreq. = %4.2f kHz\n', ...
                 gx,diff(current),gy) ;
	         end
         end
      end
   end
end



function   [cc,xx] = findclicks(x,thresh,fs,fh)
%
%     clicks = findclicks(x,thresh,fs,fh)
%     Return the time cue to each click in x, in seconds
%     x is a signal vector
%     thresh is the click detection threshold - try a value of 0.01 to
%     begin with
%     fs is the sampling rate of x [default = 32000]
%     fh is the high pass filter frequency [default = 10000]
%
%     mark johnson, WHOI
%     August, 2000
%     modified June 2003

% for sperm whales use:
tc = 2.5e-3 ;           % power averaging time constant in seconds

% for ziphius use:
tc = 0.5e-3 ;           % power averaging time constant in seconds

blanking = 20e-3 ;      % blanking time after a click is detected before another

[b a] = cheby1(6,0.5,fh/fs*2,'high') ;
pp = 1/tc/fs ;

xf = filter(b,a,x);
xx = filter(pp,[1 -(1-pp)],abs(xf)) ;
cc = [] ;

if thresh==0,
   return
end

cc = find(diff(xx>thresh)>0)/fs ;
done = 0 ;

if isempty(cc),
   return ;
end

while ~done,
   kg = find(diff(cc)>blanking) ;
   done = length(kg) == (length(cc)-1) ;
   cc = cc([1;kg+1]) ;
end
return


function plotRES(AXc,RES,XLIMS) ;
      
axes(AXc)
if ~isempty(RES.cue),
   kk = find(sum(RES.cue')'>XLIMS(1) & RES.cue(:,1)<=XLIMS(2)) ;
   if ~isempty(kk),
      plot([RES.cue(kk,1) sum(RES.cue(kk,:)')']',0.2*ones(2,length(kk)),'k*-') ;
      for k=kk',
         text(max([XLIMS(1) RES.cue(k,1)+0.1]),0.6,RES.stype{k},'FontSize',10) ;
      end
   else
      plot(0,0,'k*-') ;
   end
else
   plot(0,0,'k*-') ;
end

set(AXc,'XLim',XLIMS,'YLim',[0 1]) ;
bc = get(gcf,'Color') ;
set(AXc,'Box','off','XTick',[],'YTick',[],'XColor',bc,'YColor',bc,'Color',bc) ;
return

