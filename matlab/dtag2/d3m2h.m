function     [h,v,incl] = d3m2h(M,p,r)
%
%     [h,v,incl] = d3m2h(M,pitch,roll)
%
%     Compute heading, field intensity and inclination angle by gimballing 
%     the magnetic field measurement matrix with the pitch and roll signals.
%     M is the magnetometer signal matrix, M=[mx,my,mz] in uT (microtesla). 
%        M can be in tag or whale frame.
%     pitch is the pitch estimate in radians in the same frame as M. 
%     roll is the roll estimate in radians in the same frame as M.
%     M, p and r must all have the same number of rows. Use a2pr.m to
%     generate pitch and roll.
%
%     h is the heading in radians in the same frame as M. The heading is 
%        with respect to magnetic north and so must be corrected for declination.
%     v is the field intensity estimate in uT.
%     incl is the field inclination angle in radians.
%
%     Output sampling rate is the same as the input sampling rate.
%
%     mark johnson, WHOI
%     majohnson@whoi.edu
%     Last modified: 25 November 2005
%     Stacy DeRuiter - Jan 2013 - tried to edit for use with d3 data in d3
%     mag coordinates
if nargin<3,
   help d3m2h
   return
end

if size(M,1)*size(M,2)==3,
   M = M(:)' ;
end

if size(M,1)~=size(p,1) || size(M,1)~=size(r,1),
   fprintf('d3m2h: M, p and r must have same number of rows\n') ;
   return
end

for k=1:size(M,1),
   T = d3makeT(p(k),r(k),0) ;   % transformation to horizontal frame
   M(k,:) = M(k,:)*T' ;       % gimbal each M vector
end
   
% heading estimate in right-hand system
h = atan2(M(:,2),M(:,1)) ;

% compute mag field intensity and inclination
v = sqrt(M.^2*[1;1;1]) ;         % compute magnetic field intensity
incl = real(asin(M(:,3)./v)) ;  % compute inclination
