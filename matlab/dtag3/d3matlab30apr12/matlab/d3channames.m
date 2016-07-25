function    [ch_names,descr,ch_nums] = d3channames(d3dir,ch)
%
%    [ch_names,descr,ch_nums] = d3channames(d3dir,ch)
%     Extract sensor channel names and descriptions from
%     the sensor definitions file in the D3 distribution.
%     d3dir is the path of the D3 directory (including the
%     d3) e.g., /tag/projects/d3'.
%     ch is a list of sensor numbers or names for which
%     numbers, names and/or descriptions are required. 
%
%     Returns:
%     uchans is a vector of sensor channel numbers following the D3 
%        sensordefs codes.
%     channames is a cell array of sensor channel names.
%     descr is a cell array of sensor channel descriptions.
%
%     Example:
%     [names,descr,nums] = d3channames('/tag/projects/d3',[37121 37123])
%     [names,descr,nums] = d3channames('/tag/projects/d3',{'D2_MX','D2_MZ'})
%
%     mark johnson
%     Univ. St. Andrews
%     February 2012

if nargin<1,
   help d3channames
   return ;
end

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

fclose(f) ;
if nargin<2 | isempty(ch),
   return
end

if iscell(ch) | isstr(ch),
   [kk,k] = ismember(ch,ch_names) ;

else
   [kk,k] = ismember(ch,ch_nums) ;
end
   
if any(k==0),
   fprintf('Warning: unknown sensor types in ch - skipping\n') ;
   k = k(k~=0) ;
end
ch_nums = ch_nums(k) ;
ch_names = {ch_names{k}} ;
descr = {descr{k}} ;
ch_nums = ch_nums(:) ;
if length(ch_nums)==1,
   ch_names = ch_names{1} ;
   descr = descr{1} ;
end
