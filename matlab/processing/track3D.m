function track = track3D(z,phi,psi,sf,r,q1p,q2p,q3p,tagonx,tagony,enforce,x,y)
% Reconstruct a track from pitch, heading and depth data, given a stating position
% 
% This function will use data from a tag to reconstruct a track by fitting
%   a state space model using a Kalman filter. If no x,y observations 
%   are provided then this corresponds to a pseudo-track obtained via dead 
%   reckoning and extreme care is required in interpreting the results.
%
% Inputs:
%   z is a vector with depth over time (in meters, an observation)
%   phi is a vector with pitch over time (in Radians, assumed as a know
%       covariate)
%   psi is a vector with heading in radians
%   sf is a scalar defining the sampling rate (in Hz)
%   r is the observation error. The default is 0.001
%   q1p is the speed state error. The default is 0.02
%   q2p is the depth state error. The default is 0.08
%   q3p is the x and y state error. The default is 1.6e-05
%   tagonx is the Easting of starting position (in meters, so requires projected data)
%   tagony is the Northing of starting position (in meters, so requires
%       projected data)
%   enforce is a logical statement. If true, then speed and depth are kept
%       strictly positive
%   x is the direct observations of Easting (in meters, so requires projected data)
%   y is the observations of Northing (in meters, so requires projected data)
%
% Output:
%   A structure containing the following:
%       p is the smoothed speeds
%       fit.ks is the fitted speeds
%       fit.kd is the fitted depths
%       fit.xs is the fitted xs
%       fit.ys is the fitted ys
%       fit.rd is the smoothed depths
%       fit.rx is the smoothed xs
%       fit.ry is the smoothed ys
%       fit.kp is the kalman a posteriori state covariance
%       fit.ksmo is the kalman smoother variance
%
%   Output sampling rate is the same as the input sampling rate.
%   Frame: This function assumes a [north,east,up] navigation frame and a 
%       [forward,right,up] local frame. In these frames, a positive pitch 
%       angle is an anti-clockwise rotation around the y-axis. A positive 
%       roll angle is a clockwise rotation around the x-axis. A descending 
%       animal will have a negative pitch angle while an animal rolled with 
%       its right side up will have a positive roll angle.
%   This function output can be quite sensitive to the inputs used, namely 
%       those that define the relative weight given to the existing data, 
%       in particular regarding (x,y)=(lat,long); increasing q3p, the (x,y)
%       state variance, will increase the weight given to independent 
%       observations of (x,y), say from GPS readings 

%The underlying state space model being fitted to the data is described in
  % "Estimating speed using the Kalman filter... and beyond", equations 5 and 6
  % a LATTE internal report available from TAM

%inputs:
 %   z (was p in MJ code) is a vector of depths
 %   phi (was pitch in MJ code) is a vector of pitchs
 %   psi is a vector of headings
 %   sf (was fs in MJ code) is the sampling frequency, in Hz
 %   r observation error (in depth)
 %   q1p state error (in speed)
 %   q2p state error (in depth)
 %   q3p state error (in x and y)
 % tagonx,tagony is the location, in x,y, where the DTag started recording
 %   enforce   if TRUE (the default) the speed and depth estimates are kept strictly non negative
 %             note this is intuitively nice, but makes this no longer a proper KF

if isempty(r)
    r = .001;
end

if isempty(q1p)
    q1p = .02;
end

if isempty(q2p)
    q2p = .08;
end

if isempty(q3p)
    q3p = 1.6e-05;
end

if isempty(enforce)
    enforce = true;
end
    
%number of times each observation was observed
n = length(z);
%defining some required quantities
%note currently these are constants
%measument error in depth
r1 = r;
r2 = [0.001,0,0;0,5,0;0,0,5];
%tate error in speed
q1 = (q1p/sf).^2;
%state error in depth
q2 = (q2p/sf).^2;
%state error in x
%q3 = (q1p/sf)^2
q3 = q3p;
%state error in y
%q3 = (q1p/sf)^2
%sampling period
SP = 1/sf;
%state transition matrix entry (2,1) - see equation 7
Gt_2_1 = -sin(phi)/sf;
%state transition matrix entry (3,1) - see equation 7
Gt_3_1 = (cos(phi).*sin(psi))./sf;
%state transition matrix entry (4,1) - see equation 7
Gt_4_1 = (cos(phi).*cos(psi))./sf;
%initial states, pitch = 1, and depth = initial observed depth
%TAM?: why start pitch at 1? why the different "conceptual" choice
% for pitch and depth?
shatm = [1, z(1), tagonx, tagony]';
% state noise matrix
Q = [q1,0,0,0;0,q2,0,0;0,0,q3,0;0,0,0,q3];
%observation matrix (a vector here)
H1 = [0,1,0,0];
H2 = [0,1,0,0;0,0,1,0;0,0,0,1];
% initial state covariance matrix
% says how much we trust initial values of s and p?
Pm = [0.01,0,0,0;0,r,0,0;0,0,0.01,0;0,0,0,0.01];
% place to store state predictions
skal = zeros(4, n);
% object for storing the kalman a posteriori state covariance (2 x 2 x n)
for k = 1:length(n)
    Ps(:,:,n) = zeros(4,4);
