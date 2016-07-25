function    [DD,W] = d3stackplot(recdir,prefix,cue,CL,intervl,DD)
%
%     DD=d3stackplot(recdir,prefix,cue,CL,[intervl,DD])
%     recdir is the directory in which the audio files are located.
%     prefix is the base name of the audio files excluding the last three
%        digits that are indicate the recording number.
%     cue is the time in seconds to start working from in source time.
%        If cue = [start_cue end_cue], the length of that interval will
%        be used as the frame length instead of the default 20s.
%     CL is a vector of source event times
%     intervl = [left right] are the times in seconds to display with
%        respect to each event time. Default is [0 0.5]. 
%     Returns:
%     D = [source_cue,time_offset]. D can be passed as an
%        input argument to allow multiple work sessions.
%        Each cue is a value from CL. The receive_cue (the time
%        of arrival of the event in the audio files) is the
%        source_cue+time_offset.
%        
%     Example:
%  D=d3stackplot('e:/by10/may26','byDMON16_26may_',CL(1,1),CL(:,1),1215+[0 0.1]);
%
%  mj, 11 June 2011
%

if nargin<4,
    help d3stackplot
    return
end

maxclicks = 500 ;         % maximum number of clicks to display
nshow = 0.0015 ;           % length of waveform to display in detail figure
figs = [1 2] ;           % which figure windows to use
MAXICI = 1 ;               % draw a horizontal black line when ICI is more than this
SRCH = 0.0025 ;           % time window over which to search for z command
TH = 0.7 ;

% the parameters below are:
%   cax = display colour limits in dB
%   f_env_ls = envelope detector signal bandpass filter cut-off frequencies in Hz
%   f_env_hs = same as f_env_ls but these values are used if the sampling
%      rate is > 100kHz.

switch prefix(1:2),
   case 'zc',      % for ziphius use:
      cax = [-93 -35] ;         
      f_env_ls = [25000 45000] ;
      f_env_hs = [30000 65000] ;

   case 'md',      % for mesoplodon use:
      cax = [-91 -35] ;       
      f_env_ls = [25000 45000] ;
      f_env_hs = [25000 65000] ;

   case 'pw',      % for pilot whale use:
      cax = [-103 -30] ;      
      f_env_ls = [20000 40000] ;
      f_env_hs = [25000 60000] ;

   case 'by',
      cax = [-96 -30] ;
      f_env_ls = 25000 ;
      f_env_hs = 25000 ; 
      
   case {'sw','pm'},      % for sperm whale use:
      cax = [-93 -15] ;
      f_env_vls = [2000 15000] ;
      f_env_ls = [2000 30000] ;
      f_env_hs = [6000 20000] ;

   otherwise,      % for others use:
      cax = [-95 -10] ;
      f_env_ls = [2000 35000] ;
      f_env_hs = [2000 35000] ;
end

% handle variable arguments
if nargin<6,
   DD = [] ;       % initialize result vector
end

if nargin<5 | isempty(intervl),
   intervl = [0 0.5] ;
end

if intervl(2)>intervl(1),
   intervl(2) = diff(intervl) ;
end

if isempty(cue),
   cue = CL(1)-0.1 ;
end

len = 20 ;        % default length of segment to analyze in seconds
if length(cue)==2,
   len = min(len,diff(cue)) ;
   cue = cue(1) ;
end

CL = CL(:,1) ;
overlap = 0.1*len ;  % 10% overlap between frames

% find sampling rate
[ct rtime fs] = d3getcues(recdir,prefix,'wav') ;

% make analysis filter
if fs<50e3,
   if exist(f_env_vls,'var'),
      [b a] = butter(6,f_env_vls/(fs/2)) ;
   else
      [b a] = butter(6,f_env_ls(1)/(fs/2),'high') ;
   end
elseif fs<100e3,
   if length(f_env_ls)==1,
      [b a] = butter(6,f_env_ls/(fs/2),'high') ;
   else
      [b a] = butter(6,f_env_ls/(fs/2)) ;
   end
else
   if length(f_env_hs)==1,
      [b a] = butter(6,f_env_hs/(fs/2),'high') ;
   else
      [b a] = butter(6,f_env_hs/(fs/2)) ;
   end
