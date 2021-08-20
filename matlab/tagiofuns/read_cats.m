function 	ncfile = read_cats(fname,depid)

% 		ncfile = read_cats(fname,depid)
%		Read data files from a CATS data Logger. This function
%     generates a netCDF file in the current working directory containing
%		the variables in the data file including:
%		A Accelerometer data structure
% 		M Magnetometer data structure
% 		T Temperature sensor data structure
%		info	Information structure for the deployment
%      
% 		Inputs:
%     fname is the file name of the CATS csv file including the complete 
%      path name if the file is not in the current working directory or in a
%      directory on the path. The .csv suffix is not needed.
% 		depid is a string containing the deployment identification code assigned
%      to this deployment, for example, mn12_186a.
%  
% 		Results:
%     ncfile if the name of the NetCDF file containing the tag data. It will
%      be 'depid'_raw.nc (e.g., mn12_186a_raw.nc).
%
%		Warning: CATS loggers can produce very large csv files which are slow to
%		process. This function is optimised for speed and memory use so will
%		tolerate large files. But processing could be slow.
%
% 		Example:
% 		fn = read_cats('cats_test_sample','mn16_209a')
%		load_nc(fn)
%		% The workspace should now contain variables A, M, G, T, P, L and info
%		% each of which is a structure.
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     last modified: 22 July 2017

if nargin<2,
    help read_cats
    return
end

[V,HDR] = read_cats_csv(fname) ;
info.depid=depid;
info.data_source=fname;
info.data_nfiles=1;
info.data_format='csv';
info.device_serial=[];
info.device_make='CATS';
info.device_type='Archival';
info.device_model_name=[];
info.device_model_version=[];
info.device_url=[];
info.dephist_device_tzone=0;
info.dephist_device_regset='dd-mm-yyyy HH:MM:SS';
info.dephist_device_datetime_start=datestr(V(1,1));

dT = diff(V(:,1)-V(1,1));
md = median(dT) ;
km = find(abs(dT-md)<0.5*md) ;
if length(km)<0.75*length(dT),
	fprintf('Warning: Many gaps in sampling. Inferred sampling rate may be inaccurate\n') ;
end	
FS = 1/(mean(dT(km))*3600*24) ;		% inferred sampling rate in Hertz

% find out which sensors are present
Sens = {'Acc','Mag','Gyr','Temp','Depth','Light'} ;
% TODO: find out what to do about GPS and other sensor channels
sl = '' ; SS = zeros(length(Sens),1) ;
ax = [3,3,3,1,1,1] ;
Sens_name = {'3 axis Accelerometer','3 axis Magnetometer','3 axis Gyroscope',...
	'Temperature','Pressure','Light level'} ;

for k=1:length(Sens),
	if any(strncmpi(HDR,Sens{k},length(Sens{k}))),
		sl = [sl,',',Sens_name{k}] ;
		SS(k) = 1 ;
	end
end

info.sensors_list = sl(2:end) ;
ncfile = [depid '_raw'] ;
save_nc(ncfile,info) ;

for k=1:length(Sens),
	if SS(k),
		save_sens_struct(V,depid,HDR,FS,fname,Sens{k},ax(k)) ;
	end
end
return


function		save_sens_struct(X,depid,CH,FS,fname,name,naxes)
%
k = find(strncmpi(CH,name,length(name))) ;
if ~isempty(k),
	if length(k)<naxes,
		fprintf(' Warning: %d axes of %s missing in data\n',naxes-length(k),name) ;
	end
	if naxes>1,
		ax = strvcat(CH{k}) ;
		ax = ax(:,end)' ;
		[ax,I] = sort(abs(ax)) ;		% sort into order of X, Y and Z
		k = k(I) ;
	else
		k = k(1) ;
	end
	if strncmpi(name,'gyr',3),
		scf = 0.001 ;	% gyroscope unit is mrad/s. Multiply by 0.001 to get rad/s
	else
		scf = 1 ;		% all other units are standard
	end
	S = sens_struct(X(:,k)*scf,FS,depid,name) ;
	S.history = 'read_cats' ;
	S.files = fname ;
	if strncmpi(name,'light',5),
		S.unit = '1' ;
		S.unit_name = 'counts' ;
		S.unit_label = 'counts' ;
	end
	add_nc([depid '_raw'],S) ;
end
