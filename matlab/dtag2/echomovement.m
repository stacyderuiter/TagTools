function    echomovement(tag,cue,CL,intervl,df,tz)
%
%     echomovement(tag,cue,CL,intervl,df,tz)
%     tag is the tag deployment string e.g., 'sw03_207a'
%     CL is a vector of click cues
%     intervl = [left right] are the times in seconds to display with
%        respect to each click. Default is [-0.001 0.025].
%
%  mark johnson, WHOI
%  majohnson@whoi.edu
%  December 2006
%

if nargin<4,
    help timeindexedechoes
    return
end

if nargin<5 | isempty(df),
   df = 1 ;
end

if nargin<6 | isempty(tz),
   tz = 0 ;
end

MAXICI = 1 ;               % draw a horizontal black line when ICI is more than this
CH = 0 ;                   % which audio channel to analyse
DSC = 1500/2 ;

% the parameters below are:
%   cax = display colour limits in dB
%   f_env_ls = envelope detector signal bandpass filter cut-off frequencies in Hz
%   f_env_hs = same as f_env_ls but these values are used if the sampling
%      rate is > 100kHz.

switch tag(1:2),
   case 'zc',      % for ziphius use:
      cax = [-100 -50] ;         
      f_env_ls = [25000 45000] ;
      f_env_hs = [40000 70000] ;

   case 'md',      % for mesoplodon use:
      cax = [-93 -35] ;       
      f_env_ls = [25000 45000] ;
      f_env_hs = [30000 65000] ;

   case 'pw',      % for pilot whale use:
      cax = [-105 -30] ;      
      f_env_ls = [20000 40000] ;
      f_env_hs = [40000 80000] ;

   case 'sw',      % for sperm whale use:
      cax = [-95 -5] ;
      f_env_ls = [5000 35000] ;
      f_env_hs = [5000 35000] ;

   otherwise,      % for sperm whales and others use:
      cax = [-95 -10] ;
      f_env_ls = [2000 35000] ;
      f_env_hs = [2000 35000] ;
end

if isempty(cue),
   cue = min(CL(:,1))-0.1 ;
   len = max(CL(:,1))-cue ;
elseif length(cue)==2,
   len = diff(cue) ;
   cue = cue(1) ;
else
   len = 20 ;        % default length of segment to analyze in seconds
end

CL = CL(:,1) ;

% find sampling rate
[c t s id fs] = tag2cue(tag) ;
fs = fs(1) ;

% make analysis filter
if fs<100e3,   
   [b a] = butter(6,f_env_ls/(fs/2)) ;
else
   [b a] = butter(6,f_env_hs/(fs/2)) ;
end

x = tagwavread(tag,cue,len+1+intervl(2)) ;
if isempty(x), return; end

k = find(CL>=cue & CL<(cue+len+1)) ;
if ~isempty(k),
   cl = round(fs*(CL(k)-cue)) ;
   kgood = find(round(cl+fs*intervl(1))>0 & round(cl+fs*intervl(2))<length(x)) ;
   cl = sort(cl(kgood)) ;
   tcl = cl/fs+cue ;
   ncl = length(cl) ;
   fprintf('%d clicks\n', ncl) ;       
else
   ncl = 0 ;
end

if ncl<=3,
   return
end

xf = filter(b,a,x) ;
displ = round(fs*intervl) ;
ki = displ(1):displ(2) ;
R = zeros(length(ki),length(cl)) ;

if CH==0 & size(xf,2)>1,
   for k=1:ncl,
      R(:,k) = sum(xf(cl(k)+ki,:)')'/size(xf,2) ;
   end
else
   for k=1:length(cl),
      R(:,k) = xf(cl(k)+ki,CH) ;
   end
end

dk = ki/fs ;
R = abs(hilbert(R)) ;
if df>1,
   R = decdc(R,df) ;
   dk = dk(1:df:end) ;
   if size(R,1)>length(dk),
      R = R(1:length(dk),:) ;
   elseif size(R,1)<length(dk),
      dk = dk(1:size(R,1)) ;
   end
end

figure(1),clf
subplot(311)
k = [0;find(diff(tcl)>MAXICI);length(tcl)]' ;
for kk=1:length(k)-1,
   ind = k(kk)+1:k(kk+1) ;
   if length(ind)>1,
      imageirreg(tcl(ind)-tz,dk*DSC,20*log10(R(:,ind))');
   end
   hold on
end
hold off
grid on
colormap(jet) ;
caxis(cax)
axis xy

loadprh(tag,'p','fs','Aw','Mw')
kk = round(fs*tcl(1))-100:round(fs*tcl(end))+100 ;
ki = linspace(kk(1),kk(end),10*length(kk)) ;
[b a] = butter(2,2.5/(fs/2*10)) ;
RR = filtfilt(b,a,interp1(kk,[Aw(kk,:) Mw(kk,:) p(kk)],ki)) ;
[pitchi rolli] = a2pr(RR(:,1:3)) ;
headi = m2h(RR(:,4:6),pitchi,rolli) ;
subplot(312)
plot(ki/fs-tz,[pitchi rolli headi]*180/pi),grid ;
subplot(313)
plot(ki/fs-tz,RR(:,7)),grid ;
set(gca,'YDir','reverse') ;
xalign([tcl(1) tcl(end)]-tz) ;
