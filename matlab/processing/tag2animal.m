function		Xa = tag2animal(X,fs,OTAB)
%
%		Xa = tag2animal(X,fs,OTAB)		% X is a matrix
%		or
%		Xa = tag2animal(X,OTAB)			% X is a sensor structure
%		or
%		Xa = tag2animal(X,Ya)			% X and Ya are sensor structures
%
%     Convert tag frame measurements to animal frame using pre-determined
%		tag orientation(s) on the animal. 
%
%		Inputs:
%		X is data from a triaxial sensor such as an accelerometer.
%		 magnetometer or a gyroscope. X can be a three column matrix or a
%		 sensor structure. In either case, X is in the tag frame, i.e., expressed
%		 in the cannonical axes of the tag, not the animal.
%		 X can have any unit and sampling rate.
%     fs is the sampling rate of X in Hz (samples per second). This is
%		 only needed if X is not a sensor structure.
%		OTAB is a matrix defining the orientation of the tag on the animal
%		 as a function of time. Each row of OTAB is:
%        [cue1 cue2 pitch roll heading]
%      where cue1 is the start time of a move in seconds with respect to the
%		 start of X. cue2 is the end time of the move. If cue1 and cue2 are the
%		 same, the move is instantaneous, otherwise a gradual move will be implemented
%		 in which the orientation of the tag is linearly interpolated between the
%		 previous and the new orientation.
%      The pitch, roll and heading angles describe the tag orientation on the
%      animal at the end of the move (angles are in radians).
%	    The first row of OTAB must have cue1 and cue2 equal to 0 as this is the initial
%		 orientation of the tag on the animal. Subsequent rows (if any) of OTAB describe
%		Ya is an optional sensor structure in which the sensor data has already been
%		 converted to the animal frame. The OTAB is extracted from this structure. This
%		 is useful, for example, to replicate tag-to-animal conversions at different
%		 sampling rates.
%
%		Output:
%		Xa is the sensor data in the animal frame, i.e., rotated to correct for the tag
%		 orientation on the animal. If X is a sensor structure, Xa will also be one. In this
%		 case the structure elements 'frame' and 'name' will be changed. The OTAB will also
%	    be added to the structure.
%
%		Example:
%		 See animaltags.org for examples of how to use this function.
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     Last modified: 15 Nov 2019

Xa = [] ;
if nargin<2,
   help tag2animal
   return
end

if isstruct(X),
	OTAB = fs ;
	if isstruct(OTAB),
		if isfield(OTAB,'otab'),
         if ischar(OTAB.otab),
            fprintf(' otab field reads "%s" and cannot be processed\n',...
               OTAB.otab) ;
            return
         end
			OTAB = reshape(OTAB.otab,5,[])' ;
		else
			fprintf(' Second sensor structure must have an otab field\n') ;
			return
		end
	end
	Xa = X ;
	[X,fs] = sens2var(X,'regular') ;
	if isempty(X),	return, end
	
elseif nargin<3,
	help tag2animal
	return
end

% first OTAB entry must be a fixed-point (i.e., cue2=0)
if any(OTAB(1,1:2)) ~= 0,   
   fprintf(' Adjusting first OTAB entry to have time 0\n') ;
   OTAB(1,1:2) = 0 ;
end

if size(OTAB,1)>1,
	[pp,I] = sort(OTAB(:,1)) ;		% sort events into causal order
	OTAB = OTAB(I,:) ;
   PTAB = o2p(OTAB) ;
   t = (0:size(X,1)-1)'/fs ;
	
   if PTAB(end,1) < t(end),
	   PTAB = [PTAB;t(end) PTAB(end,2:4);] ;
   end
   prh = interp1(PTAB(:,1),PTAB(:,2:4),t) ;

else
	prh = OTAB(3:5) ;
end

Q = euler2rotmat(prh) ;
X = rotate_vecs(X,Q) ;

if ~isempty(Xa),
	Xa.otab = reshape(OTAB',[],1)' ;
	Xa.frame = 'animal' ;
	Xa.name = [Xa.name 'a'] ;
	Xa.data = X ;
	if ~isfield(Xa,'history') || isempty(Xa.history),
		Xa.history = 'tag2animal' ;
	else
		Xa.history = [Xa.history ',tag2animal'] ;
    end
else % if matrix input, return matrix output
    Xa = X;
end
return


function    PTAB = o2p(OTAB)
%
%
SMALL = 0.1 ;     % duration in seconds of the shortest move
n = size(OTAB,1) ;
k = 1 ;
while k<size(OTAB,1),	% remove overlapping events
   kk = find(OTAB(k,2)+SMALL<OTAB(k+1:end,1))' ;
   OTAB = OTAB([1:k k+kk],:) ;
   k = k+1 ;
end

if size(OTAB,1)<n,
   fprintf(' Overlapping events found in OTAB and removed\n') ;
end

% force sudden moves to have duration SMALL
k = find(OTAB(:,1) == OTAB(:,2)) ;
OTAB(k,2) = OTAB(k,1)+SMALL ;

PTAB = OTAB(1,[1 3:5]) ;		% initialise PTAB
for k=2:size(OTAB,1),			% add any moves in the OTAB
   if OTAB(k,2)>OTAB(k,1),
      PTAB = [PTAB; OTAB(k,1) PTAB(end,2:4)] ;
      PTAB = [PTAB; OTAB(k,2:5)] ;
   else
      PTAB = [PTAB; OTAB(k,[1 3:5])] ;
   end
end

% check for angles wrapping at +/- 180 degrees
PTAB(:,2:4) = unwrap(PTAB(:,2:4)) ;
return