end
% note all other variance-covariance matrices have th same stucture/dimensions
% Pms is the a priori state variance-covariance matrix
Pms = Ps;
% Psmo is the smoothing variance-covariance matrix
Psmo = Ps;
%implementing the kalman Filter
for i = 1:n
    % make state transition matrix
    Ak = [1,0,0,0;Gt_2_1(i),1,0,0;Gt_3_1(i),0,1,0;Gt_4_1(i),0,0,1];
    %after the initial state only
    %(hence this bit is ONLY not evaluated for the inital state)
    if i > 1
      % update a priori state cov
      Pm = Ak*P*Ak' + Q;
      %a priori state estimate
      shatm = Ak*shat;
    end
    % compute kalman gain
    if isnan(x(i))
      H = H1;
      r = r1;
    else
        H = H2;
        r = r2;
    end
    K = (Pm*H')/(H*Pm*H'+r);
    % a posteriori state estimates
    if isnan(x(i))
      shat = shatm + K*(z(i)-H*shatm);
    else
      shat = shatm + K*([z(i);x(i);y(i)]-H*shatm);
    end
    % forcing speed and depth always to be positive
    %TAM?: must be a smarter way to do this ????
    if enforce == true
        if shat(1:2) < 0
            shat(1:2) = 0;
        else
            shat(1:2) = shat(1:2);
        end
    end
    % a posteriori state cov
    d = [1,1,1,1];
    P = (diag(d)-K*H)*Pm ;
    %store results of iteration
    skal(:,i) = shat;
    Pms(:,:,i) = Pm;
    Ps(:,:,i) = P;
end

%object to hold the states smoothed by the Rauch smoother
srau = zeros(4,n);
%note that for the last point
%no smoothing possible, it's the point itself
srau(:,n) = shat;
% and the same for the variance-covariance
% which is the same as that of the filtering
% as per wording just after equation 8.85 in Gannot & Yeredor 2008
Psmo(:,:,n)  = Ps(:,:,n);
% Kalman/Rauch smoother
% so now we are moving backwards
for i = n:2
  % make state transition matrix
  Ak = [1,0,0,0;Gt_2_1(i-1),1,0,0;Gt_3_1(i-1),0,1,0;Gt_4_1(i-1),0,0,1];
  % smoother gain - equation 8.69 in Gannot & Yeredor 2008
  K = Ps(:,:,(i-1)).*Ak'.*inv(Pms(:,:,i));
  % smooth state - (supposedly) equation 8.68 in Gannot & Yeredor 2008
  srau(:,(i-1)) = skal(:,(i-1))+K.*(srau(:,i)-Ak.*skal(:,(i-1)));
  %smoother variance - equation 8.85 in Gannot & Yeredor 2008
  Psmo(:,:,(i-1)) = Ps(:,:,(i-1))-K.*(Pms(:,:,i)-Psmo(:,:,i)).*K';
end

value1 = srau(1,:);
value2 = skal(1,:);
value3 = skal(2,:);
value4 = skal(3,:);
value5 = skal(4,:);
value6 = srau(2,:);
value7 = srau(3,:);
value8 = srau(4,:);
value9 = Ps;
value10 = Psmo;

%make structure output
field1 = 'speeds';  value1 = value1;
field2 = 'fit_ks';  value2 = value2;
field3 = 'fit_kd';  value3 = value3;
field4 = 'fit_kx';  value4 = value4;
field5 = 'fit_ky';  value5 = value5;
field6 = 'fit_rd';  value6 = value6;
field7 = 'fit_rx';  value7 = value7;
field8 = 'fit_ry';  value8 = value8;
field9 = 'fit_kp';  value9 = Ps;
field10 = 'fit_ksmo'; value10 = Psmo;

track = struct(field1,value1,field2,value2,field3,value3,field4,value4,...
    field5,value5,field6,value6,field7,value7,field8,value8,field9,value9,field10,value10);

end