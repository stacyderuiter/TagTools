function    [x,fs] = wavseq_read(cues,recdir,prefix,suffix)
%
%     [x,fs] = wavseq_read(cues,recdir,prefix)
%		or
%     [x,fs] = wavseq_read(cues,recdir,prefix,suffix)
%
%     Read a segment of sound from a sequence of wav files. The wav files
%     must all have filenames with the same prefix followed by increasing
%     (but not necessarily sequential) numbers. 
%
%		Inputs:
%     cues = [start_cue end_cue] specifies the time frame to read. The cues 
%		 are in seconds with respect to the first sample in the first file in 
%		 the sequence. If cues straddles the end of one file and the start of
%		 the next, the correct samples from each file will be concatenated.
%     recdir is a string containing the full path name to the directory
%		 where the files are stored. Use recdir=[] if the files are in the
%		 current working directory.
%     prefix is the base part of the name of the files to read from e.g., 
%      if the files have names like 'eg207a001.wav', use prefix='eg207a'.
%		 All WAV files with the correct prefix and suffix in the directory will
%		 be included in the sequence.
%		suffix is an optional argument that allows the suffix (i.e., the part
%		 of the filename after the last '.') to be specified. The default is
%		 'wav'.
%
%		Returns:
%		x is a vector or matrix of audio samples. x will have as many columns as
%		 there are channels in the audio files. It will have a number of rows
%		 equal to floor((end_cue-start_cue)*fs).
%		fs is the sampling rate of the sound data.
%
%     This function assumes that the data in the wav files are contiguous, 
%		 i.e., there is no gap between successive files. If the recordings 
%		 come from Soundtraps, make sure the 'zero fill dropouts' option is 
%		 selected in the tools menu of Soundtrap Host.
%		Note: To improve speed, this function saves a file with cue information 
%		 in the same directory as the data. The file is called:
%		 _'prefix''suffix'cues.mat in Matlab and Octave. This file is used by
%		 successive calls of wavseqread. The file is automatically generated if
%		 it is not found. If you change any of the WAV files in the directory (e.g.,
%		 by adding new files, you must delete the cue file to force wavseqread to
%		 re-read the directory.
%
%     Examples
%        TBD
%
%     modified 24 July 2017
%     markjohnson@st-andrews.ac.uk
%     Licensed as GPL, 2013

x = [] ; fs = [] ;
if nargin<3,
   help wavseq_read
   return
end

if nargin<4 || isempty(suffix) || ~ischar(suffix),
   suffix = 'wav' ;
end

if suffix(1) == '.',
	suffix = suffix(2:end) ;
end
	
% check format of directory name for MAC compatibility
if ~isempty(recdir) && ~ismember(recdir(end),'/\'),
   recdir(end+1) = '/' ;
end
recdir(recdir=='\') = '/' ;

% read in cues
C = getwavseqcues(recdir,prefix,suffix) ; % this function is below
if isempty(C),
   fprintf(' Error: unable to find files\n') ;
   return
end

fs = C.fs ;
ct = C.cuetab ;
fn = C.fn ;

if isempty(ct),
   fprintf(' Error: unable to make cue file\n') ;
   return
end

k = find(ct(:,1)<=cues(1),1,'last') ;
if isempty(k),
   fprintf(' Error: cue is before the start of recording\n') ;
   return
end

% compute the number of samples to read
n = round(fs*(cues(2)-cues(1))) ;     
c = cues(1) ;
x = [] ;

while n>0,
   fnum = find(c>=ct(:,1),1,'last') ;    % find which file the current cue comes from
	if isempty(fnum),	break, end
   st = round(fs*(c-ct(fnum,1))) ;   	% convert cue to samples wrt start of file

   % find out how many samples can be taken from this file
   len = min(n,ct(bn,2)-st) ;		% truncate the length if it exceeds the length of the recording
	if len==0,
      c = c+1/(2*fs);   % catch rare case of cue coinciding with block end
      continue
   end

   % and read the samples
   xx = get_audio([recdir fn{fnum}],st+[1 len]) ;   
   x = [x;xx] ;
   if size(xx,1)<len,
      fprintf(' Error: unable to read all samples in file %s\n',fname) ;
      return
   end
   n = n-len ;
   c = c+(len+1)/fs ;
end
return


function    C = getcuefile(recdir,prefix,suffix)
%
%  look for a cue file or generate one if there isn't one
%

% try to find a cue file from a previous invocation of wavseqread
cuefname = [recdir '_' prefix suffix 'cues.mat'] ;
if exist(cuefname,'file'),
   C = load(cuefname) ;
   return
end
      
fprintf(' Generating cue file - will take a few seconds\n') ;
ff = dir([recdir,prefix,'*.',suffix]) ;
fn = {ff.name} ;

if isempty(fn),
   fprintf(' No recordings starting with %s found in directory %s\n', prefix, recdir) ;
   C = [] ;
   return
end

fprintf(' %d recordings found\n',length(fn)) ;
fs = -1 ;
t = 0 ;
cuetab = zeros(length(fn),1) ;
for k=1:length(fn),
   fname = [recdir fn{k}] ;
   [s,fss] = get_audio(fname,'size') ;
   if fs==-1,
      fs = fss ;
   end
   cuetab(k,:) = [t s(1)] ;
   t = t+s(1)/fs ;
end

save(cuefname,'fn','fs','cuetab','recdir') ;
C = load(cuefname) ;
return

