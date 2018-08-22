function    incl = inclination(A,M,fc)

%     incl = inclination(A,M,[fc])
%     Estimate the local magnetic field vector inclination angle directly from
%     acceleration and magnetic field measurements.
%
%		Inputs:
%     A is the accelerometer signal matrix, A=[ax,ay,az] in any consistent unit
%		 (e.g., in g or m/s2). A can be in any frame.
%     M is the magnetometer signal matrix, M=[mx,my,mz] in any consistent unit
%		 (e.g., in uT or Gauss). M must be in the same frame as A.
%	   fc (optional) specifies the cut-off frequency of a low-pass filter to
%		 apply to A and M before computing the inclination angle. The filter cut-off
%		 frequency is with respect to 1=Nyquist frequency. Filtering adds no
%		 group delay. If fc is not specified, no filtering is performed.
%
%		Returns:
%     incl is the magnetic field inclination angle in radians.
%
%     Output sampling rate is the same as the input sampling rate.
%		Frame: This function assumes a [north,east,up] navigation frame and a
%		[forward,right,up] local frame. In these frames, the magnetic field vector has
%		a positive inclination angle when it points below the horizon.
%		is an anti-clockwise rotation around the y-axis. Other frames can be used as long
%		as A and M are in the same frame however the interpretation of incl will differ
%		accordingly.
%
%		Example:
%		 incl = inclination([0.77 -0.6 -0.22],[22 -22 14])
% 	    returns: incl=-0.91595 radians.
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     last modified: Jan 2017

if nargin<2,
	help inclination
	return
end

% catch the case of a single acceleration vector
if min([size(A,1) size(A,2)])==1,
   A = A(:)' ;
end

if min([size(M,1) size(M,2)])==1,
   M = M(:)' ;
end

if size(M,1)~=size(A,1),
	fprintf('A and M must have the same number of rows\n') ;
	incl = [] ;
	return
end
	
if nargin==3,
	A = fir_nodelay(A,round(8/fc),fc) ;
	M = fir_nodelay(M,round(8/fc),fc) ;
end
	

vm = sqrt(sum(M.^2,2)) ;         % compute magnetic field intensity
va = sqrt(sum(A.^2,2)) ;         
incl = -real(asin(sum(A.*M,2)./(va.*vm))) ;