end

% initialize
displ = 1:round(fs*intervl(2)) ;
dk = displ/fs ;
figure(figs(1))
clf
next = 1 ; 

while next<2,
   while next==1,
      fprintf('reading at %d  ', cue) ;

      k = find(CL>=cue & CL<(cue+len)) ;
      cl = CL(k) ;
      ncl = length(k) 
      if ncl>3,
         fprintf('%d clicks\n', ncl) ;       
      else
         cue = cue + len ;
         clf, plot(0,0); title('Too few clicks in block') ;
         drawnow ; 
         fprintf('Goto next block or quit (q=quit)? ')
         [gx gy button] = ginput(1) ;
         fprintf('\n') ;
         if button=='q',
            return ;
         end
         continue
      end

      % read in the block of audio
      x = d3wavread(cue+intervl(1)+[0 intervl(2)+len+10000/fs],recdir,prefix,'wav') ;
      if isempty(x), return; end
      tcl = cl-cue ;    
      xf = filter(b,a,x) ;
      R = clickenv(xf,tcl*fs+1,displ) ;
      hold off, zoom off
      imagesc(dk,1:ncl,adjust2Axis(20*log10(R)'),cax); grid
      hold on
      colormap(jet) ;
      next = 0 ; 
   end

   dd = NaN*ones(ncl,1) ;
   % find points already selected in this block
   if ~isempty(DD),
      kk = find(DD(:,1)>=cue & DD(:,1)<(cue+len)) ;
      if ~isempty(kk),
         ddd = DD(kk,:) ;
         DD = DD(find(DD(:,1)<cue | DD(:,1)>=(cue+len)),:) ;
         kmatch = nearest(cl,ddd(:,1),0.001) ;
         kmgood = find(~isnan(kmatch)) ;
         dd(kmatch(kmgood)) = ddd(kmgood,2)-intervl(1) ;
      end
   end
  
   hd = plot(dd,1:length(dd),'k*') ;
   title(sprintf('%d to %d', cue, cue+len)) ;

   while next==0,
      accept = 0 ;
      [xr yr button] = ginput(1) ;
      if button=='q',           % type 'q' to end session
         next = 2 ;

      elseif button=='z',
         fprintf('Click on end point\n') ;
         [xr1 yr1 button] = ginput(1) ;
         if button==1 | button=='z',
            xr = [xr;xr1] ;
            [yr,indi] = sort([yr yr1]) ;
            xr = xr(indi) ;
            yr = [max([1 round(yr(1))]);min([ncl round(yr(2))])] ;
            if diff(yr)>=1,
               % extrapolate last two inputs
               xr = interp1(dk,(1:length(dk))',xr) ;
               pp = lineinterp(R,[yr,xr],TH,round(SRCH*fs)) ;
               dd(pp(:,1)) = interp1((1:length(dk))',dk,pp(:,2)) ;
            end
            set(hd,'XData',dd) ;
         end

      elseif button=='b',           % type 'b' to go to previous frame
         next = 1 ;
         cue = cue-len+overlap ;    % advance time cursor

      elseif button=='f',           % type 'f' to go to next frame
         next = 1 ;
         cue = cue+len-overlap ;    % advance time cursor

      elseif button=='r',           % type 'r' to clear all currently selected points
         dd = NaN*dd ;
         set(hd,'XData',dd) ;

      elseif button=='x' & yr>0.5 & yr<ncl+0.5 & xr>0 & xr<intervl(2),
         kcl = round(yr) ;
         dd(kcl) = NaN ;
         set(hd,'XData',dd) ;

      elseif button==1 & yr>0.5 & yr<ncl+0.5 & xr>0 & xr<intervl(2),
         kcl = round(yr) ;
         figure(figs(2)), clf
         ddd = showpiece(xf(round(tcl(kcl)*fs)+displ,:),dk,xr,nshow*fs,fs) ;
         if length(ddd)==length(kcl),
            dd(kcl) = ddd ;
         end
         figure(figs(1))
         set(hd,'XData',dd) ;
      end
      
      if next,           % finish sequence and store in DD
         kcl = find(~isnan(dd(:,1))) ;
         if ~isempty(kcl),
            DD = [DD;[cl(kcl) dd(kcl,:)+intervl(1)]] ;
            [v,I] = sort(DD(:,1)) ;
            DD = DD(I,:) ;
         end
         save d3stackplot_Recover DD
      end
   end
end


function     R = clickenv(xf,c,ki)
%
%

CH = 0 ;
if size(xf,2)==1,
   CH = 1 ;
end

c = round(c) ;
kki = ki(1):ki(end)+10000 ;
R = zeros(length(kki),length(c)) ;
if CH==0 & size(xf,2)>1,
   for k=1:length(c),
      R(:,k) = sum(xf(c(k)+kki,:)')'/size(xf,2) ;
   end
else
   for k=1:length(c),
      R(:,k) = xf(c(k)+kki,CH) ;
   end
end

if size(R,1)>10000,
   R = hilbenv(R) ;
else
   R = abs(hilbert(R)) ;
end
R = R(1:length(ki),:) ;
return


function   X = showpiece(xx,dk,xr,nshow,fs)
%
%
w = -30:30 ;                  % rms and aoa analysis window in samples
grd = 58 ;                    % display guard band in samples
if size(xx,2)>1,
   r = abs(hilbert(sum(xx')')) ;
else
   r = abs(hilbert(xx)) ;
end

kns = round(nshow) ;
kkx = min(find(dk>xr))+(-kns:kns) ;
kkx = kkx(find(kkx>0 & kkx<length(dk))) ;
renv = abs(hilbert(r(kkx))) ;
plot(dk(kkx),r(kkx)),grid
hold on

% plot default peak selection
[mm m] = max(renv) ;
kc = kkx(m) ;
hb = plot([1;1]*(dk(kc)+[min(w) max(w)]/fs),get(gca,'YLim')'*[1 1],'k-') ;
hv = plot([1;1]*(dk(kc)+[-grd grd]/fs),get(gca,'YLim')'*[1 1],'k--') ;
ks = kc+w ;
if ks(1)<1,
   ks = ks-ks(1)+1 ;
elseif ks(end)>length(r),
   ks = ks+length(r)-ks(end) ;
end
[mr nr] = max(r(ks)) ;
xpk = dk(ks(nr)) ;
hg = plot(dk(kc)+[-grd grd]/fs,mr/3*[1;1],'k--') ;    % plot -10dB guard bands

[xr yr button] = ginput(1) ;

if button=='x'         
   X = NaN*ones(1,4+6*(size(xx,2)-1)) ;
   return
end

if button=='s' & xr>=dk(kkx(1)) & xr<=dk(kkx(end))
   m = interp1(dk(kkx),(1:length(kkx))',xr) ;
   kc = kkx(round(m)) ;
   set(hb(1),'XData',[1;1]*(dk(kc)+min(w)/fs)) ;
   set(hb(2),'XData',[1;1]*(dk(kc)+max(w)/fs)) ;
   set(hv(1),'XData',[1;1]*(dk(kc)-grd/fs)) ;
   set(hv(2),'XData',[1;1]*(dk(kc)+grd/fs)) ;
   ks = kc+w ;
   if ks(1)<1,
      ks = ks-ks(1)+1 ;
   elseif ks(end)>length(r),
      ks = ks+length(r)-ks(end) ;
   end
   [mr nr] = max(r(ks)) ;
   xpk = dk(ks(nr)) ;
   set(hg,'XData',dk(kc)+[-grd grd]/fs,'YData',mr/3*[1;1])
   pause(0.5)
else
   xr = xpk ;
end
   
X = xr ;
return


function    PP = lineinterp(R,P,th,win)
%
% look for peaks in R close to the line between P(1,:) and P(2,:)
%
p = polyfit(P(:,1),P(:,2),1) ;
PP = (round(P(1,1)):round(P(2,1)))' ;
yp = round(polyval(p,PP)) ;
XX = zeros(2*win+1,length(yp)) ;
sel = (-win:win)' ;
ye = 0*PP ;
for k=1:length(yp),
   w1 = max(yp(k)-win,1) ;
   w2 = min(yp(k)+win,size(R,1)) ;
   ye(k) = find1stpk(R(w1:w2,PP(k)),th)+w1-1 ;
end

PP(:,2) = ye ;
return

