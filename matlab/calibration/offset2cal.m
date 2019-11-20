function		cal = offset2cal(cal,offs)

%		cal = offset2cal(cal,offs)
%		Add a time-varying offset to a calibration structure
%		by making the calibration polynomial time-varying.
%
%		Inputs:
%		cal is a calibration structure or an empty matrix.
%		offs is a matrix with at least two columns. The first
%		 column is the time of an offset change. The second and
%		 subsequent columns are the value of the offset change
%		 for each axis of the sensor.
%
%		Returns:
%		cal is the same calibration structure but with an
%		 added .tseg field and a .poly field that is 3-dimensional
%		 Note that any preexisting .tseg field will be over-written.
%		 
%		Example:
%		 TBD
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     Last modified: July 2018

cal.tseg = offs(:,1)' ;

if isfield(cal,'POLY'),
   cal.poly = cal.POLY ;
   cal = rmfield(cal,'POLY') ;
end

if ~isfield(cal,'poly'),
	cal.poly = repmat([1 0],size(offs,2)-1,1) ;
end
	
p = cal.poly(:,:,1) ;
pp = repmat(p,1,1,size(offs,1)) ;

for k=1:size(offs,1),
	pp(:,2,k) = p(:,2) + offs(k,2:end)' ;
end

cal.poly = pp ;
