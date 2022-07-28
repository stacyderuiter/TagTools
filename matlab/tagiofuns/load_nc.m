function    X = load_nc(fname,vname,nodata)

%     load_nc
%     or
%     load_nc(fname)
%     or
%     load_nc(fname,vname)
%     or
%     load_nc(fname,vname,nodata)
%		or
%		X=load_nc(...)
%
%     Load variables from a NetCDF archive file. The file is assumed to be in 
%		the current working directory unless a pathname is added to the beginning 
%		of fname. If fname is not specified, a file selection window is opened.
%     If no output argument is given, the variables will be created in
%		the current workplace, overwriting any variables with the same name that are
%		already there. If an output argument is given, the variables will be stored
%		as fields of a structure.
%
%		Inputs:
%		fname is the name of the metadata file. If the name does not include a .nc
%		 suffix, this will be added automatically.
%     vname is the name of a single variable to read in. If not specified, or if
%      vname is empty, all variables in the file are read. vname can also be a 
%      cell array specifying multiple variables to read.
%     nodata if 1 all of the requested variables will be read in but with only 
%      their metadata fields, i.e., without data.
%
%		Returns:
%		X, if specified, is a structure containing sensor and metadata structures. The
%		 field names in X will be the same as the names of the variables in the NetCDF
%		 file, e.g., if the file contains A and P, X will have fields X.A, X.P and
%		 X.info (the file metadata). If no output argument is given, the
%		 variables will be created in the calling workplace.
%
%		Example:
%		 load_nc('testset1')
% 	    loads variables from file testset1.nc into the workplace.
%
%     Valid: Matlab, Octave
%     markjohnson@bios.au.dk
%     modified: 05 July 2018 added file selection ui window
%               05 June 2021 added nodata option

X = [] ;
if nargin<1,
   pth = [] ; udir = [] ;
   if exist('_loadnctemp.txt','file'),
      pth = char(load('_loadnctemp.txt','-ascii')) ;
   end
   if ~isempty(pth) && isdir(pth),
      udir = pwd ;
      cd(pth) ;
   end
   [fname,pth]=uigetfile('*.nc') ;
   if ~isempty(udir),
      cd(udir) ;
   end
   if isempty(fname) || (length(fname)==1 && fname(1)==0),
      help load_nc
      return
   end
   fname = [pth fname] ;
   save('_loadnctemp.txt','-ascii','pth') ;
end

% append .nc suffix to file name if needed
if length(fname)<3 || ~all(fname(end+(-2:0))=='.nc'),
   fname(end+(1:3))='.nc';
end

if ~exist(fname,'file'),
   fprintf(' File %s not found\n', fname);
	return ;
end

if nargin<2,
   vname = [] ;
end

if nargin<3,
   nodata = 0 ;
end

T = ncinfo(fname) ;
if ~isempty(T.Attributes),
   F = {T.Attributes(:).Name} ;
   V = {T.Attributes(:).Value} ;
   info = struct ;
   for k=1:length(F),
      info.(F{k}) = V{k} ;
   end

   if isempty(vname) || any(strcmp(vname,'info')),
      if nargout==0,
         assignin('caller','info',info) ;
      else
         X.info = info ;
      end
   end
end

% load the variables from the file
F = {T.Variables(:).Name} ;
for k=1:length(F),
	fn = F{k} ;
 	if fn(1)=='_', continue, end		% skip place-holder variable
   if ~isempty(vname) && all(strcmp(vname,fn)==0), continue, end
   if nodata == 1,
      X.(fn).data = [] ;
   else
   	X.(fn).data = ncread(fname,fn);
   end
   
	if (T.Variables(k).Size(1)==1) && (X.(fn).data(1) == T.Variables(k).FillValue), %RJS updated 2017-08-02
		X.(fn).data = [] ;
	end
	
	attr = T.Variables(k).Attributes ;
	if ~isempty(attr),
		f = {attr(:).Name} ;
		v = {attr(:).Value} ;
		for kk=1:length(f),
			X.(fn).(f{kk}) = v{kk} ;
		end
	end
end

if isempty(X),
   return
end
   
% if no output argument, push the variables into the calling workspace
if nargout==0,
   F = fieldnames(X) ;
	for k=1:length(F),
		fn = F{k} ;
		if fn(1)=='_', continue, end		% skip place-holder variable
		assignin('caller',fn,X.(fn)) ;
	end
	clear X
end	
return
