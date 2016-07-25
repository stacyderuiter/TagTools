function bathy = getmed09bathy(lat_limits, lon_limits)

%get bathymetry data for the area around a med09 tagout.
%uses bathymetry data from the NOAA National geophysical data center
%database, downloaded 21 Aug 09, available at
%http://www.ngdc.noaa.gov/cgi-bin/mgg/gdas_gtran
%
%inputs are: 
%  lat_limits       2 element vector of the min and max latitudes of
%                   the desired area (in decimal degrees, positive north
%                   and negative south)
%  lon_limits       2 element vector of the min and max longitude of the
%                   desired area (in decimal degrees, positive east and
%                   negative west)
%output is:
%  bathy            a three-column vector of [lon lat depth_in_meters]
%
%S. DeRuiter, August 2009

latmin = min(lat_limits);
latmax = max(lat_limits);
lonmin = min(lon_limits);
lonmax = max(lon_limits);
entermed09bathy %enter in bathy data for a very large area
%get the subset of the data within the specified lat/lon limits
bathy = med09bathy(med09bathy(:,2) > latmin ,:);
bathy = bathy(bathy(:,2) < latmax ,:);
bathy = bathy(bathy(:,1) < lonmax ,:);
bathy = bathy(bathy(:,1) > lonmin ,:);
clear med09bathy