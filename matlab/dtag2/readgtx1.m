function    [P,starttime] = readgtx1(fname,fs)
%
%    [P,starttime] = readgtx1(fname,fs)
% Read and extract data from an EXTGPS text file containing NMEA sentences.
% fname is the filename. fs is the nominal audio sampling rate for the recording.
% Lines starting with % are ignored as comments. The following NMEA
% sentences are supported. All other sentences are ignored.
%
% $DTCLK,n*
%   n is the number of ADC samples since the start of recording corresponding to
%   the time in the following $GPRMC and $GPGGA sentences plus one second.
%
% $GPRMC,hhmmss,A,latitude,N,longitude,W,sog,cog,yymmdd,decl,W,*checksum
%   time is in UTC.
%   latitude and longitude are in ddmm.mmmm where dd = degrees, mm=minutes
%   and the following letter N/S or W/E specifies the hemisphere.
%   decl is the magnetic declination and the following letter W or E
%   specifies the direction (this letter may be missing in some sentences - default
%   value is east?)
%
% $GPGGA,hhmmss,latitude,N,longitude,W,quality,num_sats,hdop,height,M,geoidal_height,M,,*checksum
%   quality: 0=no fix, 1=non-differential fix, 2=differential fix
%   num_sats: number of satellites received (%d)
%   hdop: hozizontal dilution of precision (%f)
%   height above mean sea level (%f) (this may not be given)
%   geoidal height (%f) (this may not be given)
%
% NMEA sentences are expected to arrive in triples {$DTCLK,$GPRMC,$GPGGA}.
% If a $DTCLK message arrives without one of the following sentences, the
% corresponding fields in P will be filled with NaNs.
%
% Returns:
% P=[gpstime,latitude,longitude,decl,quality,num_sats,hdop,cuetime,diffsamples]
%
% cuetime is the number of seconds since tagon according to the tag clock.
% gpstime is the GPS second-of-day
% latitude and longitude are in decimal degrees with -ve indicating W or S, respectively.
% NaN is used whenever a field value is unknown or if the GPS strings indicate an invalid
% value.
%
% starttime is the back-calculated GPS date and time of the first ADC sample:
%  [yr mon day hr min sec]
%
% mark johnson, WHOI
% majohnson@whoi.edu
% last modified: Oct. 2007

if nargin<1,
	help readgtx
	return
end

if nargin<2,
   fs = 1 ;
end

f = fopen(fname,'rt') ;
if f<0,
   fprintf(' Unable to open file - check name\n') ;
   return
end

Pwidth = 9 ;
P = NaN*zeros(1000,Pwidth) ;    % allocate some space for P
V = NaN*zeros(1,Pwidth) ;
n = 0 ;
lastnn = NaN ;

while 1,
   s = fgetl(f) ;
   if s==-1,
      done = 1 ;
      break ;
   end

   ks = max(findstr(s,'$')) ;
   ke = min(findstr(s,'*')) ;

   % check if this is a legitimate NMEA sentence
   if ~isempty(s) & length([ks ke])==2 & ke>ks,
      % which NMEA sentence is it?
      [mess,s] = strtok(s(ks+1:end),',') ;
      switch mess,
         case 'DTCLK'
            if ~isnan(V(1)),
               if n==0,
                  starttime = r(1:6) ;
                  starttime(6) = starttime(6)+1-V(8) ;
                  starttime = datevec(datenum(starttime)) ;
               end
   		      n = n+1 ;
		         if n>size(P,1) ;
			         P = [P;NaN*zeros(1000,Pwidth)] ;    % allocate more space
		         end
		         P(n,:) = V ;
               V(1) = NaN ;
	         end
            V = NaN*V ;

            nn = str2double(strtok(s,',')) ;
            if ~isempty(nn), V(8:9) = [nn/fs nn-lastnn]; lastnn = nn ; end

         case 'GPRMC'
            r = procRMC(s) ;
            V(1:4) = [r(4:6)*[3600;60;1]+1 r(7:9)] ;
         case 'GPGGA'
            V(5:7) = procGGA(s) ;
         otherwise
      end
   end
end
            
if ~isnan(V(1)),
   if n==0,
      starttime = r(1:6) ;
      starttime(6) = starttime(6)+1-V(8) ;
      starttime = datevec(datenum(starttime)) ;
   end
   n = n+1 ;
   P(n,:) = V ;
end
P = P(1:n,:) ;
return


function r = procRMC(s)
%
% examine the GPRMC message in s and return:
% r=[year,month,day,hr,min,sec,latitude,longitude,decl]
%

[loc cnt] = sscanf(s,',%f,%c,%f,%c,%f,%c,%f,%f,%f,%f,%c') ;
if cnt<10,
   return
end

% process date and time
ymd = round(loc(9)) ;
yr = mod(ymd,100) ;
daymon = (ymd-yr)/100 ;
mon = mod(daymon,100) ;
day = (daymon-mon)/100 ;
hms = round(loc(1)) ;
sec = mod(hms,100) ;
hrmin = (hms-sec)/100 ;
min = mod(hrmin,100) ;
hr = (hrmin-min)/100 ;
r = [2000+yr mon day hr min sec] ;

% process latitude
latmin = mod(loc(3),100) ;
lat = round((loc(3)-latmin)/100)+latmin/60 ;
if loc(4)==abs('S'),
   lat = -lat ;
end
r(7) = lat ;

% process longitude
longmin = mod(loc(5),100) ;
long = round((loc(5)-longmin)/100)+longmin/60 ;
if loc(6)==abs('W'),
   long = -long ;
end
r(8) = long ;

% process declination
decl = loc(10) ;
if length(loc)==11 & loc(11)=='W',
	decl = -decl ;
end
r(9) = decl ;

% process error
if loc(2)~='A',
   r(8:9) = NaN ;
end
return


function r = procGGA(s)
%
% examine the GPGGA message in s and return
% [quality,num_sats,hdop]
%

[loc cnt] = sscanf(s,',%f,%f,%c,%f,%c,%f,%f,%f') ;
if cnt<8,
   r = NaN*[1 1 1] ;
   return
end

r = [round(loc(6:7))' loc(8)] ;
return
