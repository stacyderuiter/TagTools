function    [fnames,ochips] = d3makefnames(tag,type,chips)
%
%    [fnames,ochips] = makefnames(tag,type,chips)
%     Look for files of a particular type but with different chip suffixes.
%     Returns a cell array of filenames.
%     chips may be empty indicating to look for all chips with the
%     correct tag name.
%
%     mark johnson, WHOI
%     majohnson@whoi.edu
%     October, 2007
%     modified for dtag3, stacy deruiter, july 2011

if nargin<2,
   help makefnames
   return
end

MAXCHIPS = 999 ;
if nargin==2 | isempty(chips),
   SEARCH = 1 ;
   chips = 1:MAXCHIPS ;
else
   SEARCH = 0 ;
end

fnames = {} ; ochips = [] ;
for k=chips(:)',
   if k>0 & k<=MAXCHIPS,
      fn = d3makefname(tag,type,k) ;
      if exist(fn,'file'),
         fnames{length(fnames)+1} = fn ;
         ochips = [ochips;k] ;
      elseif SEARCH==0,
         fprintf(' Unable to find a file with name %s, skipping\n', fn) ;
      end
   else
      fprintf(' Bad chip number %03d in chip list - skipping\n', k) ;
   end
end
return
