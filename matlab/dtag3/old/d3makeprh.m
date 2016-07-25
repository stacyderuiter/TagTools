function    d3makeprh(recdir,prefix,df,fname)
%
%   d3makeprh(recdir,prefix,df,fname)
%   Generate complete PRH file from a raw file using calibrations
%   and tag orientations in the tag deployment calibration file
%
%   mark johnson
%   markjohnson@st-andrews.ac.uk
%   last modified: July 2012
%

[CAL,DEPLOY] = d3findcal(recdir,prefix) ;
X = d3readswv(recdir,prefix,df) ;
p = d3calpressure(X,CAL,'none');
[A,CAL,fs] = d3calacc(X,CAL,'none') ;
M = d3calmag(X,CAL,'none') ;

% report on trustworthiness of heading estimate
dp = (A.*M*[1;1;1])./norm2(M) ;
incl = asin(mean(dp)) ;     % do the mean before the asin to avoid problems
                           % when the specific acceleration is large
sincl = asin(std(dp)) ;
fprintf(' Mean Magnetic Field Inclination: %4.2f\260 (%4.2f\260 RMS)\n',...
       180/pi*incl, 180/pi*sincl) ;

if isfield(DEPLOY,'OTAB'),
   % Compute the whale frame A and M matrices:
   [Aw,Mw] = tag2whale(A,M,OTAB,fs) ;

   % Compute whale frame pitch, roll, heading
   [pitch roll] = a2pr(Aw) ;
   [head vm incl] = m2h(Mw,pitch,roll) ;
   if isfield(DEPLOY,'DECLINATION'),
      head = head + DEPLOY.DECLINATION*pi/180 ;      % adjust heading for declination angle in radians
   end
   save(fname,'p','A','M','fs','Aw','Mw','pitch','roll','head') ;
else
   save(fname,'p','A','M','fs') ;
end
