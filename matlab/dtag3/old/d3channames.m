function    [ch_names,descr,ch_nums] = d3channames(d3dir,ch)
%
%    [ch_names,descr,ch_nums] = d3channames(d3dir,ch)
%     Extract sensor channel names and descriptions from
%     the sensor definitions file in the D3 distribution.
%     d3dir is the path of the D3 directory (including the
%     d3) e.g., /tag/projects/d3'.
%     ch is an optional list of sensor numbers for which
%     names and descriptions are required. If ch is not given,
%     all sensor channels are returned
%

%if nargin<2,
%   help d3channames
%   return ;
%end

ch_names = [] ;
descr = [] ;
fname = '/api/include/sensdefs.h' ;
if ismember(d3dir(end),{'/','\'}),
   d3dir = d3dir(1:end-1) ;
end

f = fopen([d3dir fname],'rt') ;
if f<=0,
   fprintf('Unable to find sensor definition file %s\n',[d3dir fname]) ;
   return ;
end

ch_names = {} ;
ch_nums = [] ;
descr = {} ;

while 1,
   s = fgets(f) ;
   if isempty(s) | s==-1, break, end
   if s(1) ~= '#',
      continue
   end
   % discard the #define token
   [t,s] = strtok(s) ;
   [cname,s] = strtok(s) ;          % channel name
   [cnum,s] = strtok(s) ;     % channel number in hex
   [t,cdescr] = strtok(s) ;    % discard comment delimiter
   ch_names{end+1} = cname ;
   % parse cnum
   if cnum(1)=='(',
      cnum = cnum(2:end-1) ;
   end
   ch_nums(end+1) = sscanf(cnum,'%x',1) ;
   % trim white space at start and end of cdescr
   k = find(~isspace(cdescr)) ;
   descr{end+1} = cdescr(k(1):k(end)) ;
end

if nargin>1 & ~isempty(ch),
   [kk,k] = ismember(ch,ch_nums) ;
   ch_nums = ch_nums(k) ;
   ch_names = {ch_names{k}} ;
   descr = {descr{k}} ;
end

ch_nums = ch_nums(:) ;
if length(ch_nums)==1,
   ch_names = ch_names{1} ;
   descr = descr{1} ;
end
fclose(f) ;
