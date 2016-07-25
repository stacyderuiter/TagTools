function       [attr,val] = getxmlfield(fname,fld)
%
%     [attr,val] = getxmlfield(fname,fld)
%     Extract the field with name fld from a D3 xml file called fname.
%     Returns the attributes in a cell array and the field value
%     in a string or cell array of strings.
%     Status: quick and dirty - need to improve later
%
%     mark johnson
%     29 October 2009

attr = {} ; val = '' ;

if nargin<1,
   help getxmlfield
   return
end

if strcmp(fname(end+(-3:0)),'.xml')==0,
   fname = [fname,'.xml'] ;
end

f = fopen(fname,'rt') ;
if f<0,
   fprintf('Cannot open file %s\n',fname) ;
   return
end

while 1,
   ss = fgetl(f) ;
   if isempty(ss) | ss<0, ss = [] ; break, end
   if strncmp(ss,['<' fld],length(fld)+1),
      break
   end
end

if isempty(ss),
   fprintf(' No %s field in file %s\n', fld,fname) ;
   fclose(f) ;
   return
end

% get the attributes, if any
k1 = min(find(ss=='>')) ;    % find the end of the field statement
[z sa] = strtok(ss(1:k1-1),' ><') ;    % skip over the field name
attr = {} ;
while ~isempty(sa),
   [z sa] = strtok(sa,' ><') ;
   if ~isempty(z),
      attr{end+1} = z ;
   end
end

ss = ss(k1+1:end) ;
% get the value - may be multi-line
% first check for empty values
if ~isempty(strfind(ss,'/>')),
   val = [] ;
   fclose(f) ;
   return
end

% check for single line values
k2 = strfind(ss,'</') ;
if ~isempty(k2),
   v = ss(1:k2-1) ;
else
   v = ss ;
   while 1,
      ss = fgetl(f) ;      % read the next line
      if isempty(ss),      % field is unclosed
         val = [] ;
         fclose(f) ;
         return
      end
      k2 = strfind(ss,'</') ;
      if(isempty(k2)),
         v = [v ss] ;
      else
         v = [v ss(1:k2-1)] ;
         break
      end
   end
end

% break the value into tokens
val = {} ;
while ~isempty(v),
   [tok,v] = strtok(v) ;
   if ~isempty(tok),
      val{end+1} = tok ;
   end
end
fclose(f) ;
if isempty(val),
   val = [] ;
end
if length(val)==1,
   val = val{1} ;
end
return
