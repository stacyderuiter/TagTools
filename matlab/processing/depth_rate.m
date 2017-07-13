function     v = depth_rate(p,fs,fc)

%     v = depth_rate(p)           % p is a sensor structure
%	  or
%     v = depth_rate(p,fc)        % p is a sensor structure
%	  or
%     v = depth_rate(p,fs)        % p is a vector
%	  or
%     v = depth_rate(p,fs,fc)     % p is a vector
%     Estimate the vertical velocity by differentiating a depth or 
%	  altitude time series. A low-pass filter reduces the sensor
%	  noise that is amplified by the differentiation.
%		
%	  Inputs:
%     p is a depth or altitude time series. p can have any units and can be in
%      a vector or can be a sensor structure.
%	   fs is the sampling rate of p in Hz. This is only needed if p is not a sensor
%      structure.
%     fc is an optional smoothing filter cut-off frequency in Hz. If fc
%	   is not given, a default value is used of 0.2 Hz (5 second time constant).
%
%	  Returns:
%     v is the vertical velocity with the same sampling rate as p. v
%	  has the same dimensions as p. The unit of v depends on the unit
%	  of p. If p is in meters, v is in meters/second
%
%     The low-pass filter is a symmetric FIR with length 4fs/fc.
%	   The group delay of the filters is removed.
%
%		Example:
%		loadnc('testdata1')
%		v = depth_rate(P)
% 	    returns: .
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     Last modified: 10 May 2017

v = [] ;
if nargin<1,
   help depth_rate
   return
end

if isstruct(p),
   if nargin>1,
	  fc = fs ;
   else
	  fc = [] ;
   end
   fs = p.fs ;
   p = p.data ;
else
   if nargin<3 | isempty(fc),
      fc = 0.2 ;
   end
end

nf = round(4*fs/fc) ;
% use central differences to avoid a half sample delay
diffp = [p(2)-p(1);(p(3:end)-p(1:end-2))/2;p(end)-p(end-1)]*fs ;
% low pass filter to reduce sensor noise
v = fir_no_delay(diffp,nf,fc/(fs/2)) ;
