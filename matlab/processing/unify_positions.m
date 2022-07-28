function		POS = unify_positions(POS,thr)

%		POS = unify_positions(POS,thr)
%
%		Group positions fixes that are less than thr seconds apart,
%		and return the mean time and position of each group. This is
%		useful with GPS tags on marine animals that come to the surface
%		occasionally. The tags may record several close positions when the
%		animal surfaces followed by a long gap when the animal is submerged.
%
%		Inputs:
%		POS is a sensor structure containing the time, latitude, and
%		 longitude of positional fixes. POS can have additional columns
%		 and these will also be averaged.
%		thr is the time threshold for unification in seconds.
%
%		Returns:
%		POS is a sensor structure with the same data columns as the
%		 input data but with fewer rows if any positions were closer
%		 than thr seconds apart.
%
%		markjohnson@bio.au.dk
%		Last modified: 31 may 2022

if nargin<2,
	help unify_positions
	return
end

d = POS.data ;
kg = find(abs(diff(d(:,1)))>thr) ;
kg = [0;kg;size(d,1)] ;
upos = [] ;

for k=1:length(kg)-1,
	if kg(k+1)-kg(k)==1,
		upos(end+1,1:size(d,2)) = d(kg(k)+1,:) ;
   else
		upos(end+1,1:size(d,2)) = mean(d(kg(k)+1:kg(k+1),:)) ;
	end
end

POS.data = upos ;
s = sprintf('unify_positions(%f)',thr) ;
if ~isfield(POS,'history') || isempty(POS.history)
	POS.history = s ;
else
	POS.history = [POS.history ',' s] ;
end
	