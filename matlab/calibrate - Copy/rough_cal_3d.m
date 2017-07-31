function    [X,G] = rough_cal_3d(X,fstr)

%    	[X,G] = rough_cal_3d(X,fstr)
%		Estimate scale factors and offsets for measurements from a triaxial
%		field sensor. This function estimates the scale factor needed
%		to make the magnitude of X close to the expected field strength. It
%		then calls fix_offset_3d to correct any offset errors in X. This
%		function does not try to optimize the results. See spherical_cal for
%		a more powerful data-driven calibration method.
%
%		Inputs:
%		X is a sensor structure or matrix containing measurements from a
%		 triaxial field sensor such as an accelerometer or magnetometer.
%		 X can be in any units and frame.
%		fstr is the expected field strength at the measurement location in
%		 the same units as X.
%
%		Returns:
%		X is a sensor structure or matrix containing the adjusted triaxial
%		 sensor measurements. It is the same size and has the same sampling
%		 rate and units as the input data. If the input is a sensor structure,
%		 the output will be also.
%		G is a calibration structure containing one field: G.poly. The first
%		 column of G.poly is the three scale factors applied to the columns of X.
%		 The second column of G.poly is the offset added to each column of X after 
%		 scaling.
%
%		Notes: this function requires a lot of data as it is looking for extreme
%		values in each axis. A minimum data size of 1000 samples should be used.
%		This function is only usable for field sensors. It will not work
%		for gyroscope data.

%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     last modified: 28 July 2017


if nargin<2,
   help rough_cal_3d
	return
end

if isstruct(X),
	x = sens2var(X) ;
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

if size(x,2)~=3,
	fprintf(' rough_cal_3d: input data must be from a 3-axis sensor\n') ;
	return
end
	
pp = max(0.1,1000/size(x,1)) ;
lims = prctile(x,[pp 100-pp]) ;
g=2*fstr./diff(lims);
offs=-mean(lims).*g ;
G.poly = [g' offs'] ;
x = x.*repmat(g,size(x,1),1) + repmat(offs,size(x,1),1) ;
[x,C] = fix_offset_3d(x) ;		% fine-tune the offsets
G.poly(:,2) = G.poly(:,2)+C.poly(:,2) ;
scf = fstr/nanmean(norm2(x)) ;
G.poly = G.poly*scf ;
x = x*scf ;

if ~isstruct(X),
	X = x ;
	return
end
	
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
	X.history = 'rough_cal_3d' ;
else
	X.history = [X.history ',rough_cal_3d'] ;
end
