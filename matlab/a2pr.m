function     [p,r,v] = a2pr(A,fc)

%     [p,r,v] = a2pr(A,[fc])
%     Pitch and roll estimation from triaxial accelerometer data. This is 
%		a non-iterative estimator with |pitch| constrained to <= 90 degrees.
%     The pitch and roll estimates give the least-square-norm error between 
%		A and the A-vector that would be measured at the estimated pitch and roll.
%	   If A is in the animal frame, the resulting pitch and roll define
%	   the orientation of the animal with respect to its navigation frame.
%	   If A is in the tag frame, the pitch and roll will define the tag
%	   orientation with respect to its navigation frame.
%
%     Inputs:
%     A is a nx3 acceleration matrix with columns [ax ay az]. Acceleration can 
%		 be in any consistent unit, e.g., g or m/s^2. 
%	   fc (optional) specifies the cut-off frequency of a low-pass filter to
%		 apply to A before computing pitch and roll. The filter cut-off
%		 frequency is with respect to 1=Nyquist frequency. The filter length is
%		 8/fc. Filtering adds no group delay. If fc is not specified, no filtering 
%		 is performed.
%
%     Returns:
%     p is the pitch estimate in radians
%     r is the roll estimate in radians
%     v is the 2-norm of the acceleration measurements in the same units as A
%
%     Output sampling rate is the same as the input sampling rate.
%		Frame: This function assumes a [north,east,up] navigation frame and a
%		[forward,right,up] local frame. In these frames, a positive pitch angle 
%		is an anti-clockwise rotation around the y-axis. A positive roll angle 
%		is a clockwise rotation around the x-axis. A descending animal will have
%		a negative pitch angle while an animal rolled with its right side up will
%		have a positive roll angle.
%
%		Example:
%		 [p,r,v] = a2pr([0.77 -0.6 -0.22])
% 	    returns: p=0.87806 radians, r=-1.9222 radians, v=1.0006 g.
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     Last modified: 10 May 2017

if nargin==0,
   help a2pr
   return
end

% catch the case of a single acceleration vector
if min([size(A,1) size(A,2)])==1,
   A = A(:)' ;
end

if nargin==2,
	A = fir_nodelay(A,round(8/fc),fc) ;
end
	
v = sqrt(sum(A.^2,2)) ;

% compute pitch and roll
p = asin(A(:,1)./v) ;
r = real(atan2(A(:,2),A(:,3))) ;
