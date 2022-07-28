function    W = body_axes(A,M,fs,fc)

%     W = body_axes(A,M)				% A and M are sensor structures or matrices
%		or
%     W = body_axes(A,M,fc)			% A and M are sensor structures
%		or
%     W = body_axes(A,M,fs,fc)		% A and M are matrices
%     Generate the cardinal axes of a tag or animal (i.e., the longitudinal, transverse,
%		and ventro-dorsal) from accelerometer and magnetic field measurements. This
%		functions generates an approximate orthonormal basis from each measurement in
%		A and M by:
%     (i)   normalizing A and M to unit length
%     (ii)  rotating the magnetometer measurement to the horizontal plane (Mh), 
%     (iii) computing the cross-product, N, of A and Mh to generate the third axis, 
%     (iv)  transposing [Mh,N,A] to form the body axis basis.
%
%     Inputs:
%     A is an accelerometer sensor structure or matrix with columns [ax ay az]. 
%		 Acceleration can be in any consistent unit, e.g., g or m/s^2. 
%     M is a magnetometer sensor structure or matrix, M=[mx,my,mz] in any consistent
%		 unit (e.g., in uT or Gauss).
%     fs is the sampling rate of the sensor data in Hz (samples per second).
%		 This is only needed if A and M are not sensor structures and filtering is required.
%	   fc (optional) specifies the cut-off frequency of a low-pass filter to
%		 apply to A and M before computing heading. The filter cut-off frequency is  
%      in Hertz. The filter length is 4*fs/fc. Filtering adds no group delay. If fc is not 
%      specified, no filtering is performed.
%
%     Returns:
%     W is a structure of body axes. If n is the number of rows in M and A:
%		 W.x is a nx3 matrix containing the X or longitudinal (caudo-rostral) axes. 
%		 W.y is a nx3 matrix containing the Y or transverse (left-right) axes.
%		 W.z is a nx3 matrix containing the Z or ventro-dorsal axes.
%		 W.sampling_rate has the sampling rate of the A and M.
%
%     Output sampling rate is the same as the input sampling rate.
%		This function expects regularly sampled A and M. Irregularly sampled data
%		can be used but filtering must be disabled (by putting fc=[]).
%		Frame: This function assumes a [north,east,up] navigation frame and a
%		[forward,right,up] local frame. The axes returned by this function will only
%		represent the animal's cardinal axes if the tag was attached so that the
%		sensor axes were aligned with the animal's axes OR if the tag A and M measurements
%		are rotated to account for the orientation of the tag on the animal (see
%		tag2animal to do this). Otherwise, the axes returned
%		by this function will be the cardinal axes of the tag, not the animal.
%
%		Example:
%		 W = body_axes([-0.3 0.52 0.8],[22 -22 14])
% 	    returns: W.x = [0.5968 0.7442 -0.2999]'
%				    W.y = [-0.5518 0.6521 0.5199]'
%					 W.z = [0.5825 -0.1448 0.7998]'
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     Last modified: 10 May 2017

if nargin<2,
   help body_axes
   return
end

if isstruct(M) && isstruct(A),
	if nargin>2,
		fc = fs ;
	else
		fc = [] ;
   end
	
   [A,M,fs] = sens2var(A,M,'regular') ;
	if isempty(A),	return, end
   
	toffs = [0,0] ;
	if isfield(A,'start_offset'),
		toffs(1) = A.start_offset ;
	end
	if isfield(M,'start_offset')
		toffs(2) = M.start_offset ;
	end
	if toffs(1)~=toffs(2),
		fprintf('body_axes: A and M must have the same start offset time\n') ;
		return
   end
else
	if isstruct(M) || isstruct(A),
		fprintf('body_axes: A and M must both be structures or matrices, not one of each\n') ;
		return
	end
	if nargin<=3,
		fc = [] ;
      if nargin<3,
         fs = [] ;
      end
	end
end	

if size(M,1)*size(M,2)==3,
   M = M(:)' ;
end

if size(A,1)*size(A,2)==3,
   A = A(:)' ;
end

if size(A,1)~=size(M,1),
	n = min([size(A,1),size(M,1)]) ;
	A = A(1:n,:) ;
	M = M(1:n,:) ;
end

if ~isempty(fc),
	nf = round(4*fs/fc) ;
   fc = fc/(fs/2) ;
	if size(M,1)>nf,
		M = fir_nodelay(M,nf,fc) ;
		A = fir_nodelay(A,nf,fc) ;
	end
end

b = sqrt(sum(M.^2,2)) ;
g = sqrt(sum(A.^2,2)) ;
M = M.*repmat(b.^(-1),1,3) ;		% normalize M to unit magnitude
A = A.*repmat(g.^(-1),1,3) ;		% normalize A to unit magnitude
I = acos(sum(A.*M,2))-pi/2 ;		% estimate inclination angle from the data

Mh = (M+repmat(sin(I),1,3).*A).*repmat(cos(I).^(-1),1,3) ;
v = sqrt(sum(Mh.^2,2)) ;
Mh = Mh.*repmat(v.^(-1),1,3) ;		% normalize Mh
N = -cross(Mh,A,2) ;       % for FRU axes

w = zeros(3,3,size(A,1)) ;
w(1,:,:) = Mh' ;
w(2,:,:) = N' ;
w(3,:,:) = A' ;
W.x = squeeze(w(:,1,:))' ;
W.y = squeeze(w(:,2,:))' ;
W.z = squeeze(w(:,3,:))' ;
W.sampling_rate = fs ;
