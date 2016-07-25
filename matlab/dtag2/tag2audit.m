function     [RES,AXs,hhh] = tag2audit(tag,tcue,RES,hflim)
%
%     R = tagaudit(tag,tcue,R,DMON, hflim)
%     Audit tool for tag 1 and 2.
%     tag is the tag deployment string e.g., 'sw03_207a'
%     tcue is the time in seconds-since-tag-on to start displaying from
%     R is an optional audit structure to edit or augment
%     hflimit is the highest frequency IN KILOHERTZ to display on the spectrogram (this
%     changes the axis limits only, not the sampling rate).  Default is
%     afs/2.
%     Output:
%        R is the audit structure made in the session. Use saveaudit
%        to save this to a file.
%
%     OPERATION
%     Type or click on the display for the following functions:
%     - type 'f' to go to the next block
%     - type 'b' to go to the previous block
%     - click on the graph to get the time cue, depth, time-to-last
%                and frequency of an event. Time-to-last is the elapsed time 
%                between the current click point and the point last clicked. 
%                Results display in the matlab command window.
%     - type 's' to select the current segment and add it to the audit.
%                You will be prompted to enter a sound type on the matlab command
%                window. Enter the desired cue and type return when complete.
%     - type 'l' to select the currect cursor position and add it to the 
%                audit as a 0-length event. You will be prompted to enter a sound 
%                type on the matlab command window. Enter a single word and type 
%                return when complete.
%     - type 'x' to delete the audit entry at the cursor position.
%                If there is no audit entry at the cursor, nothing happens.
%                If there is more than one audit entry overlapping the cursor, one
%                will be deleted (the first one encountered in the audit structure).
%     - type 'p' to play the entire display through computer speakers
%     - type 'i' to play the marked segment through speakers or headphones.
%                Simultaneously, sound segment will be saved to c:\tempsound.wav
%                (if file already exists, make sure no other program uses it)
%     - type 'q' or press the right hand mouse button to finish auditing.
%     - type 'a' to report the angle of arrival of the selected segment
%
%     mark johnson, WHOI
%     majohnson@whoi.edu
%     last modified March 2005
%     added buttons and updated audit structure


