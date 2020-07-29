function    X = do_cal(X,varargin)

%     X = do_cal(X,cal)				% X is a sensor structure
%		or
%     X = do_cal(X,cal,...)		% X is a sensor structure
%		or
%     X = do_cal(X,fs,cal)			% X is a matrix or vector
%		or
%     X = do_cal(X,fs,cal,...)	% X is a matrix or vector
%
%		Implement a calibration on sensor data.
%
%		Inputs:
%		X is a sensor structure or a matrix or vector.
%		fs is the sampling rate of X. This is only required if X
%		 is not a sensor structure.
%		cal is a calibration structure for the data in X.
%      For example, this could come from spherical_cal.
%		Additional named inputs (these can come in any order):
%		'T' is a sensor structure or vector of temperature
%		  measurements for use in temperature compensation. This
%		  must be followed by a vector or sensor structure e.g.,
%			X = do_cal(X,fs,cal,'T',T);
%		  If T is not a sensor structure, it must be the
%		  same size and sampling rate as the data in X. Temperature
%       compensation is only performed if there is a tcomp field in
%       the cal structure.
%	   'nomap' is an optional argument that is used to disable
%		  axis mapping for vector sensors. e.g.,
%			X = do_cal(X,fs,cal,'nomap');
%		  Default is to apply the mapping if one is specified in the 
%		  cal structure.
%
%		Returns:
%		X is a sensor structure with calibration implemented.
%		 Data size and sampling rate is the same as for the
%		 input data but units may have changed.
%
%     Cal fields currently supported are:
%     poly, cross, map, tcomp, tref, tseg, tcomp
%		Any other fields in cal will be ignored.
%
%		Example:
%		 TBD
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     Last modified: July 2018 - added support for time varying cals
%     Dec 2018 - fixed bug reading last input argument
%		Dec 2019 - added support for multiple covariates in T

nextin = 1 ;
if ~isstruct(X),
	if nargin<3,
		help do_cal
		return
	end
   x = X ;
	fs = varargin{1} ;
	nextin = 2 ;
else
	if nargin<2,
		help do_cal
		return
	end
   [x,fs] = sens2var(X) ;
   if isempty(x), return, end
end

C = varargin{nextin} ;
nextin = nextin+1 ;
	
if ~isstruct(C),
   fprintf(' Calibration information must be in a cal structure\n') ;
   return
end

nomap = 0 ;
T = [] ;
while nextin<nargin,
	v = varargin{nextin} ;
	nextin = nextin+1 ;
	if strcmp(v,'nomap')
		nomap = 1 ;
	elseif strcmp(v,'map')
      nomap = 0 ;
	elseif strcmp(v,'T')
		if nextin<nargin,
			T = varargin{nextin} ;
			nextin = nextin+1 ;
		else
			fprintf(' No temperature data given with ''T'' option - unable to apply temperature compensation\n') ;
		end
	end
end

fnames = fieldnames(C) ;
k = find(ismember(fnames,{'TSEG','tseg'})) ;
if ~isempty(k),
	kseg = round(C.(fnames{k(1)})*fs)+1 ;
	kseg = min(max(kseg(:),1),size(x,1)-1) ;
	kseg(:,2) = [kseg(2:end)-1;size(x,1)] ;
   if isstruct(X),
   	X.cal_tseg = C.(fnames{k(1)}) ;
   end
else
	kseg = [1 size(x,1)] ;
end

% 1. find and apply the calibration polynomial
k = find(ismember(fnames,{'POLY','poly'})) ;
if ~isempty(k),
	p = C.(fnames{k(1)}) ;
   if size(p,1)~=size(x,2),
      fprintf(' Calibration polynomial must have %d rows to match this data\n',size(x,2)) ;
      return
   end
	if size(p,3) == size(kseg,1),		% test for time-varying poly
		for kk=1:size(kseg,1),
			ks = kseg(kk,1):kseg(kk,2) ;
			x(ks,:) = x(ks,:).*repmat(p(:,1,kk)',length(ks),1) + repmat(p(:,2,kk)',length(ks),1);
		end
	else
		x = x.*repmat(p(:,1,1)',size(x,1),1) + repmat(p(:,2,1)',size(x,1),1);
	end
   if isstruct(X),
   	X.cal_poly = reshape(p,size(p,1),[],1) ;
   end
