function    [PA,R,T] = posture_change(A,M,fs,t)

%     [PA,R,T] = posture_change(A,M,t)		% A and M are sensor structures
%		or
%     [PA,R,T] = posture_change(A,M,fs,t)	% A and M are matrices
%
%     Compute the change in posture over intervals of time. Posture
%		is parameterised by two angles: the pointing angle, i.e., the direction
%		in the navigation frame of the animal's or tag's longitudinal axis; and
%		the roll angle, i.e., the angle that the animal rotates around its
%		longitudinal axis.
%
%     Inputs:
%     A is an accelerometer sensor structure or matrix with columns [ax ay az]. 
%		 Acceleration can be in any consistent unit, e.g., g or m/s^2. 
%     M is a magnetometer sensor structure or matrix, M=[mx,my,mz] in any consistent 
%		 unit (e.g., in uT or Gauss). A and M must both have the same number of samples
%		 and have the same sampling rate.
%     fs is the sampling rate of the sensor data in Hz (samples per second).
%		 This is only needed if A and M are not sensor structures and filtering is required.
%     t is the time interval in seconds over which to compute the change in angle.
%		 If t is a scalar, the pointing angle and roll will be computed for each t
%		 second interval in A and M. If t is a 2-column matrix, the pointing angle and roll
%		 are computed over each interval defined by the rows of t with the first column being
%		 the start time of each interval and the second column being the end time.
%
%     Returns:
%     PA is a vector containing the change in pointing angle in radians over each t 
%		 second interval.
%     R is a vector containing the change in roll angle in radians over the same time 
%		 intervals.
%		T is a vector of the central times in seconds (i.e., midpoint of each computation 
%		 interval) corresponding to each pointing angle and roll angle.
%
%		This function does not filter A and M but they should be low-pass filtered before
%		using this function to reduce noise in PA and R from high frequency variations 
%		in A and M due to specific acceleration, swimming movements or sharp maneuvers. A
%		delay-free low-pass filter with fc = 4/t in Hz and n=t*fs is recommended, i.e.,
%			Af = fir_nodelay(A,t*fs,8/(t*fs)) ;		% 4/t is 4/t/(fs/2) wrt Nyquist frequency.
%
%		Frame: This function assumes a [north,east,up] navigation frame and a
%		[forward,right,up] local frame. The angles returned by this function will only
%		represent the animal's cardinal axes if the tag was attached so that the
%		sensor axes were aligned with the animal's axes OR if the tag A and M measurements
%		are rotated to account for the orientation of the tag on the animal (see
%		tag2animal to do this). Otherwise, the axes returned
%		by this function will be the cardinal axes of the tag, not the animal.
%
%		Example:
%		 load_nc('testset1')
%        PC = posture_change(A, M, [0 0.5]);
%       Returns: the posture change in the first half second: PC = 0.1183 radians.
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     Last modified: 14 September 2018

if nargin<3,
   help posture_change
   return
end

if isstruct(A),
	t = fs ;
	
	% check that A and M are compatible - they need the same sampling rate and time offset
	if isstruct(M),
		[A,M,fs] = sens2var(A,M) ;	
	else
		[A,fs] = sens2var(A) ;	
	end
	
	if isempty(A) || size(A,1)~=size(M,1),
		fprintf('A and M do not have the same size or sampling rate\n') ;
		return
	end

else
	if isstruct(M),
		fprintf('A and M must both be structures or matrices\n') ;
		return
	end

	if nargin<4,
	   fprintf('Error: Need to specify fs and t\n') ;
	   return
	end
end	

W = body_axes(A,M,fs) ;
if length(t)==1,
	tt = (0:t:(size(A,1)-1)/fs-t)' ;
	tt(:,2) = tt(:,1)+t ;
	t = tt ;
end
K = round(fs*t)+1 ;
K = K(all(K,2)>0 & all(K<=size(A,1),2),:) ;
T = (mean(K,2)-1)/fs ;
PA = zeros(size(K,1),1) ;
R = zeros(size(K,1),1) ;
for k=1:size(K,1),
	ks = K(k,1) ;
	ke = K(k,2) ;
	Ts = [W.x(ks,:);W.y(ks,:);W.z(ks,:)]' ; % body axes at the start of the interval
	Te = [W.x(ke,:);W.y(ke,:);W.z(ke,:)]' ; % body axes at the end of the interval
	TT = Ts'*Te ;				% body axes transformation over the interval
	PA(k) = real(acos(TT(1,1))) ;				% change in pointing angle
	R(k) = atan(-TT(3,2)/TT(3,3)) ;	% change in roll angle
end
