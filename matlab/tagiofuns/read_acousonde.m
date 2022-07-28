function    X = read_acousonde(fbase,depid,species,owner,df,fnums,chs)

%    read_acousonde(fbase,depid,species,owner)
%    or
%    read_acousonde(fbase,depid,species,owner,df)
%    or
%    read_acousonde(fbase,depid,species,owner,df,fnums)
%    or
%    read_acousonde(fbase,depid,species,owner,df,fnums,chs)
%    
%     Read sensor data from a set of Acousonde MT files and convert
%     to sensor structure format.
%     Inputs:
%     fbase is a string containing the full path name and first two letters
%      of the Acousonde files to be read. e.g., 'd:/mn19/mn19_192a/MN'
%     depid is a string containing the name assigned to this deployment,
%      e.g., 'mn19_192a'.
%     species is a string containing the two letter species prefix, e.g. 'mn'. 
%      This should match one or more of the species defined in the file 
%      user/species.csv. If there is more than one match, you will be asked 
%      to select the species from a list of matches.
%     owner is a string containing the initials of the nominal data owner
%      (the person who will be identified in the sensor metadata as whom to
%      approach for data access). This should match one or more of the 
%      researchers defined in the file user/researchers.csv. If there is 
%      more than one match, you will be asked to select the person from a 
%      list of matches.
%     df specifies an optional integer decimation factor to apply to each
%      sensor channel. If not specified, no decimation is performed.
%     fnums is an optional vector containing the file numbers to read. If
%      fnums is not specified or is empty, all of the files will be read.
%     chs is an optional string containing the letters of the channels to
%      read, e.g., chs='PIJK' would read just the pressure and
%      acceleration. If chs is not specified or is empty, all of the
%      channels will be read.
%
%     Output:
%     If no output is specified, variables will be generated directly in the
%     workspace. If an output variable is specified, the variables will be
%     stored as fields in a structure, e.g., X.info, X.P etc, if the
%     calling line is X=read_acousond(...).
%
%     markjohnson@st-andrews.ac.uk
%     last modified: 19 Jan 2020

X = [] ;
if nargin<4,
   help read_acousonde
   return
end

if nargin<5,
   df = 1 ;
end

if nargin<6,
   fnums = [] ;
end

if nargin<7,
   chs = 'ijklpxyz' ;
end

info = make_info(depid,'ac',species,owner) ;
X.info = info ;
ff = dir([fbase '*.mt']) ;
ftype = '' ;
fn = [] ;
for k=1:length(ff),
   nm = strtok(ff(k).name,'.') ;
   fn(end+1) = str2double(nm(4:end)) ;
   ftype(end+1) = nm(3) ;
end

fn = unique(fn) ;
ftype = lower(unique(ftype)) ;
if ~isempty(fnums),
   fn = fn(ismember(fn,fnums)) ;
end
if ~isempty(chs),
   ftype = ftype(ismember(ftype,lower(chs))) ;
end

if isempty(fn),
   if isempty(fnums),
      fprintf(' No recordings matching %s*.mt\n',fbase) ;
   else
      fprintf(' No recordings matching %s*.mt with numbers %d to %d\n',...
         fbase,min(fnums),max(fnums)) ;
   end
   return
end

fprintf('\n %d recordings found\n',length(fn)) ;
chname = {} ;
DD = {} ;
TT = {} ;
stt = [] ;
fnames = '' ;
for k=1:length(ftype),
   fprintf(' Reading sensor channel %c\n',ftype(k)) ;
   D = [] ;
   T = [] ;
   for kk=1:length(fn),
      fname = [fbase ftype(k) sprintf('%05d',fn(kk)) '.mt'] ;
      fnames = [fnames 'fname,'] ;
      [d,hdr,md] = MTRead(fname);	% use acousonde raw data reader function
      if kk==1,
         chname{k} = hdr.abbrev ;
      end
      D(end+(1:length(d))) = d ;
      T(end+1,:) = [md.datenumber str2double(hdr.msec) md.srate md.count] ;
   end
   T(:,5:6) = T(:,3:4) ;
   if df>1,
      D = decdc(D(:),df) ;
      T(:,5:6) = T(:,3:4)/df ;
   end
   DD{k} = D(:) ;
   TT{k} = T ;
end

X.timing = TT ;
vtypes = {'Accel','Light','Press','Mag'} ;
stypes = {'acc','light','press','mag'} ;
conv = [9.81/1000,1,1,10] ;   % conversion factors between Acousonde units and SI

for k=1:length(vtypes),
   kch = find(strncmp(vtypes{k},chname,3)) ;
   if isempty(kch), continue, end
   if length(kch)==1,
      x = DD{kch} ;
   else
      axn = lower(vertcat(chname{kch})) ;
      [ll,kax] = sort(axn(:,end)) ;
      x = horzcat(DD{kch(kax)}) ;
   end
   x = conv(k)*x ;
   v = sens_struct(x,TT{kch(1)}(1,5),depid,stypes{k}) ;
   X.(v.name) = v ;
end

stt = datestr(datevec(TT{1}(1)),info.dephist_device_regset) ;
info.device_serial = hdr.sourcesn ;
info.sensors_firm = hdr.sourcevers ;
info.dephist_deploy_datetime_start = stt ;
info.dephist_device_datetime_start = stt ;
info.dephist_device_tzone = 'UNKNOWN' ;
info.dtype_nfiles = length(fn)*length(ftype) ;
info.dtype_source = fnames(1:end-1) ;
info.project_name = hdr.title ;
if isfield(X,'LL'),
   info.sensors_list = [info.sensors_list,',Light'] ;
end
X.info = info ;

if nargout~=0,
   return
end

% if no output argument, push the variables into the calling workspace
F = fieldnames(X) ;
for k=1:length(F),
	assignin('caller',F{k},X.(F{k})) ;
end
clear X
return
