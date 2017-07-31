function    s = merge_fields(s1,s2) 
%
%     s = merge_fields(s1,s2)
%     Merge the fields of two structures. If there are duplicate
%     fields, the fields in s1 are taken.
%
%		Inputs:
%		s1, s2 are arbitrary structures e.g., containing metadata or settings.
%
%		Returns:
%		s is a structure containing all of the fields in s1 and s2.
%
%		Examples:
%		s1 = struct('a',1,'b',[2 3 4])
%		s2 = struct('b',3,'c','cat')
%		s = merge_fields(s1,s2)
%		Returns: s containing s.b=[2,3,4], s.c='cat', s.a=1
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     Last modified: 5 May 2017

s = [] ;
if nargin<2,
   help merge_fields
   return
end

if ~isstruct(s1) & ~isstruct(s2),
	fprintf('Both inputs must be structures in mergefields\n') ;
	return
end
	
s = s2 ;
Z = fieldnames(s1) ;
for k=1:length(Z),
   s = setfield(s,Z{k},getfield(s1,Z{k})) ;
end
