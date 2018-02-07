function    [X,G] = fix_3d(X,T,fs,fstr,prct)

%     [X,G] = fix_3d(X,T,fstr)			% X and T are sensor structures
%		or
%     [X,G] = fix_3d(X,T,fstr,prct)		% X and T are sensor structures
%		or
%     [X,G] = fix_3d(X,T,fs,fstr)		% X and T are matrices/vectors
%		or
%     [X,G] = fix_3d(X,T,fs,fstr,prct)	% X and T are matrices/vectors
%
%		Estimate scale factors and offsets for measurements from a triaxial
%		field sensor. This function uses an iterative approximate least-squares
%		method to estimate the scale factors, temperature sensitivity and
%		offsets needed to make the magnitude of X close to the expected field 
%		strength. This function removes data that are changing rapidly as these
%		can have greater errors (e.g., due to specific acceleration). The function
%		also tries to balance the data so that a roughly equal number of measurements
%		from a wide range of orientations are processed. See spherical_cal for
%		a more powerful data-driven calibration method for short data sets.
%
%     Inputs:
%		X is a sensor structure or matrix containing measurements from a
%		 triaxial field sensor such as an accelerometer or magnetometer.
%		 X can be in any units and frame.
%     T is a sensor structure or vector of temperature in degrees Celsius.
%		 T must be at the same sampling rate as X. Put [] in this field if
%		 temperature compensation is not required.
%     fs is the sampling rate of the sensor data in Hz (samples per second).
%		 This is only needed if X is not a sensor structure. X and T 
%      must both have the same sampling rate (use decdc.m or resample.m 
%		 if needed to achieve this).
%		fstr is the expected field strength at the measurement location in
%		 the same units as X.
%     prct is the percentage of low jerk points to be kept. Default value 
%      is 2% but a larger value may be needed if A is small.
%
%     Results:
%		X is a sensor structure or matrix containing the adjusted triaxial
%		 sensor measurements. It is the same size and has the same sampling
%		 rate and units as the input data. If the input is a sensor structure,
%		 the output will be also.
%		G is a calibration structure containing the offset, gain, and temperature
%		 sensitivities deduced by the function.
%		G.poly is a matrix of polynomials. The first column of G.poly is the 
%		 three scale factors applied to the columns of X. The second column 
%		 is the offset added to each column of X after scaling.
%		G.tcomp is the temperature compensation polynomial for each axis.
%		G.tref is the reference temperature which is always 20 degrees Celsius.
%
%		Note: this function is only usable for field sensors. It will not work
%		for gyroscope data.
%
%		Example:
%		 load...
%		 [AA,cal] = fix_3d(A,fs);
% 	    returns: .
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     Last modified: 30 July 2017

NF = 11 ;			% filter length
cal = [] ;
if nargin<2,
   help fix_3d
   return
end

if isstruct(X),
	if ~isempty(T),
		[x,T,fs] = sens2var(X,T,'regular') ;
	else
		[x,fs] = sens2var(X,'regular') ;
	end
	if isempty(x),
		return
	end
		
	% have to undo any matrix operations on x before applying scale and offset changes
	if isfield(X,'cal_map'),
		x = x*inv(X.cal_map) ;
	end
	if isfield(X,'cal_cross'),
		x = x*inv(X.cal_cross) ;
	end
else
	x = X ;
end

if nargin<3 || isempty(prct),
   prct = 2 ;       % 2% default
end

if fs>5,
   df = round(fs/5) ;
   x = decdc(x,df) ;   % decimate data to around 5Hz
	if ~isempty(T),
		T = decdc(T,df) ;   % decimate data to around 5Hz
	end
   fs = fs/df ;
end

nf = 11 ;
jj = conv(ones(nf,1)/nf,njerk(Ad,fsd));
jj = jj(floor(nf/2)+(1:size(Ad,1)));
jthr = prctile(jj,prct) ;
k = find(jj<jthr);
Ab = balance_3d(Ad(k,:)) ;		% this function is in the same file
G = minvar(Ab(k,:),T(k));		% this function is in the same file

if ~isstruct(X),
	X = applycal(X,G) ;
	return
end
	
x = applycal(X.data,G) ;
X.cal_poly = G.poly ;
% redo any matrix operations on x after applying scale and offset changes
if isfield(X,'cal_map'),
	x = x*X.cal_map ;
end
if isfield(X,'cal_cross'),
	x = x*X.cal_cross ;
end
X.data = x ;

if ~isfield(X,'history') || isempty(X.history),
	X.history = 'fix_3d' ;
else
	X.history = [X.history ',fix_3d'] ;
end
return


function    A = balance3d(A)
%     Reduce the number of similar vector measurements in a triaxial
%     measurement matrix
CMAX = 3 ;     % target condition number
NMAX = 10 ;    % maximum number of loops
k = find(~any(isnan(A),2)) ;
A = A(k,:);
nA = mean(norm2(A)) ;

for klp=1:NMAX,
   R = A'*A ;      % form outer product of matrix
	cond(R)
   if cond(R)<CMAX, break, end
   [V,D] = eig(R) ;
   [m,k] = max(diag(D)) ;
   Av = abs(A*V(:,k)) ;
   ko = find(Av<0.7071*nA) ;
   ki = find(Av>=0.7071*nA) ;
   kg = randperm(length(ki),round(0.75*length(ki))) ;
   k = sort([ko;ki(kg)]) ;
   A = A(k,:);
   R = A'*A ;      % form outer product of matrix
end
return


function   g = minvar(v,t)
%   Minimize the variance of the squared 2-norm of triaxial measurements v=[x,y,z],
%   i.e., cov(x.^2+y.^2+z.^2), by fitting a d.c. offset and a temperature vector 
%	 to each axis.
%   A locally-linearized least-squares method is used in which the adjustments
%   are assumed small so that
%           e = (x+gt).^2+y.^2+z.^2
%   where g is the free variable, is approximated by:
%           e ~ x.^2+y.^2+z.^2+2gx.*t
%   which is linear in g.
%   To make the solution tractable, the covariance of the 2-norm-squared is minimized 
%	 rather than the 2-norm per se. This serves to emphasise outliers. Filter and 
%	 decimate the input vectors to ameliorate this.

g = [] ;
wm = sum(v.^2,2) ;
w = wm - repmat(mean(wm),size(wm,1),1) ;	% remove means
if ~isempty(t),
   v(:,4:6) = v.*repmat(t,1,3) ;
end
v = v - repmat(mean(v),size(v,1),1) ;		% remove means
P = w'*v ;											% form least-squares solution
R = v'*v ;
rr = rcond(R) ;
if ~isnan(rr) && (rr>1e-5),	% don't solve if the condition is poor
	g = -0.5*inv(R)*P' ;
end
return
