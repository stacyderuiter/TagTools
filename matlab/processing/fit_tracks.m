function    [D,C,T] = fit_tracks(P,T,D,fs)

%      [D,C,T] = fit_tracks(P,T,D,fs)
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
%      C is a two column matrix with one less row than P containing the
%       inferred currents between pairs of GPS points needed to match the tracks.
%       If the difference between the two tracks is due to the media moving, 
%       C can be considered an estimate of the current in m/s. The axes and frame
%       are the same as for the input data.
%      T is a vector of times corresponding to each row of C.
%
%	    Example:
%		   TBD
%
%      Valid: Matlab, Octave
%      markjohnson@bios.au.dk
%      last modified: 18 April 2021 - fixed handling of DR track outside of fixes
%        - changed pseudo-current reporting.
     
if nargin<4,
	help fit_tracks
	return
end
	
kg = find(T>=0 & T<size(D,1)/fs) ;  % find position fixes that coincide in time with the DR track
k = round(T(kg)*fs)+1 ;             % find the corresponding DR track sample numbers
if length(k)==1,
   D = D-repmat(D(k(1),:),size(D,1),1) ;  % reference track to first GPS point
   C = [] ;
   return
end

P = P(kg,:) ;
D1 = D(k(1),:) ;
C = NaN(length(k)-1,2) ;
for gk=1:length(k)-1,
	kk = k(gk):k(gk+1) ;
	d = D(kk,:)+repmat(P(gk,:)-D(kk(1),:),length(kk),1) ;
	C(gk,:) = (P(gk+1,:)-d(end,:))/(length(kk)-1) ;
	D(kk(1:end-1),:) = d(1:length(kk)-1,:)+repmat(C(gk,:),length(kk)-1,1).*repmat((0:length(kk)-2)',1,2) ;
end

% do points before first gps position - use first current estimate
kk = 1:k(1)-1 ;
if ~isempty(kk),
	d = D(kk,:)+repmat(P(1,:)-D1,length(kk),1) ;
	D(kk,:) = d+repmat(C(1,:),length(kk),1).*repmat((-length(kk):-1)',1,2) ;
end

% do points after last gps position - use final current estimate
kk = k(end):size(D,1) ;
if ~isempty(kk),
	d = D(kk,:)+repmat(P(end,:)-D(kk(1),:),length(kk),1) ;
	D(kk,:) = d+repmat(C(end,:),length(kk),1).*repmat((0:length(kk)-1)',1,2) ;
end

C = C/fs ;
T = (T(1:end-1)+T(2:end))/2 ;
