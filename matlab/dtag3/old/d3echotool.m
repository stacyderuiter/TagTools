function    [DD,W] = d3echotool(recdir,prefix,cue,CL,intervl,DD)
%
%     DD=d3echotool(recdir,prefix,cue,CL,[intervl,DD])
%     tag is the tag deployment string e.g., 'sw03_207a'
%     cue is the time in seconds-since-tag-on to start working from.
%        If cue = [start_cue end_cue], the length of that interval will
%        be used as the frame length instead of the default 20s.
%     CL is a vector of click cues
%     intervl = [left right] are the times in seconds to display with
%        respect to each click. Default is [-0.001 0.025].
%     DD is the data structure defined below. DD can be passed as an
%        input argument to allow multiple work sessions.
%
%  Each matrix in the cell array DD contains the following columns:
%  1  click_cue
%  2  selected_two_way_travel_time, s
%  3  pk_two_way_travel_time, s
%  4  pk_of_env_looking_ahead
%  5  rms of env looking ahead
%  6  rms of env left channel
%  7  rms of env right channel
%  8  angle by wb_tdoa in degrees
%  9  angle by xc_tdoa in degrees
%  10 quality index wb_tdoa
%  11 quality index xc_tdoa
%
%  mark johnson, WHOI
%  majohnson@whoi.edu
%  February 2005
%

global   aoa_factor
if nargin<5,
    help d3echotool
    return
end

maxclicks = 1000 ;         % maximum number of clicks to display
nshow = 0.0015 ;           % length of waveform to display in detail figure
aoa_sc = 1500/0.025 ;      % how to convert time delay to angle of arrival on stereo tags
figs = [1 2 3] ;           % which figure windows to use
MAXICI = 1 ;               % draw a horizontal black line when ICI is more than this

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
   DD = {} ;       % initialize cell array of echo sequences
end

if isempty(cue),
   cue = CL(1)-0.1 ;
end

if length(cue)==2,
   len = diff(cue) ;
   cue = cue(1) ;
else
   len = 20 ;        % default length of segment to analyze in seconds
end

CL = CL(:,1) ;
overlap = 0.1*len ;  % 10% overlap between frames

% find sampling rate
[ct fs] = d3getcues(recdir,prefix,'wav') ;
aoa_factor = aoa_sc/fs ;

% make analysis filter
if fs<50e3,
   if exist(f_env_vls,'var'),
      [b a] = butter(6,f_env_vls/(fs/2)) ;
   else
      [b a] = butter(6,f_env_ls(1)/(fs/2),'high') ;
   end
elseif fs<100e3,   
   [b a] = butter(6,f_env_ls/(fs/2)) ;
else
   [b a] = butter(6,f_env_hs/(fs/2)) ;
end

% initialize
displ = round(fs*intervl) ;
dk = (displ(1):displ(2))/fs ;
ki = displ(1):displ(2) ;
currentseq = length(DD)+1 ;
seqplot = NaN*ones(length(DD),1) ;
figure(figs(1))
clf
next = 1 ; 
off_frame = [] ;
MODES = {'BOTTOM','TARGET'} ;
MODE = 1 ;
cleanh = [] ;

