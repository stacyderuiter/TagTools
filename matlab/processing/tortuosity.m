function    t = tortuosity(T,fs,intvl)

%    t = tortuosity(T,fs,intvl)
%    Measure tortuousity index of a regularly sampled horizontal track.
%    Tortuosity can be measured in a number of ways. This function
%    compares the stretched-out track length (STL) over an interval of
%    time with the distance made good (DMG, i.e., the distance actually
%    covered in the interval). The index returned is (STL-DMG)/STL which
%    is 0 for straightline movement and 1 for extreme circular movement.
%
%    Inputs:
%    T contains the animal positions in a local horizontal plane. T has a row
%     for each position and two columns: northing and easting. The
%     positions can be in any consistent spatial unit, e.g., metres, km,
%     nautical miles, and are referenced to an arbitrary 0,0 location. 
%     T cannot be in degrees as the distance equivalent to a degree latitude 
%     is not the same as for a degree longitude.
%    fs is the sampling rate of the positions in Hertz (samples per
%     second).
%    intvl is the time interval in seconds over which tortuosity is
%     calculated. This should be chosen according to the scale of interest,
%     e.g., the typical length of a foraging bout.
%
%    Returns:
%    t is the tortuosity index which is between 0 and 1 as described
%     above. t contains a value for each period of intvl seconds.
%
%    This tortuosity index is fairly insensitive to speed so if T is 
%    produced by dead-reckoning (e.g., using ptrack or htrack), the speed
%    estimate is not important. Also the frame of T is not important as
%    long as the two axes (nominally called northing and easting) used to
%    describe the positions are perpendicular.
%
%	  Example:
%       load_nc('testset1')
%       sampling_rate = P.sampling_rate;
%		v = ocdr(P,A);
%		s = sqrt(max(1-v.^2,0));
%		Track = ptrack(A,M,s);
%		t = tortuosity(Track,sampling_rate,1200)
% 	   returns: t = [0.4921 5.8226; 0.2963 17.6704; 0.0119 136.4259; 0.1517 19.1493]
%       
%
%    Valid: Matlab, Octave
%    markjohnson@st-andrews.ac.uk
%    last modified: 10 July 2017 

k = round(fs*intvl) ;
[N,z] = buffer(T(:,1),k,0,'nodelay') ;
[E,z] = buffer(T(:,2),k,0,'nodelay') ;
lmg = sqrt((E(end,:)-E(1,:)).^2 + (N(end,:)-N(1,:)).^2)' ;
stl = sum(sqrt(diff(E).^2 + diff(N).^2))' ;
t = (stl-lmg)./stl ;
t(:,2) = sqrt(mean((N-repmat(mean(N),size(N,1),1)).^2+(E-repmat(mean(E),size(E,1),1)).^2))' ;
