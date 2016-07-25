function    [CAL,DEPLOY] = d3deployment_old(recdir,prefix,uname)
%
%      [CAL,DEPLOY] = d3deployment_old(recdir,prefix,uname)
%        Collect information about a deployment and create a deployment
%        'cal' file. The 'cal' file will be called <uname>cal.xml and
%        will be written to the CAL directory on the tag path (see
%        settagpath.m).
%        some old xml files don't have the field "EXP" and this is an
%        inexpert attempt to work around that.
%        Examples:
%            CAL=d3deployment('e:/data/bb10','bb215a','bb10_215a') ;
%        or  d3deployment('e:/data/bb10','bb10_215a') ;
%
%        markjohnson@st-andrews.ac.uk
%        26 feb 2013, sdr may 2013
%

DEPLOY = [] ; CAL = [] ;

if nargin<2,
   help d3deployment
   return
end

if nargin<3,
   uname = prefix ;
end

% make a filename for the deployment 'cal' file
global TAG_PATHS
if isempty(TAG_PATHS) || ~isfield(TAG_PATHS,'CAL'),
   fprintf(' No %s file path - use settagpath\n','CAL') ;
   return
end
ufname = sprintf('%s/%s',getfield(TAG_PATHS,'CAL'),[uname 'cal.xml']) ;

% check if a deployment file already exists - if so, check if overwriting is ok
if exist(ufname,'file'),
   ss = sprintf(' A deployment with the same name already exists.\n Do you want to overwrite it? y/n... ') ;
   s = input(ss,'s') ;
   if lower(s(1))=='n',
      return
   end
end

senssuffix = 'swv' ;
[fn,did,recn,recdir] = getrecfnames(recdir,prefix) ;
DEPLOY.ID = dec2hex(did(1)) ;
DEPLOY.NAME = [] ;
DEPLOY.RECN = recn ;
DEPLOY.RECDIR = recdir ;
DEPLOY.FN = fn ;
DEPLOY.SCUES = struct ;
for k=1:length(fn),
   d3=readd3xml([recdir fn{k} '.xml']) ;
   cues = d3.CUE ;
   for kk=1:length(cues),
      if strcmp(cues{kk}.SUFFIX,senssuffix)
         break ;
      end
   end
   cc = cues{kk} ;
   DEPLOY.SCUES.SAMPLE(k) = str2num(cc.SAMPLE) ;
   t = str2num(cc.TIME) ;
   t(end) = t(end) + str2num(cc.CUE) ;
   DEPLOY.SCUES.TIME(k,:) = t ;

   n = wavread16([recdir fn{k} '.swv'],'size') ;
   DEPLOY.SCUES.N(k) = n(1) ;
   cfg = cc.ID ;
end

% find the configuration entry in d3 for the sensor file
d3=readd3xml([recdir fn{1} '.xml']) ;
for k=1:length(d3.CFG),
   cc = d3.CFG{k} ;
   if strcmp(cc.ID,cfg),
      break
   end
end

% get the base sensor sampling rate
if ~isfield(cc,'EXP')
    cc.EXP = '-3';
end
sfs = str2num(cc.FS)*10^str2num(cc.EXP) ;

% check for timing errors in the sensor files
DEPLOY.SCUES.TERR(1) = 0 ;
for k=1:length(fn)-1,
   fdur = etime(DEPLOY.SCUES.TIME(k+1,:),DEPLOY.SCUES.TIME(k,:)) ;
   sdur = DEPLOY.SCUES.N(k)/sfs ;
   terr = fdur-sdur ;
   DEPLOY.SCUES.TERR(k+1) = terr ;
   if abs(terr)>0.001,
      fprintf('Sensor timing error of %3.3f ms between files %d and %d\n',...
         terr*1000,k,k+1);
   end
end

DEPLOY.SCUES.SSTART = DEPLOY.SCUES.TIME(1,:) ;

% look for a suitable CAL
[CAL,id,cname] = d3findcal(DEPLOY.ID) ;
if ~isempty(CAL),
   DEPLOY.NAME = cname ;
   DEPLOY.CAL = CAL ;
end

% create the deployment record file
writematxml(DEPLOY,'DEPLOY',ufname) ;

