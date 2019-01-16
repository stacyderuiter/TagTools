function    X = apply_cal(X,C,T)

%     X = apply_cal(X,cal)
%		or
%     X = apply_cal(X,cal,T)
%
%		Implement a calibration on sensor data.
%
%		Inputs:
%		X is a sensor structure or a matrix or vector. 
%		cal is a calibration structure for the data in X.
%      For example, this could come from spherical_cal.
%		T is a sensor structure or vector of temperature
%		 measurements for use in temperature compensation.
%		 If T is not a sensor structure, it must be the
%		 same size and sampling rate as the data in X. T
%      is only required if there is a tcomp field in the
%      cal structure.
%
%		Returns:
%		X is a sensor structure with calibration implemented.
%		 Data size and sampling rate is the same as for the
%		 input data but units may have changed.
%
%     Cal fields currently supported are:
%     poly, cross, map, tcomp, tref
%
%		Example:
%		 TBD
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     Last modified: January 2018
%     - cal fields can be in upper or lower case

if nargin<2,
   help apply_cal
   return
end

if ~isstruct(C),
   fprintf(' Calibration information must be in a cal structure\n') ;
   return
end

if nargin<3,
   T = [] ;
end

if isstruct(X),
   x = sens2var(X) ;
   if isempty(x), return, end
else
   x = X ;
end

p = [] ;
if isfield(C,'poly'),
	p = C.poly ;
elseif isfield(C,'POLY'),
	p = C.POLY ;
end

if ~isempty(p),
   if size(p,1)~=size(x,2),
      fprintf(' Calibration polynomial must have %d rows to match this data\n',size(x,2)) ;
      return
   end
   x = x.*repmat(p(:,1)',size(x,1),1) + repmat(p(:,2)',size(x,1),1);
   if isstruct(X),
   	X.cal_poly = p ;
   end
end

p = [] ;
if isfield(C,'tcomp'),
	p = C.tcomp ;
elseif isfield(C,'TCOMP'),
	p = C.TCOMP ;
end

if ~isempty(p) && ~isempty(T) && size(T,1)==size(x,1),
	% TODO interp T to match X
   if isfield(C,'tref'),
		tref = C.tref ;
   elseif isfield(C,'TREF'),
		tref = C.TREF ;
	else
      tref = 20 ;
   end
	if length(p)==size(x,2),
		x = x + (T-tref)*p(:)' ;
	elseif size(X.data,2)==1,
		x = x + polyval([p(:)' 0],T) ;
	end
   if isstruct(X),
      X.cal_tcomp = p ;
      X.cal_tref = tref ;
   end
end

p = [] ;
if isfield(C,'cross'),
	p = C.cross ;
elseif isfield(C,'CROSS'),
	p = C.CROSS ;
end

if ~isempty(p),
   x = x * p ;
   if isstruct(X),
      X.cal_cross = p ;
   end
end

p = [] ;
if isfield(C,'map'),
	p = C.map ;
elseif isfield(C,'MAP'),
	p = C.MAP ;
end

if ~isempty(p),
	x = x * p ;
   if isstruct(X),
      X.cal_map = p ;
   end
end

if ~isstruct(X),
   X = x ;
   return
end

X.data = x ;
X.frame = 'tag' ;

if isfield(C,'unit'),
	X.source_unit = X.unit ;
	X.source_unit_name = X.unit_name ;
	X.source_unit_label = X.unit_label ;
	X.unit = C.unit ;
	X.unit_name = C.unit_name ;
	X.unit_label = C.unit_label ;
end

if isfield(C,'name'),
	X.cal_name = C.name ;
end

if ~isfield(X,'history') || isempty(X.history),
	X.history = 'apply_cal' ;
else
	X.history = [X.history ',apply_cal'] ;
end
return
