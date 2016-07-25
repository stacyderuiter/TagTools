function    d3makeprhfile(tag,s,fs,fname)
%
%   Generate complete PRH file from a raw file using calibrations
%   and tag orientations in the tag deployment calibration file
%
%   tag is the tag ID string, for example 'zc11_267a'
%   s and fs are the raw sensor data matrix and sampling rate.
%      If [], data will be loaded using loadraw(tag).
%      The sampling rate of the prh file is currently always 5Hz.  This is
%      not currently adjustable but note that the d3 sensors sample at different rates - the accelerometers in particular at higher rates - and currently, accessing the sensor stream data individually using d3parseswv is a better method of attack if you need higher sampling rate data. 
%   fname is the file name under which to save the resulting prh file. Note that if fname is not
%      specified, the default PRH file will be overwritten. If fname
%      is specified and is not an absolute file name, the file will
%      be created in the current working directory. 
%
%   mark johnson
%   majohnson@whoi.edu
%   last modified: 24 June 2006
%   modified for tag 3, stacy deruiter, july 2011, april 2012
%

loadcal(tag) ;

if ~exist('CAL','var')
   fprintf(' No CAL structure in the tag file - perform calibration before running makeprhfile') ;
   return
end

if ~exist('CAL','var')
   fprintf(' No CAL structure in the tag file - perform calibration before running makeprhfile') ;
   return
end

if ~exist('DECL','var')
   fprintf(' No DECL (magnetic field declination) variable in tag file - using DECL=0\n') ;
   DECL = 0 ;
elseif abs(DECL) > 0.5
    fprintf([' DECL converted from ' num2str(DECL) ' degrees to ' num2str(DECL*pi/180) ' radians for heading calculation\n']) ; 
    DECL = DECL*pi/180 ; %convert DECL to radians if it is in degrees!
end

if nargin<3 | isempty(s),
   [s,fs] = loadraw(tag) ;
end

% if fs==5,
%    [p,tempr] = calpressure(s,CAL,'lowbat') ;    % only apply lowbat correction to decimated data
%    % this is a bug that needs to be fixed - ideally, lowbat onset variable should be stored as
%    % a cue not a number of samples but this means that fs has to be passed to the cal tools
% else
   [p,tempr] = calpressure(s,CAL,'none') ;
% end


%run accelerometer calibration
ax = polyval(CAL.ACAL(1,:),s(:,1));
ay = polyval(CAL.ACAL(2,:),s(:,2));
az = polyval(CAL.ACAL(3,:),s(:,3));
A = [ax, ay, az];

%run accelerometer calibration
mx = polyval(CAL.MCAL(1,:),s(:,4));
my = polyval(CAL.MCAL(2,:),s(:,5));
mz = polyval(CAL.MCAL(3,:),s(:,6));
M = [mx, my, mz];

if ~exist('OTAB','var'),
   fprintf(' No OTAB (tag orientation) matrix in tag file - only computing tag frame variables\n') ;
   % save results
   saveprh(tag,'p','fs','A','M','tempr') ;
   return
end

% Compute the whale frame A and M matrices:
[Aw,Mw] = tag2whale(A,M,OTAB,fs) ;

% Compute whale frame pitch, roll, heading
[pitch roll] = a2pr(Aw) ;
[head vm incl] = m2h(Mw,pitch,roll) ;
head = head + DECL ; %head is in radians

% report on trustworthiness of heading estimate
fprintf(' After gimballing :-\n') ;
fprintf(' Mean Magnetic Field Inclination: %4.2f\260 (%4.2f\260 RMS)\n',...
       180/pi*mean(incl), 180/pi*std(incl)) ;

% save results
if nargin<4,
   saveprh(tag,'p','pitch','roll','head','fs','Aw','Mw','A','M','tempr') ;
else
   save(fname,'p','pitch','roll','head','fs','Aw','Mw','A','M','tempr') ;
end
