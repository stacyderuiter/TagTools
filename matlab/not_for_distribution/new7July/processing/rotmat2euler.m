function    prh = rotmat2euler(Q)
%
%      prh = euler2rotmat(Q)
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
%		  prh = rotmat2euler()
% 	     returns: prh = ?
%
%      Valid: Matlab, Octave
%      markjohnson@st-andrews.ac.uk
%      last modified: 15 May 2017

prh = [asin(Q(3,1)) atan2(Q(3,2),Q(3,3)) atan2(Q(2,1),Q(1,1))] ;
