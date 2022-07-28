function     [fstr,incl] = check_AM(A,M,fs)

%     fstr = check_AM(X)               % X is a sensor structure
%     or
%     fstr = check_AM(X,fs)            % X is a matrix
%     or
%     [fstr,incl] = check_AM(A,M)		% M and A are sensor structures
%		or
%     [fstr,incl] = check_AM(A,M,fs)  % M and A are matrices
%
%     Compute field intensity of acceleration and magnetometer data, and the
%     inclination angle of the magnetic field. This is useful for checking the
%     quality of a calibration, for detecting drift, and for validating the mapping
%     of the sensor axes to the tag axes. 
%
%		Inputs:
%     A is an accelerometer sensor structure or matrix with columns [ax ay az]. 
%		 Acceleration can be in any consistent unit, e.g., g or m/s^2. 
%     M is a magnetometer sensor structure or matrix, M=[mx,my,mz] in any consistent 
%		 unit (e.g., in uT or Gauss).
%     X can be either A or M data and is used if check_AM is called with only one type 
%      of data. 
%     fs is the sampling rate of the sensor data in Hz (samples per second).
%		 This is only needed if A and M are not sensor structures and filtering is required.
%
%		Returns:
%     fstr is the estimated field intensity of A and or M in the same units as A and M.
%      fstr is a vector or a two column matrix. If only one type of data is input, 
%      fstr will be a column vector. If both A and M are input, fstr will have two columns
%      with the field strength of A in the 1st column and the field strength of M in the
%      2nd column.
%     incl is the estimated field inclination angle (i.e., the angle with respect to the 
%      horizontal plane) in radians. incl is a column vector. By convention, a field 
%      vector pointing below the horizon has a positive inclination angle. This is only 
%      returned if the function is called with both A and M data.
%		
%		The sampling rate of fstr and incl is the same as the input sampling rate.
%     This function automatically low-pass filters the data with a cut-off frequency
 %    of 5 Hz if the sampling rate is greater than 10 Hz.
%		Frame: This function assumes a [north,east,up] navigation frame and a
%		[forward,right,up] local frame.
%
%		Example:
%		 [fstr,incl] = check_AM([-0.3 0.52 0.8],[22 -22 14],5)
% 	    returns: fstr=[1.0002,34.1174], incl=0.20181 radians.
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     last modified: 2 Aug 2017

fstr=[]; incl=[] ;
fc = 5 ;             % low pass filter frequency in Hz

if nargin<1,
   help check_AM
   return
end

if isstruct(A),
   if nargin>=2,
   	[A,M,fs] = sens2var(A,M,'regular') ;
   else
   	[A,fs] = sens2var(A,'regular') ;
      M = [] ;
   end
	if isempty(A),
      return
   end
else
	if nargin<2,
      help check_AM
	   return
   end

	if nargin==2,
      if numel(M) == 1,
         fs = M ;
         M = [] ;
      else
         fprintf(' Need to specify sampling frequency for matrix arguments\n') ;
         return
      end
	end
end	

% check for single vector inputs
if size(M,1)*size(M,2)==3,
   M = M(:)' ;
end

if size(A,1)*size(A,2)==3,
   A = A(:)' ;
end

% check that sizes of A and M are compatible
if ~isempty(M) && (size(A,1)~=size(M,1)),
	n = min([size(A,1),size(M,1)]) ;
	A = A(1:n,:) ;
	M = M(1:n,:) ;
end

if fs>10,
	nf = round(4*fs/fc) ;
	if size(A,1)>nf,
		M = fir_nodelay(M,nf,fc/(fs/2)) ;
		A = fir_nodelay(A,nf,fc/(fs/2)) ;
	end
end

% compute mag field intensity and inclination

fstr = sqrt(sum(A.^2,2)) ;         % compute field intensity of first input argument
if ~isempty(M),
   fstr(:,2) = real(sqrt(sum(M.^2,2))) ; % compute field intensity of second input argument
end

if nargout>1,
   incl = -real(asin(sum(A.*M,2)./(fstr(:,1).*fstr(:,2)))) ;
end
