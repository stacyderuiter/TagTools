function     [s,v]=speed_from_depth(p,A,fs,fc,plim)

%     [s,v]=speed_from_depth(p,A)               % p and A are sensor structures
%     or
%     [s,v]=speed_from_depth(p,A,fc)            % p and A are sensor structures
%     or
%     [s,v]=speed_from_depth(p,A,fc,plim)       % p and A are sensor structures
%     or
%     [s,v]=speed_from_depth(p,A,fs)            % p and A are vectors/matrices
%     or
%     [s,v]=speed_from_depth(p,A,fs,fc)         % p and A are vectors/matrices
%     or
%     [s,v]=speed_from_depth(p,A,fs,fc,plim)    % p and A are vectors/matrices
%
%     [s,v]=speed_from_depth(p,A,fs,fc,plim)
%     Estimate the forward speed of a diving animal by first computing
%		the depth-rate (i.e., the first differential of the depth) and then
%		correcting for the pitch angle. 
%		or
%     v=speed_from_depth(p,fs,fc)
%     Just estimate the depth-rate (i.e., the first differential of the depth). 
%
%		Inputs:
%     p is the depth vector (a regularly sampled time series) in meters.
%		 sampled at fs Hz.
%     A is a nx3 acceleration matrix with columns [ax ay az]. Acceleration can 
%		 be in any consistent unit, e.g., g or m/s^2. A must have the same number
%		 of rows as p.
%		fs is the sampling rate of p and A in Hz (samples per second).
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
%     v is the depth-rate (or vertical velocity) in m/s
%     
%     Output sampling rate is the same as the input sampling rate so s and v have
%		the same size as p.
%		Frame: This function assumes a [north,east,up] navigation frame and a
%		[forward,right,up] local frame. In these frames, a positive pitch angle 
%		is an anti-clockwise rotation around the y-axis. A descending animal will have
%		a negative pitch angle.
%
%		Example:
%		 [s,v] = speed_from_depth()
% 	    returns: .
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     Last modified: 15 May 2017

if nargin<2
   help('speed_from_depth') ;
   return
end

if isstruct(p) && isstruct(A)
	if nargin<3
        fs = [];
    end
	if nargin<4
		fc = [] ;
    end
    plim = fc ;
	fc = fs ;
	fs = p.sampling_rate ;
	p = p.data ;
    A = A.data ;
else
   if nargin<3
      fprintf('speed_from_depth: fs required for vector/matrix sensor data\n');
      return
   end
   if nargin<4
	   fc = [] ;
   end
   if nargin<5
	   plim = [] ;
   end
end

[m,n] = size(A);
if m==1 && n==1					% second call type - no A
	if nargin<3 || isempty(fs)
		fc = 0.2 ;						% default filter cut-off of 0.2 Hz
	else
		fc = fs ;
	end
	fs = A ;
	A = [] ;
else
	if nargin<4 || isempty(fc)
		fc = 0.2 ;						% default filter cut-off of 0.2 Hz
    end
end

if nargin<5 || isempty(plim)
	plim = 20/180*pi ;			   % default 20 degree pitch angle cut-off
end

nf = round(4*fs/fc) ;
v = fir_nodelay([p(2)-p(1);diff(p)]*fs,nf,fc/(fs/2)) ;

if ~isempty(A)
	A = fir_nodelay(A,nf,fc/(fs/2)) ;
	pitch = a2pr(A) ;
	pitch(abs(pitch)<plim) = NaN ;
	s = v./sin(pitch) ;
else
	s = v;
end
