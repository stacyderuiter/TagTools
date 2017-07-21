function 	ncfile = read_ll3m(datapath,depid)

% 		ncfile = read_ll3m(datapath,depid)
%		Read data files from a Little Leonardo LL3M data Logger. This functions 
%     generates a netCDF file in the current working directory containing:
%		A Accelerometer data structure
% 		M Magnetometer data structure
% 		P Pressure sensor data structure
% 		T Temperature sensor data structure
% 		S Speed sensor (propeller) data structure
%		info	Information structure for the deployment
%      
% 		Inputs:
% 		datapath is a string containing the path to the directory containing 
%      Little Leonardo raw binary text files.
% 		depid is a string containing the deployment identification code assigned
%      to this deployment, for example, mn12_186a.
%  
% 		Results:
%     ncfile if the name of the NetCDF file containing the tag data. It will
%      be 'depid'_raw.nc (e.g., mn12_186a_raw.nc).
%
% 		Example:
% 		datapath='C:\tagTools\testdata\mn12_186a'
% 		depid='mn12_186a'
% 		read_ll3m(datapath,depid)
%		loadnc([depid '_raw'])
%		% The workspace should now contain variables A, M, P, T, S and info
%		% each of which is a structure.
%
%     Valid: Matlab, Octave
%     rjs30@st-andrews.ac.uk and markjohnson@st-andrews.ac.uk
%     last modified: July 2017

if nargin<2 || ~exist(datapath,'dir')
    help read_ll3m
    return
end

if ~isempty(datapath) && ~ismember(datapath(end),'\/'),
	datapath(end+1) = '/' ;
end
	
files = dir([datapath '*.txt']);    % Source (raw) binary file

if isempty(files),
   fprintf(' No files found in %s\n',datapath) ;
   return
end

X = cell(length(files),1) ; CH = cell(length(files),1) ; 
STT = cell(length(files),1) ; FS = zeros(length(files),1) ;
for k=1:length(files),
	hdr = read_csv([datapath files(k).name],[],[1 10]) ;		% read the header in lines 1..10
	X{k} = dlmread([datapath files(k).name],'\t',10,0) ;		% read the data in the remainder of the file	[X{end+1},hdr] = read_llm3file(fname) ;
		
	% LL3M file header comprises 10 lines:
	% File name
   % Channel
   % Units        
   % Total record             
   % Record No.             
   % Start location               
   % Start date    
   % Start time      
   % Data size        
   % Interval(Sec)       

	CH{k} = strip_quotes(hdr{2,2}) ;						% sensor channel
	STT{k} = [strip_quotes(hdr{7,2}),' ',strip_quotes(hdr{8,2})] ;		% date and time
	FS(k) = 1./str2num(hdr{10,2}) ;		% convert sampling interval to sampling rate
end

stt = datestr(datenum(STT,'dd/mm/yyyy HH:MM:SS')) ;
info.depid=depid;
info.device_serial=[];
info.device_make='Little Leonardo Inc., Japan';
info.device_type='Archival';
info.device_model_name=[];
info.device_model_version=[];
info.device_url=[];

ncfile = [depid '_raw'] ;
savenc(ncfile,info) ;
save_sens_struct3(X,depid,CH,FS,files,'Acceleration','acc') ;
save_sens_struct3(X,depid,CH,FS,files,'Compass','mag') ;
save_sens_struct1(X,depid,CH,FS,files,'Depth','pr') ;
save_sens_struct1(X,depid,CH,FS,files,'Temperature','Int_t') ;
save_sens_struct1(X,depid,CH,FS,files,'Propeller','sp') ;
return


function		save_sens_struct3(X,depid,CH,FS,files,name,type)
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
	S = sens_struct([X{k}],FS(k(1)),depid,type) ;
	S.history = 'read_ll3m' ;
	S.unit = '1' ;
	S.unit_name = 'counts' ;
	S.unit_label = 'counts' ;
	fn = strcat([files(k).name ',']) ;
	S.files = fn(1:end-1) ;
	addnc([depid '_raw'],S) ;
end


function		save_sens_struct1(X,depid,CH,FS,files,name,type)
%
k = find(strncmpi(CH,name,length(name))) ;
if ~isempty(k),
	if length(k)>1,
		fprintf(' Warning: more than one axis of %s found in data\n',name) ;
	end
	k = k(1) ;
	ax = strvcat(CH{k}) ;
	S = sens_struct([X{k}],FS(k),depid,type) ;
	S.history = 'read_ll3m' ;
	S.unit = '1' ;
	S.unit_name = 'counts' ;
	S.unit_label = 'counts' ;
	fn = strcat([files(k).name ',']) ;
	S.files = fn(1:end-1) ;
	addnc([depid '_raw'],S) ;
end

	
