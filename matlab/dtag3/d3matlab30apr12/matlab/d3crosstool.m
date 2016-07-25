function    D=d3crosstool(recdir,prefix,cl1,cue,offset,D)
%
%     D=d3crosstool(recdir,prefix,scl,cue,offset,D)
%     Collect distance between data from a pair of tagged whales.
%     recdir is the directory where the receiver recordings are
%     prefix is the deployment name of the receiving whale.
%     scl is the click-cue list for the source whale (e.g., from
%     findclicks.m).
%     cue is the starting cue in source-tag time. cue may also be 
%     a 2-vector containing [startcue endcue] for the analysis
%     frame in which case subsequent analysis frames will be of length
%     endcue-startcue.
%     offset is the time delay in seconds between source-tag and
%     receive-tag times. If the receive tag started after the source
%     tag, the offset will be negative. Use toffset.m to give a starting
%     estimate for offset and then try nearby values until a vertical
%     line appears in the stackplot. If offset has two elements the two are 
%     interpreted as the start and end offsets defining the extent 
%     of the stackplot. If offset has a single element, the stackplot
%     is centered on offset and has extent: offset+[-0.25 0.25] seconds.
%     D is the output from a previous call to crosstool allowing multi-
%     session data collection.
%     Returns:
%     D is the offset list, a 2 column matrix with columns:
%        D = [cue offset] where cue is the time in seconds since tag out
%        of each offset measure. Offset is the time delay between a source
%        click and its reception on the second whale.
%
%     Screen commands are:
%        f  - step forward to next frame
%        b  - step back to previous frame
%        x  - reject selection at the cursor
%        r  - clear all selections in the current frame
%        z  - select start point for the line finder. Press z again with
%             the mouse at the end point to select all points on the line.
%        q  - quit
%
%     mark johnson
%     majohnson@whoi.edu
%     Last modified: 27 May 2006

if nargin<6,
   D = [] ;
end

if nargin<5,
   help d3crosstool
   return
end

overlap = 1 ;           % frame-to-frame default overlap in seconds
maxclicks = 200 ;       % maximum number of clicks to show in a frame
nshow = 0.006 ;         % default amount of signal to show in pop-up window (ms)
len = 20 ;              % default length of segment to analyze in seconds
TH = 0.5 ;
SRCH = 0.01 ;           % time window over which to search for z command

if isempty(cue),
   cue = cl1(1)-1 ;
elseif length(cue)>1,
   len = abs(diff(cue)) ;
   cue = min(cue) ;
end

if length(offset)==1,
   intervl = [-0.25 0.25] ;     % display time interval in seconds referenced to each click
else
   intervl = offset ;
   offset = mean(offset) ;
   intervl = intervl - offset ;
end

% the parameters below are:
%   cax = display colour limits in dB
%   fh_click = click detector signal high-pass (or bandpass, if 2-vector) filter cut-off
%              frequency in Hz
%   fl_click = click detector low-pass filter cut-off frequency in Hz
%   fh_env = envelope detector signal high-pass (or bandpass, if 2-vector) filter cut-off
%              frequency in Hz
%   fl_env = envelope detector low-pass filter cut-off frequency in Hz
%   blanking = blanking time after a click is detected before another can
%              be detected
%   def_thresh = default threshold for the click detector

switch prefix(1:2),

   case 'by',
      cax = [-95 -10] ;
      fh_env = 20000 ;
      fl_env = 5000 ; 
      blanking = 10e-3 ;         
      def_thresh = 0.02 ;
      SRCH = 0.007 ;
      TH = 0.7 ;
      nshow = 0.004 ;
      
   otherwise,      % for sperm whales and others use:
      cax = [-97 -30] ;
      fh_env = 2000 ;
      fl_env = 1000 ; 
      blanking = 10e-3 ;         
      def_thresh = 0.02 ;
end

