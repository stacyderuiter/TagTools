function		remove_nc(fname,vname)

%		remove_nc(fname,vname)
%		Remove a variable from a NetCDF archive file. The file is assumed to be in 
%     the current working directory unless a pathname is added to the beginning of fname.
%     Only data variables can be deleted, not the info metadata structure.
%
%		Inputs:
%		fname is the name of the metadata file. If the name does not include a .nc
%		 suffix, this will be added automatically.
%		vname is the name of the variable to be removed.
%
%		Example:
%		 remove_nc('dog17_124a','A')
% 	    removes variable A from file dog17_124a.nc.
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     last modified: 6 December 2018

if nargin<2,
	help remove_nc
end
	
if ~ischar(vname),
	fprintf('Variable name to remove_nc must be a string\n') ;
	return
end
	
% append .nc suffix to file name if needed
if length(fname)<3 || ~all(fname(end+(-2:0))=='.nc'),
   fname(end+(1:3))='.nc';
end

try
   T = ncinfo(fname) ;
catch
   fprintf('Unable to find file %s\n', fname)
   return
end

k = strcmp(vname,{T.Variables.Name}) ;

if sum(k)==0,
   if strcmp(vname,'info'),
      fprintf('info metadata cannot be removed from an nc file\n') ;
   else
      fprintf('No variable called %s in file %s\n',vname,fname) ;
   end
   return
end

tempname = '_temp.nc' ;
if exist(tempname,'file'),
   delete(tempname)
end

X = load_nc(fname,'info') ;
save_nc(tempname,X.info) ;

% copy the variables from the source file
F = {T.Variables(:).Name} ;
for kv=1:length(F),
	fn = F{kv} ;
 	if k(kv)==1 || fn(1)=='_', continue, end		% skip place-holder or unwanted variables
   X = load_nc(fname,fn) ;
   add_nc(tempname,X.(fn)) ;
end

% now overwrite old file with new file
delete(fname) ;
[status,result] = movefile(tempname,fname) ;
if status == 0,
   fprintf(['File rename failed with message: ',result]) ;
end

ncwriteatt(fname,'/','creation_date',datestr(now));
return
