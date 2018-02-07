function    X = undo_cal(X,T)

%     X = apply_cal(X)
%		or
%     X = apply_cal(X,T)
%		Undo any calibration steps that have been applied to sensor 
%		data. This will reverse any re-mapping, scaling and offset
%		adjustments that have been applied to the data, reverting
%		the sensor data to the state it was when read in from the
%		source (excluding any filtering or decimation steps).
%
%		Inputs:
%		X is a sensor structure or set of sensor structures in the
%		 'tag frame', i.e., with calibrations applied.
%
%		Returns:
%		X is a sensor structure reverted to the 'sensor frame',
%		 i.e., without calibrations.
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     last modified: 28 July 2017


if nargin<1,
	help undo_cal
	return
end
	
if ~isstruct(X),
	fprintf(' Input to undo_cal must be a sensor structure\n') ;
	return
end

if isfield(X,'info'),		% X is a set of sensor structures
	f = fieldnames(X) ;
	for k=1:length(f),
		if strcmpi(f{k},'info'), continue, end
		X.(f{k}) = undo_cal1(X.(f{k}),T) ;
	end
else
	X = undo_cal1(X,T) ;
end
return


function		X = undo_cal1(X,T)
%
%	
if isfield(X,'cal_map'),
	X.data = X.data * inv(X.map) ;
	X.cal_map = eye(size(X.data,2)) ;
end

if isfield(X,'cal_cross'),
	X.data = X.data * inv(X.cross) ;
	X.cal_cross = eye(size(X.data,2)) ;
end

if ~isempty(T) && isfield(X,'cal_tcomp') && size(T,1)==size(X.data,1),
   if ~isfield(X,'cal_tref'),
      tref = 0 ;
	else
		tref = X.cal_tref ;
   end
   X.data = X.data - (T-tref)*C.tcomp ;
	X.cal_tcomp = zeros(1,size(X,2)) ;
end

if isfield(X,'cal_poly'),
	p = X.cal_poly ;
	X.data = (X.data - repmat(p(:,2)',size(X.data,1),1)).*repmat(1./p(:,1)',size(X.data,1),1) ;
	X.cal_poly = repmat([1 0],size(X.data,2),1) ;
end

if isfield(X,'source_unit'),
	X.unit = X.source_unit ;
	X.unit_name = X.source_unit_name ;
	X.unit_label = X.source_unit_label ;
end

X.frame = 'raw' ;

if ~isfield(X,'history') || isempty(X.history),
	X.history = 'undo_cal' ;
else
	X.history = [X.history ',undo_cal'] ;
end
return
