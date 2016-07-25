function    [jk,K,FR,I] = findflukesbyjerk(Aw,fs,fl,TH,tmax,Tf)
%
%     [jk,K,fr] = findflukesbyjerk(Aw,fs,fl,TH,tmax,Tf)
%     EXPERIMENTAL: may change without notice!!
%     Produce the caudal-rostral jerk signal (low-pass filtered
%     to fl Hz) and look for zero-crossings with hysteric threshold 
%     levels of +/- TH m/s^3. Zeros-crossings more than tmax
%     seconds apart are discarded.
%     Fluking rate is estimated over Tf(1) second bins spaced
%     at Tf(2) seconds.
%     e.g., for pilot whales use fl=2, TH=2, tmax=2.5, Tf=[5,1]
%
%     Returns: jk - the filtered jerk in m/s^3
%     K = [Kst,Ked,S], where Kst and Ked are the cues to the start
%     and end of each zero-crossing (i.e., the two threshold crossings)
%     and S is the sign of the zero-crossing.
%     fr = [meanfr_ingroup,fl/sec,fraction_fluked,time] is a matrix
%     of fluke-rate results. meanfr_ingroup is the mean of the 
%     instantaneous fluking rates, fl/sec is the number of flukes in
%     the interval divided by interval length (i.e., irrespective
%     of the proportion of time without fluking in the interval),
%     fraction_fluked is the proportion of the interval in which
%     there is fluking and time is the time in seconds of each
%     measurement.
%
%     mark johnson, WHOI
%     majohnson@whoi.edu
%     17 January 2008

if nargin<3,
   help findflukesbyjerk
   return
end

[b,a]=butter(4,fl/(fs/2)) ;          % low-pass filter to clean up signal

if size(Aw,2)<3,
   jk = diff(Aw(:,1))*fs*9.81 ;
else
   jk = diff(Aw(:,3))*fs*9.81 ;
end

jk = filter(b,a,jk) ;

if nargin<5,
   return
end

K = findzc(jk,TH,tmax*fs/2) ;
K(:,1:2) = K(:,1:2)/fs ;                % convert sample numbers to time in seconds

if nargout<3,
   return
end

% if fluking rates are requested, resample the detected fluke strokes to
% an even time grid

if nargin<6,
   DELTA = 5 ;                 % time grid in seconds for fluking rate computation
else
   DELTA = Tf ;
end

if length(DELTA)==1,
   DELTA(2) = DELTA ;
end

TAVE = DELTA(1) ;
TSKIP = DELTA(2) ;
tv = 0.5*(K(1:end-1,2)+K(2:end,2)) ;   % mean time of fluking half cycles
tf = 2*diff(K(:,2)) ;                  % instantaneous fluking cycle durations
k = find(tf<=tmax & K(1:end-1,3)+K(2:end,3)==0) ;  % find allowable fluking cycles
tv = tv(k) ;
tf = tf(k) ;
fr = 1./tf ;                           % instantaneous fluking rate at times tv
samps = round(fs*[K(k,2) K(k+1,1)]) ;

nbls = 1+floor((length(jk)-TAVE*fs)/(fs*TSKIP)) ;  % number of analysis blocks
Ts = (0:nbls-1)'*TSKIP ;
y = zeros(nbls,2) ;

for k=1:nbls,
   kk = find(tv>=Ts(k) & tv<Ts(k)+TAVE) ;
   if ~isempty(kk),
      mfr = mean(fr(kk)) ;
      y(k,:) = [mfr length(kk)+1] ;
   end
end

FR = [y(:,1) y(:,2)/(2*TAVE) zeros(nbls,1) Ts+TAVE/2] ;
k = find(FR(:,1)>0) ;
FR(k,3) = min(y(k,2)./(y(k,1)*2*TAVE),1) ;

if nargout<4,
   return
end

pk = zeros(length(tv),2) ;
for k=1:length(tv),
   [pk(k,1) pk(k,2)] = max(abs(jk(samps(k,1):samps(k,2)))) ;
end
I = [(pk(:,2)-1+samps(:,1))/fs pk(:,1) fr] ;
