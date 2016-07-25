function    P = wslparams(tag,cue,P)
%
%     P = wslparams(tag,cue,P)
%     Interactive tool to extract information about whistles.
%     tag   is the name of a tag deployment, e.g., 'pw04_297a'
%     cue   is either a list of cues to whistles, or a section
%           of an audit (the R structure) from findaudit
%           or can be the sound type names to search for in
%           findaudit, e.g., 'wsl' or {'wsl','sq'}
%     P     is optional. It is the output from a previous session
%           of wslparams that you want to edit.
%     A number of commands are available in the graphical window
%     that opens:
%     f  to move to next whistle
%     b  to move back to previous whistle
%     c  to add a comment (enter the comment at the prompt in the
%        command window)
%     p  to play the sound
%     q  to quit
%     d  to designate the type of whistle (focal, non-focal, etc.)
%     x  to delete the entire frequency contour for the whistle
%     h  to enter the number of harmonics that are evident (counting
%        by eye)
%     z  to delete the nearest point on the frequency contour
%     n  to notify the harmonic number of the frequency contour 
%     l  moves the left hand limit of analysis to the current cursor
%        position. This is used to exclude high energy signals prior
%        to the whistle.
%     r  moves the right hand limit of analysis to the current cursor
%        position. This is used to exclude high energy signals following
%        the whistle. Note that the program treats the 0.1 s of signal
%        following the right hand limit as an ambient noise sample for
%        SNR computation.
%     a  add a gap or discontinuity indicator at the mouse position
%     e  erase the nearest gap to the current mouse position
%
%     click with the left mouse button twice to mark a rectangle that
%     covers a section of a harmonic for which you want the frequency
%     contour. You can add more points by clicking more rectangles.
%     All the points should lie on the same harmonic. You will be
%     prompted to enter which harmonic you are following (the
%     fundamental is 1). You can change this number using command 'n'.
%
%     Output:
%     P is a structure containing the tag name, the date of last edit,
%     and a cell array of structures called params. There is a structure
%     for each whistle processed. The structure components are:
%     cue:           the start cue and duration of the whistle from tagaudit
%     limcue:        the limits for energy analysis (start and end cues)
%     clip:          1 if the whistle is strong enough to clip in the recording system
%     durenergy:     duration of the whistle under the 95% energy criterion
%     startenergy:   cue of the start of the whistle under the 95% energy criterion
%     durrms:        RMS duration of the signal in seconds
%     sigrms:        RMS signal level
%     SNR:           signal-to-noise ratio in dB
%     aoaq:          quality of angle of arrival (0.5 is bad, 1 is best)
%     aoa:           angle of arrival in radians
%     fp:            the peak frequency averaged over the energy duration
%     designation:   the type of whistle
%     audstype:      the audit stype designation
%     contour:       the frequency contour - a 2-column matrix [cue,freq]
%     charm:         harmonic number of the contour
%     harmonics:     number of visible harmonics
%     discont:       cues of any discontinuities in the whistle
%
%     mark johnson, WHOI
%     majohnson@whoi.edu
%     last modified: 18 January 2008

DRANGE = 70 ;                       % dynamic range of spectrogram display, dB
RECFILE = 'RECOVER_wslparams' ;     % name of the backup file in the working directory
designopts = {'unknown','focal','non-focal','non-tonal'} ;

if nargin<2,
   help wslparams
   return
end

if isstruct(cue),
   R = cue ;
   cue = R.cue ;
elseif iscell(cue) | isstr(cue),
   [cue R] = findaudit(tag,cue) ;
else
   R = [] ;                % if cues are passed, there is not audit information
end

if isempty(cue),
   return
end

% check for long duration cues
k = find(cue(:,2)<15) ;
if length(k)<size(cue,1),
   fprintf(' Error: One or more durations is greater than 15 - eliminating\n') ;
   cue = cue(k,:) ;
   R.cue = cue ;
   R.stype = {R.stype{k}} ;
end

if nargin<3,
   P.tag = tag ;
   P.params = cell(size(cue,1),1) ;
else
   if ~isequal(P.tag,tag),
      fprintf(' Error: passed "P" structure is for a different tag\n') ;
      return
   end
   if length(P.params)<size(cue,1), P.params{size(cue,1)} = [] ; end
end

