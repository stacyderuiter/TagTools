function    [CAL,DEPLOY,devid] = d3findcal(recdir,prefix,caldir)
%
%    [CAL,DEPLOY,devid] = d3findcal(recdir,prefix,caldir)
%

CAL = [] ;
DEPLOY = [] ;
if ~isempty(prefix),
   % check first if a metadata file specific to the deployment has already
   % been made.
   fn = [recdir prefix 'cal.xml'] ;
   if exist([recdir prefix 'cal.xml'],'file'),
      readmatxml(fn) ;
      if isfield(DEPLOY,'CAL'),
         CAL = DEPLOY.CAL ;
         return
      end
   end
end

% otherwise, look for a cal file for the device in the caldir
[fn,devid,recn,recdir] = getrecfnames(recdir,prefix) ;
if nargin<3,
   caldir = [] ;
end
if ~isempty(caldir) & ~ismember(caldir(end),'/\'),
   caldir(end+1) = '/' ;
end

D = dir([caldir '*.xml']) ;
for k=1:length(D),
   readmatxml([caldir D(k).name]) ;
   if hex2dec(DEV.ID)==devid,
      CAL = DEV.CAL ;
      break ;
   end
end

if isempty(CAL),
   fprintf('Unable to find a CAL for device %s\n',dec2hex(did)) ;
end

