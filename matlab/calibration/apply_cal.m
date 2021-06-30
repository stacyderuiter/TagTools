function    X = apply_cal(X,C,T,nomap)

%     X = apply_cal(X,cal)
%		or
%     X = apply_cal(X,cal,T)
%		or
%     X = apply_cal(X,cal,T,nomap)
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
%	   nomap is an optional argument that is used to disable
%		 axis mapping for vector sensors. Mapping is disabled
%		 if nomap=1, otherwise mapping will be performed if
%		 the cal structure contains a map field.
%
%		Returns:
%		X is a sensor structure with calibration implemented.
%		 Data size and sampling rate is the same as for the
%		 input data but units may have changed.
%
%     Cal fields currently supported are:
%     poly, cross, map, tcomp, tref
%		Any other fields in cal will be ignored.
%
%		Example:
%		cats = load_nc(cats_test_raw);
%   catsSpher = spherical_cal(cats.A.data);
%   cats.ACal = apply_cal(cats.A, catsSpher);
%   % Might not totally work, but pretty close
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     Last modified: June 2021
%     - cal fields can be in upper or lower case
%		- added comments and nomap support
%     - fixed errors in temperature compensation
%     - added example

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

if nargin<4,
   nomap = 0 ;
end

if isstruct(X),
   x = sens2var(X) ;
   if isempty(x), return, end
else
   x = X ;
end

% 1. find and apply the calibration polynomial
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

% 2. find and apply temperature compensation
p = [] ;
if isfield(C,'tcomp'),
	p = C.tcomp ;
elseif isfield(C,'TCOMP'),
	p = C.TCOMP ;
end

if ~isempty(p) && ~isempty(T),
   if isfield(C,'tref'),
		tref = C.tref ;
   elseif isfield(C,'TREF'),
		tref = C.TREF ;
	else
      tref = 20 ;
   end
   t = sens2var(T) ;
   if size(t,1)==size(x,1),
      % TODO interp t to match X
      if length(p)==size(x,2),
         x = x + (t-tref)*p(:)' ;
      elseif size(x,2)==1,
		x = x + polyval([p(:)' 0],t-tref) ;
      end
      if isstruct(X),
         X.cal_tcomp = p ;
         X.cal_tref = tref ;
      end
   end
end

% 3. find and apply any cross-axis corrections - only for vector sensors
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

% 4. find and apply an axis conversion map - only for vector sensors
if nomap==0,
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
         if isfield(C,'axes'),
            X.axes = C.axes ;
         end
		end
	end
end

if ~isstruct(X),
   X = x ;
   return
end

X.data = x ;
X.frame = 'tag' ;

if isfield(C,'unit'),
	X.unit = C.unit ;
end
if isfield(C,'unit_name'),
	X.unit_name = C.unit_name ;
end
if isfield(C,'unit_label'),
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
