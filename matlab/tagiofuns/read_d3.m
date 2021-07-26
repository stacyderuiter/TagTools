function    ncfile = read_d3(recdir,prefix,depid,df)

%     ncfile = read_d3(recdir,prefix)
%	   or
%     ncfile = read_d3(recdir,prefix,depid)
%	   or
%     ncfile = read_d3(recdir,prefix,df)
%	   or
%     ncfile = read_d3(recdir,prefix,depid,df)
%
%     Reads a sequence of D3 format SWV (sensor wav) sensor files
%     and assembles a continuous sensor sequence in x. This function
%     calls read_d3_swv to read in each file and is optimised to handle
%		long sequences of sensor files.
%
%		Inputs:
%     recdir is a string containing the full path name to the directory
%		 where the files are stored. Use recdir=[] if the files are in the
%		 current working directory. All SWV files in the directory will
%		 be read.
%     prefix is the first part of the name of the files to analyse. The
%		 remainder of the file name should be a number that changes for each
%		 file. For example, if the files have names like 'eg207a001.swv', 
%		 use a prefix of 'eg207a'.
% 		depid is an optional string containing the deployment identification 
%		 code assigned to this deployment, for example, eg12_207a. If depid 
%		 is empty, the prefix will be used as the depid.
%     df is an optional decimation factor. If df is not specified, a
%      df of 1 is used, i.e., the full rate data is returned (which
%      may be very large and cause memory problems). If df is a
%      positive integer, the data will be decimated to give a rate 
%      for each channel of 1/df of the input data rate. If df is a negative
%		 number, abs(df) is interpreted as a target sampling rate for the
%		 sensors and each sensor channel will be decimated by an appropriate
%		 factor.
%
%     Returns:
%     ncfile is the name of the NetCDF file containing the tag data. It will
%      be 'depid'_raw.nc (e.g., mn12_186a_raw.nc).
%
%		Example:
%		 TBD
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     Last modified: 25 July 2017

MAXSIZE = 30e6 ;  % maximum size of storage object before using part files
ncfile = [] ;
if nargin<2,
	help read_d3
	return
end

if nargin==2,
	df = [] ;
	depid = '' ;
elseif nargin==3,
	if ~ischar(depid),
		df = depid ;
		depid = [] ;
	end
end
	
if isempty(df),
   df = 1 ;
end

if isempty(depid),
   depid = prefix ;
end

% get file names and cue table
C = get_d3_cuetab(recdir,prefix,'swv') ;
if isempty(C.fn), return, end		% if no files with the required name were found
basefs = C.fs ;
fn = C.fn ;
recdir = C.recdir ;
ct = C.cuetab ;
x = [] ;

% in case there are any part files from a previous call, delete them
npartf = 0 ;
delete('_d3rpart*.mat') ;
fnames = '' ;

% read in swv data from each file in turn
for k=1:length(fn),
   fprintf('Reading file %s\n', fn{k}) ;
	fnames(end+(1:length(fn{k})+1)) = [fn{k} ','] ;		% assemble a file name string for the info metadata
	
   XX = read_d3_swv([recdir '/' fn{k}]) ;		% read the data file
   ctab = ct(ct(:,1)==k,2:end) ;     	% get the part of the cue table for this file
   fs = XX.fs; 
	cn = XX.cn ;
   xx = XX.x ;
   clear XX
   fsmult = round(fs/basefs) ;
   if isempty(x),		% first time round do this...
		D = read_d3_chan_names(cn) ;	% read sensor definitions: this function is in the same file
      x = cell(length(xx),1) ;		% allocate space for the sensor data
      if df<0,								% see if a common output fs is requested
         fso = abs(df) ;
         df = round(fs/fso) ;			% decimation factor needed for each channel
			if any(df<1),
				fprintf(' Error: decimated sensor sampling rate must be less than or equal to %3.1f Hz)\n',min(fs)) ;
				return
			end
			if any(abs(fs./df-fso)>1e-6),
				fprintf(' Error: decimated sampling rate is not an integer divider of some sensor sampling rates\n') ;
				return
			end
         for kk=1:length(xx),
            z{kk} = df(kk) ;					% initialize the decimation states
         end
      else
         [z{1:length(xx)}] = deal(df) ;	% initialize the decimation states
         df = df*ones(size(fs)) ;
      end
      curs = cell(length(xx),1) ;
   end

	% remove any single sample outliers on each sensor, skipping MAG and ACC sensors
   for kk=1:length(xx),
      if ismember(D(kk).type,{'acc','mag'}), continue, end
      xx{kk} = deglitch(xx{kk}) ;			% this function is below in the same file
   end

   try
		% NaN-fill end of X if there is a gap in the cue table
		if ctab(end,end) < 0,
			nfill = ctab(end,2) ;
			fprintf(' Filling gap in file %s of %d samples\n', file{k},nfill);
			for kk=1:length(xx),
				fill = NaN*ones(nfill*fsmult(kk),1) ;
				xx{kk}(end+(1:size(fill,1))) = fill ;
			end
		end
   catch
		fprintf(' Error filling gap in file %s of %d samples. Timing may be incorrect\n', fn{k},nfill);
	end
   
	% accumulate result, decimating each channel if requested
   for kk=1:length(xx),
      if df(kk)==1,
         x{kk}(end+(1:length(xx{kk}))) = xx{kk} ;
      else 
   	   [xd,z{kk}] = decz(xx{kk},z{kk}) ;
         x{kk}(end+(1:size(xd,1))) = xd ;
      end
   end
   
	% check if the accumulated data is getting too large - if so,
	% save it to a part file for later assembly
   sz = whos('x') ;
   if sz.bytes > MAXSIZE,
      npartf = npartf+1 ;
      fname = sprintf('_d3rpart%d.mat',npartf) ;
      save(fname,'x') ;
      x = cell(length(xx),1) ;
   end
