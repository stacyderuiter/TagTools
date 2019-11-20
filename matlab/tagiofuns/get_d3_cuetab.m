function    C = get_d3_cuetab(recdir,prefix,suffix)

%     C = get_d3_cuetab(recdir,prefix,suffix)
%     Get timing and file information for a set of WAV format files from a 
%		DTAG deployment. All data files with names like recdir/prefixnnn.suffix, 
%		where nnn is a 3 digit number will be included. The suffix can be 'wav'
%		(the default) or 'swv' or any other suffix assigned to WAV-format data.
%		This function is called by read_d3 and is not normally called directly.
%		The function tries to load a previously generated cue file. The cue file 
%		is a helper file used to speed up finding sections of a long data stream. 
%		The file (called _'prefix''suffix'cues.mat) is saved in the current working
%		directory. If this file is deleted, it is automatically re-generated 
%		the next time this function is run.

%		Inputs:
%     recdir is a string containing the full path name to the directory
%		 where the files are stored. Use recdir=[] if the files are in the
%		 current working directory. All SWV files in the directory will
%		 be read. For each SWV file there must also be an XML file with 
%		 the same name.
%     prefix is the first part of the name of the files to analyse. The
%		 remainder of the file name should be a number that changes for each
%		 file. For example, if the files have names like 'eg207a001.swv', 
%		 use a prefix of 'eg207a'.
%     suffix is an optional file suffix such as 'swv'. The default
%      is 'wav'.
%
%     Returns:
%		C is a structure of timing information containing the fields:
%     C.cuetab is a matrix with a row for each contiguous block of data
%		 in the deployment.The columns of cuetab are:
%        1. File number
%        2. Start time in seconds since the start time (see below)
%        3. Number of samples in the block
%        4. Status of block (1=zero-filled, 0=data bearing, -1=data gap)
%     C.fs is the base sampling rate of the sensors. For sensor suites with
%		 different sampling rates, this is the lowest sampling rate of any channel.
%     C.fnames is a cell structure of file names.
%     C.recdir is the directory name for the recordings.
%     C.id is the identification number for the recording device.
%		C.start_time is the UNIX time at the start of the first recording.
%		C.dtype is a string containing the tag type ('D3' or 'D4').
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     Last modified: 2 March 2018 - fixed bug at line 68

TERR_THR = 0.005 ;       % report timing errors larger than this many seconds
SERR_THR = 3 ;           % as long as they are also at least this many samples
C = [] ;
if nargin<2,
   help get_d3_cuetab
   return
end

if nargin<3 || isempty(suffix) || ~ischar(suffix),
   suffix = 'wav' ;
end