% find sampling rate and turn intervl into samples
[ct ref_time fs] = d3getcues(recdir,prefix,'wav') ;
displ = round(fs*intervl) ;
dk = (displ(1):displ(2))/fs + offset ;
CL = cl1(:,1) ;

if nargin<5,
   D = [] ;
end

if length(cue)==2,
   len = diff(cue) ;
   cue = cue(1) ;
end

cleanh = [] ;
figure(1)
clf

while 1,
   next = 1 ;
   while next==1,
       fprintf('reading at %d  ', cue) ;
       cl = CL(find(CL>cue & CL<cue+len)) ;
       cl = cl(1:min([maxclicks length(cl)])) ;
       next = length(cl)<3 ; 
       if next,
          cue = cue + len ;
          clf, plot(0,0); title('No clicks in block') ;
          s = input('Continue yes or no? ','s') ;
          if isequal(s,'n') | isequal(s,'no'),
             next = 2 ;
          end
       else
          x2 = d3wavread(cue+offset+[0 len+intervl(2)],recdir,prefix,'wav') ;
          if isempty(x2), return; end
          cl = cl-cue ;
          kgood = find(round(fs*(cl+intervl(1)))>0 & round(fs*(cl+intervl(2)))<length(x2)) ;
          cl = cl(kgood) ;
          ncl = length(cl) ;
          fprintf('%d clicks\n', ncl) ;
          R = clickenv(x2(:,1),round(cl*fs),displ,fs,fh_env,fl_env) ;
      end
   end
   
   dd = NaN*ones(ncl,1) ;
   if next==0,
      hold off, zoom off
      RR=adjust2Axis(R'); %reduce matrix to axis dimension (peak-picking)
      imagesc(dk,1:ncl,20*log10(abs(RR)),cax) ;
      hold on
   
      % find points already selected in this block
      if ~isempty(D),
         kbot = find(D(:,1)>=cue & D(:,1)<(cue+len)) ;
         knotbot = find(~(D(:,1)>=cue & D(:,1)<(cue+len))) ;

         % find corresponding click
         for kk=1:length(kbot),
            [mm kcl] = min(abs(cl-(D(kbot(kk),1)-cue))) ;
            dd(kcl) = D(kbot(kk),2) ;
         end
         D = D(knotbot,:) ;
      end
  
      hd = plot(dd,1:length(dd),'k.') ;
      title(sprintf('%d to %d', cue, cue+len)) ;
   end
   
   while next==0,
      figure(3),clf
      showpeaks(R,dk,dd) ;
      figure(1)
      set(hd,'XData',dd) ;

      [xr yr button] = ginput(1) ;
      if button=='z',
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
         end

      elseif button=='r',
         dd = NaN*dd ;
      elseif button=='f',
         next = 1 ;
      elseif button=='b',
         next = -1 ;
      elseif button=='q' | button==3,
         next = 2 ;
      elseif button=='x',
         kcl = round(yr) ;
         if kcl>=1 & kcl<=ncl,
            dd(kcl) = NaN ;
         end
      elseif button==1,
         kcl = round(yr) ;
         if kcl>=1 & kcl<=ncl,
            dd(kcl) = showpiece(R(:,kcl),dk,xr,nshow*fs,dd(kcl)) ;
         end
      else
         fprintf('Commands are f,b,x,r,z,q\n') ;
      end      % if button
   end

   if next,
      kcl = find(~isnan(dd)) ;
      if ~isempty(kcl),
         D = [D; [cue+cl(kcl) dd(kcl)]] ;
      end
      if ~isempty(D),
         [mm I] = unique(D(:,1)) ;
         D = D(I,:) ;
      end
         
      if next==2 & exist('RR','var'),
         Rd.R = RR ;
         Rd.X = dk ;
         Rd.Y = 1:ncl ;
      else
         Rd.R = NaN ;
      end

      if next==2,
         return ;
      end
      save d3crosstool_Recover D
      cue = cue + next*(len-overlap) ;
   end      % if next
end      % while 1
return


function   cc = findclicks(x,thresh,fs,fh,fl,blanking)
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

win = 96 ;        % look +/- 1ms of a detection to find the diff peak

if length(fh)==2,
   [b a] = butter(6,fh/(fs/2)) ;
else
   [b a] = butter(6,fh/(fs/2),'high') ;
end

[b_env a_env] = butter(2,fl/fs/2) ;
xf = filter(b,a,x) ;
xx = abs(filtfilt(b_env,a_env,abs(xf))) ;
cc = find(diff(xx>thresh)>0) ;
dxx = diff(xx) ;
cc = cc(find(cc>win & cc<length(x)-win)) ;

done = 0 ;
if isempty(cc),
   return ;
end

while ~done,
   kg = find(diff(cc)>blanking*fs) ;
   done = length(kg) == (length(cc)-1) ;
   cc = cc([1;kg+1]) ;
end

ccoffs = 0*cc ;
for k=1:length(cc),
    [nn ccoffs(k)] = max(dxx(cc(k)+(-win:win))) ;
end
cc = (cc+ccoffs-win)/fs ;
return


function     R = clickenv(x,c,t,fs,fh,fl,mf)
%
%     R = clickenv(x,c,t,fs,fh)
%

if length(fh)==2,
   [b a] = butter(6,fh/(fs/2)) ;
else
   [b a] = butter(6,fh/(fs/2),'high') ;
end

[b_env a_env] = butter(2,fl/(fs/2)) ;
c = round(c) ;
xf = filter(b,a,x) ;
xx = sqrt(abs(filtfilt(b_env,a_env,xf.^2))) ;
ki = t(1):t(2) ;
R = zeros(diff(t)+1,length(c)) ;

for k=1:length(c),
   R(:,k) = xx(c(k)+ki) ;
end
return


function   xr = showpiece(r,dk,xr,nshow,pt)
%
%  r = envelope for selected click
%  dk = time index of r relative to A click time
%  xr = time to show relative to A click time
%  nshow = number of samples to show either side of xr

figure(2), clf
kns = round(nshow) ;
kkx = min(find(dk>xr))+(-kns:kns) ;
kkx = kkx(find(kkx>0 & kkx<length(dk))) ;
plot(dk(kkx),r(kkx)),grid
hold on

[mm,nn] = max(r(kkx)) ;
mx = dk(kkx(nn)) ;
if isnan(pt),
   kp = 1 ;
else
   kp = min(find(dk>pt)) ;
end
hh = plot(pt,min([mm r(kp)]),'ro',mx,mm,'r*') ;
set(hh,'MarkerSize',10) ;
[xr yr button] = ginput(1) ;

if button==3 | button=='x',
   xr = NaN ;                 % delete point
elseif button=='m',
   xr = mx ;
elseif yr<0,
   xr = pt ;
end
figure(1)
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
yp = min(max(yp,win+1),size(R,1)-win) ;

for k=1:length(yp),
   XX(:,k) = R(yp(k)+sel,PP(k)) ;
end
ye = find1stpk(XX,th) ;
PP(:,2) = yp+ye-win ;
return


function    showpeaks(R,dk,dd)
%
% look for peaks in R close to the line between P(1,:) and P(2,:)
%

win = 300 ;        % how many samples on either side of the line to search
pt = round(interp1(dk,(1:length(dk))',dd)) ;
XX = zeros(2*win+1,length(dd)) ;
sel = (-win:win)' ;
pt = min(max(pt,win+1),size(R,1)-win) ;

for k=1:length(dd),
   if ~isnan(pt(k)),
      XX(:,k) = R(pt(k)+sel,k) ;
   end
end

mx = nanmean(max(abs(XX))) ;
if mx>0,
   mx = -1/mean(max(abs(XX))) ;
else
   mx = 1 ;
end
plot(sel,XX*mx+ones(size(XX,1),1)*(1:length(dd))),grid
set(gca,'YDir','reverse','YLim',[0 length(dd)])
return

