function    [V,q] = inv_axis(A)

%     [V,q] = inv_axis(A)
%		Identify the axis in triaxial movement measurements that varies
%		the least, i.e., the invariant axis. Rotational and linear movement in
%		some types of propulsion largely occur in 2 dimensions e.g., body rotation
%		in cetacean caudal propulsion occurs around the animal's transverse axis.
%		Likewise sychronized wing flaps in flight or pectoral swimming may generate
%		acceleration in the longitudinal and dorso-ventral axes but much less in the
%		transverse axis. This function identifies the direction of the axis that moves
%		the least in a movement matrix.
%
%		Input:
%		A is a triaxial sensor measurement axis e.g., from on accelerometer or magnetometer.
%		 The frame and unit of A do not matter.
%
%		Returns:		 
%		V is a 3x1 vector defining the least varying axis in A. V is a direction vector so
%		 has a length of 1 and is unit-less. V is defined in the same frame as A.
% 		q is the fraction of movement in the invariant axis. A small number (e.g., <0.05)
%		 implies that very little movement occurs in this axis and so the movement is largely
%		 planar (i.e., two-dimensional). If the fraction is >> 0.05, the motion in A is 
%		 better described as three-dimensional. q is a fraction and so does not have a unit.
%
%		This function returns one invariant axis that applies to the entire input signal so
%		it is important to choose a relevant sub-sample of movement data, A, to analyse.
%
%		Example:
%		 [V,q] = inv_axis(sin(2*pi*0.1*(1:100)')*[0.9 -0.4 0.3])
% 	    returns: V=[-0.0796;0.4773;0.8752], q=1.6241e-09.
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     Last modified: 10 May 2017


% energy ratio between plane-of-motion and axis of rotation
k = find(~any(isnan(A),2)) ;
QQ = A(k,:)'*A(k,:) ;      % form outer product of movement matrix
[V,D,~] = svd(QQ) ;         	% do singular value decomposition 
V = V(:,3) ;				   % this is the least varying axis (i.e., the one with the smallest SV)
q = D(3,3)/sqrt(D(1,1)*D(2,2)) ;  % what fraction of movement is in the 'invariant' axis