end

% 2. find and apply temperature compensation
k = find(ismember(fnames,{'tcomp','TCOMP'})) ;
if ~isempty(k) && ~isempty(T),
	p = reshape(C.(fnames{k(1)}),size(x,2),[]) ;
	if isstruct(T),
		T = sens2var(T) ;
	end
	k = find(ismember(fnames,{'tref','TREF'})) ;
	if ~isempty(k),
		tref = C.(fnames{k(1)}) ;
		tref(length(tref)+1:size(T,2)) = 0 ;
	else
      tref = zeros(1,size(T,2)) ;
   end
	T = remove_nan(T-repmat(tref,size(T,1),1)) ;  % remove all the NaNs in T
	k = find(ismember(fnames,{'tconst','TCONST'})) ;
	if ~isempty(k),
		tc = C.(fnames{k(1)}) ;
		tc(length(tc)+1:size(T,2)) = 0 ;
		for kk=1:size(T,2),
			if tc(kk)<=0, continue, end
			pf = 1/(fs*tc(kk)) ;  % pole frequency of a one-pole low-pass filter
			T(:,kk) = filter(pf,[1 -(1-pf)],T(:,kk),T(1,kk)) ;
		end
		if isstruct(X),
			X.cal_tconst = tc ;
		end
	end
	
	k = find(ismember(fnames,{'tadvance','TADVANCE'})) ;
	if ~isempty(k),
		ta = C.(fnames{k(1)}) ;
		ta(length(ta)+1:size(T,2)) = 0 ;
		for kk=1:size(T,2),
			if ta(kk)<=0, continue, end
         nd = round(fs*ta(kk)) ;
         T(:,kk) = [T(nd:end,kk);repmat(T(end,kk),nd-1,1)] ;
		end
		if isstruct(X),
			X.cal_tadvance = ta ;
		end
	end

   if size(T,1)~=size(x,1),      % TODO interp t to match X if it doesn't already
		fprintf('Mismatch in size of T and X - cannot use T\n') ;
		p = 0 ;
	elseif size(p,2)/size(T,2) == size(kseg,1),		% test for time-varying tcomp
		for kk=1:size(kseg,1),
			ks = kseg(kk,1):kseg(kk,2) ;
			pp = p(:,(kk-1)*size(T,2)+(1:size(T,2))) ;
			x(ks,:) = x(ks,:) + T(ks,:)*pp' ;
		end
	else
		x = x + T*p' ;
	end
	
   if isstruct(X),
      X.cal_tcomp = p ;
      X.cal_tref = tref ;
   end
end

% 3. find and apply any cross-axis corrections - only for vector sensors
k = find(ismember(fnames,{'CROSS','cross'})) ;
if ~isempty(k),
	p = C.(fnames{k(1)}) ;
	if size(p,3) == size(kseg,1),		% test for time-varying cross
		for kk=1:size(kseg,1),
			ks = kseg(kk,1):kseg(kk,2) ;
			x(ks,:) = x(ks,:)*p(:,:,kk) ;
		end
	else
		x = x*p(:,:,1) ;
	end
   if isstruct(X),
      X.cal_cross = reshape(p,size(p,1),[],1) ;
   end
end

% 4. find and apply an axis conversion map - only for vector sensors
if nomap==0,
	k = find(ismember(fnames,{'MAP','map'})) ;
	if ~isempty(k),
		p = C.(fnames{k(1)}) ;
		x = x * p ;
		if isstruct(X),
			X.cal_map = p ;
         if isfield(C,'axes'),
            X.axes = C.axes ;
         end
		end
	end
end

% Report results
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
	X.history = 'do_cal' ;
else
	X.history = [X.history ',do_cal'] ;
end
return
