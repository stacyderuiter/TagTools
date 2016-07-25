function     RES = ggtag3audit(tag,tcue,RES,fhigh,z)

%     Tagaudit tool adapted for version 3 DTAG deployments. Subject to change.
%
%     R = ggtag3audit(tag,tcue,R) will start the audit program for the
%     specified deployment tag at start cue tcue and using a pre-existing
%     audit structure R.
%
%     R = ggtag3audit(tag,tcue,R,fhigh,z) will start a
%     more customized version of the audit program with user specified
%     upper frequency range and information to plot in upper and lower plots
%
%     tag   is the tag deployment 9-letter string e.g., 'sw03_207a'
%     tcue  is the time in seconds-since-tag-on to start tagaudit display
%     R     is an optional audit structure to edit or augment
%     fhigh is an optional limit (Hz) on the frequency display of the
%           spectrogram. Default fhigh is fs/2.
%     z     should be 1 if you want to display dive depth info in the bottom
%           panel, or 0 if you want just spectrogram display (default is to show depth data).
%
%     Output:
%        R is the audit structure made in the session. The audit structure
%        contains time cues and text identifiers (cue types) associated 
%        with audited events. Use saveaudit to save this to a file.
%
%        A safety backup is stored in a temporary mat file in your work
%        directory every time the display window is moved. Load this file, 
%        then check that the loaded RES structure is the correct audit
%        structure, rename it to R, and use saveaudit to write to file.
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
%     stacy deruiter, july 2011 - modified for use with dtag3; jan 2012
%     modified to accept wavx overflow files
%     FHJ, november 2011: Various fixes, improvements and customizations.
%     stacy deruiter, april 2012 - modified for grampus audits


