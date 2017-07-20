function [sstagon jdata] = rms_speed(tag, csts, d3, txtout, recdir, prefix)
%calculate rms flow noise in 66-94 Hz band and (optional) export data to a
%text file.
%this script requires that the dtag path is set and that a prh file exists.
%
% INPUTS
% tag is the tag id string, eg 'bw13_123a'
% csts is a 2 element vector indicating times (in seconds since tagon)
%   to include in analysis, in the form [startsec endsec]. 
%   Default (is csts is missing, empty, or [0 NaN]) is to analyse the entire acoustic
%   record.
% d3 indicates whether the tag in questions is a dtag2 or d3.  (0=dtag2,
%   1=d3.  if missing or empty, the default is to assume a d3.
% if txtout=1 then the script will save a text file of the output --
%   default is to save a mat file only in the current directory.
% recdir is the path where the acoustic records for the tagout are kept,
%   eg 'C:\dtag\data\bp13\bp13_123a'
% prefix is the short tag ID string that appears in the d3 dtg file names,
%   eg 'bp123a'
% (NOTE: recdir and prefix are only needed for d3, so if d3=0 these inputs
% will be ignored if provided.  If omitted for a d3 tagout they will be generated automatically.)
%
%outputs:
%   sstagon    a vector of times in seconds since start of record
%   jdata      a vector of rms levels in the 66-94 Hz band in dB re 1 uPa
%
% these 2 outputs are automatically saved as "speedwhale.mat" (see lines
% 111-112 if you want to change that.)
%
%stacy deruiter + alison stimpert, Feb 2013, Feb 2014

%********************************************************************
%SET CONSTANTS, INPUT CHECKING
%********************************************************************
df = 100;  %decimation factor for audio sampling rate (we are looking at low freqs so this will speed things up and not cause any problems)

%tag sensitivities (pk clip levels) 
SensTag3 = 178;
SensTag2 = 176;

if nargin < 2 || isempty(csts) %default is to calculate rms levels for the entire tag record
    %script will try to calculate for a duration equal to the PRH file
    %(which will always be <= audio duration)
    csts = [0 NaN];
end

if nargin < 3 || isempty(d3) %default is to assume tag is a d3
    d3 = 1;
end

if nargin < 4 || isempty(txtout) %default is to NOT save txt files
    txtout=0;
end

if nargin < 5 || isempty(recdir) || isempty(prefix)
    prefix = [tag(1:2), tag(6:end)];
    recdir = d3getrecdir(tag);
end
%********************************************************************
%LOAD TAGOUT SPECIFIC INFO
%********************************************************************
%load cal file 
CAL = loadcal(tag); %see if it's a DTAG2
if isstruct(CAL) %if it is...
    TAGON = CAL.TAGON; 
    UTC2LOC = 0; %for dtag2, TAGON time is given in local time already so needs no conversion.  in fact, this UTC2LOC value is only used as input to cst2datenum, and is ignored if d3=0 anyway.
else %if it's a d3...
    [CAL,DEPLOY,ufname] = d3loadcal(tag);
    TAGON = DEPLOY.SCUES.SSTART;
    TAGON(4) = TAGON(4) + DEPLOY.UTC2LOC;
    if exist('GMT2LOC','var') %in case the cal file is old-style, with GMT2LOC instead of UTC2LOC
        UTC2LOC=GMT2LOC;
    else
        UTC2LOC = DEPLOY.UTC2LOC;
    end
end

tagont = TAGON(4:6)'; %tag on time in hh mm ss
%load prh file
%loadprh(tag);
 
if isnan(csts(2))
    %csts(2) = floor(length(p)/fs);
    [ta,ts] = recordlength(tag);
    csts(2) = ta;
end
a = csts.*5; %there is a 5 here because we want the output sampling rate to be 5 Hz - does not matter what input sensor sample rate is.
if a(1) == 0 %this loop is to make sure there's no error if the first entry of csts is 0 -- don't want the program to try to access p(0) or time 0 anywhere.
    a(1) = a(1)+1; %csts to include (2 element vector= [start end]), in samples @ 5 Hz
end
k = a(1):a(2); %k is a full vector of sample numbers (at 5 Hz output sampling rate), either 1:length(recording), if csts is not specified, or from the start of csts to the end of csts.

%**************************************************************************
% rms level in 66-94 Hz band -- 1 second long window (fs samples), 
% sampled 5x per second (overlap=0.8*fs samples) 
%**************************************************************************
%read in dummy clip to get AFS
if d3
    [x,afs] = d3wavread([1 1.1], recdir, prefix) ; %dummy clip to get afs
else
    [x,afs] = tagwavread(tag, 10, 1) ;
end
clear x %erase dummy clip

k2 = a(1):(15*5):a(2); %jumps ahead 15 sec at a time - to let us read in data 15 sec at a time
rmsvals = ones(length(k),1); %preallocate space
ovrflow = []; %initialize a variable (this if for the "buffering" in line 73)
z=[]; %initialize a variable (this if for the "buffering" in line 73)

for kk2 = k2
    if kk2 == k2(1)
        rind = 0; %initialize the index variable (could do this before the loop instead if you wanted to)
    end
    clear x X xd xdf xd0 %make sure nothing is left-over from previous iterations
     if  ismember(kk2, k2(1:60:end)) %every once in a while,
         disp(['rms speed calcs - ' num2str(floor(kk2/max(a)*100)) '% done...']); %report to the matlab window on progress 
     end
     if d3
         [x,afs] = d3wavread(ceil([kk2/5 min((kk2/5+15),a(2)/5)]), recdir, prefix) ;  %read in 15 second clip of acoust data
     else
         [x,afs] = tagwavread(tag, ceil(kk2/5), min(15, (a(2)/5 - ceil(kk2/5)) ) ); %read in 15 second clip of acoust data
     end
    if isempty(x); break; end
    if df/10 > 2 %if decimating a ton, do it in 2 steps
        xd0 = decdc(x(:,1),df/10); %decimating, step 1
        xd = decdc(xd0,10); %decimating, step 2
     else
         xd = decdc(x,df); %or, if not decimating too much, do it all in one go
     end
     %apply filter
     xdf = fir_nodelay(xd,128,[66/(afs/df/2) , 94/(afs/df/2)]); %xdf is x, decimated and filtered
     %"buffer" the 15 second clip into one-second chunks, with one chunk in
     %each column of matrix X
     n = afs/df; %analyse 1 sec of acoustic data at a time -- there are afs/df samples per second in the decimated data
     nov = round(0.8*afs/df); %allow for 0.8*fs samples of overlap...so the one second analysis window slides forward by 0.2 sec per time -> 5hz data
     [X,z,ovrflow] = buffer([ovrflow;xdf],n,nov,'nodelay') ; % n is the number of samples per chunk; nov is the amount of overlap in samples
     for j = 1:size(X,2) %process one column of the buffered data at a time
        rind = rind+1; %which sample we are calculating in rmsvals
        y = X(:,j); %the data to use this iteration of the loop (1 second worth of acoustic data)
        if isempty(y) %if there is no data...uh-oh!
            break
        end
        if d3
            rmsvals(rind) = 20*log10(std(y)) + SensTag3; % calculate rms level in dB re 1 uPa 
        else
            rmsvals(rind) = 20*log10(std(y)) + SensTag2; % calculate rms level in dB re 1 uPa 
        end
        clear y %just in case, clean up!
    end
end

jdata(:,1) = rmsvals(:); %rename rms data

ttimeser = cst2datenum(tag,k/5,d3,TAGON,UTC2LOC); % This line converts sec since tagon to a matlab datenumber
ttimestr = datestr(ttimeser, 'HH:MM:SS.FFF'); %this converts the datenumber to a string time e.g. 12:05:15.665
%sec since tag on
sstagon = k./5; %output sample rate in jdata is 5 Hz, so sample times in sec are k/5
sstagon1 = sstagon(1:5:end);  %to get 1Hz decimated output sample-time data, take every 5th time


%decimate from 5 to 1 Hz
jdata1=jdata(1:5:end,:);   %5 is not sensor sampling rate - it's output speed estimate sampling rate
ttimestr1 = ttimestr(1:5:end,:);  %5 is not sensor sampling rate - it's output speed estimate sampling rate


%make sure lengths match. note: they should not be off by more than a
%sample or two (rounding error) or else be worried about this! can check by
%comparing length of sstagon and rmsvals.
if length(jdata) > length(sstagon)
    jdata = jdata(1:length(sstagon));
elseif length(jdata) < length(sstagon)
    jdata(end+1:length(sstagon)) = 0;
end
speedwhale = [sstagon(:) jdata]; 
save speedwhale speedwhale; %save matlab .mat file with outputs

if txtout == 1  %if user has requested to save txt files...
%save files...first construct file names
jpath = uigetdir('','Select the folder where you want to save the output.'); %this opens a window and asks the user to select the folder where they want to save the output files.
filename5 = [jpath '\' tag 'rmsflow_5Hz.txt'];
filename1 = [jpath '\' tag 'rmsflow_1Hz.txt'];
%5 Hz
fid = fopen(filename5, 'w'); %open the file

%header row
fprintf(fid, '%s \t %s \t %s \r\n', 'local time', 'time (sec since tag start)', 'rms flow noise (66-94 Hz band)');  %the "%letter" bits say what kind of data is in each col, the \t say to put a tab between columns...see help fprintf
nrows = length(jdata);  %nrows is the number of data points in the whole file/dataset
 for row=1:nrows
     if rem(row,100000) == 0  %every once in a while,
         disp(['Saving 5 Hz file: ' num2str(row/nrows*100) '% finished']); %report to the matlab screen on % finished
     end
     if row ==1 %for some reason, sometimes you need to put and extra "return" before the first data line so it does not append it to the header row.
         fprintf(fid, '\n');
     end
    fprintf(fid, '%s \t %f \t %f \r\n', ttimestr(row,:), sstagon(row), jdata(row)); %write one row of data values
 end

fclose(fid); %close the file


%1 Hz -- same as the 5 Hz basically, so see notes above
fid = fopen(filename1, 'w');

%header row
fprintf(fid, '%s \t %s \t %s \r\n', 'time (hours of day)', 'time (sec since tag start)', 'rms flow noise (66-94 Hz band)');
nrows = length(jdata1);
 for row=1:nrows
     if rem(row,1000000) == 0
         disp(['Saving 1 Hz file: ' num2str((row/nrows)*100) '% finished']);
     end
     if row ==1
         fprintf(fid, '\n');
     end
    fprintf(fid, '%s \t %f \t %f \r\n', ttimestr1(row,:), sstagon1(row), jdata1(row));
 end

fclose(fid);
end

function    fname = d3getrecdir(tag)
%    fname = makefname(tag,type,[chip,SILENT])
%     Generate a standard filename for a given tag deployment
%     and file type. Optional chip number is used for SWV, AUDIO,
%     GTX and LOG files.
%
%     mark johnson
%     majohnson@whoi.edu
%     last modified: 24 June 2006
%     modified by stacy deruiter for dtag3, july 2011, feb 2014 (recdir
%     only version - stolen from d3makefname)

fname = [] ; 

if length(tag)~=9,
   if isempty(SILENT),
      fprintf(' Tag deployment name must have 9 characters e.g., sw05_199a') ;
   end
   return
end

shortname = tag([1:2 6:9]) ;
subdir = tag(1:4) ;
suffix = sprintf('%s/%s/', subdir, tag) ; 
type = 'AUDIO' ;
    
% try to make filename
global TAG_PATHS
if isempty(TAG_PATHS) || ~isfield(TAG_PATHS,type),
   if isempty(SILENT),
      fprintf(' No %s file path - use settagpath\n', type) ;
   end
   return
end
fname = sprintf('%s/%s',getfield(TAG_PATHS,type),suffix) ;
