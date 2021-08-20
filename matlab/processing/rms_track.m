function    [t,ti] = rms_track(T,fs,intvl)

%    [t,ti] = rms_track(T,fs,intvl)
%    Measure the RMS distance covered by an animal over an interval, i.e.,
%    the radius of a circle that covers most of the track in that interval.
%    This is a measure of track tortuousity. This function finds the mean
%    of the track in each interval and then computes the RMS distance from
%    the mean point to each position in the interval. This is the
%    square-root of the mean of the squared track lengths where each track
%    length is the square-root of the sum of the northing distance from the
%    mean squared plus the easting distance from the mean squared. A high
%    number indicates that the animal travels a long distance in the interval,
%    i.e., it is performing largely straight-line movement. 
%
%    Inputs:
%    T contains the animal positions in a local horizontal plane. T has a row
%     for each position and two columns: northing and easting, i.e. T = [northing, easting]. The
%     positions can be in any consistent spatial unit, e.g., metres, km,
%     nautical miles, and are referenced to an arbitrary 0,0 location. 
%     T cannot be in degrees as the distance equivalent to a degree latitude 
%     is not the same as for a degree longitude. Consider using lalo2llf to
%     convert from latitude/longitude data to meters northing & easting in
%     a local-level frame.
%    fs is the sampling rate of the positions in Hertz (samples per
%     second).
%    intvl is the time interval in seconds over which tortuosity is
%     calculated. This should be chosen according to the scale of interest,
%     e.g., the typical length of a foraging bout.
%
%    Returns:
%    t is the RMS track length in the same units as T.
%    ti is the same as t but scaled to the RMS track length of an animal
%     moving in a straightline at a speed of 1 unit per second. Divide
%     this by the mean speed to get an index of travel between 0 and 1. 0
%     means no distance is covered while 1 means the full straightline
%     distance is covered.
%
%    t and ti contain a value for each period of intvl seconds.
%
%    This tortuosity measure is sensitive to speed so if T is 
%    produced by dead-reckoning (e.g., using ptrack or htrack), the
%    speed estimate will impact the result. To make a speed-independent
%    index, consider dividing t by the mean speed times half the interval
%    length, i.e., the maximum straight-line distance the animal could
%    cover from the mean position in an interval.
%    The frame of T is not important as long as the two axes (nominally 
%    called northing and easting) used to describe the positions are 
%    perpendicular.
%
%	  Example:
%       load_nc('testset1')
%       sampling_rate = P.sampling_rate;
%		v = ocdr(P,A);
%		s = sqrt(max(1-v.^2,0));
%		Track = ptrack(A,M,s);
%       intvl = [0 600]
%       [RMStrackLength, RMStrackLengthScaled] = rms_track(Track, sampling_rate, intvl)
%
%    Valid: Matlab, Octave
%    markjohnson@st-andrews.ac.uk
%    last modified: 10 July 2017 

if nargin<3,
	help rms_track
	return
end
	
k = round(fs*intvl) ;
[N,z] = buffer(T(:,1),k,0,'nodelay') ;
[E,z] = buffer(T(:,2),k,0,'nodelay') ;
t = sqrt(mean((N-repmat(mean(N),size(N,1),1)).^2+(E-repmat(mean(E),size(E,1),1)).^2))' ;
t(:,2) = t(:,1)*2*fs/sqrt(k*(k+2)/3) ;
