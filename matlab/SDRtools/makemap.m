function		[M,Mlat,Mlong,Bz] = makemap(Bl,lat,long)
%
%		[M,Mlat,Mlong] = makemap(Bl,[lat,long])
%		Make a matrix map from altitude list Bl. Bl is a 3-column
%		matrix [longitude,latitude,altitude] generated from 
%		 http://topex.ucsd.edu/cgi-bin/get_data.cgi
%		lat and long specify (optional) ranges to limit the map to.
%		Each should be a two element vector i.e., [lat_min,lat_max].
%
%     The resulting map can be plotted using:
%		 imagesc(Mlong,Mlat,M'), axis xy
%
%		mark johnson, WHOI
%		February 2002

RES = 0.01 ;		% output resolution in degrees

if nargin>=2,
	klat = find((Bl(:,2)>=min(lat)) & (Bl(:,2)<=max(lat))) ;
	Bl = Bl(klat,:) ;
	klong = find((Bl(:,1)>=min(long)) & (Bl(:,1)<=max(long))); 
	Bl = Bl(klong,:) ;
else
	lat = [min(Bl(:,2)) max(Bl(:,2))] ;
	long = [min(Bl(:,1)) max(Bl(:,1))] ;
end

% reshape list into a matrix
kr = min(find(abs(diff(Bl(:,2)))>RES)); 
kc = floor(length(Bl)/kr) ;
Blong = reshape(Bl(1:kr*kc,1),kr,kc) ;
Blat = reshape(Bl(1:kr*kc,2),kr,kc) ;
Bz = reshape(Bl(1:kr*kc,3),kr,kc) ;

Mlat = (min(lat):RES:max(lat))' ;
Mlong = (min(long):RES:max(long))' ;
M = interp2(Blat,Blong,Bz,Mlat,Mlong','linear') ;
