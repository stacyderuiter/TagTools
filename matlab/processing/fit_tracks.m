function    [D,C] = fit_tracks(P,T,D,fs)

%      [D,C] = fit_tracks(P,T,D,fs)
%      Simple track integration method to merge infrequent
%      but accurate positions with a regularly sampled track
%      that is not absolutely accurate.
%
%      Inputs:
%      P is a two column matrix containing the anchor positions.
%       The two columns contain the 'northing' and 'easting' coordinates
%       of the positions in a local level frame. Any units, axes and frame
%       can be used as long as they are consistent with the regularly sampled
%       track. Note that P should not be in spherical coordinates such
%       as latitude and longitude - convert these to a local level frame
%       using lalo2llf.
%      T is a vector of times at which the animal is at each position
%       in P. Times are in seconds since the start of the regularly
%       sampled track. T must have the same number of rows as P. Times
%       must be greater than or equal to 0 and less than the time length
%       of the regularly sampled track.
%      D is a two column matrix containing the regularly sampled track
%       points. The two columns contain the 'x' and 'y' coordinates of the
%       track points in a local level frame. Units, axes and frame must
%       match those of P.
%      fs is the sampling rate in Hz of D.
%
%      Returns:
%      D is a two column matrix containing the fitted track. It contains
%       the same number of track points as the input D and is sampled 
%       at the same rate (fs). The units, axes and frame are the same as for
%       the input data.
%      C is a two column matrix the same size as D containing the track
%		  increments needed to match the tracks. If the difference between the
%		  two tracks is due to the media moving, C can be considered an estimate
%		  of the current in m/s. The axes and frame are the same as for
%       the input data.
%
%	    Example:
%		   TBD
%
%      Valid: Matlab, Octave
%      markjohnson@st-andrews.ac.uk
%      last modified: 2 Feb 2018 - fixed handling of DR track after last fix 
     
if nargin<4,
	help fit_tracks
	return
end
	
kg = find(T>=0 & T<size(D,1)/fs) ;  % find position fixes that coincide in time with the DR track
k = round(T(kg)*fs)+1 ;             % find the corresponding DR track sample numbers
V = [0,0;P(kg,:)-D(k,:)] ;          % errors between fixes and DR track at fix times
% repeat last error - this will be applied to the remnant DR track after last fix
V(end+1,:) = V(end,:) ;             

dk = [k(1);diff(k);size(D,1)-k(end)] ;               
ki = [0;cumsum(dk)] ;
C = zeros(size(D,1),2) ;            % make space for the merged track
for kk=1:length(dk),
   C(ki(kk)+1:ki(kk+1),:) = repmat(V(kk,:),dk(kk),1)+1/dk(kk)*(0:dk(kk)-1)'*(V(kk+1,:)-V(kk,:)) ;
end
D = D+C ;
C = [zeros(1,size(C,2));diff(C)*fs] ;		% estimated 'currents'