NS = 10 ;          % number of seconds to display
BL = 2048 ;         % specgram (fft) block size (was 512, 5/09 aks)
CLIM = [-90 0] ;   % color axis limits in dB for specgram
CH = 1 ;           % which channel to display if multichannel audio
THRESH = 0 ;       % click detector threshold, 0 to disable
volume = 15 ;      % amplification factor for audio output - often needed to
                   % hear weak signals (if volume>1, loud transients will
                   % be clipped when playing the sound cut  (was 20, 5/09
                   % aks)
SOUND_FH = 0 ;     % high-pass filter for sound playback - 0 for no filter
SOUND_FL = 0 ;     % low-pass filter for sound playback - 0 for no filter
SOUND_DF = 1 ;     % decimation factor for playing sound
AOA_FH = 10e3 ;     % high-pass filter for angle-of-arrival measurement
AOA_SCF = 1500/0.025 ;     % v/h

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

if nargin<3 || isempty(RES),
   RES.cue = [] ;
   RES.comment = [] ;
elseif nargin<4 || isempty(hflim)
    hflim = afs/2/1000;
end

k = loadprh(tag,'p','fs', 'pitch', 'roll', 'head', 'Aw') ;           % read p and fs from the sensor file
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

% high pass filter for envelope
[bh ah] = cheby1(6,0.5,FH/afs*2,'high') ;
% envelope smoothing filter
pp = 1/TC/afs ;

% angle-of-arrival filter
[baoa aaoa] = butter(4,AOA_FH/(afs/2),'high') ;

current = [0 0] ;
figure(1),clf
if ~isempty(p),
   kb = 1:floor(NS*fs) ;
   AXm = axes('position',[0.11,0.76,0.78,0.18]) ;
   AXc = axes('position',[0.11,0.70,0.78,0.05]) ;
   AXs = axes('position',[0.11,0.34,0.78,0.35]) ;
   AXp = axes('position',[0.11,0.11,0.78,0.2]) ;
else
%    AXm = axes('position',[0.11,0.60,0.78,0.34]) ;
   AXc = axes('position',[0.11,0.9,0.78,0.07]) ;
   AXs = axes('position',[0.11,0.11,0.78,0.78]) ;
end

bc = get(gcf,'Color') ;
set(AXc,'XLim',[0 1],'YLim',[0 1]) ;
set(AXc,'Box','off','XTick',[],'YTick',[],'XColor',bc,'YColor',bc,'Color',bc) ;
cleanh = [] ;

while 1,
   [x,afs] = tagwavread(tag,tcue,NS) ;
%    if size(x,2)==1 && nargin>3 && ~isempty(DMON),
%       [x,cleanh] = dmoncleanup(x,0.0001,[],cleanh) ;
%    end
   if isempty(x), return, end    
   [B F T] = specgram(x(:,CH),BL,afs,hamming(BL),BL/2) ;
   xx = filter(pp,[1 -(1-pp)],abs(filter(bh,ah,x(:,CH)))) ;
   if ~isempty(p)
   kk = 1:5:length(xx) ;
   ks = kb + round(tcue*fs) ;
   axes(AXm), plot(ks/fs,pitch(ks)/pi*180,'b') ; hold on; plot(ks/fs,roll(ks)/pi*180, 'g'); plot(ks/fs,(acos(cos(head(ks)))/pi*180).*sign(asin(sin(head(ks)))),'r'); hold off; grid
   legend('pitch', 'roll', 'heading');
   set(AXm,'XAxisLocation','top') ;
%    yl = get(gca,'YLim') ;
%    yl(2) = min([yl(2) MAXYONCLICKDISPLAY]) ;
    ylabel('Degrees');
    xlim([tcue tcue+NS]);
   end  
   plotRES(AXc,RES,[tcue tcue+NS]) ;

   if ~isempty(p),
      ks = kb + round(tcue*fs) ;
% %       axes(AXp), plot (ks(2:end)/fs , sqrt((abs(diff(Aw(ks,2))'*fs*9.81)).^2)) %plot(ks/fs,p(ks)), grid
%  axes(AXp), plot(ks/fs , abs(sqrt(Aw(ks,1).^2+Aw(ks,2).^2+Aw(ks,3).^2)-1).*fs.*9.81); %plot(ks/fs,p(ks)), grid
    axes(AXp), plot(ks/fs, p(ks)), grid;
    set(gca,'YDir','reverse') ;
      axis([tcue tcue+max(T) get(gca,'YLim')]) ;
      xlabel('Time, s')
%       ylabel('Jerk, m/s^3') 
    ylabel('Depth, m')

   end
   
   BB = adjust2Axis(20*log10(abs(B))) ;
   axes(AXs), imagesc(tcue+T,F/1000,BB,CLIM) ;
   axis xy, grid ; ylim([0.01 hflim]);
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
   currsel = [];
   while done == 0,
      axes(AXs) ; pause(0) ;
      [gx gy button] = ginput(1) ;
      if button>='A',
         button = lower(setstr(button)) ;
      end
      
      if button==3 | button=='q',
         save tagaudit_RECOVER RES
         disp( ' Ending audit program')
         disp( ' Remember to save data using saveaudit(tag,R)')
         return

      elseif button=='s',
         ss = input(' Enter comment... ','s') ;
         cc = sort(current) ;
         RES.cue = [RES.cue;[cc(1) diff(cc)]] ;
         RES.stype{size(RES.cue,1)} = ss ;
         save tagaudit_RECOVER RES
         plotRES(AXc,RES,[tcue tcue+NS]) ;

      elseif button=='a',
         try
            length_temp=abs(diff(current)*10);
            [x_temp,afs_org] = d3wavread_x(min(current)+[0 length_temp],...
                               recdir, [tag(1:2) tag(6:9)], 'wav' ) ;
            x_temp = resample(x_temp,afs,afs_org);
            xf = filter(baoa,aaoa,x_temp) ;
            [aa,qq] = xc_tdoa(xf(:,1),xf(:,2)) ;
            fprintf(' Angle of arrival %3.1f, quality %1.2f\n',asin(aa*AOA_SCF/afs_org)*180/pi,qq) ;
            clear x_temp xf % clear variables from memory
         catch
            disp(' An error occurred during angle-of-arrival calculation and operation was aborted')
            disp(' Problem is likely memory related')
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
            
            if ~isempty(bs),
               xf = filter(bs,as,x) ;
               sound(volume*xf,afs/SOUND_DF,16) ;
            else
               sound(volume*x,afs/SOUND_DF,16) ;
            end
            
      elseif button=='i',
            if all(current>0),
                % Load the current marked segment
                length_temp=0.1*ceil(abs(diff(current)*10));
                [x_temp,afs_org] = tagwavread(tag, min(current), length_temp) ;
                x_temp = x_temp(:,CH);
                
                % Write a full-sample version to temporary file
                try
                    wavwrite(x_temp,afs_org,16,'C:\tempsound.wav');
                catch
                    disp(' Error writing to c:\tempsound.wav, close other programs and try again')
                end
                
                % downsample and play
                x_temp = resample(x_temp,afs,afs_org);
                if ~isempty(bs),
                    xf = filter(bs,as,x_temp) ;
                    sound(volume*xf,afs/SOUND_DF,16) ;
                else
                    sound(volume*x_temp,afs/SOUND_DF,16) ;
                end
                clear x_temp % clear variable from memory
            else
                fprintf('Invalid click: Need to mark interval before pressing i to play sound from this interval\n')                
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
            delete(currsel); hold on; currsel = plot(sort(current),[gy gy], 'k*-'); hold off
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

