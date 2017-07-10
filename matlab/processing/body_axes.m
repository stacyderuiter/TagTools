function    W = body_axes(A,M,fc)

%     W = bodyaxes(A,M,fc)
%     Generate the cardinal axes of an animal (i.e., the longitudinal, transverse,
%		and ventro-dorsal) from accelerometer and magnetic field measurements. This
%		functions generates an approximate orthonormal basis from each measurement of
%		A and M by:
%     (i)   normalizing A and M to unit length
%     (ii)  rotating the magnetometer measurement to the horizontal plane (Mh), 
%     (iii) computing the cross-product, N, of A and Mh to generate the third axis, 
%     (iv)  transposing [Mh,N,A] to form the body axis basis.
%
%     Inputs:
%     A is the acceleration matrix with columns [ax ay az]. Acceleration can 
%		 be in any consistent unit, e.g., g or m/s^2. 
%     M is the magnetometer signal matrix, M=[mx,my,mz] in any consistent unit
%		 (e.g., in uT or Gauss).
%	   fc (optional) specifies the cut-off frequency of a low-pass filter to
%		 apply to A and M before computing the axes. The filter cut-off
%		 frequency is with respect to 1=Nyquist frequency. The filter length is
%		 8/fc. Filtering adds no group delay. If fc is not specified, no filtering 
%		 is performed.
%
%     Returns:
%     W is the 3x3xn matrix of body axes where n is the number of rows in M and A.
%		 W(:,1,:) are the X or longitudinal (caudo-rostral) axes. 
%		 W(:,2,:) are the Y or transverse (left-right) axes.
%		 W(:,3,:) are the Z or ventro-dorsal axes.
%
%     Output sampling rate is the same as the input sampling rate.
%		Frame: This function assumes a [north,east,up] navigation frame and a
%		[forward,right,up] local frame. This function will only return the
%		animal's cardinal axes if the tag was attached so that the
%		sensor axes aligned with the animal's axes OR if the tag A and M measurements
%		are rotated to account for the orientation of the tag on the animal (see
%		tagorientation() and tag2animal() to do this). Otherwise, the axes returned
%		by this function will be the cardinal axes of the tag, not the animal.
%
%		Example:
%		 W = bodyaxes([-0.3 0.52 0.8],[22 -22 14])
% 	    returns: W=[0.59682  -0.55182   0.58249
%				       0.74420   0.65208  -0.14477
%					    -0.29994   0.51990   0.79984]
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     Last modified: 10 May 2017

if nargin<2,
   help bodyaxes
   return
end

if size(M,1)*size(M,2)==3,
   M = M(:)' ;
end

if size(A,1)*size(A,2)==3,
   A = A(:)' ;
end

if size(A,1)~=size(M,1),
   fprintf('bodyaxes: A and M must have same number of rows\n') ;
   return
end

if nargin==3 && size(A,1)>8/fc,
	M = fir_nodelay(M,round(8/fc),fc) ;
	A = fir_nodelay(A,round(8/fc),fc) ;
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

W = zeros(3,3,size(A,1)) ;
W(1,:,:) = Mh' ;
W(2,:,:) = N' ;
W(3,:,:) = A' ;
