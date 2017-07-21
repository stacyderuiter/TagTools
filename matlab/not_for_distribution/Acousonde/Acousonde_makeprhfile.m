

%% Deployment-specific inputs 
DECL = 12.45; %declination angle of magnetic field. DEGREES.
%optional inputs:+++++++++++++++++++++++++++++++++++
TAGLOC = [33.903, -120.3187]; %Lat/Lon of tag-on
TAGOFF_CST =  []; %time tag off whale in seconds since tag-start
TAGON_CST = []; %time of tag on whale in seconds since tag-start

FIELDSITE = 'SoCal'; %name of field site
UTC2LOC = -7 ; %hours time difference from UTC; UTC + UTC2LOC = LOCALTIME
%++++++++++++++++++++++++++++++++++++++++++++++++++++++

caldir = 'C:\Users\Stacy DeRuiter\Dropbox\TagTools\matlab\Acousonde\cal'; %folder where your xml cal files are kept
prhdir = 'C:\Users\Stacy DeRuiter\Dropbox\dtag\data_d3\prh'; %folder where prh files are to be saved
settagpath('cal',caldir,'prh',prhdir) ;

deploy_name = '20160914-B020-BP';

%% Find Acousonde MT files
%select all the MT files you want to read in
%(they must be in one directory)
%NOTE: if you only want non-acoustic files, to save time 
%DO NOT select
%files where the 3rd letter is H or S (acoustic data)
[filename,fileloc]=uigetfile('*.MT', 'select MT files to read','multiselect','on');
filenamestr = char(filename);
audio = findstr(filenamestr(:,3)','S');
filename(audio) = [];
cd(pwd); %change to current working directory
if ischar(filename)
    filename = {filename}; %make filename a cell array if it isn't
end

%make sure files are named in alpha-numeric order 
%so temporal and x-y-z axis data come in right order!
filename = sort(filename);

clear filenamestr audio
%% load in acousonde movement sensor data from MT files
%note: the file MTread.m is from Greeneridge Biosciences, availiable at
%http://www.acousonde.com/downloads/MTRead.m
%retrieved 10/28/2016
%loop below is based on ReadAcousonde by Dave Cade

D = cell(size(filename)); %create empty cell array to store data 
for i = 1:length(filename) %loop over MT files
    %read in the i-th file
    [d, header, info] = MTRead([fileloc filename{i}]);
    %for 1st file, create matrices 
        %H to store header info
        %I to store "info" (metadata from MT file)
    %(append to these for each new file)
    if i == 1; H = header; I = info; 
    else H = [H header]; I = [I info];
    end
    %add data from file i to cell array D
    D{i} = d; 
        
%    d2 = d/max(abs(d)); % use these lines for writing audio to wav. !!assumes that
%    there is clipping somewhere in the file!
%    audiowrite([fileloc filename{i}(1:end-2) 'wav'],d2,round(info.srate))
end

%functions to figure out which kind of data is in a given cell:
% magnetometer, accelerometer, H is acoustics (HF), S is acoustics
% (lowpower), P is pressure
%HF acoustics
isH = ~cellfun(@isempty,cellfun(@(x) strfind(x,'Pow'),{H.abbrev},'uniformoutput',false)) | ~cellfun(@isempty,cellfun(@(x) strfind(x,'Freq'),{H.abbrev},'uniformoutput',false)); %is hydrophone
D(isH) = [];
ismag = ~cellfun(@isempty,cellfun(@(x) strfind(x,'Mag'),{H.abbrev},'uniformoutput',false));
isacc = ~cellfun(@isempty,cellfun(@(x) strfind(x,'Acc'),{H.abbrev},'uniformoutput',false));

ispress = ~cellfun(@isempty, cellfun(@(x) strfind(x,'Press'), {H.abbrev}, 'uniformoutput', false));
%other
isO = ~(ismag | isacc | ispress | isH);

clear d header info i isH 
%% Sampling rates
%acceleration (Afs)
Afs = I(find(isacc,1,'first')).srate;
% other sensors (fs)
srates = [I.srate];
%other sensor rate is the one that's less than Afs (or less than 100)
try fs = max(srates(srates<Afs)); catch; fs = max(srates<100); end
%if no Afs, of if acc rate is low, fs=Afs
if isempty(fs) || (~isempty(Afs) && Afs<50); fs = Afs; end
%return error if unable to determine fs
if isempty(fs); error('Could not determine sample rates'); end
%ii is an index to the location (in D) of non-acc data
ii = find(srates == fs,1,'first');
clear srates

%% Acceleration data
Adata=[];
Atime=[];
if any(isacc)
    %loop over sets of X-Y-Z acc data files
    % (each axis has its own file; may be >3 files in total)
    for fn = 1:(sum(isacc)/3)
        ai = find(isacc);
        %get start time of accel data for the current trio
        Atime1 = I(ai(fn)).datenumber;
        %make a vector of times of acc datapoints (in units of days)
        %(format is matlab datenumber)
        %times in seconds
        ats = ((1:(I(ai(fn)).nsamp))-1)/Afs;
        Atime = [Atime; Atime1 + datenum([zeros(length(ats),5), ats'])];
        %make a vector of acceleration data points, columns are x-y-z
        %Adata/Atime are growing inside loop - may want to preallocate space?
        Adata = [Adata; [D{ai(fn):(sum(isacc)/3):max(ai)}] ];
        %generate error if acc data and time-stamps of acc data are not same length
        if size(Atime,1)~=size(Adata,1); error('Acc data and timestamp length mismatch'); end
        if length(find(diff(Atime)>(1.2*1/Afs/24/60/60))) > 0
            error(['There is a time gap between the end of one data file and the start of the next (found for file ', num2str(fn), '.)']);
        end
    end %end loop over sets of xyz acc data
end %end "if any(isacc)"

%% decimated acc data
%find first start time of any file
st = min([I.datenumber]);
%check that first files for all sensors start at the same time
sensornames = unique({H.abbrev});
for k = 1:length(sensornames)
    sens = sensornames{k};
    isthis = ~cellfun(@isempty,cellfun(@(x) strfind(x,sens),{H.abbrev},'uniformoutput',false));
    isens = find(isthis, 1, 'first');
    if I(isens).datenumber ~= st
        sprintf('%s',['Start time of ' sens ' data is after the first sensor recording start time by ' num2str(I(isens).datenumber-st) ' datenum units.']);
    end
end
%find out duration of each dataset
dur = zeros(length(sensornames),1);
for k = 1:length(sensornames)
    sens = sensornames{k};
    isthis = ~cellfun(@isempty,cellfun(@(x) strfind(x,sens),{H.abbrev},'uniformoutput',false));
    thisfs = I(find(isthis,1,'first')).srate;
    dur(k) = sum([I(isthis).nsamp])/thisfs;
end

%find lowest fs among variables needed for the prh file
prhsensors = {'Accel/Z', 'Accel/Y', 'Accel/X', 'Mag/X', 'Mag/Y','Mag/Z', 'Press', 'Temp'};
[junk,vind] = ismember(prhsensors,{H.abbrev});
[fslo,si] = min([I(vind).srate]);
slowsensor = prhsensors{si};

%add Acc data downsampled to fs, to "data" data table
%time stamps
%get time stamps in seconds
DN = ((1:(min(dur)*fslo))-1)/fslo;
DN = st + datenum([zeros(length(DN),5), DN']);
%If running an earlier version of matlab use the following two lines
%instead of 'table'
%    data = dataset(floor(DN),DN-floor(DN),nan(size(DN)),nan(size(DN)),nan(size(DN)));
%    data.Properties.VarNames = ({'Date','Time','Acc1','Acc2','Acc3'});
data = table(floor(DN),DN-floor(DN),nan(size(DN)),nan(size(DN)),nan(size(DN)),'VariableNames',{'Date','Time','Acc1','Acc2','Acc3'});
acc = decdc(Adata,Afs/fslo); %decimate accel data
acc = acc(1:(min(dur)*fslo),:);

%put 3 channels of acc data into "data" data table
data.Acc1(1:size(acc,1)) = acc(:,1); data.Acc2(1:size(acc,1)) = acc(:,2); data.Acc3(1:size(acc,1)) = acc(:,3);


%% magnetometer data
if any(ismag)
    Mdata = [];
    mi = find(ismag);
    for fn = 1:(sum(ismag)/3)
        try 
            thisdat = [D{mi(fn):(sum(ismag)/3):max(mi)}];
        catch ME 
            %this is needed because in my sample dataset the three 
            %mag axes data were one sample different in length 
            %(for one set of mag files of the three).
            %don't know if this same safeguard will be needed for other
            %sensors?
            datsize = max([I(mi(fn):(sum(ismag)/3):max(mi)).nsamp]);
            thisdat = zeros(datsize,3);
            thisdat(1:I(mi(fn)).nsamp,1) = [D{mi(fn)}]; 
            thisdat(1:I(mi(fn)+sum(ismag)/3).nsamp,2) = [D{mi(fn)+sum(ismag)/3}];
            thisdat(1:I(mi(fn)+2*sum(ismag)/3).nsamp,3) = [D{mi(fn)+2*sum(ismag)/3}];
         end
        Mdata = [Mdata; thisdat ];
    end
    %check sampling rate
    if I(find(ismag,1,'first')).srate > fslo
      Mdata_lo = decdc(Mdata,I(find(ismag,1,'first')).srate/fslo);
      %put Mag data into "data" data table as well as Mdata matrix
      data.Mx = Mdata_lo(1:size(data,1),1); 
      data.My = Mdata_lo(1:size(data,1),2); 
      data.Mz = Mdata_lo(1:size(data,1),3);
    else
      %put Mag data into "data" data table as well as Mdata matrix
      data.Mx = Mdata(:,1); 
      data.My = Mdata(:,2); 
      data.Mz = Mdata(:,3);
    end
    end



%% pressure (depth) data
%note: info says that units are dbar but Acousonde web site says that
%the results are already adjusted for temperature - how can both be true?
%assuming that results are in m.
p = vertcat(D{ispress});
%put this sensor data into "data" data table
%sampling rate of this sensor
pfs = I(find(ispress,1,'first')).srate;
%check if this sensor sample rate is multiple of standard rate fs
if min([rem(fslo,pfs), rem(pfs,fslo)]) ~= 0
   error([ 'pressure sample rate and base sample rate are not compatible (not multiples of each other)']); 
end
if pfs > fslo
    p = decdc(p, pfs/fslo);
    pfs = fslo;
end

if length(p) ~= length(data.Mx)
    disp(strcat({'Warning: length mismatch of '}, num2str(abs(length(data.Mx) - length(p))/fs), {' seconds between pressure and magnetometer data. Data will be truncated or zero-filled.'}));
    if length(p) > length(data.Mx)
        %shorten p
        p = p(1:length(data.Mx));
    else
        %or lengthen it...to match data.Mx
        p = [p; zeros(length(data.Mx)-length(p),1)];
    end
end
data.Press = p;


%% Other sensor data streams
%indices of other sensor data in data structure
oi = find(isO);
%names of other sensor data streams
osens = unique({H(oi).abbrev});
%loop over different "other" sensors
for s = 1:size(osens,2)
    %get string name of sensor data stream
    stype = osens(s);
    %logical vector indicating which entries in oi are this sensor
    iss = strcmp({H(oi).abbrev}, stype);
    %note: this assumes that all "other" sensor are single-column
    %(single-axis)
    Sdata = vertcat(D{oi(iss)});
    %put this sensor data into "data" data table
    %sampling rate of this sensor
    ofs = I(oi(find(iss,1,'first'))).srate;
    %check if this sensor sample rate is multiple of standard rate fs
    if min([rem(fslo,ofs), rem(ofs,fslo)]) ~= 0
        error([ stype ' sample rate and base sample rate are not compatible (not multiples of each other)']); 
    end
    if ofs > fslo
        Sresamp = decdc(Sdata, ofs/fslo);
    else
        Sresamp = resample(Sdata,fslo,ofs);
    end
    
    if length(Sresamp) ~= length(data.Mx)
        disp(strcat({'Warning: length mismatch of '}, num2str(abs(length(data.Mx) - length(Sresamp))/fs), {' seconds between '}, stype, {' and magnetometer data. Data will be truncated or zero-filled.'}));
        if length(Sresamp) > length(data.Mx)
            %shorten Sresamp
           Sresamp = Sresamp(1:length(data.Mx));
        else
            %or lengthen it...to match data.Mx
           Sresamp = [Sresamp; zeros(length(data.Mx)-length(Sresamp),1)];
        end
    end
    data.(cell2mat(stype)) = Sresamp;
end
 

%% apply calibration info from device-specific calibration
%find cal file and load it
sprintf('%s%s%s', 'Tag serial number is ' , H(1).sourcesn, '. Choose the cal file.')
[calfname, calpath] = uigetfile('*.mat','Choose the cal file');
calfile = [calpath calfname];

%apply acousonde bench calibrations to the data
%[A,M,p, caldata] = applyAcousondeCal(data, calfile);

%for 20160914-B020-BP there are 2 sets of cal constants, "on" and "off"
endon = 38622 ;
[A,M,p, caldata] = applyAcousondeCal(data, calfile,endon);

%% use dtag tools to get PRH file from A,M,p data -- DEPTH
%pressure sensor
CAL = struct('PRESS',struct('PCAL', [0,1,0], 'TREF', 20));
[p,CAL2] = acousondeCalPressure(caldata.Press,caldata.Temp, fs, CAL);
figure(2),clf
plot(-p); grid on

%% use dtag tools to get PRH file from A,M,p data -- ACC
%accelerometer
%change axes orientation if needed

%create CAL, a d3-style cal that does nothing
blank_cal
%also create X to simplify matters...all data, d3 style
x = cell(4,1);
x{1} = caldata.Acc1;
x{2} = caldata.Acc2;
x{3} = caldata.Acc3;
x{4} = caldata.Temp;
x{5} = caldata.Press;
x{6} = caldata.Mx;
x{7} = caldata.My;
x{8} = caldata.Mz;
X.cn = [4609, 4610, 4611, 5121, 4865, 4353, 4354, 4355]'; %must be a col vector for d3calacc (d3channames)
X.fs = repmat(fs, length(X.cn),1);
X.x  = x;

min_depth = 10; 

[A,CAL,fs] = acousondeAutoCalAcc(X,CAL,'full',min_depth) ;

%% use dtag tools to get PRH file from A,M,p data -- MAG
%magnetometer
%change axes orientation if needed
%need to create CAL.MAG
[M,CAL] = acousondeAutoCalMag(X,CAL,'full',min_depth) ;
%[M,CAL] = d3calmag(X,CAL,'none',min_depth) ;

%save whale-frame results
deploy_name = deploy_name(1:9);
saveprh(deploy_name,'p','fs','A','M') ;  %This requires a nine character tag deployment name- this is not the acousonde convention so far

%% use dtag tools to get PRH file from A,M,p data -- Convert to whale frame
%Produce the orientation table. 
TH = 75; %Choose depth threshold to get some, but especially with long deployments 
DIR = 'descent'; % use just the 'ascent', 'descent' or 'both'
METHOD = 1;  %MJ now recommends method 1 for almost all species
%wierd b020 whale
%PRH = prhpredictor(p-4.6,A,fs,TH,METHOD, DIR);
%normal whales
PRH = prhpredictor(p,A,fs,TH,METHOD, DIR);

%     Returns PRH = [cue,p0,r0,h0,dir,quality] with a row for each dive edge
%     analyzed. cue is the second-since-tagon of the dive edge. [p0,r0,h0]
%     are the deduced tag orientation angles in radians. 'dir' is the dive
%     direction: 1 is an ascent, -1 is a descent. 'quality' is one or more
%     columns of quality metrices depending on the method employed.

%Blue is Aw(:,1), Green is Aw(:,2), and red is Aw(:,3)
%you can also try ginput on the MIDDLE panel, this will output offset in
%DEGREEs, so need to convert to radians (*pi/180).  Order to click = blue, green,
%red.  Can check with photos to see if
%degree offset matches what it looks like in the pictures for how the tag was oriented.  Can also ask tagger
%if they remember orientation of the tag when it went on (if no pictures)
%to get an initial position

PRH2 = mean(PRH(:,2:4), 1); %if it looks like there are no slips and you want to average all the points you accepted - this will be in radians

OTAB = [0, 0, PRH2]; %make sure OTAB is in radians and seconds since start of tag recording!
%tag2whale help documents explain how to enter OTAB information.  
%first line is an initial offset -- [0 0 P R H].  Can enter at command line
%or in variable editor.  If no tag move, this is all you need to do.  If
%tag moves one row is added for each move (blue, green, red)
%Moves:  [movetimecue movetimecue P R H] (NEW position, after the move).
%Slides:  [slidestartcue slideendcue P R H] (position after the slide is finished).  
%make sure OTAB is in radians and seconds (not datapoints - divide by sample rate (fs) if in points) since start of tag recording!

% OTAB = [move1;move2;move3...]
% where each row corresponds to a move of the tag and has the form:
% moven = [t1,t2,p0,r0,h0]
% where t1 and t2 are the start and end times of the move (in seconds-since-tagon), and p0,
% r0, h0 are the new orientation Euler angles after the move (in radians). If the move is
% instantaneous, use t2=t1. If you are not sure if there was a move or you simply want to
% notify a time at which the tag was at a certain orientation, use t2=0. If the move time is
% uncertain, note this on the orientation worksheet.

%calculate Aw and Mw, acc and mag data in whale-frame instead of tag-frame
[Aw,Mw] = tag2whale(A,M,OTAB,fs);

%compare original A matrix with your corrected one.  (zoom in and use subplot_zoom to compare panels)
pnorm = p/max(p); 
figure(11),clf; subplot(211); plot((1:size(A,1))/fs,A); grid on; hold on; plot((1:size(pnorm,1))/fs, -pnorm, 'k', 'LineWidth',2);
subplot(212); plot((1:size(Aw,1))/fs, Aw); hold on; plot((1:size(pnorm,1))/fs, -pnorm, 'k', 'LineWidth',2);  %-- check values around 0, 0, and 1
grid on
%zoom in to check that blue and green average to zero, especially during surface
%intervals (can often see fluke strokes), and red (Z) averages around 1.  
%check that blue (X) is negative on descent and positive on ascent.  (Green
%is y)
%% if there are issues with NaNs at the end (I had 100 in my test whale)
lastgood = find(~isnan(A(:,1)),1,'last');
p = p(1:lastgood); A = A(1:lastgood,:); Aw = Aw(1:lastgood,:); M = M(1:lastgood,:); Mw = Mw(1:lastgood,:);

%% use dtag tools to get PRH file from A,M,p data -- make pitch, roll, head from Aw, Mw
%use tag2 tools to make pitch, roll, and head
[pitch, roll] = a2pr(Aw) ;
[head, vm, incl] = m2h(Mw,pitch,roll) ;
head = head + DECL*pi/180 ;      % adjust heading for declination angle in RADIANS
%check that the inclination is correct for your site...check a map of mag
%field inclination if you don't know what it should be
180/pi*mean(incl)
%and that it's std is not too big, less than somewhere around 5 degrees
180/pi*std(incl)



%% use dtag tools to get PRH file from A,M,p data -- save results
%save tag2 style prh file
saveprh(deploy_name,'p','pitch','roll','head','fs','Aw','Mw','A','M') ;

%save xml cal file 
d3savecal(deploy_name,'CAL',CAL)
d3savecal(deploy_name, 'DECL', DECL);
%can save other stuff too ...

%save HF accel data in the PRH plus save fs for accel data
%also save a vector of timestamps for the main data and for the HF accel
Ahf = Adata;
Afs = I(find(isacc,1,'first').srate;
times = data(:,'Date') + data(:,'Time');
saveprh(deploy_name,'p','pitch','roll','head','fs','Aw','Mw','A','M', 'A', 'Atimes', 'Afs', 'Atimes', 'times') ;


