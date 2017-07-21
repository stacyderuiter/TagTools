function		addnc(fname,X)

%		addnc(fname,X)
%		Add a variable to a NetCDF archive file. If the archive file does not exist,
%		it is created. The file is assumed to be in the current working directory 
%		unless a pathname is added to the beginning of fname.
%
%		Inputs:
%		fname is the name of the metadata file. If the name does not include a .nc
%		 suffix, this will be added automatically.
%		X is a sensor or metadata structure. Only these kind of variables can be saved
%		 in a NetCDF file because the supporting information in these structures is
%		 needed to describe the contents of the file. For non-archive and non-portable
%		 storage of variables, consider using the usual 'save' function in Matlab and Octabe.
%
%		Example:
%		 addnc('dog17_124a',A)
% 	    generates a file dog17_124a.nc and adds a variable A.
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     last modified: 12 July 2017

if nargin<2,
	help savenc
end
	
if ~isstruct(X),
	fprintf('savenc can only save sensor or metadata structures\n') ;
	return
end
	
% append .nc suffix to file name if needed
if length(fname)<3 || ~all(fname(end+(-2:0))=='.nc'),
   fname(end+(1:3))='.nc';
end

% test if X is a metadata structure or a sensor structure
if ~isfield(X,'name')
	vname = [] ;
else
	vname = X.name ;
end

% check that the deployment ID of X matches the one in the file if the file
% already exists
depid = [] ;
if exist(fname,'file'),
	S = ncinfo(fname) ;
	k = find(strcmp({S.Attributes(:).Name},'depid')) ;
	if ~isempty(k),
		depid = S.Attributes(k).Value ;
		if strcmp(depid,X.depid)==0
			fprintf('File already associated with deployment id: %s. Choose a different file name.\n', depid);
			return ;
		end
	end
			
	% check if there is already a variable with this name in the file
	k = find(strcmp({S.Variables(:).Name},vname)) ;
	if ~isempty(k),
		fprintf('Variable %s already exists in file: choose a different name\n',vname) ;
		return
	end
end

% now ready to save the structure
if ~isempty(vname),		% X is a sensor structure
	if ~isfield(X,'data') || isempty(X.data),
		nccreate(fname,vname);
	else
		nccreate(fname,vname,'Dimensions',{'samples',size(X.data,1),'axis',size(X.data,2)});
		ncwrite(fname,vname,X.data);
	end

	ncwriteatt(fname,vname,'name',X.name);
	if isfield(X,'fs'),
		ncwriteatt(fname,vname,'sampling','regular');
		ncwriteatt(fname,vname,'sampling_rate',X.fs);
		ncwriteatt(fname,vname,'sampling_rate_unit','Hz');
	end
	
	if ~isfield(X,'meta'),
		fprintf('Warning: No metadata in variable %s\n',X.name);
	else
		F = fieldnames(X.meta) ;
		V = struct2cell(X.meta) ;
		for k=1:length(F),
			if ~ischar(V{k})
				fprintf('All metadata fields must be strings: leaving field %s blank\n',F{k}) ;
				ncwriteatt(fname,vname,['meta_' F{k}],'') ;
			else
				ncwriteatt(fname,vname,['meta_' F{k}],V{k}) ;
			end
		end
	end

	% save some default file attributes if none are present
	if isempty(depid),
		ncwriteatt(fname,'/','depid',X.depid);
		depid = X.depid ;
	end
	ncwriteatt(fname,'/','creation_date',datestr(now));
	return
end	

% Otherwise X is a metadata structure. Add it to the general attributes for the file
% Overwrite any field already present
if isempty(depid),
	nccreate(fname,'_empty');
end

F = fieldnames(X) ;
V = struct2cell(X) ;
for k=1:length(F),
	if ~ischar(V{k})
		fprintf('All metadata fields must be strings: leaving field %s blank\n',F{k}) ;
		ncwriteatt(fname,'/',F{k},'') ;
	else
		ncwriteatt(fname,'/',F{k},V{k}) ;
	end
end

ncwriteatt(fname,'/','creation_date',datestr(now));
return
