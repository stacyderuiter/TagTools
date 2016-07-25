function       [id,fullid] = getxmldevid(fname)
%
%     [id,fullid = getxmldevid(fname)
%     Extract the DEVID sentence from a D3 xml file.
%     Returns the short id as an 8 digit number and the
%     full id as a string. 
%
%     mark johnson
%     29 October 2009

id = [] ; fullid = [] ;

if nargin<1,
   help getxmldevid
   return
end

[Z,fullid]=getxmlfield(fname,'DEVID') ;
S = [] ;
if isempty(fullid),
   fprintf(' No complete DEVID statement found\n') ;
   return
end

% parse id string
ss = fullid ;
Z = {} ;
while ~isempty(ss),
   [Z{end+1},ss] = strtok(ss,',') ;
end
id = hex2dec(horzcat(Z{3:4})) ;
return