while next<2,
   while next==1,
      fprintf('reading at %d  ', cue) ;
      x = d3wavread(cue+[0 len+1+intervl(2)+10000/fs],recdir,prefix,'wav') ;
      if isempty(x), return; end

      k = find(CL>=cue & CL<(cue+len+1)) ;
      if ~isempty(k),
         cl = round(fs*(CL(k)-cue)) ;
         cl = cl(1:min([maxclicks length(cl)])) ;
         kgood = find(round(cl+fs*intervl(1))>0 & round(cl+fs*intervl(2))<length(x)) ;
         cl = cl(kgood) ;
         tcl = cl/fs+cue ;
         ncl = length(cl) ;
         fprintf('%d clicks\n', ncl) ;       
      else
         ncl = 0 ;
      end

      if ncl>3,
         xf = filter(b,a,x) ;
         R = clickenv(xf,cl,ki) ;
         hold off, zoom off
         imagesc(dk,1:ncl,adjust2Axis(20*log10(R)'),cax); grid
         hold on
         colormap(jet) ;
         kk = find(diff(cl)>MAXICI*fs) ;     % plot horizontal bars where ICI is large
         for kkk=kk',
            plot([min(dk);max(dk)],(kkk+0.5)*[1;1],'k')
         end
         next = 0 ; 
      else
         cue = cue + len ;
         clf, plot(0,0); title('No clicks in block') ;
         drawnow ; 
         fprintf('Goto next block or quit (q=quit)? ')
         [gx gy button] = ginput(1) ;
         if button=='q',
            return ;
         end
      end
   end

   % plot old sequences in this block
   % find points already selected in this block
   for k=1:length(DD),
      ddd = DD{k} ;
      if ~isempty(ddd) & any(ddd(:,1)>=cue & ddd(:,1)<(cue+len+1)),
         kbot = nearest(tcl,ddd(:,1),0.001) ;
         kk = find(~isnan(kbot)) ;
         seqplot(k) = plot(ddd(kk,2),kbot(kk),'k.-') ;
      end
   end
  
   dd = NaN*ones(ncl,4+6*(size(xf,2)-1)) ;
   hd = plot(dd(:,1),1:size(dd,1),'k*') ;
   title(sprintf('%d to %d', cue, cue+len)) ;

   while next==0,
      accept = 0 ;
      [xr yr button] = ginput(1) ;
      if button=='a',               % type 'a' to accept the current sequence
         accept = 1 ;
      elseif button=='q',           % type 'q' to end session
         accept = 1 ;
         next = 2 ;
         if nargout==2,
            W.R = R ;
            W.cl = tcl ;
            W.t = dk ;
         end
      elseif button=='b',           % type 'b' to go to previous frame
         accept = 1 ;
         next = 1 ;
         cue = cue-len+overlap ;    % advance time cursor
      elseif button=='f',           % type 'f' to go to next frame
         accept = 1 ;
         next = 1 ;
         cue = cue+len-overlap ;    % advance time cursor
      elseif button=='r',           % type 'r' to clear all currently selected points
         dd = NaN*dd ;
         set(hd,'XData',dd(:,1)) ;
      elseif button=='e',           % type 'e' to edit a sequence
         % look for nearest sequence to crosshairs
         yr = round(max([1 min([length(dd) yr])])) ;
         arat = abs(diff(intervl)/(max(tcl)-min(tcl))) ;
         ddist = NaN*ones(length(DD),1) ;
         for k=1:length(DD),
            ddd = DD{k} ;
            if ~isempty(ddd) & any(ddd(:,1)>=cue & ddd(:,1)<(cue+len+1)),
               ddist(k) = min(arat*abs(ddd(:,1)-tcl(yr))+abs(ddd(:,3)-xr)) ;
            end
         end
         [m currentseq] = min(ddist) ;
         ddd = DD{currentseq} ;
         kbot = nearest(tcl,ddd(:,1),1e-3) ;
         kk = find(~isnan(kbot)) ;
         dd(kbot(kk),:) = ddd(kk,2:end) ;
         set(seqplot(currentseq),'XData',NaN*kk) ;
         set(hd,'XData',dd(:,1)) ;
         kk = find(ddd(:,1)<tcl(1)-1e-3 | ddd(:,1)>tcl(end)+1e-3) ;
         off_frame = ddd(kk,:) ;

      elseif button==1 & yr>0.5 & yr<ncl+0.5 & xr>intervl(1) & xr<intervl(2),
         kcl = round(yr) ;
         figure(figs(2)), clf
         dd(kcl,:) = showpiece(xf(cl(kcl)+ki,:),dk,xr,nshow*fs,fs) ;
         kcl = find(~isnan(dd(:,1))) ;
         if ~isempty(kcl),
            figure(figs(3)),clf
            subplot(131)
            plot(cl(kcl)/fs,dd(kcl,2)*1500/2,'k.-'),grid ;
            title('One-way distance to target (m)') ;
            if size(dd,2)>6,
               subplot(132)
               plot(cl(kcl)/fs,dd(kcl,[7 8]),'.-'),grid ;
               title('Angle-of-arrival of echoes (degrees)') ;
               subplot(133)
               plot(cl(kcl)/fs,[dd(kcl,9) 1-dd(kcl,10)],'.-'),grid ;
               title('Quality of AoA measurements (0 is best)') ;
            end
         end
         figure(figs(1))
         set(hd,'XData',dd(:,1)) ;
         newseq = 0 ;
      end
      
      if accept,           % finish sequence and store in DD
         kcl = find(~isnan(dd(:,1))) ;
         if ~isempty(kcl),
            seqplot(currentseq) = plot(dd(kcl,1),kcl,'k.-') ;
            V = [off_frame;tcl(kcl) dd(kcl,:)] ;
            [mm I] = sort(V(:,1)) ;
            DD{currentseq} = V(I,:) ;
            off_frame = [] ;
         end
         save echotool_Recover DD
         dd = NaN*dd ;
         currentseq = length(DD)+1 ;
         set(hd,'XData',dd(:,1)) ;
         newseq = 0 ;
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
global aoa_factor

w = -30:30 ;                  % rms and aoa analysis window in samples
grd = 58 ;                    % display guard band in samples
if size(xx,2)>1,
   r = abs(hilbert(sum(xx')')) ;
   h = hilbert(xx) ;
else
   r = abs(hilbert(xx)) ;
   h = [] ;
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
   
X = [xr xpk mr std(r(ks))] ;
if ~isempty(h),
   [td1,q1] = wb_tdoa(h(ks,1),h(ks,2)) ;
   [td2,q2] = xc_tdoa(h(ks,1),h(ks,2)) ;
   aa = 180/pi*real(asin([td1 td2]*aoa_factor)) ;
   X = [X std(h(ks,:)) aa [q1 q2]] ;
   fprintf('-> peak level %5f, angle of arrival %3.1f (%3.1f), q %1.2f (%1.2f)\n',mr,aa(1),aa(2),q1,q2) ;
end
return