if ~isempty(recdir) && ~ismember(recdir(end),'/\'),
   recdir(end+1) = '/' ;
end

recdir(recdir=='\') = '/' ;      % use / for MAC compatibility
%cuefname = [recdir '_' prefix suffix 'cues.mat'] ;
if exist('gettempdir'),
   tempdir = gettempdir ;
else
   tempdir = [] ;
end
cuefname = [tempdir '_' prefix suffix 'cues.mat'] ;
if exist(cuefname,'file'),
   C = load(cuefname) ;
	return
end
      
if isempty(recdir),
	fprintf(' Cue file for %s not found - run d3getcues or read_d3\n', prefix) ;
	return
end
	
fprintf(' Generating cue file for %s - will take a few seconds\n', suffix) ;
ff = dir([recdir,prefix,'*.xml']) ;		% get file names
if isempty(ff), 
   fprintf(' No recordings starting with %s found in directory %s\n', prefix, recdir) ;
	return
end

fn = {} ;
for k=1:length(ff),		% strip the suffix from the file names
   nm = ff(k).name ;
   nm = nm(1:find(nm=='.',1,'last')-1) ;
	if ~isnan(str2double(nm(end+(-2:0)))),
		fn{end+1} = nm ;
	end
end

fprintf(' Found %d files. Checking file    ',length(fn)) ;
id = [] ; fs = [] ; BLKS = [] ;

% read in XML metadata for each data file and assemble a cue table
for k=1:length(fn),
   fprintf('\b\b\b%03d',k) ;
   d3 = read_d3_xml([recdir fn{k} '.xml']) ;
   if isempty(d3),
      fprintf(' Error: unable to find or read file %s.xml\n', fn{k});
      return
   end
   
   % find the sampling rate if we don't already know it
   if isempty(fs),
      [fs fsne] = getfs(d3,suffix) ;		% this function is in the same file
      id = getid(d3) ;							% this function is in the same file
   end

   % find WAVBLK entries with the correct suffix
   blks = getwavblks(d3,suffix) ;   % check if WAVBLK entries are in the xml file
   if isempty(blks),
      blks = getwavtblks([recdir fn{k}],suffix) ;	% getwavblks and getwavtblks are below
   end
   if isempty(blks),
      fprintf('\n Error: no WAVBLK data or timing files - check version of d3read and re-run\n') ;
		return
	end

   % if a corresponding WAV file exists, check the sample count and rate
   fname = [recdir fn{k} '.' suffix] ;
   if ~exist(fname,'file'),
      fprintf(' No %s file found for recording %s, skipping\n',suffix,fn{k}) ;
   else
      [s,fss] = get_audio(fname,'size') ;
      if(fsne~=fss(1))
         fprintf(' Warning: Sampling rate mismatch in recording %s\n',fn{k}) ;
      end
      if s(1)~=sum(blks(:,3)),
         fprintf(' Warning: Sample count mismatch in recording %s\n',fn{k}) ;
      end
   end
   BLKS = [BLKS;repmat(k,size(blks,1),1) blks] ;
end
fprintf('\n') ;

if isempty(fs),
   fprintf(' Warning: Unable to determine sampling rate for this configuration\n');
   return ;
end

if(size(BLKS,1)<=1),
   return
end

% BLKS has columns: [file number,Unix time,microseconds,samples,type]
frst = 1 ;
while 1,				% check the timing of the BLKS
   tpred = cumsum(BLKS(1:end-1,4))/fs ;
   tnxt = (BLKS(2:end,2)-BLKS(1,2))+(BLKS(2:end,3)-BLKS(1,3))*1e-6 ;
   terr = tnxt - tpred ;
   serr = round(terr*fs) ;       % time errors in samples
   k = find((abs(terr)>TERR_THR) & (abs(serr)>SERR_THR),1) ;
   if isempty(k),
      BLKS(2:end,3) = BLKS(2:end,3) - terr*1e6 ;
      break ;
   end
   BLKS(2:k,3) = BLKS(2:k,3) - terr(1:k-1)*1e6 ;
   if frst,
      fprintf(' Warning: Gaps found between data blocks\n') ;
      fprintf('          Gaps are allowed and are managed by the tag tools but if gaps are\n') ;
      fprintf('          unexpected check version of d3read or d4read.\n') ;
      frst = 0 ;
   end
   if k<size(BLKS,1) && (BLKS(k,1)==BLKS(k+1,1)),
      fprintf(' => gap in file %s of %3.3f seconds (%d samples)\n',...
               fn{BLKS(k,1)},terr(k),serr(k)) ;
   else
      fprintf(' => gap between files %s and %s of %3.3f seconds (%d samples)\n',...
               fn{BLKS(k,1)},fn{BLKS(k+1,1)},terr(k),serr(k)) ;
   end
   st = tpred(k)+BLKS(1,2)+BLKS(1,3)*1e-6 ;
   ablks = [BLKS(k,1) floor(st) rem(st,1)*1e6 serr(k) -1] ;
   BLKS = [BLKS(1:k,:);ablks;BLKS(k+1:end,:)] ;   % add the gap lines to the block table
end

k = find((terr<-TERR_THR) & (serr<-SERR_THR)) ;
if ~isempty(k),
   fprintf(' %d data overruns detected with maximum size %3.3f seconds (%d samples)\n',...
               length(k),-min(terr),-min(serr)) ;
end

% nominate a reference time and refer the cues to this time
C.start_time = BLKS(1,2)+BLKS(1,3)*1e-6 ;  % start time is time of 1st sample in the deployment
ctimes = (BLKS(:,2)-BLKS(1,2))+(BLKS(:,3)-BLKS(1,3))*1e-6 ;
C.cuetab = [BLKS(:,1) ctimes BLKS(:,4:5)] ;
C.fs = fs ;
C.id = id ;
C.fnames = fn ;
C.recdir = recdir ;
save(cuefname,'C') ;
return


function    [fs,fsne,k] = getfs(d3,suffix)
%
%
fs = [] ;
if ~isfield(d3,'CFG'),
   return
end

for k=1:length(d3.CFG),
   c = d3.CFG{k}(1) ;
   if ~isfield(c,'FTYPE'), continue, end
   if ~strcmp(c.FTYPE,'wav'), continue, end
   if ~isfield(c,'SUFFIX'), continue, end
   if ~strncmp(c.SUFFIX,suffix,length(suffix)), continue, end
   if ~isfield(c,'FS'), continue, end
   if isfield(c,'EXP'),
      c.EXP(c.EXP=='_') = '-' ;     % reverse the fix in readd3xml to overcome Matlab
                                    % field name restrictions
      expn = str2double(c.EXP) ;
   else
      expn = 0 ;
   end
   fsne = str2double(c.FS) ;
   fs = fsne * 10^expn ;
   break ;
end
return


function		id = getid(d3)
%
%
id = [] ;
if ~isfield(d3,'DEVID')
	return
end
	
ss = d3.DEVID ;
Z = {} ;
while ~isempty(ss),						% parse id string
   [Z{end+1},ss] = strtok(ss,', ') ;
end

if length(Z)<4,
   id = hex2dec(horzcat(Z{1:2})) ;
else
   id = hex2dec(horzcat(Z{3:4})) ;
end
return


function    blks = getwavblks(d3,suffix)
%
%
blks = [] ;
if ~isfield(d3,'WAVBLK'),
   return
end

for k=1:length(d3.WAVBLK),
   c = d3.WAVBLK{k} ;
   if ~isfield(c,'SUFFIX'), continue, end
   if ~strcmp(c.SUFFIX,suffix), continue, end
   if ~isfield(c,'RTIME') | ~isfield(c,'MTICKS') | ~isfield(c,'NSAMPS'), continue, end
   blks(end+1,:) = [str2double({c.RTIME;c.MTICKS;c.NSAMPS})',0] ;
end
return


function    t = getcuetime(d3,suffix)
%
%
t = [] ;
if ~isfield(d3,'CUE'),
   return
end

if isstruct(d3.CUE)
   d3.CUE = {d3.CUE} ;
end

for k=1:length(d3.CUE),
   c = d3.CUE{k} ;
   if ~isfield(c,'SUFFIX'), continue, end
   if ~strcmp(c.SUFFIX,suffix), continue, end
   if ~isfield(c,'TIME') | ~isfield(c,'CUE'), continue, end
   t(1) = d3datenum(sscanf(c.TIME,'%d,',6)') ;
   t(2) = str2double(c.CUE)*1e6 ;
   return
end
return


function blks = getwavtblks(fn,suffix)
%
%
blks = [] ;
fname = [fn,'.wavt'] ;  % first check if there are '.wavt' files in the new format
if exist(fname,'file'),
   c = read_csv(fname,0) ;
   ks = strmatch(suffix,{c.SUFFIX}) ;
   for kk=1:length(ks),
      x = str2double(strvcat(c(ks(kk)).RTIME)) ;
      x(2) = str2double(strvcat(c(ks(kk)).MTICKS)) ;
      x(3) = str2double(strvcat(c(ks(kk)).NSAMPS)) ;
      x(4) = str2double(strvcat(c(ks(kk)).STATUS)) ;
      blks(end+1,:) = x ;
   end
end

% if not, check for the old format
if isempty(blks),
   fname = [fn,'.',suffix,'t'] ;
   if exist(fname,'file'),
      blks(end+(1:size(s,1)),:) = str2double(read_csv(fname,1)) ;
   end
end
return