P.date = datestr(clock,0) ;
k = 1 ;
while(1),

   [FB,tbin,fbin,P.params{k}] = procsignal(tag,cue(k,:),P.params{k}) ;
   if ~isfield(P.params{k},'designation'),
         P.params{k}.designation = designopts{1} ;
   end
   
   if ~isempty(R),
      P.params{k}.audstype = R.stype{k} ;
   end

   figure(1),clf
   imagesc(tbin-tbin(1),fbin,FB),grid
   axis xy
   hold on
   hh = plot([1;1]*((P.params{k}.startenergy-tbin(1))+[0 P.params{k}.durenergy]),[0;max(fbin)]*[1 1],'k') ;
   set(hh,'LineWidth',1.5) ;

   if isfield(P.params{k},'limcue'),
      hh = plot([1;1]*(P.params{k}.limcue-tbin(1)),[0;max(fbin)]*[1 1],'k--') ;
      set(hh,'LineWidth',1.5) ;
   end

   if isfield(P.params{k},'discont'),
      discont = P.params{k}.discont ;
      hh = plot([1;1]*(discont(:,1)'-tbin(1)),[0;max(fbin)]*ones(1,size(discont,1)),'w-') ;
      hh = [hh;plot([1;1]*(discont(:,2)'-tbin(1)),[0;max(fbin)]*ones(1,size(discont,1)),'w-')] ;
      set(hh,'LineWidth',1) ;
   end

   if isfield(P.params{k},'contour') & ~isempty(P.params{k}.contour),
      while ~isfield(P.params{k},'charm') | isnan(P.params{k}.charm),
         fprintf(' Contour does not have a harmonic number!!\n') ;
         ss = input(' Enter the harmonic number of the contour... ','s') ;
         ch = round(str2double(ss)) ;
         if ch>0 & ch<10,
            P.params{k}.contour(:,2) = P.params{k}.contour(:,2)/ch ;
            P.params{k}.charm = ch ;
         end
      end
      c = P.params{k}.contour ;
      plot(c(:,1)-tbin(1),c(:,2),'k.') ;
   end

   title(sprintf('whistle %d at cue %5.1f%s',k,tbin(1))) ;
   figure(1)
   cc = caxis ;
   caxis(cc(2)+[-DRANGE 0]) ;           % limit the dynamic range displayed

   done = 0 ;
   show = 1 ;
   while done == 0,
      if show==1,
         showparams(P.params{k},k) ;
         show = 0 ;
      end
      save(RECFILE,'P') ;                % make backup
      pause(0) ;                       % force figure to draw itself completely
      [gx gy button] = ginput(1) ;
      if button>='A',
         button = lower(setstr(button)) ;    % accept upper or lower case commands
      end

      if button=='q',
         return

      elseif button=='c',
         ss = input(' Enter comment... ','s') ;
         P.params{k}.comment = ss ;
         show = 1 ;

      elseif button=='h',
         ss = input(' Enter the harmonic number of the contour... ','s') ;
         ch = round(str2double(ss)) ;
         if ch>0 & ch<10,
            P.params{k}.charm = ch ;
         end
         show = 1 ;

      elseif button=='n',
         ss = input(' Enter number of clear harmonics... ','s') ;
         P.params{k}.harmonics = round(str2double(ss)) ;
         show = 1 ;

      elseif button=='d',
         [kd,ok] = listdlg('ListString',designopts,'SelectionMode','single',...
            'InitialValue',strmatch(P.params{k}.designation,designopts,'exact'),...
            'OKString','Accept','Name','Whistle designation','ListSize',[160 160]) ;
         if ok,
            P.params{k}.designation = designopts{kd} ;
         end
         show = 1 ;

      elseif button=='f',
         k = k+1 ;
         done = 1 ;
         if k>size(cue,1),
            return
         end

      elseif button=='b',
         k = max(k-1,1) ;
         done = 1 ;

      elseif button=='x',
         P.params{k}.contour = [] ;
         P.params{k}.charm = NaN ;
         done = 1 ;

      elseif button=='l',
         P.params{k}.limcue(1) = gx+tbin(1) ;
         done = 1 ;

      elseif button=='r',
         if gx+tbin(1)<P.params{k}.limcue(1)+0.05,
            fprintf(' Right hand limit must be to the right of the left hand limit\n') ;
         else
            P.params{k}.limcue(2) = gx+tbin(1) ;
            done = 1 ;
         end

      elseif button=='p',
         [x,afs] = tagwavread(tag,P.params{k}.limcue(1),diff(P.params{k}.limcue)) ;
         gain = 0.5/max(abs(x(:,1))) ;
         sound(gain*x(:,1),afs,16) ;

      elseif button=='z',     % delete nearest contour point to (gx,gy)
         ASPECTRAT = abs(diff(get(gca,'YLim'))/diff(get(gca,'XLim'))) ;
         if isfield(P.params{k},'contour'),
            c = P.params{k}.contour ;
            [mm ks] = min(abs((c(:,1)-tbin(1))*ASPECTRAT+j*c(:,2)-(gx*ASPECTRAT+j*gy))) ;
            if ~isempty(ks),
               kk = setxor((1:size(c,1)),ks) ;
               P.params{k}.contour = c(kk,:) ;
               done = 1 ;
            end
         end

      elseif button=='a',     % add a discontinuity at gx
         fprintf('Click on the endpoint of the discontinuity\n') ;
         [gx1,gy1,button] = ginput(1) ;
         discont = sort([gx,gx1])+tbin(1) ;
         if isfield(P.params{k},'discont'),
            discont = [P.params{k}.discont; discont] ;
            [ddd ksort] = sort(discont(:,1)) ;
            discont = discont(ksort,:) ;
         end
         P.params{k}.discont = discont ;
         done = 1 ;

      elseif button=='e',     % eliminate nearest discontinuity to gx
         if isfield(P.params{k},'discont'),
            c = P.params{k}.discont ;
            [mm ks] = min(abs(min(c'-tbin(1)-gx))) ;
            if ~isempty(ks),
               kk = setxor((1:size(c,1)),ks) ;
               P.params{k}.discont = c(kk,:) ;
               done = 1 ;
            end
         end

      elseif button==1,
         if gy<0 | gx<0 | gx>tbin(end)-tbin(1),
            fprintf('Invalid click: commands are b c d f h l n p q r x z\n') ;
         else
            [gx2 gy2 button] = ginput(1) ;
            if button==1,
               q = sort([gx gy;gx2 gy2]) ;    % extract x and y
               if ~isfield(P.params{k},'contour'),
                  P.params{k}.contour = [] ;
               end
               c = [P.params{k}.contour;followridge(FB,tbin,fbin,q)] ;
               [cc,kc] = unique(c(:,1)) ;
               P.params{k}.contour = c(kc,:) ;

               while ~isfield(P.params{k},'charm') | isnan(P.params{k}.charm),
                  ss = input(' Enter the harmonic number of the contour... ','s') ;
                  ch = round(str2double(ss)) ;
                  if ch>0 & ch<10,
                     P.params{k}.charm = ch ;
                  else
                     P.params{k}.charm = NaN ;
                  end
               end
               done = 1 ;
            end
         end
      end
   end
end


function    [FB,tbin,fbin,P] = procsignal(tag,cue,P)
%
%
%

% criteria
engcrit = 0.95 ;        % 95% of energy duration criterion
NFFT = 4096 ;           % FFT size to use in spectral analysis
BLKSIZE = 0.01 ;        % block length for spectrogram analysis, ms
BLKOVLP = 0.005 ;        % overlap between blocks, ms
fc = 700 ;              % high-pass filter to apply to signal, Hz
fl = 42e3 ;             % low-pass filter, Hz
PREF = 0.2 ;            % amount to read prior to the start cue, s
SUFF = 0.2 ;            % amount to read after the end cue, s
NDUR = 0.1 ;            % amount to read after the suffix for a noise measurement
CH = 1 ;                % which channel of multi-channel signals to analyse
OTHERCH = 2 ;           % which other channel to analyse for angle-of-arrival
separation = 0.025 ;    % hydrophone separation in stereo tags, m

% determine the start and end cues to use
P.cue = cue ;
stcue = cue(1)-PREF ;            % use PREF and SUFF to define the overall cues
edcue = sum(cue)+SUFF ;
if ~isfield(P,'limcue'),
   P.limcue = [stcue,edcue] ;  % limcues set the part of the signal analyzed
else
   stcue = min(P.limcue(1)-PREF,stcue) ;
   edcue = max(P.limcue(2)+SUFF,edcue) ;
end

% read in the signal
[x,afs] = tagwavread(tag,stcue,edcue-stcue+NDUR) ;
P.clip = max(abs(x(:,CH)))>0.8 ;          % is the signal close to clipping?

% decimate by 2 if the sampling rate is 192 kHz.
if afs>100e3,
   x = decdc(x,2) ;
   afs = afs/2 ;
end

% filter it to get rid of out-of-band noise
fl = min([fl,afs*0.45]) ;
[bh ah] = butter(6,[fc fl]/(afs/2)) ;     % design a filter
xf = filter(bh,ah,x(:,CH)) ;              % and apply the filter to one channel

% find the noise power
knse = round(afs*(P.limcue(2)-stcue))+(1:round(NDUR*afs)) ; % indices of the noise segment
nrms = std(xf(knse)) ;                    % noise level in RMS

% find the signal
klims = round(afs*(P.limcue-stcue))+1 ;   % restrict analysis to limitcues
ksig = klims(1):klims(2) ;                % indices of the signal segment
envsq = abs(hilbenv(xf(ksig))).^2 ;       % compute the squared envelope
eng = cumsum(envsq-nrms^2) ;              % compute cumulative energy
lthr = max(eng)*(1-engcrit)/2 ;           % find the alpha and 1-alpha energy levels
uthr = max(eng)-lthr ;
kst = klims(1)+min(find(eng>lthr))-1 ;    % find the samples that pass these thresholds
ked = klims(1)+max(find(eng<uthr))-1 ;    %  in terms of the entire signal, x
P.durenergy = (ked-kst)/afs ;             % energy duration is the time difference between
                                          % the start and end sample numbers
P.startenergy = stcue+(kst-1)/afs ;       % energy start cue

% compute RMS duration
t = (0:length(ksig)-1)'/afs ;
t0 = sum(t.*(envsq-nrms^2))/eng(end) ;    % centroid time
tms = sum(t.^2.*(envsq-nrms^2))/eng(end) ;
P.durrms = sqrt(tms-t0^2) ;               % rms duration

% compute SNR
keng = (kst:ked) ;                        % indices of the signal according to energy
xs = xf(keng) ;                           % the energy signal
P.sigrms = std(xs) ;                      % rms level of the signal
P.SNR = 20*log10(P.sigrms/nrms) ;         % signal to noise ratio in dB

% compute angle of arrival
if size(x,2)>=2,
   xf2 = filter(bh,ah,x(:,OTHERCH)) ;     % get the other signal channel
   [cmin,P.aoaq] = xc_tdoa(xs,xf2(keng)) ;   % compute TDOA
   P.aoa = cmin*1500/(afs*separation) ;   % convert to angle of arrival
   clear xf2
else
   P.aoa = NaN ; P.aoaq = NaN ;        % if mono data, give NaN for aoa
end

% spectrogram analysis of the entire signal
% break the signal into BLKSIZE overlapping segments
[xb,z] = buffer(x(:,CH),round(afs*BLKSIZE),round(afs*BLKOVLP),'nodelay') ;
% take windowed FFT of each segment
FB = abs(fft(xb.*(hanning(size(xb,1))*ones(1,size(xb,2))),NFFT)).^2 ;
FB = FB(1:NFFT/2,:) ;                     % just keep the lower half of the fft
fbin = (0:size(FB,1)-1)'/NFFT*afs ;        % frequency bins of spectrogram
tbin = BLKSIZE/2+(0:size(FB,2)-1)'*(BLKSIZE-BLKOVLP) ;   % time bins of spectrogram

% analyse the part of the spectrogram that contains the energy signal
sbins = nearest(tbin,[kst ked]'/afs) ;
ksig = sbins(1):sbins(2) ;                % indices of the signal part of the spectrogram
[pkpow,nn] = max(sum(FB(:,ksig)')) ;      % find the overall peak of the signal
P.fp = (nn-1)*afs/NFFT ;                  % peak frequency, Hz
FB = 10*log10(FB) ;                       % the spectrogram in dB
tbin = tbin+stcue ;                       % convert bin times to cue time
return


function    showparams(P,k)
%
%
%
fprintf('\n *** Whistle %d, cue %5.1f ***\n',k,P.startenergy) ;
fprintf(' Designation\t\t%s\n',P.designation) ;
fprintf(' Energy duration\t%2.2f s\n',P.durenergy) ;
fprintf(' RMS duration\t\t%2.2f s\n',P.durrms) ;
fprintf(' Peak frequency\t\t%4.1f Hz\n',P.fp) ;
fprintf(' SNR\t\t\t\t%2.0f dB\n',P.SNR) ;
if isfield(P,'harmonics'),
   fprintf(' Visible harmonics\t%d\n',P.harmonics) ;
end
if isfield(P,'charm') & ~isnan(P.charm),
   fprintf(' Contour harmonic\t%d\n',P.charm) ;
end

%if isfield(P,'audstype'),
%   fprintf(' Audit stype:\t%s\n',P.audstype) ;
%end

if isfield(P,'comment'),
   fprintf(' Comment:\t%s\n',P.comment) ;
end
return


function    pk = followridge(FB,tbin,fbin,q) ;
%
%
%

kf = nearest(fbin,q(:,2)) ;           % define the sub-section of FB
kf = kf(1):kf(2) ;
kt = nearest(tbin-tbin(1),q(:,1)) ;
kt = kt(1):kt(2) ;
FBS = FB(kf,kt) ;
[m,km] = max(FBS) ;
kg = find(m>min(FBS)+6) ;
pk = [tbin(kt(kg)) fbin(kf(km(kg)))] ;

% find the ridge within q and follow it
