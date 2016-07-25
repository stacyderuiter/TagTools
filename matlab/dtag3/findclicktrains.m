function [ctrain, spec_freqs, C_all , OPTS, cl] = findclicktrains(tag, d3, cl, OPTS, fname, recdir, prefix)
% [ctrain, spec_freqs ] = findclicktrains(tag, d3, cl, OPTS, fname, recdir, prefix)
%
%Use spectral properties of clicks to assign them to click trains.
%Input data is acoustic data on one channel.
%
%Reference:
%Starkhammar, J., Nilsson, J., Amundin, M., Kuczaj, S. A., Almqvist, M.,
%& Persson, H. W. (2011). Separating overlapping click trains originating
%from multiple individuals in echolocation recordings. 
%The Journal of the Acoustical Society of America, 129(1), 458–66.
%doi:10.1121/1.3519404
%
%INPUTS:
%%%% REQUIRED INPUTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
%   tag     tag id string, e.g. 'gg11_216a'
%   d3      0 if data are from dtag2, 1 if data are from dtag3.  For dtag2,
%           make sure the dtag path is set before running this function.
%           For dtag3, either set the tag paths OR ELSE be sure to include
%           the optional input arguments recdir and prefix.
%   cl      a vector of the time cues of detected clicks that are to be
%           classified. if a matrix is given, 1st colum will be used as start times. 
%%%%%  OPTIONAL INPUTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
% the following optional arguments are all in struture array "OPTS"
%--------------------------------------------------------------------------
%   OPTS.ckdur  duration of acoustic data, in seconds, to use for each click.
%               should be just a bit longer than the longest click but long enough to have 
%               a reasonable number of samples to get spectrum.  value used by
%               Starkhammar was 150 usec (ckdur = 0.00015) w/ afs=1Mz -> 150
%               samples.  Default is the duration that will give >= 150 samples
%               of acoustic data per click.
%   OPTS.ncorr  number of clicks to look back in time for a "match" if a click
%               is determined NOT to belong to the same click train as the one
%               immediately preceding it in the sequence.  Default = 30 (as in
%               Starkhammar et al. 2011).
%   OPTS.freqs   a 2-element vector of the minimum and maximum frequencies to be
%               included in click-to-click correlation calculations, in kHz.  The
%               default is [50 , afs/2].  (That's 50 kHz!!) According to Starkhammar et al. 2011,
%               lowering the lower bound leads to lower correlation between
%               successive clicks in a train, since the lower freq components
%               vary more from click to click.  However, in dtag data, the
%               lower frequency content is often considered to be an indicator
%               of clicks having been produced by the tagged whale, so it may
%               be interesting to experiment w/lower values.
%   OPTS.n_fft  FFT size to be used for calculation of the spectrum of each
%               click.  Default is the next power of 2 that is greater than the
%                analyzed signal duration in samples.
%   OPTS.win     window type for spectrum calculation.  Default is (after
%                Starkhammar et al 2011) a Tukey window with ratio of
%                taper=0.15.  for now no other options are available; leave this
%                input as [].
%   OPTS.ckpre   time, in seconds, BEFORE cl, at which to start reading in data.
%              if cl gives times that precede clicks or are just at the very
%              start of clicks, you could use 0.  Otherwise, if cl gives time
%              at the peak amplitude of the click or during the click rise
%              time, then you'd want to read in some time before cl.  Default
%              is 0.25*ckdur.
%   OPTS.THR     threshold for deciding whether a click is a member of a train
%                -- if the correlation index exceeds THR then the click is judged member
%               of the train. default = 0.9 (Starkhammar et al was 0.95).
%--------------------------------------------------------------------------
%  other optional inputs:
%--------------------------------------------------------------------------
%   fname   a file name (complete with path and file extension) under which to save the
%           output spectra data.  if empty or missing, the program will call the file
%           'tag_clicktrains.txt' (where tag is the tag id string) and will open an explorer window to let you
%           choose the folder where it will be saved.
%   recdir      for dtag3 -- path to the directory where the
%               acoustic data files are located.  Setting tag path also works.
%   prefix      for dtag3 -- short tag id string = prefix of
%                acoustic data file names.  For example, 'gg216a'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%OUTPUTS:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   ctrain      a vector the same length as cl.  for each click,
%               returns a number indicating the click train to which the click
%               was assigned.
%   spec_freqs  frequencies in Hz at which fft (spectrum) was calculated
%   C_all       correlation metrics for lag 1 for each click.
%   OPTS        OPTS used for the analysis
%   cl          cl (from input), but sorted into chronological order!
%
%   the function will also output a text file in the current folder with spectra of ALL
%   clicks analyzed (can read it in for later plotting of spectra).  each
%   row is one click (in same order as cl) and each column is one frequency
%   in same order as spec_freqs).
%
%Stacy DeRuiter, University of St Andrews, March 2013

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Check input arguments and apply defaults as needed.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 3
    error('Missing input arguments -- see "help findclicktrains" for help.');
end
if nargin <4 
    OPTS = [];
