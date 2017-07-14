function    T = find_dives(p,fs,th,surface,findall)

%     T = find_dives(p,fs,mindepth)
%	   or
%     T = find_dives(p,fs,mindepth,surface)
%	   or
%     T = find_dives(p,fs,mindepth,surface,findall)
%     Find time cues for the start and end of either dives in a depth record
%		or flights in an altitude record.
%
%     Inputs:
%     p is a depth or altitude time series (vector) in meters.
%     fs is the sampling rate of the sensor data in Hz (samples per second).
%     mindepth is the threshold in meters at which to recognize a dive or flight.
%		 Dives shallow or flights lower than mindepth will be ignored.
%     surface is the threshold in meters at which the animal is presumed to have
%	    reached the surface. Default value is 1. A smaller value can be used if the
%		 dive/altitude data are very accurate and you need to detect shallow dives/flights.
%     findall when 1 forces the algorithm to include incomplete dives at the start and end 
%		 of the record. Default is 0 which only recognizes complete dives.
%
%     Returns:
%     T is a structure array with size equal to the number of dives/flights found. The
%		 fields of T are:
%    		start 	time in seconds of the start of each dive/flight
%			end 		time in seconds of the start of each dive/flight
%			max 		maximum depth/altitude reached in each dive/flight
%			tmax	   time in seconds at which the animal reaches the max depth/altitude
%
%     If there are n dives/flights beyond mindepth in p, then T will be a structure 
%		containing n-element vectors, e.g., to access the start time of the kth dive/flight 
%		use T.start(k). 
%
%		Example:
%		 T = find_dives()
% 	    returns: T=[].
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     Last modified: 10 May 2017

T = [] ;
if nargin<3,
   help('find_dives') ;
   return
end

if nargin<4 || isempty(surface),
   surface = 1 ;        % maximum p value for a surfacing
end

if nargin<5,
   findall = 0 ;
end

searchlen = 20 ;        % how far to look in seconds to find actual surfacing
dpthresh = 0.25 ;       % vertical velocity threshold for surfacing
dp_lp = 0.5 ;           % low-pass filter frequency for vertical velocity

% find threshold crossings and surface times
tth = find(diff(p>th)>0) ;
tsurf = find(p<surface) ;
ton = 0*tth ;
toff = ton ;
k = 0 ;

% sort through threshold crossings to find valid dive start and end points
for kth=1:length(tth) ;
   if all(tth(kth)>toff),
      ks0 = find(tsurf<tth(kth)) ;
      ks1 = find(tsurf>tth(kth)) ;
      if findall | (~isempty(ks0) & ~isempty(ks1)),
         k = k+1 ;
         if isempty(ks0),
            ton(k) = 1 ;
         else
            ton(k) = max(tsurf(ks0)) ;
         end
         if isempty(ks1),
            toff(k) = length(p) ;
         else
            toff(k) = min(tsurf(ks1)) ;
         end
      end
   end
end

% truncate dive list to only dives with starts and stops in the record
ton = ton(1:k) ;
toff = toff(1:k) ;

% filter vertical velocity to find actual surfacing moments
n = round(4*fs/dp_lp) ;
dp = fir_nodelay([0;diff(p)]*fs,n,dp_lp/(fs/2)) ;

% for each ton, look back to find last time whale was at the surface
% for each toff, look forward to find next time whale is at the surface
dmax = zeros(length(ton),2) ;
for k=1:length(ton),
   ind = ton(k)+(-round(searchlen*fs):0) ;
   ind = ind(find(ind>0)) ;
   ki = max(find(dp(ind)<dpthresh)) ;
   if isempty(ki),
      ki=1 ;
   end
   ton(k) = ind(ki) ;
   ind = toff(k)+(0:round(searchlen*fs)) ;
   ind = ind(find(ind<=length(p))) ;
   ki = min(find(dp(ind)>-dpthresh)) ;
   if isempty(ki),
      ki=1 ;
   end
   toff(k) = ind(ki) ;
   [dm km] = max(p(ton(k):toff(k))) ;
   dmax(k,:) = [dm (ton(k)+km-1)/fs] ;
end

% assemble output
t = [[ton toff]/fs dmax] ;
t = t(all(~isnan(t),2),:) ;
T.start = t(:,1) ;
T.end = t(:,2) ;
T.max = t(:,3) ;
T.tmax = t(:,4) ;
