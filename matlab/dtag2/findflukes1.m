function    [ph,K,GL] = findflukes1(Aw,Mw,fs,FR,TH,tmax)
%
%    [ph,K,GL] = findflukes1(Aw,Mw,fs,FR,TH,tmax)
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
%    tmax is the maximum duration allowable for a fluke stroke in seconds. 
%    A fluke stroke is counted whenever there 
%    is a cyclic variation in the pitch deviation with peak-to-peak magnitude 
%    greater than +/-TH and consistent with a fluke stroke of duration
%    less than tmax seconds, e.g., for Mesoplodon choose tmax=4.
%    Default value is 8/FR.
%  
%    Output: 
%    ph is the pitch deviation from mean orientation used to find fluke strokes
%    K is a matrix of cues to zero crossings in seconds (1st column) and
%     zero-crossing directions (2nd column). +1 means a positive-going zero
%     crossing.
%    GL is a matrix containing the start time (first column) and end time
%    (2nd column) of any glides (i.e., no zero crossings in tmax or more
%    seconds).
%
%    mark johnson    1 June 2011

if nargin<3,
   help findflukes1
   return
end

if nargin<4 | isempty(FR),
   FR = 0.5 ;              % default fluking frequency in Hz
end

if nargin<5,
   TH = [] ;
end

if nargin<6,
   tmax = 8/FR ;      
end

[b a] = butter(2,FR/3/(fs/2)) ;   % make a low-pass filter
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
else
   ph = real(asin(Aw(:,3)-Af(:,3))) ;  % if no magnetometer, just estimate dorso-ventral specific acceleration
end
   
% filter phase to smooth specific acceleration transients and
% to remove any dc offset (there usually isn't any at this point)
[b a] = butter(1,[FR/3 min(fs/3,FR*4)]/(fs/2)) ;   % make a bandpass filter
ph = filtfilt(b,a,ph) ;          

if isempty(tmax) | isempty(TH),
   K = [] ; GL = [] ;
   return ;
end

K = findzc(ph,TH,tmax*fs/2) ;

% find glides - any interval between zeros crossings greater than tmax
k = find(K(2:end,1)-K(1:end-1,2)>fs*tmax) ;
glk = [K(k,1)-1 K(k+1,2)+1] ;

% shorten the glides to only include sections with jerk < TH
glc = round(mean(glk,2)) ;
for k=1:length(glc),
   kk = glc(k):-1:glk(k,1) ;
   glk(k,1) = glc(k) - find(abs(ph(kk))>=TH,1)+1 ;
   kk = glc(k):glk(k,2) ;
   glk(k,2) = glc(k) + find(abs(ph(kk))>=TH,1)-1 ;
end

% convert sample numbers to times in seconds
K = [mean(K(:,1:2),2)/fs K(:,3)] ;               
GL = glk/fs ;
GL = GL(find(GL(:,2)-GL(:,1)>tmax/2),:) ;
