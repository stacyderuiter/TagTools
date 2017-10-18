function    [k,dist] = nearest_position(trk,pt)

%    [k,dist] = nearest_position(trk,pt)
%    Find the point in a track that is closest in distance to a given
%	  position. The track is converted to a local level frame centered at
%	  the position. 
%
%	  Inputs:
%    trk = [latitude,longitude] is a matrix of track points.
%    pt = [latitude,longitude] is the reference position.
%
%    Returns:
%    k is the row number of trk that is closest to pt.
%	  dist is the distance between trk(k,:) and pt in metres.
%
%    Note: this function assumes the track is on the surface of the
%     geoid and also uses a simple spherical model for the geoid. For
%     more accurate conversion to a cartesian frame, use the mapping
%     tools in Matlab/Octave.
%
%	  Example:
%		TBD
%
%    Valid: Matlab, Octave
%    markjohnson@st-andrews.ac.uk
%    last modified: 29 Sept 2017 

if nargin<2,
	help nearest_position
	return
end

ne = lalo2llf(trk,pt) ;
d = sum(ne.^2,2) ;
[dist,k] = min(d) ;
