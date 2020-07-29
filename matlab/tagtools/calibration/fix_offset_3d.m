function    [X,G] = fix_offset_3d(X)
%
%     [X,G] = fix_offset_3d(X)
%     Estimate the offset in each axis of a triaxial field measurement,
%		e.g., from an accelerometer or magnetometer. This is useful for
%		correcting drift or calibration errors in a sensor.
%
%		Inputs:
%		X is a sensor structure or matrix containing measurements from a
%		 triaxial field sensor such as an accelerometer or magnetometer.
%		 X can be in any units and frame.
%
%		Returns:
%		X is a sensor structure or matrix containing the adjusted triaxial
%		 sensor measurements. It is the same size and has the same sampling
%		 rate and units as the input data. If the input is a sensor structure,
%		 the output will be also.
%		G is a calibration structure containing one field: G.poly. The first
%		 column of G.poly contains 1 as this function does not adjust the scale
%		 factor of X. The second column of G.poly is the offset added to each 
%		 column of X.
%
%		Note: this function is only usable for field sensors. It will not work
%		for gyroscope data.
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     last modified: 28 July 2017

G.poly = [ones(3,1) zeros(3,1)] ;
if nargin<1,
   help fix_offset_3d
	return
end

if isstruct(X),
	x = sens2var(X) ;
else
	x = X ;
end

if size(x,2)~=3,
	fprintf(' fix_offset_3d: input data must be from a 3-axis sensor\n') ;
	return
end

k = find(all(~isnan(x),2)) ;
bsq = sum(x(k,:).^2,2) ;
mb = sqrt(mean(bsq)) ;
XX = [2*x(k,:) repmat(mb,length(k),1)];
R = XX'*XX ;			% R is the outer product of XX
if cond(R)>1e3,
	fprintf(' fix_offset_3d: condition too poor to get reliable solution\n') ;
	return
end
	
P = sum(repmat(bsq,1,4).*XX) ;
H = -inv(R)*P' ;
G.poly = [ones(3,1) H(1:3)] ;
x = x+repmat(H(1:3)',size(x,1),1) ;

if ~isstruct(X),
	X = x ;
	return
end
	
X.data = x ;
% check if a map or cross-term have been applied to X - if so, these need to
% be removed from G.poly - the polynomial is always in the sensor frame. This
% is easily done for offsets by multiplying the offset vector by the inverse
% of the transformations.
if isfield(X,'cal_map'),
	G.poly(:,2) = inv(reshape(X.cal_map,3,3))'*G.poly(:,2) ;
end
if isfield(X,'cal_cross'),
	G.poly(:,2) = inv(reshape(X.cal_cross,3,3))'*G.poly(:,2) ;
end
X.cal_poly = G.poly ;

if ~isfield(X,'history') || isempty(X.history),
	X.history = 'fix_offset_3d' ;
else
	X.history = [X.history ',fix_offset_3d'] ;
end
return
