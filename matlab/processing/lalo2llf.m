function    NE = lalo2llf(trk,pt)

%     NE = lalo2llf(trk)
%     or
%     NE = lalo2llf(trk,pt)
%
%     Convert latitude-longitude track points into a
%     local level frame. All inputs are in degrees.
%
%     Inputs:
%     trk = [latitude,longitude] is a matrix of track points.
%     pt = [latitude,longitude] is the centre point of the
%      local level frame. If pt is not given, the first point
%      in the track will be used.
%
%     Returns:
%     NE = [northing,easting] is a matrix of track points in
%      the local level frame. Northing and easting are in metres.
%      The axes of the frame are true (geographic) north and true east.
%
%     Note: this function assumes the track is on the surface of the
%     geoid and also uses a simple spherical model for the geoid. For
%     more accurate conversion to a cartesian frame, use the mapping
%     tools in Matlab/Octave.
%
%	   Example:
%		  load_nc('testset7')
%         POSLLF = lalo2llf([POS.data(:,2),POS.data(:,3)]);
%         figure
%         xlabel("Easting, m")
%         ylabel("Northing, m")
%         title("Known positions in local-level frame")
%         hold on
%         plot(POSLLF(:,2),POSLLF(:,1))
%      Returns: plot of known positions of a whale at the surface in a local-level
%      frame
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     last modified: 29 Sept. 2017 

if nargin<1,
	help lalo2llf
	return
end
	
if nargin<2,
   pt = trk(1,:) ;
end

trk = trk - repmat(pt,size(trk,1),1) ;
k = find(trk(:,2)>180) ;
trk(k,2) = trk(k,2)-360 ;
k = find(trk(:,2)<-180) ;
trk(k,2) = trk(k,2)+360 ;
NE = trk(:,1)*1852*60 ;
NE(:,2) = trk(:,2)*1852*60*cos(pt(1)*pi/180) ;
