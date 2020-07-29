function    [map,incl] = find_map(A,M,fs,incl)

%     [map,incl] = find_map(A,M)					% A and M are sensor structures
%		or
%     [map,incl] = find_map(A,M,fs)				% A and M are matrices
%		or
%     [map,incl] = find_map(A,M,incl)			% A and M are sensor structures
%		or
%     [map,incl] = find_map(A,M,fs,incl)		% A and M are matrices
%		
%		Search for the map matrix to apply to magnetometer measurements so as
%		to minimize the variance in the angle between A and M. This map matrix
%		could then be entered in the calibration structure for M. The function
%		systematically tests permutations of axes allowing each axis also to be
%		multiplied by -1. This assumes that each axis of the sensors used to
%		measure A is parallel to an axis of the sensor used to measure M. All 
%		possible combinations of axes are tested and the mapping giving the lowest
%		variance in inclination angle between A and M is returned along with the
%		vector of inclination angles.
%
%		Inputs:
%     A is an accelerometer sensor structure or matrix with columns [ax ay az]. 
%		 Acceleration can be in any consistent unit, e.g., g or m/s^2. 
%     M is a magnetometer sensor structure or matrix, M=[mx,my,mz] in any consistent 
%		 unit (e.g., in uT or Gauss). A and M must have the same number of rows and
%		 must be sampled at the same rate.
%     fs is the sampling rate of the sensor data in Hz (samples per second).
%		 This is only needed if A and M are not sensor structures.
%		incl is the nominal inclination angle for the location where the data were collected.
%		 This is only needed to determine whether the map matrix should be multiplied by -1.
%		 If incl is not supplied, check that the returned inclination angles are close to the
%		 expected values. If they are similar but with the wrong sign, try using -map instead of map. 
%
%		Returns:
%		map is a 3x3 map matrix, i.e., an orthonormal matrix containing only values of 1, -1 or 0.
%		 This matrix can be added to the cal structure (in a field named 'map') for the magnetometer.
%		 To apply the map use apply_cal or just post-multiply M by map.
%		incl is the vector of resulting inclination angles between A and M*map. It is in radians
%		 and has as many rows as there are rows in A and M if fs<=5 Hz. If fs is >5Hz, the input data
%		 is automatically decimated to close to 5 Hz. Always plot incl after running this
%		 function to check that it has found a suitable map. If incl is very variable, the A and M
%		 data may have been too noisy or inaccurate to find a suitable map.
%
%		Note: A and M should be collected during a set of flip movements of the tag. These movements
%		should involve combinations of pitches, rolls and yaws. The movements should be made well away
%		from any magnetic fields and so preferably outside. A and M could also be taken from a section 
%		of data collected on an animal in which the animal has a widely varying posture. Sampling rate
%		is automatically reduced to 5 Hz within the function to reduce effect of specific acceleration in A.
%
%		Example: TBD
%
%		markjohnson@st-andrews.ac.uk
%		Last modified: 12 Feb. 2018

map=[]; incl=[] ;
if nargin<2,
   help find_map
   return
end

if isstruct(M) && isstruct(A),
	if nargin>2,
		incl = fs ;
	else
		incl = [] ;
	end
		
	[A,M,fs] = sens2var(A,M) ;
	if isempty(A), return, end
else
	if isstruct(M) || isstruct(A),
		fprintf('find_map: A and M must both be structures or matrices, not one of each\n') ;
		return
	end
	if nargin==3,
		incl = [] ;
	elseif nargin==2,
	   fprintf('Error: Need to specify fs if calling find_map with matrix inputs\n') ;
	   return
	end
end	

e3 = eye(3) ;
maps = {e3,e3([1 3 2],:),e3([2 1 3],:),e3([2 3 1],:),e3([3 1 2],:),e3([3 2 1],:)} ;
signs = {e3,diag([1 1 -1]),diag([1 -1 1]),diag([-1 1 1])};

for k=1:length(maps),
   for kk=1:length(signs),
      m = maps{k}*signs{kk} ;
      [f,incl1]=check_AM(A,M*m,fs) ;
      R(k,kk) = mean(incl1) ;
      S(k,kk) = std(incl1) ;
   end
end

[rr,kk] = min(S) ;
[r,k] = min(rr) ;
map = maps{kk(k)}*signs{k} ;
[f,incl1]=check_AM(A,M*map,fs) ;

if ~isempty(incl) && (incl*mean(incl1))<0,
   incl = -incl1 ;
   map = -map ;
else
   incl = incl1 ;
end
