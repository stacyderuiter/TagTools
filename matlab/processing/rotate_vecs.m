function      V = rotate_vecs(V,Q)
%
%     V = rotatevecs(V,Q)
%	   Rotate triaxial vector measurements from one frame to another.
%     T is the time-varying direction cosine (3x3xn) relating the second 
%     frame to the first. 
%
%     Inputs:
%     V is a 3-element vector or a 3-column matrix of vector measurements
%		 for example V could be from an accelerometer or magnetometer.
%		Q is the rotation matrix. If Q is a single 3x3 matrix, the same
%		 rotation is appled to all vectors in V. If Q is a 3x3xn matrix where
%		 n is the number of rows in V, a different transformation given by Q(:,:,k)
%		 is applied to each row of V.
%
%     Returns:
%     V is the rotated vector or matrix with the same size as the input V.
%
%		Frame: This function makes no assumptions about frame.
%
%		Example:
%		 Q = euler2rotmat(pi/180*[25 -60 33]);
%		 V = rotatevecs([0.77 -0.6 -0.22],Q)
% 	    returns: V=[0.7072,-0.1256,0.6967].
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     Last modified: 10 May 2017

if nargin<2,
   help rotatevec ;
   return
end

if size(V,2)==1,
	V = V' ;
end
	
if size(Q,3)==1,
	V = V*Q' ;
else
   for k=1:size(V,1),
      V(k,:) = V(k,:)*Q(:,:,k)' ;
   end
end
