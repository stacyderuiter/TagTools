function    [P,starttime] = readgtx(tag,chips)
%
%    [P,starttime] = readgtx(tag,chips)
% Read and extract data from EXTGPS text files for a tag deployment containing 
% NMEA sentences. If chips are not specified, all chips are found and converted.
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

if nargin<2,
   chips = [] ;
end

if nargin<1,
	help readgtx
	return
end

[fnames,chips] = makefnames(tag,'GTX',chips) ;
if isempty(fnames),
   fprintf(' Unable to find any files with names like:\n %s\n',...
         makefname(tag,'GTX',1)) ;
   fprintf(' Check that the tag AUDIO path is correct using gettagpath') ;
   return
end

loadcal(tag) ;
fs = CUETAB(1,5) ;

for k=1:length(chips),
   fprintf('\nReading %s\n', fnames{k}) ;
   if k==1,
      [P,starttime] = readgtx1(fnames{1},fs) ;
   else
      p = readgtx1(fnames{k},fs) ;
      P(end+(1:size(p,1)),:) = p ;
   end
end
