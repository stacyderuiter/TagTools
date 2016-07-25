function    [t,fs] = d3reclength(recdir,prefix)
%
%     [t,fs] = d3reclength(recdir,prefix)
%

t = [] ; fs = [] ;

if nargin<2,
   help d3reclength
   return
end

[ct,fs] = d3getcues(recdir,prefix) ;
if ~isempty(ct),
   t = ct(end,end)/fs ;
end
return
