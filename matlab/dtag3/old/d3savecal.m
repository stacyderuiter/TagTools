function    d3savecal(recdir,prefix,name,value)
%
%    d3savecal(recdir,prefix,name,value)
%     Save calibration information specific to a tag deployment.
%     An XML format file is generated and stored in the same
%     directory as the source data. The file is named <prefix>cal.xml
%     where <prefix> is the deployment name e.g., 'mn185a'.
%     Name is any valid field name for a DEPLOY structure.
%     To remove a field, use:
%     d3savecal(recdir,prefix,name)
%
%    mark johnson
%    markjohnson@st-andrews.ac.uk
%    last modified: July 2012

if nargin<2 | isempty(prefix),
   help d3savecal
   return
end

suffix = 'cal.xml' ;
% see if there is already a deployment-specific cal file started
DEPLOY = [] ;
fn = [recdir prefix suffix] ;
if exist(fn,'file'),
   readmatxml(fn) ;
else
   % get basic deployment information
   [ff,did,recn,recdir] = getrecfnames(recdir,prefix) ;
   DEPLOY.ID = did(1) ;
   DEPLOY.RECDIR = recdir ;
   DEPLOY.FILES = ff ;
   d3 = readd3xml([recdir ff{1} '.xml']) ;
   DEPLOY.TIME = sscanf(d3.CUE{1}.TIME,'%d,')' ;
end

if nargin>2,
   % update the DEPLOY information
   if nargin>3,
      DEPLOY = setfield(DEPLOY,name,value) ;
   else
      DEPLOY = rmfield(DEPLOY,name) ;
   end
end

writematxml(DEPLOY,'DEPLOY',fn) ;