end

if df>1,
   % get the last few samples out of the decimation filter
   for kk=1:length(x),
      xd = decz([],z{kk}) ;
      x{kk}(end+(1:length(xd))) = xd ;
   end
end

% reload part files if they were used
if npartf>0,
   npartf = npartf+1 ;
   fname = sprintf('_d3rpart%d.mat',npartf) ;
   save(fname,'x') ;
   x = cell(length(xx),1) ;
   for k=1:npartf ;
      fname = sprintf('_d3rpart%d.mat',k) ;
      xx = load(fname) ;
      delete(fname) ;
      xx = xx.x ;
      for kk=1:length(xx),
         x{kk}(end+(1:length(xx{kk}))) = xx{kk} ;
      end
   end
   clear xx
end

% reorient columns if necessary
for kk=1:length(x),
   x{kk} = x{kk}(:) ;
end

% assemble channels by sensor type
fs = fs./df ;
info.depid=depid;
info.data_source=fnames(1:end-1);
info.data_nfiles=length(fn);
info.data_format='swv';
info.device_serial=sprintf('%08x',C.id);
info.device_make='DTAG';
info.device_type='Archival';
info.device_model_name=C.dtype;
info.device_model_version=[];
info.device_url='www.soundtags.org';
info.sensors_list='3 axis Accelerometer,3 axis Magnetometer,Pressure,Temperature';
info.dephist_device_tzone=0;
info.dephist_device_regset='dd-mm-yyyy HH:MM:SS';
info.dephist_device_datetime_start=datestr(ref_time);

ncfile = [depid '_raw'] ;
savenc(ncfile,info) ;
save_sens_struct(x,depid,D,fs,fn,'acc') ;		% this function is below in the same file
save_sens_struct(x,depid,D,fs,fn,'mag') ;
save_sens_struct(x,depid,D,fs,fn,'press') ;
save_sens_struct(x,depid,D,fs,fn,'tempr') ;
return


function		save_sens_struct(X,depid,D,FS,files,type)
%
k = find(strncmpi(D.type,type,length(type))) ;
if ~isempty(k),
	X = [X{k}] ;
	fs = FS(k(1)) ;
	if strcmp(type,'mag') && (length(k)==6),
		X = mag6to3(X,fs) ;		% handle D3 magnetometer data: this function is below
		fs = 2*fs ;
	end
		
	S = sens_struct(X,fs,depid,type) ;
	S.history = 'read_d3' ;
	S.unit = 're. 1' ;
	S.unit_name = 'relative to 1.0 full-scale' ;
	S.unit_label = 're. 1' ;
	S.start_offset = 0 ;
	fn = strcat([files(k).name ',']) ;
	S.files = fn(1:end-1) ;
	addnc([depid '_raw'],S) ;
end


function    C = read_d3_chan_names(ch)
%
%
C = struct ;
S = read_csv('d3_sensor_defs.csv') ;		% read the sensor definitions file
S(end+1).number = '-1' ;
S(end).name = 'unknown' ;
cn = str2num(strvcat(S(:).number)) ;		% get the channel numbers
[kk,k] = ismember(ch,cn) ;
if any(k==0),
   fprintf('Warning: unknown sensor types found - skipping\n') ;
	k(k==0) = length(S) ; 
end

C.name = stripquotes({S(k).name}) ;
C.descr = stripquotes({S(k).description}) ;
C.type = stripquotes({S(k).cal}) ;
C.ax = stripquotes({S(k).qualifier1}) ;
return


function    x = deglitch(x)
%
%
m = 10 ;
for kk=1:4,
   xx=abs(diff(x));
   k=find(xx>nanmean(xx)*m);
   if isempty(k), break, end
   if k(1)==1,
      x(1:2) = NaN ;
      k = k(2:end) ;
      if isempty(k), break, end
   end
   x(k)=x(k-1);
end
return


function    M = mag6to3(M,fs)
%
%
fc = 0.1 ;
df = min(round(fs/(8*fc)),16) ;
MM = sum(M,2) ;
Moffs = decdc(MM,df)/6 ;
fr = fc/(mfs/2/df) ;
Mf = fir_nodelay(Moffs,round(6/fr),fr) ;
Md = reshape(repmat(Mf',df,1),[],1) ;
if size(Md,1)<size(M,1),
   Md(end+(1:size(M,1)-size(Md,1))) = Md(end) ;
end
Z = repmat(Md,1,6) ;
M = M-Z ;
return