end
if nargin < 5 || isempty(fname) %note! this bit will not work on linux/unix.  but if you're using those os you specified the path anyway, right?
    fname0 = [tag '_clicktrains.txt'];
    dirname = uigetdir([],'Choose the folder where you want to save the output text file.');
    fname = [dirname '\' fname0];
end
if nargin < 6 || isempty(recdir)
    recdir = d3makefname(tag,'RECDIR'); % get audio path
    if nargin < 7 || isempty(prefix)
        prefix = [tag(1:2) tag(6:9)];
        [x,afs] = d3wavread_x([10 10.01],recdir, prefix, 'wav' ) ; %get acoustic sampling rate
       clear x
    end
end
if ~isfield(OPTS,'freqs')
    if ~exist('afs','var')
        if d3==0
            [x,afs] = tagwavread(tag,10,0.01); clear x;
        elseif d3 ==1
            [x,afs] = d3wavread_x([10 10.01],recdir, prefix, 'wav' ) ; clear x; %get acoustic sampling rate
        end
    end
    OPTS.freqs = [50 , afs/2/1000]; %frequencies in kHz to use for correlation between successive clicks
end
if ~isfield(OPTS,'ncorr')
    OPTS.ncorr = 30;
end
if ~isfield(OPTS,'ckdur')
    OPTS.ckdur = 150/afs; %time in seconds that will give 150 samples
end
if ~isfield(OPTS,'ckpre')
    OPTS.ckpre = 0.25*OPTS.ckdur;
end
if ~isfield(OPTS,'n_fft')
    OPTS.n_fft = 2^nextpow2(ceil(OPTS.ckdur*afs));
end 
if ~isfield(OPTS,'win')
    OPTS.win = 'Tukey';
    taperratio = 0.15;
    w0 = sigwin.tukeywin(OPTS.n_fft,taperratio);
    w = generate(w0);
end
if ~isfield(OPTS,'THR')
    OPTS.THR = 0.9;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   preliminaries - preallocate space, initialize stuff, etc.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cl = sort(cl); %make sure click list is in chronological order!
%a matrix of acoustic data for ncorr+1 clicks.  ncorr+1 columns, ckdur*afs
%rows.
A = NaN*ones(ceil(OPTS.ckdur*afs) , OPTS.ncorr+1);
%a matrix of spectra for ncorr+1 clicks.  ncorr+1 columns, n_fft rows.
S = NaN*ones(OPTS.n_fft/2+1,OPTS.ncorr+1);
train_num = 1; %initialize counter for click trains
spec_freqs = afs/2*linspace(0,1,OPTS.n_fft/2+1);
fuse = find(spec_freqs>=1000*OPTS.freqs(1),1,'first') : find(spec_freqs<=1000*OPTS.freqs(2),1,'last'); %frequencies to use in the analysis
ctrain = zeros(length(cl),1); ctrain(1)=train_num; %preallocate space
C_all = zeros(length(cl),1);
%open file where spectra will be saved
fid = fopen(fname, 'w');
%write header row
% fprintf(fid, [repmat('%s \t ',1,length(spec_freqs)), '\r\n'],num2str(spec_freqs)); %annoyingly this does not work...
 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   loop over all clicks.  
%   keep ncorr+1 clicks in workspace at any one time.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for k = 1:length(cl)
    if ismember(k,1:5000:length(cl))
        disp(['Processing click ' num2str(k) ' of ' num2str(length(cl)) '...']);
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   load in acoustic data. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    clear x
    if d3 == 0
        [x,afs] = tagwavread(tag,cl(k)-OPTS.ckpre,OPTS.ckdur-OPTS.ckpre); x = x(:,1);
    elseif d3 == 1
        [x,afs] = d3wavread_x([cl(k)-OPTS.ckpre cl(k)-OPTS.ckpre+OPTS.ckdur],recdir, prefix, 'wav' ) ; x = x(:,1); 
    end
    if length(x)<length(A) %just in case x comes out a sample or two shorter than expected...
        x(end+1:length(A)) = 0;%pad it longer.
    elseif length(x)>length(A)%and if it's a sample or two too long,
        x = x(1:length(A));%truncate it.
    end
    A = [A(:,2:end), x(:,1)]; %matrix of acoustic data with most recent click in last column.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   calculate spectrum
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if length(x)<OPTS.n_fft %just in case x is shorter than n_fft...
        x(end+1:OPTS.n_fft) = 0;%pad it longer.
    elseif length(x)>OPTS.n_fft%and if it's too long,
        x = x(1:OPTS.n_fft);%truncate it.
    end
    sk0 = fft(x.*w,OPTS.n_fft)/length(A); %compute fft
    sk = 2*abs(sk0(1:OPTS.n_fft/2+1));
    %add spectrum to txt file
    fprintf(fid, [repmat('%f \t ',1,length(spec_freqs)), '\r\n'], sk);
    S = [S(:,2:end), sk]; %one-sided amplitude spectrum of latest click in last column of S
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   calculate correlation coefficient with preceding click
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if k>1 %as long as there is a preceding click ...
        %calculate corr index with preceding click
        C =  sum(S(fuse,end).*S(fuse,end-1)) / max(sum(S(fuse,end).^2) , sum(S(fuse,end-1).^2));
        C_all(k) = C;
        if C>OPTS.THR
            ctrain(k) = train_num;
        else
            lag = 1;
            while C<OPTS.THR && lag <= OPTS.ncorr-1 %look back in time over up to ncorr clicks to find one like the current one
                lag = lag+1;
                if isnan(S(1,end-lag)); %if there are no clicks "lag" clicks before the current one, stop
                    break
                end
                C =  sum(S(fuse,end).*S(fuse,end-lag)) / max(sum(S(fuse,end).^2) , sum(S(fuse,end-lag).^2));
            end
            if C>OPTS.THR
                ctrain(k) = ctrain(k-lag); %this click is in a train with a click lag clicks ago
            else
                train_num = train_num+1; %new click train, not matching any clicks in last ncorr clicks!
                ctrain(k) = train_num;
            end
        end
    end
end
fclose(fid);
    
    