function     s=ocdr(p,A,fs,fc,plim)

%     s=ocdr(p,A)               % p and A are sensor structures
%     or
%     s=ocdr(p,A,fc)            % p and A are sensor structures
%     or
%     s=ocdr(p,A,fc,plim)       % p and A are sensor structures
%     or
%     s=ocdr(p,A,fs)            % p and A are vectors/matrices
%     or
%     s=ocdr(p,A,fs,fc)         % p and A are vectors/matrices
%     or
%     s=ocdr(p,A,fs,fc,plim)    % p and A are vectors/matrices
%
%     Estimate the forward speed of a flying or diving animal by first computing
%		the altitude or depth-rate (i.e., the first differential of the pressure 
%		in meters) and then correcting for the pitch angle. This is called the 
%		Orientation Corrected Depth Rate. There are two major assumptions in this 
%     method: (i) the animal moves in the direction of its longitudinal axis, and
%     (ii) the frame of A coincides with the animal's axes.
%
%		Inputs:
%     p is the depth or altitude vector (a regularly sampled time series) in meters.
%		 sampled at fs Hz.
%     A is a nx3 acceleration matrix with columns [ax ay az]. Acceleration can 
%		 be in any consistent unit, e.g., g or m/s^2. A must have the same number
%		 of rows as p.
%		fs is the sampling rate of p and A in Hz (samples per second). fs is not
%      required if p and A are sensor structures.
%	   fc (optional) specifies the cut-off frequency of a low-pass filter to
%		 apply to p after computing depth-rate and to A before computing pitch.
%		 The filter cut-off frequency is in Hz. The filter length is 4*fs/fc.
%		 Filtering adds no group delay. If fc is empty or not given, the default 
%		 value of 0.2 Hz (i.e., a 5 second time constant) is used.
%		plim (optional) specifies the minimum pitch angle in radians at which speed
%		 can be computed. Errors in speed estimation using this method increase strongly
%		 at low pitch angles. To avoid estimates with poor accuracy being used in
%		 later analyses, speed estimates at low pitch angles are replaced by NaN
%		 (not-a-number). The default threshold for this is 20 degrees.
%
%		Returns:
%		s is the forward speed estimate in m/s
%     
%     Output sampling rate is the same as the input sampling rate so s has
%		the same size as p.
%		Frame: This function assumes a [north,east,up] navigation frame and a
%		[forward,right,up] local frame. In these frames, a positive pitch angle 
%		is an anti-clockwise rotation around the y-axis. A descending animal will have
%		a negative pitch angle.
%
%		Example:
%		 s = ocdr()
% 	    returns: .
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     Last modified: 3 Feb 2021 - fixed sign error that was returning
%     negative speeds.

s = [] ;
if nargin<2,
   help('ocdr') ;
   return
end

if isstruct(p) && isstruct(A),
	if nargin<3,
		fs = [] ;
   end
	if nargin<4,
		fc = [] ;
   end
   plim = fc ;
	fc = fs ;
   [A,p,fs] = sens2var(A,p);
else
   if nargin<3,
      fprintf('ocdr: fs required for vector/matrix sensor data\n');
      return
   end
	if nargin<4,
		fc = [] ;
   end
	if nargin<5,
		plim = [] ;
   end
end

if isempty(fc),
	fc = 0.2 ;						% default filter cut-off of 0.2 Hz
end

if isempty(plim),
	plim = 20/180*pi ;			% default 20 degree pitch angle cut-off
end

nf = round(4*fs/fc) ;
% use central differences to avoid a half sample delay
diffp = [p(2)-p(1);(p(3:end)-p(1:end-2))/2;p(end)-p(end-1)]*fs ;
v = fir_nodelay(diffp,nf,fc/(fs/2)) ;
A = fir_nodelay(A,nf,fc/(fs/2)) ;
pitch = a2pr(A) ;
pitch(abs(pitch)<plim) = NaN ;
s = -v./sin(pitch) ;    % mj added -ve sign here 3/2/21
