function      V = rotate_vecs(V,Q)
%
%     V = rotate_vecs(V,Q)
%	   Rotate triaxial vector measurements from one frame to another.
%
%     Inputs:
%     V is a sensor structure, matrix or vector containing measurements
%		 from a triaxial sensor, e.g., an accelerometer, magnetometer or gyroscope.
%		 If V is a matrix it should have 3 columns. If V is a single measurement,
%		 it will be a 1x3 or 3x1 vector.
%		Q is a rotation matrix specifying how V is to be rotated. If Q is a 
%		 single 3x3 matrix, the same rotation is applied to all vectors in V. 
%		 If Q is a 3x3xn matrix where n is the number of rows of data in V, a 
%		 different transformation given by Q(:,:,k) is applied to each row of V.
%		 Use euler2rotmat to generate a rotation matrix from euler angles.
%
%     Returns:
%     V is the rotated data with the same size and sampling rate as the input V.
%		 If the input was a sensor structure, the output will also be. 
%
%		Frame: This function assumes that the axes of V are consistent with the
%		 axes assumed in generating the rotation matrix, i.e., forward-right-up. 
%		 This function changes the frame of V by rotating it into a new frame. For
%		 example if V is in the tag frame and Q is the rotation matrix relating tag
%		 and animal frame, then the output will be in the animal frame.
%
%		Example:
%		 Q = euler2rotmat(pi/180*[25 -60 33]);
%		 V = rotate_vecs([0.77 -0.6 -0.22],Q)
% 	    returns: V=[0.7072,-0.1256,0.6967].
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     Last modified: 4 August 2017

if nargin<2,
   help rotate_vecs ;
   return
end

if isstruct(V),
	v = sens2var(V) ;
	if isempty(v), return, end
else
	v = V ;
end
	
if size(v,2)==1,
	v = v' ;
end
	
if size(Q,3)==1,
	v = v*Q' ;
else
   for k=1:size(v,1),
      v(k,:) = v(k,:)*Q(:,:,k)' ;
   end
end

if ~isstruct(V),
	V = v ;
	return
end
	
V.data = v ;
if ~isfield(V,'history') || isempty(V.history),
	V.history = 'rotate_vecs' ;
else
	V.history = [V.history ',' 'rotate_vecs'] ;
	end
end

