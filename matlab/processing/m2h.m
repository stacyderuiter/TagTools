function     [h,v,incl] = m2h(M,A,fs,fc)

%     [h,v,incl] = m2h(M,A)			% M and A are sensor structures or matrices
%		or
%     [h,v,incl] = m2h(M,A,fc)		% M and A are sensor structures
%		or
%     [h,v,incl] = m2h(M,A,fs,fc)	% M and A are matrices
%     Compute heading, field intensity and inclination angle by gimballing 
%     the magnetic field measurement matrix with the pitch and roll estimated from
%		the accelerometer matrix.
%		The heading is computed with respect to the frame of M and is the magnetic
%		heading NOT the true heading. M and A must have the same sampling 
%		rate, frame, and number of rows.
%
%		Inputs:
%     M is a magnetometer sensor structure or matrix, M=[mx,my,mz] in any consistent 
%		 unit (e.g., in uT or Gauss).
%     A is an accelerometer sensor structure or matrix with columns [ax ay az]. 
%		 Acceleration can be in any consistent unit, e.g., g or m/s^2. 
%     fs is the sampling rate of the sensor data in Hz (samples per second).
%		 This is only needed if A and M are not sensor structures and filtering is required.
%	   fc (optional) specifies the cut-off frequency of a low-pass filter to
%		 apply to A and M before computing heading. The filter cut-off frequency is with 
%      in Hertz. The filter length is 4*fs/fc. Filtering adds no group delay. If fc is not 
%      specified, no filtering is performed.
%
%		Returns:
%     h is the heading in radians in the same frame as M. The heading is 
%      with respect to magnetic north (i.e., the north vector of the navigation frame)
%		 and so must be corrected for declination. 
%     v is the estimated magnetic field intensity in the same units as M. This is just
%		 the 2-norm of M after filtering (if specified).
%     incl is the estimated field inclination angle (i.e., the angle with respect to the 
%      horizontal plane) in radians. By convention, a field vector pointing below the 
%      horizon has a positive inclination angle. See note in the function if using incl.
%		
%		Output sampling rate is the same as the input sampling rate, i.e., h, v, and incl 
%		are estimated with the same sampling rate as M and A and so are each nx1 vectors.
%		Frame: This function assumes a [north,east,up] navigation frame and a
%		[forward,right,up] local frame. North and east are magnetic, not true. In these frames,
%		a positive heading is a clockwise rotation around the z-axis. 
%
%		Example:
%		 [h,v,incl] = m2h([22 -22 14],[-0.3 0.52 0.8])
% 	    returns: h=0.89486 radians, v=34.117, incl=0.20181 radians.
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     last modified: 15 May 2017

h=[]; v=[]; incl=[] ;
if nargin<2,
   help m2h
   return
end

if isstruct(M) && isstruct(A),
	if nargin>2,
		fc = fs ;
    else
        fc = [];
    end
    if A.fs ~= M.fs,
		fprintf('m2h: A and M must be at the same sampling rate\n') ;
		return
	end
	fs = M.fs ;
	M = M.data ;
	A = A.data ;
else
	if nargin==2,
		fc = [] ;
	elseif nargin==3,
	   fprintf('Error: Need to specify fs and fc if calling m2h with matrix inputs\n') ;
	   return
	end
end	

if size(M,1)*size(M,2)==3,
   M = M(:)' ;
end

if size(A,1)*size(A,2)==3,
   A = A(:)' ;
end

if size(A,1)~=size(M,1),
   fprintf('m2h: A and M must have same number of rows\n') ;
   return
end

if ~isempty(fc),
	nf = round(4*fs/fc) ;
   fc = fc/(fs/2) ;
	if size(M,1)>nf,
		M = fir_nodelay(M,nf,fc) ;
		A = fir_nodelay(A,nf,fc) ;
	end
end

[p,r] = a2pr(A) ;		% get the pitch and roll from A

% slow way to do the gimballing:
% Mh = zeros(size(M,1),size(M,2)) ;
% for k=1:size(M,1),
%   T = makeT(p(k),r(k),0) ;   % transformation to horizontal frame
%   Mh(k,:) = M(k,:)*T' ;       % gimbal each M vector
% end
% equivalent but faster way because it can be vectorized:
cp = cos(p) ;
sp = sin(p) ;
cr = cos(r) ;
sr = sin(r) ;
Tx = [cp -sr.*sp -cr.*sp] ;
Ty = [zeros(length(cp),1) cr -sr] ;
Tz = [sp sr.*cp cr.*cp] ;
Mh = [sum(M.*Tx,2) sum(M.*Ty,2) sum(M.*Tz,2)] ;

% heading estimate in FRU system
h = atan2(-Mh(:,2),Mh(:,1)) ;

% compute mag field intensity and inclination
v = sqrt(sum(Mh.^2,2)) ;         % compute magnetic field intensity
incl = -real(asin(Mh(:,3)./v)) ;  % compute inclination

% Mh(:,3) is sp*Mx+srcp*My+crcp*Mz which is A.M if there is no
% specific acceleration. So the inclination angle computed here is the 
% same as the angle computed directly from A and M by the function 
% inclination.m if there is no specific acceleration. 
% If there is specific acceleration, both methods produce
% inclination angle estimates with errors and the errors are different
% because of the different computational methods.
