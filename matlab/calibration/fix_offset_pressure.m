function    [p,poffs] = depthoffset(p,fs,intvl,tc)
%
%    [p,poffs] = depthoffset(p,fs,intvl,tc)
%     Correct a depth or altitude profile for offsets caused by
%     miscalibration and sensor drift. This function finds minima
%     in the dive/altitude profile that are consistent with
%     surfacing/landing and smooths these to make a time-varying
%     '0 pressure' offset vector. This tool should be used if there
%     are still pressure offsets after correcting for temperature using
%     fixdepth.m
%
%     Inputs:
%     p is a vector of depth/altitude in meters.
%     fs is the sampling rate of p and t in Hz. The depth and temperature
%      must have the same sampling rate (use decdc.m or resample.m before 
%      fixdepth if needed to achieve this).
%     intvl is the search interval in seconds that is used to find surfacings
%      or landings. This should be chosen to be a little more than the
%      usual inter-surfacing/inter-landing interval. Default value is 1
%      hour.
%     tc is the smoothing time constant in seconds used to filter the
%      surface depth offsets. tc should be at least 10 times larger than
%      intvl unless the depth/altitude sensor has a faster drift. Default 
%      value is 12 hours.
%
%     Results:
%     p is a vector of corrected depth/altitude measurements at the same
%      sampling rate as the input vector.
%     poffs is a 2-column matrix containing a set of times (column 1) and 
%      estimated pressure offsets (column 2). Times are in seconds since the
%      first sample in p. Pressure offsets are in metres.
%
%		This function makes a number of assumptions about the depth/altitude
%     data and about the behaviour of animals:
%     - the depth data should have few incorrect outlier (negative) values
%       that fall well beyond the surface. If there are a number of outliers,
%       these can be reduced using medianfilter.m before calling depthoffset.
%     - the pressure offset in the sensor varies slowly and smoothly with 
%       respect to the inter-surfacing/inter-landing interval. This
%       function will not be effective at correcting step changes in calibration.
%
%		Example:
%		 load...
%		 [pp,poffs] = depthoffset(p,fs,15*60,8*3600);
% 	    returns: .
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     Last modified: 18 June 2017

poffs = [] ;
if nargin<2,
   help depthoffset
   return
end

if nargin<3 || isempty(intvl),
   intvl = 3600 ;       % 1 hour default
end

if nargin<4 || isempty(tc),
   tc = 12*3600 ;       % 12 hour default
end

if fs>5,
   df = round(fs/5) ;
   pp = decdc(p,df) ;   % decimate depth to around 5Hz
   fsd = fs/df ;
else
   pp = p ;
   fsd = fs ;
end
kintvl = round(intvl*fsd/2) ;
[P,z]=buffer(pp,2*kintvl,kintvl,'nodelay');
offs= nanmin(P)';

% get rid of any remaining NaN in offs
if isnan(offs(1)),
   offs(1) = offs(find(~isnan(offs),1)) ;
end

for k=2:length(offs),
   if isnan(offs(k)),
      offs(k)=offs(k-1);
   end
end

% smooth the local offsets
offs = medianfilter(offs,3) ;
fc = intvl/tc/2 ;
fof = fir_nodelay(offs,round(5/fc),fc);
T = (1:length(fof))'*kintvl/fsd ;
poffs = interp1([0;T;length(p)/fs],[fof(1);fof;fof(end)],(1:length(p))'/fs);
p = p-poffs ;
poffs = [T,fof] ;
