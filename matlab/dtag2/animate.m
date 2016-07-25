function   animate(pitch,roll,head,v,fn)
%
%      animate(pitch,roll,head,[v,[fn]])
%      Animate a pitch-roll-heading record with an approximate
%      frame rate of 100 fps.
%      pitch, roll, and head are in radians.
%      v is an optional viewpoint in degrees [az el]. Default
%      view is [0 90], i.e., from straight above with north to the
%      top of the page.
%      If a 5th argument is given, it will be used as a filename
%		 prefix and a bit map file will be generated for each frame.
%		 The files will be given sequential number suffixes.
%
%      This function requires the whale model function physeter.m to
%      generate the basic shape.
%
%      mark johnson, WHOI
%      majohnson@whoi.edu
%      September 2001
%

if nargin < 4
   v = [0 90] ;
end

% make whale model

[x y z] = physeter ;
x = -x+0.4 ;
[m n] = size(x) ;
XYZ = [x(:) y(:) z(:)]' ;

% initialize figure

figure(1)
clf

h1 = surf(x,y,z,z) ;
axis_vec = 0.5*[-1 1 -1 1 -1 1];
axis(axis_vec) ;
axis('off')
axis('square')
cc = jet ;
cc = cc/max(max(cc)) ;
colormap(cc) ;
brighten(0.5) ;
l = light ;
material metal
lighting gouraud
view(v) ;
shading interp
lightangle(0,90) ;

% iterate through pitch-roll-heading to animate

for kk=1:length(pitch),
   hh = head(kk)-pi/2 ;
   rr = -roll(kk) ;
   pp = -pitch(kk) ;
 
   % make rotation matrices
   H = [cos(hh) sin(hh) 0;-sin(hh) cos(hh) 0;0 0 1] ;
   R = [1 0 0;0 cos(rr) sin(rr);0 -sin(rr) cos(rr)] ;
   P = [cos(pp) 0 sin(pp);0 1 0;-sin(pp) 0 cos(pp)] ;
   
   % apply rotations to basic shape
   xyz = H*P*R*XYZ ;
   x = reshape(xyz(1,:),m,n) ;
   y = reshape(xyz(2,:),m,n) ;
   z = reshape(xyz(3,:),m,n) ;
   
   % change orientation of shape
   set(h1,'xdata',x,'ydata',y,'zdata',z);
   
   pause(0.01);
   if nargin==5,
      fprintf(' %d of %d\n',kk,length(pitch)) ;
      print('-dbmp16m',sprintf('%s%03d',fn,kk)) ; 
   end
   
end
