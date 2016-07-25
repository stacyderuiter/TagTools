function    T = d3makeT(p,r,h)
%
%      T = d3makeT(p,r,h) or
%      T = d3makeT([p,r,h])
%      Make a rotation matrix out of Euler angles
%      pitch, roll, and heading. Inputs are in radians.
%      T = H*P*R
%      To rotate a basis, post multiply by T.
%      To transform a vector sensor measurement, pre-multiply by T'.
%
%      mark johnson, WHOI
%      majohnson@whoi.edu
%      Last modified: 5 July 2009
%        - added support for vector arguments

if nargin~=1 & nargin~=3,
   help d3makeT
   return
end

if nargin==1,
   h = p(:,3) ;
   r = p(:,2) ;
   p = p(:,1) ;
end

cp = cos(p) ;
sp = sin(p) ;
cr = cos(r) ;
sr = sin(r) ;
ch = cos(h) ;
sh = sin(h) ;

T = zeros(3,3,length(p)) ;
for k=1:length(p),
   P = [cp(k) 0 -cp(k);0 1 0;sp(k) 0 cp(k)] ;
   R = [1 0 0;0 cr(k) -sr(k);0 sr(k) cr(k)] ;
   H = [ch(k) -sh(k) 0;sh(k) ch(k) 0;0 0 1] ;
   T(:,:,k) = H*P*R ;
end

T = squeeze(T) ;
%below is WRONG b/c both tag 2.2 and tag 3 are RH coords
% %convert from left to right handed coords
% Sz = diag([1 1 -1]);
% T = Sz*T*Sz; 