NS = 10 ;          % number of seconds to display
BL = 512;         % specgram (fft) block size (was 512, 5/09 aks)
CLIM = [-90 0] ;  % color axis limits in dB for specgram
CH = 1 ;           % which channel to display if multichannel audio
THRESH = 0 ;       % click detector threshold, 0 to disable
volume = 20 ;      % amplification factor for audio output - often needed to
                   % hear weak signals (if volume>1, loud transients will
                   % be clipped when playing the sound cut  (was 20, 5/09 aks)
SOUND_FH = 100 ;  % high-pass filter (Hz) for sound playback - 0 for no filter
SOUND_FL = 0 ;     % low-pass filter (Hz) for sound playback - 0 for no filter
SOUND_DF = 1 ;     % decimation factor for playing sound
AOA_FH = 2e3 ;     % high-pass filter for angle-of-arrival measurement
AOA_SCF = 1500 / .0225 ; % sound speed divided by half the 
                         % stereo hydrophone separation (adjusted for D3)
                         
MAXYONCLICKDISPLAY = 0.01 ;
DEFAULT_FHIGH      = 48000 ; % Default maximum frequency shown in spectrogram
AFS_RESAMPLE       = 96000 ; % Resample sound to limit data


% high-pass filter frequencies (Hz) for click detector 
switch tag(1:2),
   case 'zc',      % for ziphius use:
      FH = 20000 ;            % high-pass filter settings for click detection
      TC = 0.5e-3 ;           % power averaging time constant in seconds
   case 'md',      % for mesoplodon use:
      FH = 20000 ;       
      TC = 0.5e-3 ;           
   case 'pw',      % for pilot whale use:
      FH = 10000 ;       
      TC = 0.5e-3 ;           
   case 'gm',      % for long-finned pilot whale use:
      FH = 10000 ;       
      TC = 0.5e-3 ;           
   case 'sw',      % for sperm whale use:
      FH = 3000 ;       
      TC = 2.5e-3 ;           
   otherwise,      % for others use:
      FH = 5000 ;       
      TC = 0.5e-3 ;           
end


%%%%%%%%%%%%%%%%%%% Set audit defaults %%%%%%%%%%%%%%%%%%%%%

if nargin<2,
    help ggtag3audit
    error(' Need additional input parameters, see help file ')
elseif length(tcue)>1 | isstruct(tcue)
    error(' Start cue needs to be a number, in seconds since tag-on')
end
if nargin<3 | isempty(RES),
   RES.cue = [] ;
   RES.comment = [] ;
end

if nargin<4 | isempty(fhigh)
    fhigh = 48000;
end

if nargin<5 | isempty(z)
    z = 1;
end


%%%%%%%%%%%%%%%%%%% Load prh file %%%%%%%%%%%%%%%%%%%%%

k = loadprh(tag,'p','fs') ;           % read p and fs from the sensor file
if k==0,
   fprintf('Unable to find a PRH file - continuing without\n') ;
   p = [] ; fs = [] ;
end

%%%%%%%%%%%%%%%%%%% Prepare filters %%%%%%%%%%%%%%%%%%%%%

% check sampling rate
recdir = d3makefname(tag,'RECDIR'); % get audio path
[x,afs] = d3wavread_x([tcue tcue+0.01],recdir, [tag(1:2) tag(6:9)], 'wav' ) ;

% Change sample rate before making filters
if afs>AFS_RESAMPLE
    afs=AFS_RESAMPLE;
end

% filters for sound playback
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


%%%%%%%%%%%%%%%%% Prepare figure plot %%%%%%%%%%%%%%%%%%%

current = [0 0] ;
figure(1),clf
if ~isempty(p) & z == 1,
   kb = 1:floor(NS*fs) ;
   AXm = axes('position',[0.11,0.76,0.78,0.18]) ;
   AXc = axes('position',[0.11,0.70,0.78,0.05]) ;
   AXs = axes('position',[0.11,0.34,0.78,0.35]) ;
   AXp = axes('position',[0.11,0.11,0.78,0.2]) ;
elseif z == 0 %don't show depth, just big spectrogram
   kb = 1:floor(NS*fs) ;
   AXm = axes('position',[0.11,0.76,0.78,0.18]) ;
   AXc = axes('position',[0.11,0.70,0.78,0.05]) ;
   AXs = axes('position',[0.11,0.070,0.78,0.62]) ;  %tall specgram
else
   AXm = axes('position',[0.11,0.60,0.78,0.34]) ;
   AXc = axes('position',[0.11,0.52,0.78,0.07]) ;
   AXs = axes('position',[0.11,0.11,0.78,0.38]) ;  
end

bc = get(gcf,'Color') ;
set(AXc,'XLim',[0 1],'YLim',[0 1]) ;
set(AXc,'Box','off','XTick',[],'YTick',[],'XColor',bc,'YColor',bc,'Color',bc) ;
cleanh = [] ;

%%%%%%%%%%%%%%%%% Start auditing loop %%%%%%%%%%%%%%%%%%%

while 1,

   [x,afs_org] = d3wavread_x([tcue tcue+NS],recdir, [tag(1:2) tag(6:9)], 'wav' ) ;
   x = x(:,CH);
   
   if isempty(x), return, end
   
   % Resample high sample rates to conserve memory and accelerate plots
   if afs_org>AFS_RESAMPLE
       x=resample(x,AFS_RESAMPLE,afs_org);
       afs=AFS_RESAMPLE;
   end
      
   % Filter to get rid of zero offset
   [BBB,AAA]=butter(4,200/(afs/2),'high');
   x=filtfilt(BBB,AAA,x);
   
   % Construct spectrogram - use top line for Matlab version with specgram
   % deactivated
   % [B F T] = spectrogram(x,hamming(BL),floor(BL/1.3),BL,afs, 'yaxis') ;
   [B F T] = specgram(x,BL,afs,hamming(BL),BL/2) ;

   % If a click detection threshold is defined, run click detector
   if THRESH,
       [cl xx] = findclicks(x,THRESH,afs,FH) ;
   end
   
   % Add audit cues
   plotRES(AXc,RES,[tcue tcue+NS]) ;
   
   % Create bottom plot
   if ~isempty(p)
       ks = kb + round(tcue*fs) ;
       if z ==1 ,
        axes(AXp),plot(ks/fs,p(ks)), grid
        set(gca,'YDir','reverse','Xlim',[tcue tcue+max(T)]);
        xlabel('Time, s')
        ylabel('Depth, m')
        axis([tcue tcue+max(T) get(gca,'YLim')]) ;                    
       end
   end
   
   % Construct spectrogram plot
   BB = adjust2Axis(20*log10(abs(B))) ;
   axes(AXs), imagesc(tcue+T,F/1000,BB, CLIM) ;
   yl = get(gca,'YLim') ;
   yl(2) = min([yl(2) fhigh/1000]) ;
   axis([tcue tcue+NS yl]) ;
   axis xy, grid ;
   
   if ~isempty(p) & z==1,
      set(AXs,'XTickLabel',[]) ;
   else
      xlabel('Time, s')
   end
   ylabel('Frequency, kHz')
   
   % Add current selection to spectrogram plot
   hold on, hhh = plot([0 0],0.8*afs/2000*[1 1],'k*-') ; hold off

   % Create envelope
   xx = filter(pp,[1 -(1-pp)],abs(filter(bh,ah,x))) ;
 
  % Plot envelope
    kk = 1:5:length(xx) ;
    axes(AXm), plot(tcue+kk/afs,10*log10(xx(kk)),'k') ; grid
    set(AXm,'XAxisLocation','top') ;
    axis([tcue tcue+NS -35 -10]) ;
    ylabel('Intensity, dB')


   % Initiate command loop
   done = 0 ;
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
                [x_temp,afs_org] = d3wavread_x(min(current)+[0 length_temp],recdir, [tag(1:2) tag(6:9)], 'wav' ) ;
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

