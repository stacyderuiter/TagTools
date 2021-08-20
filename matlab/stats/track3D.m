
function [track] = track3D(z,phi,psi,sf,r,q1p,q2p,q3p,tagonx,tagony,enforce,x,y)
% Reconstruct a track from pitch, heading and depth data, given a starting position
%
% This function will use data from a tag to reconstruct a track 
% by fitting a state space model using a Kalman filter. 
% If no x,y observations are provided then this corresponds 
% to a *pseudo-track* obtained via dead reckoning,
% and *extreme care* is required in interpreting the results.
% 
% Inputs:
% z         A vector with depth over time (in meters, an observation)
% phi       A vector with pitch over time (in Radians, assumed as a known covariate)
% psi       A vector with heading over time (in Radians, assumed as a known covariate)
% sf        A scalar defining the sampling rate (in Hz)
% r         (optional; defaults to 0.001) Observation error
% q1p       (optional; defaults to 0.02) speed state error
% q2p       (optional; defaults to 0.08) depth state error
% q3p       (optional; defaults to 1.6e-05) x and y state error
% tagonx    Easting of starting position (in meters, so requires projected data)
% tagony    Northing of starting position (in meters, so requires projected data)
% enforce   (optional; defaults to 1) Logical. If 1, then speed and depth are kept strictly positive
% x         Direct observations of Easting (in meters, so requires projected data)
% y         Direct observations of Northing (in meters, so requires projected data)
% 
% See also: m2h, a2pr
%
% Output:
% A structure with 10 elements:
% p: the smoothed speeds
% ks: the fitted speeds
% kd: the fitted depths
% xs: the fitted xs
% ys: the fitted ys
% rd: the smoothed depths
% rx: the smoothed xs
% ry: the smoothed ys
% kp: the kalman a posteriori state covariance
% ksmo: the kalman smoother variance
% 
% NOTES:
% Output sampling rate is the same as the input sampling rate.
% Frame: This function assumes a [north,east,up] navigation frame and a [forward,right,up] local frame. In these frames, a positive pitch angle is an anti-clockwise rotation around the y-axis. A positive roll angle is a clockwise rotation around the x-axis. A descending animal will have a negative pitch angle while an animal rolled with its right side up will have a positive roll angle.
% This function output can be quite sensitive to the inputs used, namely those that define the relative weight given to the existing data, in particular regarding (x,y)=(lat,long); increasing q3p, the (x,y) state variance, will increase the weight given to independent observations of (x,y), say from GPS readings 
% 
% Examples
% load_nc('testset1.nc')
% p = a2pr(A); 
% h = m2h(M,A); 
% track=track3D(P.data,p,h,A.sampling_rate,0.001,0.02,0.08,1.6e-05,...
%   1000,1000,1,[],[]);
% subplot(2,1,1)
% plot(P.data); ylabel('Depth (m)'); xlabel('Time'); axis ij;
% subplot(2,1,2)
% plot(track.rx,track.ry, 'k-'); xlabel('X'); ylabel('Y');
% 
%Tiago Marques, matlab translation by Stacy DeRuiter


  % The underlying state space model being fitted to the data is described in
  % "Estimating speed using the Kalman filter... and beyond", equations 5 and 6
  % a LATTE internal report available from TAM
 %--------------------------------------------------------------------------
% track3D(z,phi,psi,sf,r=0.001,q1p=0.02,q2p=0.08,q3p=1.6e-05,tagonx,tagony,enforce=T,x,y)
if nargin < 5 || isempty(r)
    r = 0.001;
end
if nargin < 6 || isempty(q1p)
    q1p = 0.02;
end
if nargin < 7 || isempty(q2p)
    q2p = 0.08;
end
if nargin < 8 || isempty(q3p)
    q3p = 1.6e-05;
end
if nargin < 11 || isempty(enforce)
    enforce=1;
end
if nargin < 12 || isempty(x)
    x = NaN*ones(1,length(z));
end
if nargin < 13 || isempty(y)
    y = NaN*ones(1,length(z));
