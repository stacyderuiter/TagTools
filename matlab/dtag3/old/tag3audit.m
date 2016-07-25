function     RES = tag3audit(tag,tcue,RES,fhigh, upperplot,lowerplot)
%
%     RES = tag3audit(tag,tcue,RES,fhigh, upperplot,lowerplot)
%     Audit tool for tag 3.
%     tag is the tag deployment string e.g., 'sw03_207a'
%
%     tcue is the time in seconds-since-tag-on to start displaying from
%
%     R is an optional audit structure to edit or augment
%
%     fhigh is the highest frequency to show in the spectrogram panel
%     (default is afs/2).  fhigh is in Hz.
%
%     upperplot is the data to be displayed in the top panel - either 'click'
%     for click detector output or 'prh' for pitch-roll-heading data.
%     Default is 'prh'.  NOTE: click detector option needs to be fixed.
%
%     lowerplot is the data to be displayed in the bottom panel - either 'z'
%     for depth or 'j' for jerk. Default is depth.
%
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
%     stacy deruiter, july 2011 - modified for use with dtag3

NS = 25 ;          % number of seconds to display
BL = 1024;         % specgram (fft) block size (was 512, 5/09 aks)
CLIM = [-120 0] ;   % color axis limits in dB for specgram
CH = 1 ;           % which channel to display if multichannel audio
THRESH = 0 ;       % click detector threshold, 0 to disable
volume = 20 ;      % amplification factor for audio output - often needed to
                   % hear weak signals (if volume>1, loud transients will
                   % be clipped when playing the sound cut  (was 20, 5/09
                   % aks)
SOUND_FH = 0 ;     % high-pass filter for sound playback - 0 for no filter
SOUND_FL = 0 ;     % low-pass filter for sound playback - 0 for no filter
SOUND_DF = 1 ;     % decimation factor for playing sound
AOA_FH = 2e3 ;     % high-pass filter for angle-of-arrival measurement
AOA_SCF = 1500/0.045 ;     % v/h . h is the hydrophone separation in m, here taken to be 45 mm for a dtag3 per Tom Hurst.


MAXYONCLICKDISPLAY = 0.01 ;

% high-pass filter frequencies (Hz) for click detector 
switch tag(1:2),
   case 'zc',      % for ziphius use:
      FH = 20000 ;       
      TC = 0.5e-3 ;           % power averaging time constant in seconds
   case 'md',      % for mesoplodon use:
      FH = 20000 ;       
      TC = 0.5e-3 ;           % power averaging time constant in seconds
   case 'pw',      % for pilot whale use:
      FH = 10000 ;       
      TC = 0.5e-3 ;           % power averaging time constant in seconds
   case 'sw',      % for sperm whale use:
      FH = 3000 ;       
      TC = 2.5e-3 ;           % power averaging time constant in seconds
   otherwise,      % for others use:
      FH = 5000 ;       
      TC = 0.5e-3 ;           % power averaging time constant in seconds
end

if nargin<3 | isempty(RES),
   RES.cue = [] ;
   RES.comment = [] ;
end

if nargin<5 | isempty(upperplot)
    upperplot = 'prh';
end

if nargin<6 | isempty(lowerplot)
    lowerplot = 'z';
end


k = loadprh(tag,'p','fs', 'pitch', 'roll', 'head') ;           % read p and fs from the sensor file
if k==0,
   fprintf('Unable to find a PRH file - continuing without\n') ;
   p = [] ; fs = [] ;
end

% check sampling rate
recdir = d3makefname(tag,'RECDIR'); %path to directory where audio files are stored for this tagout
[x,afs] = d3wavread([tcue tcue+0.01],recdir, [tag(1:2) tag(6:9)], 'wav' ) ;
if SOUND_FH > 0,
   [bs as] = butter(6,SOUND_FH/(afs/2),'high') ;
elseif SOUND_FL > 0,
   [bs as] = butter(6,SOUND_FL/(afs/2)) ;
else
   bs = [] ;
end

if nargin<4 | isempty(fhigh)
    fhigh = afs/2;
end

% high pass filter for envelope
[bh ah] = cheby1(6,0.5,FH/afs*2,'high') ;
% envelope smoothing filter
pp = 1/TC/afs ;

% % angle-of-arrival filter
% [baoa aaoa] = butter(4,AOA_FH/(afs/2),'high') ;

current = [0 0] ;
figure(1),clf
if ~isempty(p),
   kb = 1:floor(NS*fs) ;
   AXm = axes('position',[0.11,0.76,0.78,0.18]) ;
   AXc = axes('position',[0.11,0.70,0.78,0.05]) ;
   AXs = axes('position',[0.11,0.34,0.78,0.35]) ;
   AXp = axes('position',[0.11,0.11,0.78,0.2]) ;
else
   AXm = axes('position',[0.11,0.60,0.78,0.34]) ;
   AXc = axes('position',[0.11,0.52,0.78,0.07]) ;
   AXs = axes('position',[0.11,0.11,0.78,0.38]) ;
end

bc = get(gcf,'Color') ;
set(AXc,'XLim',[0 1],'YLim',[0 1]) ;
set(AXc,'Box','off','XTick',[],'YTick',[],'XColor',bc,'YColor',bc,'Color',bc) ;
cleanh = [] ;

while 1,
   [x,afs] = d3wavread([tcue tcue+NS],recdir, [tag(1:2) tag(6:9)], 'wav' ) ;
   x = x(:,CH);
   if fhigh < afs/2; % for low(er) freq cases
       decfactor = floor(afs/2/fhigh);
       x = decimate(x(:,1),decfactor);
       afs = afs/decfactor;
   end
   if isempty(x), return, end
   [B, F, T] = spectrogram(x,hamming(BL),floor(BL/1.3),BL,afs, 'yaxis') ;
   %    [B F T] = specgram(x(:,CH),BL,afs,hamming(BL),BL/2) ;
    xx = filter(pp,[1 -(1-pp)],abs(filter(bh,ah,x(:,CH)))) ;

   kk = 1:5:length(xx) ;
   if ~isempty(p)
   ks = kb + round(tcue*fs) ;
   end
   
   %UPPER PLOT (above specgram)
   switch upperplot
       case 'click'
           error('click detection not yet developed for audit display')
       case 'prh'
           if exist('head')
           axes(AXm), plot(ks/fs,pitch(ks)/pi*180,'b') ; hold on; plot(ks/fs,roll(ks)/pi*180, 'g'); plot(ks/fs,(head(ks)/pi*180),'r'); hold off; grid
           legend('pitch', 'roll', 'heading');
           set(AXm,'XAxisLocation','top') ;
        %    yl = get(gca,'YLim') ;
        %    yl(2) = min([yl(2) MAXYONCLICKDISPLAY]) ;
            ylabel('Degrees');
            xlim([tcue tcue+NS]);
           end
       otherwise
           error('Invalid selection for data display in upper plot');
   end
  
   plotRES(AXc,RES,[tcue tcue+NS]) ;
   
   %LOWER PLOT (below specgram)
   if ~isempty(p)
   switch lowerplot
       case 'z'
            if ~isempty(p),
                ks = kb + round(tcue*fs) ;
                axes(AXp),plot(ks/fs,p(ks)), grid
                set(gca,'YDir','reverse') ;
                axis([tcue tcue+max(T) get(gca,'YLim')]) ;
                xlabel('Time, s')
                ylabel('Depth, m')
            end
       case 'j'
           if ~isempty(Aw),
                ks = kb + round(tcue*fs) ;
                axes(AXp), plot (ks(2:end)/fs , sqrt((abs(diff(Aw(ks,2))'*fs*9.81)).^2)) %plot(ks/fs,p(ks)), grid
                axis([tcue tcue+max(T) get(gca,'YLim')]) ;
                xlabel('Time, s')
                ylabel('Jerk, m/s^3') 
           end
       otherwise
           error('Invalid selection for data display in lower plot');
   end
   end
   
   %SPECTROGRAM PLOT
   BB = adjust2Axis(20*log10(abs(B))) ;
   axes(AXs), imagesc(tcue+T,F/1000,BB, CLIM) ;
   axis xy, grid ; ylim([0.001 fhigh/1000]);
   if ~isempty(p),
      set(AXs,'XTickLabel',[]) ;
   else
      xlabel('Time, s')
   end
   ylabel('Frequency, kHz')
   hold on
   hhh = plot([0 0],0.8*afs/2000*[1 1],'k*-') ;    % plot cursor
   hold off

   done = 0 ;
   while done == 0,
      axes(AXs) ; pause(0) ;
      [gx gy button] = ginput(1) ;
      if button>='A',
         button = lower(setstr(button)) ;
      end
      if button==3 | button=='q',
         save tagaudit_RECOVER RES
         return

      elseif button=='s',
         ss = input(' Enter comment... ','s') ;
         cc = sort(current) ;
         RES.cue = [RES.cue;[cc(1) diff(cc)]] ;
         RES.stype{size(RES.cue,1)} = ss ;
         save tagaudit_RECOVER RES
         plotRES(AXc,RES,[tcue tcue+NS]) ;

      elseif button=='a',
         if size(x,2)>1,
            cc = sort(current)-tcue ;
            kcc = round(afs*cc(1)):round(afs*cc(2)) ;
            xf = filter(baoa,aaoa,x(kcc,:)) ;
            [aa,qq] = xc_tdoa(xf(:,1),xf(:,2)) ;
            fprintf(' Angle of arrival %3.1f, quality %1.2f\n',asin(aa*AOA_SCF/afs)*180/pi,qq) ;
         end

      elseif button=='l',
         ss = input(' Enter comment... ','s') ;
         RES.cue = [RES.cue;[gx 0]] ;
         RES.stype{size(RES.cue,1)} = ss ;
         save tagaudit_RECOVER RES
         plotRES(AXc,RES,[tcue tcue+NS]) ;

      elseif button=='x',
         kres = min(find(gx>=RES.cue(:,1)-0.1 & gx<sum(RES.cue')'+0.1)) ;
         if ~isempty(kres),
            kkeep = setxor(1:size(RES.cue,1),kres) ;
            RES.cue = RES.cue(kkeep,:) ;
            RES.stype = {RES.stype{kkeep}} ;
            plotRES(AXc,RES,[tcue tcue+NS]) ;
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
            chk = min(size(x,2),2) ;
            if ~isempty(bs),
               xf = filter(bs,as,x(:,1:chk)) ;
               sound(volume*xf,afs/SOUND_DF,16) ;
            else
               sound(volume*x(:,1:chk),afs/SOUND_DF,16) ;
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

