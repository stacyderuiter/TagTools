function    [RI,t] = residence_index(T,fs,maxt,r,tstep)

%     [RI,t]=residence_index(T,fs,maxt)
%     or
%     [RI,t]=residence_index(T,fs,maxt,r)
%     or
%     [RI,t]=residence_index(T,fs,maxt,r,tstep)
%
%     Compute the residence index (RI) of a regularly sampled track.
%     RI is a measure of the track tortuosity which is similar to Area
%     Restricted Search and Time of First Passage. This function follows
%     the definition of RI in Johnson et al. Proc Royal Soc. 2008 275:133-139
%     which differs a little from other definitions. RI is the amount of time
%     that the animal is within a sphere of radius r meters divided by r. The
%     units are therefore time/meter. A large RI implies that the track
%     is circling and effectively staying in the same area. A low RI implies
%		a progressing track with few course changes. The track can be
%		two dimensional (i.e., horizontal information only) or three dimensional.
%		If no depth or altitude information is given, the depth is assumed to be 
%		zero and the RI measures the time that the track is within a circle of
%		radius r.
%
%		Inputs:
%	   T is the estimated track in a local level frame. T must have two or three
%		 columns. The first two columns are the horizontal locations usually described
%		 in terms of the northward and eastward position (termed 'northing' 
%      and 'easting', i.e, T=[northing,easting]). If T has three columns, the third
%		 column is the depth or altitude of each track point. However, any perpendicular
%      set of 2 or 3 axes will work. The track must be in meters.
%     fs is the sampling rate of the track in Hz (samples per second).
%		maxt is the maximum time in seconds that the track is analysed before
%		 and after each track point. This should be larger than the expected maximum
%		 time that the track could be within the sphere.
%     r is the optional radius of the sphere in meters. Default value is 20 m.
%     tstep is the optional time step of the analysis in seconds. Default value
%      is 5 s.
%
%     Returns:
%     RI is a vector of residence indices.
%     t is a vector giving the time in seconds of each sample of RI with respect
%      to the start time of the track.
%
%     Example:
%       load_nc('testset1')
%       sampling_rate = P.sampling_rate;
%		v = ocdr(P,A);
%		s = sqrt(max(1-v.^2,0));
%		Track = ptrack(A,M,s);
%       maxtime = 600;
%       [RIvalues, timesOfIndices] = residence_index(Track, sampling_rate, maxtime)
%       
%     Returns:
%       Many residence index values, the last 5 entries in RIvalues are
%       [9.2740; 8.9640; 8.7420; 8.3300; 8.0920]
%      And timesOfIndices is multiples of 5 from 0 through 5510
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     last modified: 26 July 2017

if nargin<3,
	help residence_index
   RI = [] ; t = [] ;
	return
end
	
if nargin<4 || isempty(r),
   r = 20 ;
end

if nargin<5 || isempty(tstep),
   tstep = 5 ;
end

t = (0:tstep:size(T,1)/fs-tstep)' ;		% make a vector of sampling moments
kcue = round(fs*t)+1 ;     % track indices at tstep intervals
Tk = T(kcue,:) ;				% track points at tstep intervals
RI = NaN*zeros(length(kcue),length(r)) ;

for k=1:length(kcue),
   if any(isnan(Tk(k,:))), continue, end
	% find the track segment within maxt seconds at each sampling moment
	kst = max(kcue(k)-maxt*fs,1) ;
	ked = min(kcue(k)+maxt*fs,size(T,1)) ;
	km = kst:ked ;
   TT = T(km,:) ;
   ng = sum(all(~isnan(TT),2)) ;
   if ng>length(km)/2,
      RI(k) = (sum(norm2(TT-repmat(Tk(k,:),length(km),1))<r)-1)*length(km)/ng ;
   end
end

k = find(~isnan(RI)) ;
RI(k) = max(RI(k)/(fs*r),0) ;
