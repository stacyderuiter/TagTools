function    [A,cal] = auto_cal_acc(A,fs,cal,usept)

%     [A,cal] = auto_cal_acc(A)					% A is a sensor structure
%		or
%     [A,cal] = auto_cal_acc(A,cal)				% A is a sensor structure
%		or
%     [A,cal] = auto_cal_acc(A,cal,usept)		% A is a sensor structure
%		or
%     [A,cal] = auto_cal_acc(A,fs)				% A is a matrix
%		or
%     [A,cal] = auto_cal_acc(A,fs,cal)			% A is a matrix
%		or
%     [A,cal] = auto_cal_acc(A,fs,cal,usept)	% A is a matrix
%
%		Data-driven calibration of triaxial accelerometer data. This
%		function low-pass filters the accelerometer data to reduce the
%		specific acceleration and then performs a constrained least-squares
%		fit to the constant gravitational field strength. In effect, the
%		function adjusts the calibration on each axis so that the data
%		points in A fall as close as possible to a sphere centred at the
%		origin and with radius 9.81 m/s^2.
%
%		Inputs:
%		A is an accelerometer sensor structure or matrix with columns [ax ay az]. 
%		 Acceleration should be in m/s^2.
%     fs is the sampling rate of the sensor data in Hz (samples per second).
%		 This is only needed if A is not a sensor structure.
%		cal is an optional calibration structure. Only cal.poly and cal.cross
%		 are supported. If cal is given, the function will try to improve
%		 it. If no cal is given, the function tries to infer the cal from the data. 
%		usept is an optional column vector with the same number of rows
%		 as in A. It is used to tell auto_cal_acc which data points to use.
%		 Only data points for which the corresponding row of usept is > 0 are
%		 used. If usept is not given, all data points in A are used.
%
%		Returns:
%		A is the improved accelerometer sensor structure or matrix. It has
%		 the same data rate as the input data and is in m/s^2. 
%	   cal is the improved calibration structure.
%
%		Note: this function has been tested extensively on Dtag data but
%		not on data from other tags. If it doesn't work well for your
%		data, let us know - it may help us improve the tool.
%
%		Note: this function contains two settings (fa and PRCNT) that
%		may need to be adjusted for some species. Read the comments in the
%		file where these settings are defined.
%
%     markjohnson@bio.au.dk
%     Last modified: 23 march 2022 - added usept input argument

DO_CROP = 1 ;          % use 0 to bypass the crop step
%fa = 0.5 ;            % target analysis sampling rate in Hz - large animals
fa = 5 ;               % target analysis sampling rate in Hz - small animals
PRCNT = 10 ;           % jerk selection threshold in percentage
		% a small value removes a lot of data points. If you have a small
		% data size, or your species is not very active, you may need to
		% increase PRCNT.
		
if nargin<1,
	help auto_cal_acc
	return
end
	
if isstruct(A),   % if A is a sensor-structure, extract the data
   if nargin>2,
      usept = cal ;
   else
      usept = [] ;
   end
	if nargin>1,
		cal = fs ;
	else
		cal = [] ;
	end
	[Ad,fs] = sens2var(A) ;
else
   if nargin<4,
      usept = [] ;
   end
	if nargin<3,
		cal = [] ;
	end
	if nargin<2 || isstruct(fs),
		fprintf(' Sampling rate is required with matrix data\n') ;
		return
	end
	Ad = A ;
end

J = sum(diff(Ad).^2,2) ;   % find where A is changing rapidly
J(end+1) = J(end) ;

if ~isempty(usept),
   Ad = Ad(usept>0,:) ;
   J = J(usept>0,:) ;
   DO_CROP = 0 ;
end

if fs>fa,      % if A is sampled faster than fa, decimate it.
   df = ceil(fs/fa) ;
   Ad = decdc(Ad,df) ;
   fsd = fs/df ;
   J = abs(decdc(J,df)) ;  % decimate the jerk as well
else
   fsd = fs ;
end

fstr = 9.81 ;		% earth's gravitational acceleration in m/s2
if DO_CROP,       % if requested, open the crop gui on A
   [Ad,tc] = crop(Ad,fsd) ;
   J = crop_to(J,fsd,tc) ; % apply the same crop to J
end

if isempty(cal),
	cal.poly = [1 0;1 0;1 0] ;
else
	if isfield(cal,'POLY'),
		cal.poly = cal.POLY ;
		cal = rmfield(cal,'POLY') ;
	end
end

thr = prctile(J,PRCNT) ;   % data selection
k = find(J<thr) ;
AA = Ad(k,:) ;
[AA,cc,sigma] = spherical_ls(AA,fstr,cal,2) ;

% update CAL
if sigma(2)>=sigma(1),
	fprintf(' Deviation not improved (was %3.2f%%, now %3.2f%%)\n',sigma*100) ;
else
   fprintf(' Deviation improved from %3.2f%% to %3.2f%%\n',sigma*100) ;
   cal = cc;
end

% apply cal to the complete accelerometer signal

if isstruct(A),
	if ~isfield(A,'history') || isempty(A.history),
		A.history = 'auto_cal_acc' ;
	else
		A.history = [A.history ',auto_cal_acc'] ;
   end
   A=do_cal(A,cal);
else
   A=do_cal(A,fs,cal);
end


