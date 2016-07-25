function       [S,dv,U] = getxmlcue(fname)
%
%     [S,dv,U] = getxmlcue(fname)
%     Extract the CUE sentence from a D3 xml file.
%     Returns S = [local_time,sample_number] for the first CUE
%     sentence found. local_time is in second of the day.
%     dv is the 6-element date vector.
%     U is the unix time number corresponding to dv.
%     Note: no support for different SUFFIX attributes. This
%     routine returns the first CUE sentence found and will be
%     phased out soon.
%     e.g.,
%     S=getxmlcue('e:/by09/27oct/byDMON1_27oct09_006')
%
%     mark johnson, WHOI
%     29 October 2009

if nargin<1,
   help getxmlcue
   return
end

S = [] ; dv = [] ; U = [] ;

[Z,val] = getxmlfield(fname,'CUE') ;
if isempty(Z) | isempty(val),
   fprintf(' No complete CUE statement found\n') ;
   return
end

% get time attribute
k = strmatch('TIME',Z) ;
if isempty(k), fprintf(' No TIME attribute in CUE field\n') ; return, end
[ss,r] = strtok(Z{k},'"') ;
[ss,r] = strtok(r,'"') ;
T = sscanf(ss,'%d,%d,%d,%d,%d,%d',6)' ;

% get sample number attribute
k = strmatch('SAMPLE',Z) ;
if isempty(k), fprintf(' No SAMPLE attribute in CUE field\n') ; return, end
[ss,r] = strtok(Z{k},'"') ;
[ss,r] = strtok(r,'"') ;
S = str2double(ss) ;

F = str2double(val) ;
ltime = T(4:6)*[3600;60;1]+F ;
S = [ltime S] ;
dv = T+[zeros(1,5),F] ;
U = d3datevec(dv) ;
return
