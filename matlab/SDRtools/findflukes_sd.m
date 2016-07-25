function    [v,ph,mx,fr] = findflukes_sd(Aw,Mw,fs,FR,TH,T)
%
%    [v,ph,mx,fr] = findflukes(Aw,Mw,fs,FR,TH,T)
%    EXPERIMENTAL - SUBJECT TO CHANGE!!
%    Find cues to each fluke stroke in Aw. Aw is the whale frame
%    accelerometer matrix at sampling rate fs. Mw is the whale frame
%    magnetometer matrix.
%
%    Optional argument FR should be set equal to the nominal fluking rate 
%    in Hz. This is used to set the cut-off frequency of a low-pass filter.
%    Default value is 0.5 Hz. Use [] to get the default value if you want
%    to enter subsequent arguments. The low-pass filter cut-off frequency
%    is set to one quarter of FR.
%
%    TH is the magnitude threshold for detecting a fluke stroke in radians.
%    If TH is not given, fluke strokes will not be located (i.e., v=[]) but 
%    the pitch-rate signal (ph) will be computed.
%
%    T is a 2-vector containing the minimum duration and maximum duration 
%    allowable for a fluke stroke. A fluke stroke is counted whenever there 
%    is a cyclic variation in the pitch deviation with peak-to-peak magnitude 
%    greater than +/-TH and consistent with a fluke stroke of duration
%    between T(1) and T(2) seconds, e.g., for Mesoplodon choose T=[0.7 4].
%    Default value is [1.5/FR 8/FR].
%
%    Use the alternate call type:
%    [v,ph,mx] = findflukes(Aw,[],fs,FR,TH,T)
%    If there is no, or unreliable magnetometer data.
%  
%    Output: v is a vector of cues to fluke strokes in seconds into Aw.
%    ph is the pitch deviation from mean orientation used to find fluke strokes
%    mx is the positive peak level of ph (in radians) for each fluke stroke
%    fr is the fluking rate in flukes-per-second resampled to once per
%    second
%    ph is a bandpass filtered (kind of: see code for details -- 
%    basically pitch related to the main body axis orientation is
%    removed, and motion about that axis remains) version of
%    pitch vector which is used for fluke stroke detection.
%
%    mark johnson, WHOI
%    majohnson@whoi.edu
%    last modified: August 2007 - changed calling format.
%    minor edits by stacy deruiter, 2012-2013.

if nargin<3,
   help findflukes
   return
end

if nargin<4,
   FR = 0.5 ;              % default fluking frequency in Hz
end

if nargin<5,
   TH = [] ;
end

if nargin<6,
   T = [1.5 8]/FR ;      
end

[b a] = butter(2,FR/4/(fs/2)) ;   % make a low-pass filter
Af = filtfilt(b,a,Aw) ;           % smooth A and M measurements with 0 group delay

if ~isempty(Mw),
   Mf = filtfilt(b,a,Mw) ;
   Wf = bodyaxes(Af,Mf) ;           % compute mean body axes from smoothed whale frame A and M
   Xf = squeeze(Wf(:,1,:))' ;       % extract smoothed whale X axis
   Zf = squeeze(Wf(:,3,:))' ;       % and Z axis

   W = bodyaxes(Aw,Mw) ;            % compute instantaneous body axes from whale frame A and M
   X = squeeze(W(:,1,:))' ;         % extract whale X axis
   Z = squeeze(W(:,3,:))' ;         % and Z axis

   % compute the angle of the unsmoothed X vector (the pointing vector) in the
   % smoothed rostral-dorsal plane

   ph = real(atan(sum(X'.*Zf')'./sum(X'.*Xf')')) ;
   [b a] = butter(1,[FR/4 min(fs/3,FR*4)]/(fs/2)) ;   % make a bandpass filter
   ph = filtfilt(b,a,ph) ;          % filter phase to remove dc offset (from where? - perhaps this
                                 % is a bias due to presence of correlated thrust in the unsmoothed
                                 % axes?)
else
   ph = real(asin(Aw(:,3)-Af(:,3))) ;
end
   
if isempty(T) || isempty(TH),
   v = [] ; mx=[] ; fr=[] ;
   return ;
end

kmin = T(1)*fs/2 ;
kmax = T(2)*fs/2 ;
kon = find(diff(ph>TH)>0) ;
koff = find(diff(ph<-TH)>0) ;

v = 0*ph ;
cnt = 0 ;

while ~isempty(kon),
   k = find(koff>kon(1)) ;
   if isempty(k),
      kon = [] ;
   else
      koff = koff(k) ;
      if (koff(1)-kon(1)<kmax) && (koff(1)-kon(1)>kmin),
         cnt = cnt+1 ;
         v(cnt) = kon(1)+1 ;
         kon = kon(kon>koff(1)) ;
      else
         kon = kon(2:end) ;
      end
   end
end

% adjust times to coincide with interpolated +ve peaks of the ph waveform
[W v] = extractcues(ph,v(1:cnt),[-1 2]) ;
[mx n] = max(W) ;
mx = mx' ;
if ~isempty(n),
   v = v+n'-2 ;
end

[W,v] = extractcues(ph,v,[-1 1]) ;
W = W' ;
xm = 0.5*(W(:,1)-W(:,3))./(W(:,3)-2*W(:,2)+W(:,1)) ;
v = real(v+xm) ; 
v = v/fs ;
%from sdr june 2012
v = sort(v); %somehow they get out of order, which kinda freaks me out.
% %also they should never be less than T(1) apart...
% vtoofast = find(diff(v) < T(1));
% v(vtoofast + 1) = [];
% % %end sdr edit

if nargout<4,
   return
end

% if fluking rates are requested, resample the detected fluke strokes to
% an even time grid

%%%%%%%%%% MARK JOHNSON'S ORIGINAL VERSION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DELTA = 2*T(2) ;                % sampling period in seconds

tv = 0.5*(v(1:(end-1))+v(2:end)) ;
fr = 1./diff(v) ;      % fluking rate at times tv
nsamps = round(size(Aw,1)/fs/DELTA) ;
y = zeros(nsamps,1) ;

for k=1:nsamps,
   kk = find(tv>=(k-1.5)*DELTA & tv<(k-0.5)*DELTA) ;
   if ~isempty(kk),
      y(k) = mean(fr(kk)) ;  
   end
end

fr = interp(y,DELTA) ;
t_y = (1:nsamps)/DELTA;
t_fr = interp(t_y, DELTA);
k = find(fr<0) ;
fr(k) = 0 ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %replaced the above with the following from stacy deruiter 2012
fr = interp1(t_fr,fr,(1:length(Aw))./fs , 'pchip', 'extrap');
