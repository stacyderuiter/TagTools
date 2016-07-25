function    d3makeprhfile(recdir,prefix,tag,df)
%
%   d3makeprhfile(recdir,prefix,tag,df)
%   Generate a complete PRH file from raw sensor data using calibrations
%   and tag orientations in the tag deployment calibration file
%   recdir and prefix specify where to find the .swv files as in d3readswv.
%   tag is the deployment name used when registering the deployment.
%   df is an optional decimation factor to apply to the PRH data. If df is
%   not given, a df=1 will be used (i.e., full rate data).
%
%   This function generates a file in the PRH directory specified in the
%   tagpath (see settagpath.m). The file name will be <uname>prhfff.mat where
%   ff is the sampling rate in Hz (up to three digits).
%
%   Example:
%     d3makeprhfile('e:/data/bb10/bb10_214a','bb214a','bb10_214a',10);
%
%   MJ with help from LMML
%   markjohnson@st-andrews.ac.uk
%   28 Feb 2013
%

[CAL,DEPLOY] = d3loadcal(tag) ;

if ~exist('CAL','var')
   fprintf(' No CAL structure - perform calibration before running makeprhfile') ;
   return
end

X = d3readswv(recdir,prefix,df) ;

% apply calibrations
[p,CAL,fsp] = d3calpressure(X,CAL,'none') ;
[M,CAL,fsm] = d3calmag(X,CAL,'none') ;
[A,CAL,fs] = d3calacc(X,CAL,'none') ;

% check sampling rates are compatible
if fsp~=fs || fsm(1)~=fs,
   fprintf('Different sampling rates on p, A and M not yet supported\n') ;
   return
end

% % decimate all channels
% if nargin==4 && df~=1,
%     %Actually DO NOT decimate! They were already decimated by d3readSWV!
% %    p = decdc(p,df) ;
% %    M = decdc(M,df) ;
% %    A = decdc(A,df) ;
%    fs = fs/df ;
% end

% check the lengths of the A, M and p matrices
S = [size(A,1),size(M,1),length(p)] ;
if length(unique(S))>1,
   n = min(S) ;
   fprintf(' Length mismatch in A, M and p. Trimming by %d samples\n',max(S)-n) ;
   A = A(1:n,:) ;
   M = M(1:n,:) ;
   p = p(1:n) ;
end

% make a filename for the PRH file
global TAG_PATHS
if isempty(TAG_PATHS) || ~isfield(TAG_PATHS,'PRH'),
   fprintf(' No PRH file path - use settagpath\n') ;
   return
end
fname = sprintf('%s/%sprh%d.mat',getfield(TAG_PATHS,'PRH'),tag,round(fs)) ;
vv = version ;

if ~isfield(DEPLOY,'OTAB'),
   fprintf(' No OTAB (tag orientation) - only computing tag frame variables\n') ;
   % save results
   if vv(1)>'6',
      save(fname,'-v6','p','fs','A','M') ;
   else
      save(fname,'p','fs','A','M') ;
   end
   return
end

% report on trustworthiness of heading estimate
dp = (A.*M*[1;1;1])./norm2(M) ;
incl = asin(mean(dp)) ;     % do the mean before the asin to avoid problems
                            % when the specific acceleration is large
sincl = asin(std(dp)) ;
fprintf(' Mean Magnetic Field Inclination: %4.2f\260 (%4.2f\260 RMS)\n',...
       180/pi*incl, 180/pi*sincl) ;

% Compute the whale frame A and M matrices:
[Aw,Mw] = tag2whale(A,M,DEPLOY.OTAB,fs) ;

% Compute whale frame pitch, roll, heading
[pitch roll] = a2pr(Aw) ;
[head,mm,incl] = m2h(Mw,pitch,roll) ;

if ~isfield(DEPLOY,'DECLINATION'),
   fprintf(' No DECL (magnetic field declination specified in CAL file - using 0\n') ;
   DECL = 0 ;
else
   DECL = DEPLOY.DECLINATION ;
end
head = head + DECL*pi/180 ;      % adjust heading for declination angle in radians

% save results
if vv(1)>'6',
   save(fname,'-v6','p','pitch','roll','head','fs','Aw','Mw','A','M') ;
else
   save(fname,'p','pitch','roll','head','fs','Aw','Mw','A','M') ;
end
