function		ncfile = convert_prh(prhfile,csvfile)

%		ncfile = convert_prh(prhfile,csvfile)
%		Example function to convert variables in an old PRH file (a Matlab
%		format file containing dive and motion data) into an nc file.
%		Inputs:
%		prhfile is a strong containing the name of the prhfile to convert
%		 The nc file will have the same base name but with a suffix sensD
%		 where D is the nearest integer to the sampling rate in Hz.
%		csvfile is a string containing the name of a CSV format text file
%		 with information to generate an info structure.

VARS = {'A','Aw','M','Mw','p','tempr'} ;
vtype = {'acc','acc','mag','mag','press','tempr'} ;
frm = [0 1 0 1 0] ;					% 0 = tag, 1 = animal
scf = [9.81,9.81,1,1,1] ;			% conversions to standard units

X=loadprh(prhfile) ;
info=csv2struct(csvfile);

fn = fieldnames(X) ;
if ~isfield(X,'fs'),
	fprintf(' PRH file must contain a variable fs with the sampling rate\n');
	return
end
	
fs = X.fs(1) ;
ncfile = sprintf('%s_sens%d',info.depid,round(fs));
save_nc(ncfile,info) ;

for k=1:length(VARS),
	k = strcmpi(fn,VARS{k}) ;
	if isempty(k), continue, end
	V=sens_struct(X.(fn{k})*scf(k),fs,info.depid,vtype{k});
	if frm(k) == 1,
		V.frame = 'animal' ;
		V.name(end+1) = 'a' ;
	else
		V.frame = 'tag' ;
	end
	add_nc(ncfile,V) ;
end
