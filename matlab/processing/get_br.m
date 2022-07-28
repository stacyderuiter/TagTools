function		ph = get_br(Ma,fs,fh,thr,ax)

%		ph = get_br(Ma,fh,thr)	% Ma is a sensor structure
%		or
%		ph = get_br(Ma,fh,thr,ax)
%		or
%		ph = get_br(Ma,fs,fh,thr)	% Ma is a matrix of sensor data
%		or
%		ph = get_br(Ma,fs,fh,thr,ax)
%
%		Estimate the body rotations due to cyclic locomotion movements.
%		Ma is the triaxial magnetometer data in the animal frame. Ma can
%	    be a sensor structure or a three-column matrix. The sampling rate
%		 of Ma must be at least 2x the highest stroke rate of the animal.
%		 The magnetometer data can be in any units as long as all three
%		 columns have the same unit.
%		fs is the sampling rate of Ma and is only needed if Ma is not a
%		 sensor structure.
% 		fh is the high-pass filter frequency in Hz to use to separate
%		 orientation changes from locomotory strokes. It should be about
%		 half of the dominant stroke frequency. Use dsf.m to estimate the
%		 dominant stroke frequency.
%		thr is an optional minimum field strength threshold to prevent errors
%		 in the computation. Errors arise if the plane of rotations is nearly
%		 perpendicular to the local magnetic field vector. To avoid these, the
%		 body rotation signal is replaced with NaN if the field strength in the
%		 locomotory plane drops below thr fraction of the total field strength.
%		 The default value is 0.2 (i.e., the locomotory plane must have at least 
%		 20% of the total field strength to compute the body rotations. For the 
%		 default value use thr=[] if you need to specify ax.
%		ax is an optional indicator that the locomotion is in the x-y plane. The
%		 function expects the locomotion to be in the x-z plane (e.g., cetacean
%		 swimming) by default. To comoute body rotations in x-y plane (e.g., for
%		 pinnipeds and many fish), use ax='y'.
%
%		Returns:
% 		ph is the body rotation signal in radians. It has the same sampling
%		 rate and number of samples as Ma.
%
%		Example:
%		ph = get_br(Ma,0.2);
% 		choose an angle threshold, e.g., thr=2 degrees, and find strokes in ph
%		[K,s] = zero_crossings(ph,thr*pi/180,fs/0.2);
%		ps = K(s>0)/fs ;	% positive-going half strokes
%		ns = K(s<0)/fs ;	% negative-going half strokes
%
%		For derivation see: Martin López L, Aguilar de Soto N, Miller P, Johnson M
%	   2016 Tracking the kinematics of caudal-oscillatory swimming: A comparison 
%	   of two on-animal sensing methods. J Exp Biol 219:2103-2109.
%
%		Note: to estimate the stroking rate of small animals for which the specific
%		acceleration is larger, it may be simpler to find the zero crossings on the 
%		high-pass-filtered acceleration (z axis for cetaceans, y axis for pinnipeds
%		and fish) directly rather than using get_br.
%
%		markjohnson@bios.au.dk
%		Last modified: 11 Feb 2021


if nargin<2 | ~isstruct(Ma)&nargin<3,
	help get_br
	return
end

if isstruct(Ma),
	if nargin==4,
		ax = thr ;
	else
		ax = [] ;
	end
	if nargin>=3,
		thr = fh ;	% shuffle input arguments
	else
		thr = [] ;
	end
	fh = fs ;
	[Ma,fs] = sens2var(Ma) ;
else
	if nargin<5,
		ax = [] ;
	end
	if nargin<4,
		thr = [] ;
	end
end
		
if isempty(thr),
	thr = 0.2 ;		% default minimum field fraction in locomotion plane
end
	
mfs = nanmean(norm2(Ma)) ;		% mean magnetic field strength
Mf = comp_filt(Ma,fs,fh);		% split the M signals into low-pass and high-pass
Ml = Mf{1} ;					% the low-pass filtered M
Mh = Mf{2} ;					% the high-pass filtered M

if ax=='y',
	m2 = Ml(:,1).^2 + Ml(:,2).^2 ;	% the magnitude-squared of Ml in the [x,y] sub-space
	ph = real(asin((Mh(:,1).*Ml(:,2)-Mh(:,2).*Ml(:,1))./m2)) ;	% estimate the body rotations
else
	m2 = Ml(:,1).^2 + Ml(:,3).^2 ;	% the magnitude-squared of Ml in the [x,z] sub-space
	ph = real(asin((Mh(:,1).*Ml(:,3)-Mh(:,3).*Ml(:,1))./m2)) ;	% estimate the body rotations
end

ph(m2<thr*mfs^2) = NaN ;	% blank out rotations when the planar field is too small
