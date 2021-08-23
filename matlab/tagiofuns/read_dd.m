function 	ncfile = read_dd(fname,depid)

% 		ncfile = read_dd(fname,depid)
%		Read data files from a Daily Diary data Logger. This function 
%     generates a netCDF file in the current working directory containing:
%		A Accelerometer data structure
% 		M Magnetometer data structure
% 		T Temperature sensor data structure
%		info	Information structure for the deployment
%      
% 		Inputs:
%     fname is the file name of the Daily Diary text file including the complete 
%      path name if the file is not in the current working directory or in a
%      directory on the path. The .txt suffix is not needed.
% 		depid is a string containing the deployment identification code assigned
%      to this deployment, for example, mn12_186a.
%  
% 		Results:
%     ncfile is the name of the NetCDF file containing the tag data. It will
%      be 'depid'_raw.nc (e.g., mn12_186a_raw.nc).
%
% 		Example:
% 		fn = read_dd('C:\tag\octave\tagtools\testdata\dd_oa14_319a\oa_14_319a_data','oa14_319a')
%		load_nc(fn)
%		% The workspace should now contain variables A, M, T and info
%		% each of which is a structure.
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     last modified: July 2017

if nargin<1,
    help read_dd
    return
end

[V,HDR] = read_tdr10dd_csv(fname) ;
info.depid=depid;
info.data_source=fname;
info.data_nfiles=1;
info.data_format='txt';
info.device_serial=[];
info.device_make='Wildlife Computers / Wildbytes';
info.device_type='Archival';
info.device_model_name='Daily Diary';
info.device_model_version=[];
info.device_url=[];
info.sensors_list='3 axis Accelerometer,3 axis Magnetometer,Temperature';
info.dephist_device_tzone='unknown';
info.dephist_device_regset='dd-mm-yyyy HH:MM:SS';
info.dephist_device_datetime_start=datestr(V(1,1));

T = V(:,1)-V(1,1);
FS = diff(find(diff(T)>0,2)) ;		% inferred sampling rate in Hertz
ncfile = [depid '_raw'] ;
save_nc(ncfile,info) ;
save_sens_struct3(V,depid,HDR,FS,fname,'Acc','acc') ;
save_sens_struct3(V,depid,HDR,FS,fname,'Mag','mag') ;
save_sens_struct1(V,depid,HDR,FS,fname,'Temp','Ext_t') ;
return


function		save_sens_struct3(X,depid,CH,FS,fname,name,type)
%
k = find(strncmpi(CH,name,length(name))) ;
if ~isempty(k),
	if length(k)<3,
		fprintf(' Warning: %d axes of %s missing in data\n',3-length(k),name) ;
	end
	ax = strvcat(CH{k}) ;
	ax = ax(:,end)' ;
	[ax,I] = sort(abs(ax)) ;		% sort into order of X, Y and Z
	k = k(I) ;
	if strcmpi(type,'acc'),
		scf = 9.81 ;	% inferred acceleration unit is g. Multiply by 9.81 to get m/s2
	else
		scf = 100 ;		% inferred magnetometer unit is gauss. Multiply by 100 to get uT
	end
	S = sens_struct(X(:,k)*scf,FS,depid,type) ;
	S.history = 'read_dd' ;
	S.files = fname ;
	add_nc([depid '_raw'],S) ;
end


function		save_sens_struct1(X,depid,CH,FS,fname,name,type)
%
k = find(strncmpi(CH,name,length(name))) ;
if ~isempty(k),
	if length(k)>1,
		fprintf(' Warning: more than one axis of %s found in data\n',name) ;
	end
	k = k(1) ;
	S = sens_struct(X(:,k),FS,depid,type) ;
	S.history = 'read_dd' ;
	S.files = fname ;
	add_nc([depid '_raw'],S) ;
end

	
