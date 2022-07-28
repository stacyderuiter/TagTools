function    prh = rotmat2euler(Q)
%
%      prh = rotmat2euler(Q)
%      Decompose a rotation (or direction cosine) matrix into Euler angles,
%		 pitch, roll, and heading.
%
%		 Inputs:
%      Q is a 3x3 rotation matrix. 
%
%		 Returns:
%		 prh is a 1x3 vector containing: prh=[p,r,h] where p is the pitch angle in radians.
%		  r is the roll angle in radians, h is the heading or yaw angle in radians.
%
%		 Example:
%          Q = [0.7601 0.0346 -0.6489; 0.4936 0.6187 0.6112; 0.4226 -0.7849 0.4532]
%		   prh = rotmat2euler(Q)
% 	     returns: prh = [0.4363, -1.0472, 0.5760] radians.
%
%      Valid: Matlab, Octave
%      markjohnson@st-andrews.ac.uk
%      last modified: 15 May 2017

prh = [asin(Q(3,1)) atan2(Q(3,2),Q(3,3)) atan2(Q(2,1),Q(1,1))] ;