end

  % number of times each observation was observed
  n=length(z);
  % defining some required quantities
  % note currently these are constants
  % measument error in depth
  r1 = r;
  r2= [0.001,0,0; 0,5,0; 0,0,5];
  % state error in speed
  q1 = (q1p/sf).^2;
  % state error in depth
  q2 = (q2p/sf).^2;
  % state error in x
  % q3 = (q1p/sf)^2
  q3=q3p;
  % state error in y
  % q3 = (q1p/sf)^2
  % sampling period
  SP = 1./sf;
  % state transition matrix entry (2,1) - see equation 7
  Gt_2_1 = -sin(phi)./sf;
  % state transition matrix entry (3,1) - see equation 7
  Gt_3_1 = (cos(phi).*sin(psi))./sf;
  % state transition matrix entry (4,1) - see equation 7
  Gt_4_1 = (cos(phi).*cos(psi))./sf;
  % initial states, pitch = 1, and depth = initial observed depth
  % TAM?: why start pitch at 1? why the different "conceptual" choice
  % for pitch and depth?
  shatm = [1;z(1);tagonx;tagony];
  % state noise matrix
  Q = [q1,0,0,0; 0,q2,0,0; 0,0,q3,0; 0,0,0,q3];
  % observation matrix (a vector here)
  H1 = [0,1,0,0];
  H2 = [0,1,0,0; 0,0,1,0; 0,0,0,1];
  % initial state covariance matrix
  % says how much we trust initial values of s and p?
  Pm = [0.01,0,0,0; 0,r,0,0; 0,0,0.01,0; 0,0,0,0.01];
  % place to store state predictions
  skal = zeros(4,n); 
  % object for storing the kalman a posteriori state covariance (2x2xn)
  Ps = zeros(4,4,n); 
  % note all other variance-covariance matrices have th same stucture/dimensions
  % Pms is the a priori state variance-covariance matrix
  Pms=Ps;
  % Psmo is the smoothing variance-covariance matrix
  Psmo=Ps;
  % implementing the kalman Filter
  for i=1:n
      % make state transition matrix
      Ak = [1,0,0,0; Gt_2_1(i),1,0,0; Gt_3_1(i),0,1,0; Gt_4_1(i),0,0,1];
    % after the initial state only
    % (hence this bit is ONLY not evaluated for the inital state)
    if i>1
      % update a priori state cov
      Pm = Ak*P*Ak' + Q ;
      % a priori state estimate
      shatm = Ak*shat;
    end %end of if i>1
    % compute kalman gain
    if isnan(x(i))
      H=H1;
      r=r1;
    else
      H=H2;
      r=r2;
    end %end of if isnan(x(i))
    
    K = Pm*H'* inv(H*Pm*H'+r);
    % a posteriori state estimates
    if isnan(x(i)) 
      shat = shatm + K*(z(i)- H*shatm);
    else
      shat = shatm + K*([z(i);x(i);y(i)] - H*shatm);
    end
    % forcing speed and depth always to be positive
    % TAM?: must be a smarter way to do this ????
    if enforce==1 
        if shat(1:2) < 0
            shat(1:2) = 0;
        end
    end
    % a posteriori state cov
    P = (eye(4) - K*H)*Pm ;
    % store results of iteration
    skal(:,i) = shat;
    Pms(:,:,i) = Pm;
    Ps(:,:,i) = P;
  end %end iteration (for i=1:n)
  
  % object to hold the states smoothed by the Rauch smoother
  srau = zeros(4,n); 
  % note that for the last point
  % no smoothing possible, it's the point itself
  srau(:,n) = shat;
  % and the same for the variance-covariance
  % which is the same as that of the filtering
  % as per wording just after equation 8.85 in Gannot & Yeredor 2008
  Psmo(:,:,n) = Ps(:,:,n);
  
  % Kalman/Rauch smoother
  % so now we are moving backwards
  for i= fliplr(2:n)
    % make state transition matrix
    Ak = [1,0,0,0; Gt_2_1(i-1),1,0,0; Gt_3_1(i-1),0,1,0; Gt_4_1(i-1),0,0,1];
    % smoother gain - equation 8.69 in Gannot & Yeredor 2008
    K = Ps(:,:,i-1)*Ak'/Pms(:,:,i); %Ps(:,:,i-1)*Ak'*inv(Pms(:,:,i));
    % smooth state - (supposedly) equation 8.68 in Gannot & Yeredor 2008
    srau(:,i-1) = skal(:,i-1) + K*(srau(:,i) - Ak*skal(:,i-1));
    % smoother variance - equation 8.85 in Gannot & Yeredor 2008
    Psmo(:,:,i-1) = Ps(:,:,i-1) - K*(Pms(:,:,i) - Psmo(:,:,i))*K' ;
  end %end of backward loop
% return required outputs
 track.speeds = srau(1,:);
 track.ks = skal(1,:);
 track.kd = skal(2,:);
 track.kx = skal(3,:);
 track.ky = skal(4,:);
 track.rd = srau(2,:);
 track.rx = srau(3,:);
 track.ry = srau(4,:);
 track.kp = Ps;
 track.ksmo=Psmo;
end