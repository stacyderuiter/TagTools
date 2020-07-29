function    n=change_fnames(recdir,prefix,newprefix)

%     n=change_fnames(recdir,prefix,newprefix)
%		Change the names of files in a directory. This is useful for
%		changing the names of a set of files from a tag deployment to
%		a different format. Only the first part of the name matching
%		the prefix is changed - any trailing letters or numbers are kept.
%		Careful: things can go very wrong when messing with valuable data 
%		files. Always do a check first on some dummy files. There may also
%		be better ways to do re-naming operations through your operating
%		system.
%
%		Inputs:
%		recdir is a string containing the full or relative (to the current 
%		 working directory) pathname of the directory where the files are stored.
%		prefix is a string containing the part of the file name to be changed.
%		newprefix is a string containing the replacement.
%
%		Returns:
%		n is the number of files that were re-named.
%
%		Example:
%		 change_fnames('/tag/data/zc17','zc17_173a','zc17_172a')
% 	    renames all files in /tag/data/zc17 called zc17_173a* to zc17_172a*.
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     last modified: 12 July 2017


n = 0;
if nargin<3,
	help change_fnames
	return
end
	
recdir(recdir == '/') = '\' ;    % need to do this for Windows machines
                                 % not sure about Unix/Mac
                                 
if ~isempty(recdir) && ~ismember(recdir(end),{'\','/'}),
   recdir(end+1) = '\' ;
end

fn = dir([recdir,prefix,'*.*']) ;
n = 0 ;
for k=1:length(fn),
   ofn = [newprefix fn(k).name(length(prefix)+1:end)] ;
   instr = sprintf('rename "%s%s" "%s"',recdir,fn(k).name,ofn) ;
   [status,result] = system(instr) ;
   if status ~= 0,
      fprintf(['Failed with message: ',result]) ;
   else
      n = n+1 ;
   end
end
