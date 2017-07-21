function    g = acc_wgs84(latitude)

%    g = acc_wgs84(latitude)
%    Returns the total acceleration due to gravitation and centripetal
%    force at the earth's surface according to the WGS84 international
%    gravity formula.
%	  latitude is in degrees
%	  Returns:
%     g in m/s^2
%
%	  Example:
%		acc_wgs84(50)   % returns 9.8107 m/s^2
%
%    Source: http://solid_earth.ou.edu/notes/potential/igf.htm
%
%	  Valid: Matlab, Octave
%    markjohnson@st-andrews.ac.uk
%    Last modified: 4 May 2017

if nargin<1,
	help acc_wgs84
	g = [] ;
	return
end
	
latrad = latitude*pi/180 ;
g = 9.7803267714*(1+0.0019318514*sin(latrad).^2)./sqrt(1-0.00669438*sin(latrad).^2) ;
