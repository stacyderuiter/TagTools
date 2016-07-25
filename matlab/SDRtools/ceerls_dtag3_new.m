function ceerls_dtag3_new(tag, recdir, prefix, minSNR, notransients, filterbank, makewavclips, st, f0, plotcheck)
%Received level determinations for controlled exposure experiments - for dtag3
%data!!!  use ceerls_dtag2 for dtag2 data sets. (either will work if
%wavclips already exist, i.e. if you will be using makewavclips=0.)
%
%save and run this file in a directory specific to the tagout of interest (where necessary files are stored - see comments below).
%This directory should have a sub-folder called SoundClips.  Wav file clips
%of each measured sound will be saved in the SoundClips directory.  If you
%don't want this to happen, comment out the "wavwrite" commands in section
%5.
%
%Before running this program, use cee_tagaudit.m (for dtag2 data), ceetag3audit.m (for dtag3 data) or another wav-file-auditing method
%to view the tag acoustic files and mark the start times of all received 
%cee transmissions.  Label them 'cee,' 'mfa,' or 'prn' if using tagaudit
%(or change code in section 3).  The code will NOT calculate RLs for things
%labeled, for example, 'mfa?' or 'prncoveredbysplashing'.  If you wish to
%include these, you can alter section 3 to use strncmp (use 3 characters)
%instead of strcmp.
%Use the tag toolbox script saveaudit.m to save the resulting
%audit structure as a .mat file with a name like "bw11_210aaud."
%Any entries in the audit whose label does not include "cee," "mfa" or "prn" will be ignored
%by the script.  If you have saved this data in a different format or with
%a different file name, you can change the code in section 3 to
%accomodate your system.
%
%    INPUTS are:
%1.     tag          =   tag string (e.g. 'bw10_239a')
%2.     minSNR       =   minimum SNR for computation of RLs.  Output will be NaN
%                       for sounds with SNR < minSNR.  SEL will be computed over the window in
%                       which SNR > minSNR.
%3.     notransients =   0 to measure RL WITHOUT any transient elimination (will
%                       give inaccurate results if any whale clicks overlap the CEE sound).
%                       1 to apply transient elimination algorithm - allows
%                       measurement of RL even if whale clicks overlap the CEE
%                       sound, but NOT useful if the CEE sound includes
%                       transients/clicks.  This algorithm will NOT compensate
%                       for CEE sounds that are covered over by surface
%                       splashing.
%4.     filterbank  =   '3o' to use a 1/3 oct filter centered at 3.4 kHz,
%                       spanning 3029 - 3815 Hz.  It is an FIR filter, see
%                       section 2 for details.
%                       '3obank' to use a filter bank of 1/3 oct filters
%                       spanning the range 250 Hz to 15 kHz.
%                       'bb' to make a broadband measurement - bandpass filter
%                        from 250 Hz to 15 kHz will be applied.  See
%                        Section 2 for details of filter design.
%5.     makewavclips =  1 to save wav file clips of each CEE
%                       sound, 0 to use previously generated clips.  use 1 the first time you run
%                       the script; if for some reason you need to re-run later, you can use the
%                       same clips (even if you want to use different filter options or minSNR,
%                       etc).  If you change st then you will need to use makewavclips=1, though.
%6.     st =            optional input - a vector of start times for the
%                       exposure sounds, in seconds since start of tag
%                       recording.  For example, if you exposed the tagged
%                       whale to MFA sonar sounds every 25 seconds starting
%                       3500 seconds into the recording, st would be
%                       something like st = [3500; 3525; 3550; 3575; ...].
%                       If st is empty ([]) or not provided, the script
%                       will attempt to load an audit file containing
%                       information about the timing of the exposure
%                       sounds.
% 7.     f0 =             center frequency around which a two element vector will be created that specifies
%                         the lower and upper bounds of a 1/3 octave filter encompassing the signal of interest.  
%                         **IN HERTZ**
%                         SOCAL RHIBS-only B Jul 9 and 10 2013 -- 3.4 kHz center frequency, [3029 3815]
%                         SOCAL RHIBS-only B Jul 12 2013 -- 2.8 kHz center frequency
%                         SOCAL RHIBS-only B Jul 12 2013 -- 2.7 KHz center frequency
%                         SOCAL scaled source -- 3.7 kHz center frequency
% 8.     plotcheck =      
%
%    OUTPUT will be saved to the current directory as a mat-file.
%
%the rms level reported is the max rms level observed in any 200 ms window during the duration of the signal.
%also reported are peak level, SEL and SNR.  For SNR, rms noise level is
%calculated as for the rms signal level, but using a clip beginning two
%seconds before the start of the CEE sound and ending 1 second before the
%start of the CEE sound.  SEL is calculated over a window where SNR > minSNR 
%
%make sure tag path is set before using this function. 
%
%if notrans = 1, this code implements a version of Walter Zimmer's (NATO NURC La Spezia) "RMS_Filter"
%script, to eliminate transients like clicks.
%
%Stacy DeRuiter, WHOI, May 2011 ; modified @ U of St Andrews, June 2012,
%modified for user-defined input (for naval transmissions), July 2013 A Stimpert

%##############################################################################################
%  1.  Preliminaries: enter values for constants, check tag sampling rate,
%       etc.
%##############################################################################################
if nargin < 10 || isempty(plotcheck)
    plotcheck=0; %don't plot output unless plotcheck is 1
end

if isempty(f0)
    f0 = 3400;
end

cal = 178; %from dtag calibration test at Dodge Pond in Nov 2011 -- FROM CALIBRATION OF ***ONE**** tag - SUBJECT TO FUTURE ADJUSTMENT
SNR_crit = minSNR; %SNR minimum for signals to be included in SEL metric, in dB.  Sounds with lower SNR will have reported RL of NaN.
% check audio sampling rate
[x,afs] = d3wavread([10 10.01],recdir, prefix, 'wav' ) ;
clear x 
if strcmp(filterbank, '3o')
    filterbounds = [f0/(2^(1/6)) f0*(2^(1/6))];
    fprintf('Analysis filter band from %1.3f to %1.3f\n **HERTZ**', filterbounds);
    % fprintf('  Accept filter band? Type y or n... ') ;
    [s] = input('  Accept filter band? Type y or n... ','s') ;
    s = char(s) ;
    % fprintf('\n') ;
    if lower(s(1))~='y'
        fprintf('  Rejecting filter band\n') ;
    return
    else end
end
%**********************************************************************************************


%##############################################################################################
%  2.  Set up filters (1/3 oct filter bank spanning 250 Hz to 15 kHz,
%      or bandpass filter 250 Hz to 15 kHz).  This part uses the toolbox
%      "octave" from matlab filecentral, available as of June 2012 at:
%      http://www.mathworks.com/matlabcentral/fileexchange/69-octave
%      The relevant script, oct3dsgn, is pasted at the bottom of this
%      function.
%##############################################################################################

if strcmp(filterbank, '3o')
    %generate FIR 1/3 oct filter
    FL = 512; %fir filter length
    B = fir1(FL, filterbounds./(afs/2)); %FIR filter - %centered at f0
    ftype = 1;
elseif strcmp(filterbank, '3obank')
    %   A. determine center frequencies for 1/3 octave filters to cover 0.25-15
    %   kHz, satisfying ANSI_S.16-1986 (reaffirmed in 2006) 
    cf = 10.^(0.1.*[24:42])';
    %   B. design 1/3 oct filters with the above center freqs (given in Hz), to
    %   satisfy ANSI S1.11-2004
    %preallocate space for filter coeffs
    B = zeros(length(cf),7);
    A = zeros(length(cf),7);
    %generate 1/3 oct filter coefficients
    for ii = 1:length(cf)
        [B(ii,:),A(ii,:)] = oct3dsgn(cf(ii),afs,3); %6th order butterworth bandpass filter
    end
    ftype = 2;
elseif strcmp(filterbank, 'bb')
    %generate bandpass "broadband" filter coefficients
    [B,A] = butter(3,[250/(afs/2) 15000/(afs/2)]); %6th order butterworth bandpass filter from 250 Hz to 15 kHz
    ftype = 2;
else error('Unknown value for input filterbank - please consult help for this script');
end
%**********************************************************************************************

%##############################################################################################
%  3.  Load in data on the start times of the MFA signals (obtained from
%      human examination of the acoustic data files).
%##############################################################################################
if nargin < 6 || isempty(st)
    RR = loadaudit(tag) ;%audit data
    st = RR.cue; %get vector of start times of all sounds noted in the audit -  matrix is [cue in sec since tagon, duration in sec]
    types = RR.stype; %get a vector of all the labels of the sounds noted in the audit
%need a vector of all events containing the cee (+/- additions like
%"coveredbysplashing")
    stall1 = st(strncmp('cee', types,3),1);  %make RL measurements only for events labeled "cee"; skip all others.
    stall2 = [stall1(:); st(strncmp('prn', types,3),1)]; % also include things marked "prn"
    stall3 = [stall2(:); st(strncmp('mfa', types,3),1)]; % also include things marked "mfa"
    stall = stall3;
    [y,sord] = sort(stall);
    stall = stall(sord,1); clear sord y
    st = st(ismember(RR.stype,{'cee'; 'prn'; 'mfa'}),:); %st is a vector of cee sound start times (marked cee, prn, or mfa) in seconds since start of recording.
    [y,sord] = sort(st(:,1)); %get an index by which the start times can be sorted into chronological order
    userdur = st(sord,2); %duration of each clip to be measured, according to the audit file
    st = st(sord,1); %sort the start times in chrono order
    stnan = stall(~ismember(stall,st(:,1)));
% else
%     userdur = st(:,2); %duration of each clip to be measured
end

noisestart = st-2; %time cues for noise clips, to be used for SNR calcs. One sec long, starting two seconds before the cee sound starts
%**********************************************************************************************



%##############################################################################################
%  4.  Preallocate space for results
%##############################################################################################
SEL = zeros(length(st),size(B,1)); %SEL in dB re 1 uPa^2*sec
SPL_pk = zeros(length(st),size(B,1)); %peak SPL in dB re 1uPa
SPL_rms = zeros(length(st),size(B,1)); %rms SPL in dB re 1uPa, max obs in any 200 ms window
hiSNRdur = zeros(length(st),size(B,1)); %duration in sec when SNR>minSNR
SNR = zeros(length(st),size(B,1)); %signal to noise ratio
Ts = zeros(length(st),size(B,1)); %start time of hiSNRdur
Te = zeros(length(st),size(B,1)); %end time of hiSNRdur
noise_rms = zeros(length(noisestart),size(B,1)); %rms noise level...
noise_pk = zeros(length(noisestart),size(B,1)); %peak noise level...
peakclip_pa = 10^(cal/20); %tag peak clip level, converted to Pascals
nf0 = 41; %number of 10 msec periods to average over during application of smoothing filter (to use as baseline for detection of transients)-leads to 200msec window)
thr = 4; %threshold (in dB) above baseline for detection of transients
%**********************************************************************************************



%##############################################################################################
%  5.  Extract clips from tag data and save them as wav files in the
%  SoundClips directory. Once this has been done once, this section can be
%  skipped (by using input makewavclips = 0)...The CEE clip is 15 sec and the noise
%  clip is 1 sec (change values below if this is undesirable).
%##############################################################################################
noisedur = 1; %duration of noise clips to extract, in seconds
%Extract a clip of tag audio for each exposure 
%and a 1 sec clip for each noise sample and save them
%as .wav files
if makewavclips == 1
    clipdir = uigetdir(recdir, 'Choose a folder for CEE wav clip storage:');
for k = 1:length(st)
    clipdur = min([25,userdur(k)]); %duration of the clip to extract, in seconds
    disp(['Extracting tag audio (clip ' num2str(k) ' of ' num2str(length(st)) ')']);
    [x,afs] = d3wavread([st(k),st(k)+clipdur],recdir, prefix, 'wav' ) ;%extract tag audio to matlab
    audiowrite([clipdir '\CEE_' num2str(k) '_' prefix '.wav' ],x,afs); %save a wave file of the clip
    [x2,afs] = d3wavread([noisestart(k),noisestart(k)+noisedur], recdir, prefix, 'wav' ) ;%extract tag audio to matlab
    audiowrite([clipdir '\noise_' num2str(k) '_' prefix '.wav'],x2,afs); %save a wave file of the noise clip
    clear x x2
end
end
%**********************************************************************************************


%##############################################################################################
%  6.  Apply filters.  Do transient elimination if required.  Calculate
%      levels. [Finally, what we are really trying to do gets done...]
%##############################################################################################

%apply filters and make calculations for 1/3 octave filter bank
if makewavclips==0
    clipdir = uigetdir(recdir,'Choose the directory where was clips of each CEE sound are stored.');
end
for k = 1:length(noisestart) %loop over CEE/noise signals to measure
    disp(['Measuring RLs (clip ' num2str(k) ' of ' num2str(length(noisestart)) ')']);

    for k2 = 1:size(B,1) %and loop over filters to be applied (for 3obank filterbank option)
    %read in noise clip data
        [x,afs,nbits]=wavread([clipdir '\noise_' num2str(k) '_' prefix]); %read in wav data for noise clip
        if ftype==2 %butterworth bandpass filter
            x_filt = filter(B(k2,:),A(k2,:),x(:,1)); %apply the bandpass butterworth filter to the signal
        elseif ftype == 1 % FIR filter
            x_filt = fftfilt(B,[x(:,1);zeros(FL,1)]); %apply fft filter
        end
        x_filt2 = x_filt.^2; %convert from amplitude to intensity
    %read in cee clip data
        [y,afs,nbits]=wavread([clipdir '\CEE_' num2str(k) '_' prefix ]); %read in wav data for edited full clip
        if ftype==2 %butterworth bandpass filter
            y_filt = filter(B(k2,:),A(k2,:),y(:,1)); %apply the bandpass butterworth filter to the signal
        elseif ftype == 1 % FIR filter
            y_filt = fftfilt(B,[y(:,1);zeros(FL,1)]); %apply fft filter
        end
        y_filt2 = y_filt.^2; %convert from amplitude to intensity

        %@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
        %noise clip       @@@@@@@@@@@@@@@@@@@@
        %@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
        
        v = zeros(length(ceil(afs*(0:0.01:0.8))));
        for p = 1:length(v);
            v(p) = (mean(x_filt2((p-1)*(afs/200)+(1:(2*afs/100))))); %average over 10 msec durations, with start of interval stepping forward by 5 msec
        end
        %smooth v with a filter spanning 41 sampled periods = 200 msec
        nf=nf0; nf1=1+(nf-1)/2;
        v2=filter(ones(nf,1)/nf,1,[v;zeros(nf,size(v,2))]); 
        v2(1:nf1,:)=[]; v2=v2(1:size(v,1),:);
    if notransients == 1
     %******************************************************************************************************
     %  do transient elimination if required
     %******************************************************************************************************
        itrn = v > v2*10^(thr/10); %index of where entries of v > v2*10^(thr/10)
        v3 = v.*(1-itrn);%fill vv with zeros where there are transients
        %widen holes to where sample values are same as noise level
        for ii=1:size(v3,2)
            for jj=2:size(v3,1)-1
                if (v3(jj-1,ii)==0) && (v3(jj,ii)>v3(jj+1,ii))
                    v3(jj,ii)=v3(jj-1,ii); 
                end
            end
            for jj=size(v3,1)-1:-1:2
                if (v3(jj+1,ii)==0) && (v3(jj,ii)>v3(jj-1,ii))
                    v3(jj,ii)=v3(jj+1,ii); 
                end
            end
        end
        %fill up holes with sample @ background/previous level
        for ii=1:size(v3,2)
            for jj=2:size(v3,1)
                if v3(jj,ii)==0,v3(jj,ii)=v3(jj-1,ii); end
            end
        end
    else v3 = v;
    end %end of the transient elim part for the noise clip...
    %**********************************************************************
        w = filter(ones(nf,1)/nf,1,[v3;zeros(nf,size(v3,2))]);%vv3 filtered w/100msec smoothing filter 
        w(1:nf1,:)=[]; w=w(1:size(v3,1),:);

        
        %$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
        %cee clip $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
        %$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
        
        vv = zeros(length(ceil(afs*(0:0.01:length(y_filt)/afs-0.2))));
        for p = 1:length(vv);
            vv(p) = (mean(y_filt2((p-1)*(afs/200)+(1:(2*afs/100))))); %average over 10 msec durations, with start of interval stepping forward by 5 msec
        end
        %smooth vv with a filter spanning 41 sampled periods
        nf=nf0; nf1=1+(nf-1)/2;
        vv2=filter(ones(nf,1)/nf,1,[vv;zeros(nf,size(vv,2))]); 
        vv2(1:nf1,:)=[]; vv2=vv2(1:size(vv,1),:);
     if notransients == 1
     %******************************************************************************************************
     %  do transient elimination if required
     %******************************************************************************************************
       itr = vv > vv2*10^(thr/10); %index of where entries of v > v2*10^(thr/10), thr = 4
        vv3 = vv.*(1-itr);%vv with zeros where there are transients
        %widen holes to where sample values are same as noise level
        for ii=1:size(vv3,2)
            for jj=2:size(vv3,1)-1
                if (vv3(jj-1,ii)==0) && (vv3(jj,ii)>vv3(jj+1,ii))
                    vv3(jj,ii)=vv3(jj-1,ii); 
                end
            end
            for jj=size(vv3,1)-1:-1:2
                if (vv3(jj+1,ii)==0) && (vv3(jj,ii)>vv3(jj-1,ii))
                    vv3(jj,ii)=vv3(jj+1,ii); 
                end
            end
        end
        %fill up holes with sample @ background/previous level
        for ii=1:size(vv3,2)
            for jj=2:size(vv3,1)
                if vv3(jj,ii)==0,vv3(jj,ii)=vv3(jj-1,ii); end
            end
        end
     else vv3 = vv; 
     end %end of the transient elim for the cee clip...
     %********************************************************************
     ww = filter(ones(nf,1)/nf,1,[vv3;zeros(nf,size(vv3,2))]);%vv3 filtered w/200msec smoothing filter
        ww(1:nf1,:)=[]; ww=ww(1:size(vv3,1),:);
    %6. noise clip level determination
        %calculate RMS noise level in dB re 1 muPa
        noise_rms(k,k2) = max( 20*log10(sqrt(mean(w))) + cal);
        %calculate peak noise level
        noise_pk(k,k2) = max(10*log10(max(abs(v3))) + cal);
        clear x x_filt
    %8. cee clip level determination -- using SMOOTHED, transient-removed data (ww)
        %Calculate the SEL for the entire time for which SNR is > SNR_crit
        %first determine SNR in 10 milli second windows ...
        %find the time window in which SNR > SNR_crit
        %Calculate the SEL for the entire time for which SNR is > SNR_crit
        %first determine SNR in 10 milli second windows 
        q = 1:length(vv3); 
        %find the time window in which SNR > SNR_crit
        snrs = zeros(length(q),1);
        for tt = 1:length(q)
            snrs(tt) =  max(10*log10(max(max(ww(tt:min( max(q) , tt+3 ),:)))) + cal - noise_rms(k,k2));
        end
        t1 = q(snrs>minSNR); %indices of the 5-msec windows with SNR > minSNR
%             if ~isempty(t1)
%              hsw = snrs(t1); %vector of SNRs from time of first SNR>minSNR to last SNR>minSNR
%              THdfm = 10; %threshold (decline from max observed) for picking the end of the hi SNR window. Originally was 12.
%              endwind = find(hsw<(max(hsw)-THdfm)); %shorten hiSNR window so it spans time from first time minSNR is exceeded until the first time the level falls 12dB below the highest measured level
%              endwind(endwind < 1.4/0.005) = []; %end time of hiSNRdur due to reduced level can not be less than 0.4 sec into clip
%              if ~isempty(endwind) %if SNR never falls 12 dB below max within the hiSNR window, then keep the original hiSNR window.
%                  t1 = t1(1:endwind(1));
%              end
%             end
%             if ~isempty(t1)
%             gap = find(diff([(t1(1)-1);t1(:)]) > 40, 1, 'first'); % get rid of any hisnrdur parts that follow a gap of more than 40 samples = 0.005*40 sec = 0.2 sec 
%             if ~isempty(gap)
%                 t1(gap:end) = [];
%             end
%             end
%             if ~isempty(t1) && t1(1)*0.005 > 0.3 % if "start time " of signal is more than 0.3 sec in, discard.
%                 t1 = [];
%             end

         if ~isempty(t1)
            tst = t1(1); %start index of hiSNR window
            tend = t1(end); %end index of hi SNR window
            Ts(k,k2) = tst*0.005; %time steps in vv3=q=t1 are 5 ms apart
            Te(k,k2) = tend*0.005;
           
            else
            tst = 0; tend = 0;
            Ts(k,k2) = 0;
            Te(k,k2) = 0;
        end
        %record SNR (max found in any 200 msec window)
        SNR(k,k2) = max(snrs);
        %next calculate the SEL and peak & rms SPL for the time when rms SNR is greater than SNR_crit
        if tst == tend %if there is no signal with SNR> SNR_crit
            SEL(k,k2) = NaN;
            SPL_pk(k,k2) = NaN;
            SPL_rms(k,k2) = NaN;
        else
            %SEL in the hi snr window
            SEL(k,k2) = max( 10*log10(sum(((ww(tst:tend,:).*peakclip_pa^2))./200)) );
            %rms spl in the hi snr window
            SPL_rms(k,k2) = (10*log10(max(max(abs(ww(tst:tend,:))))) + cal);
            %peak level
            SPL_pk(k,k2) = max(10*log10(max(abs(vv3))) + cal);
        end
        hiSNRdur(k,k2) = (tend - tst)*0.005; %duration of the signal with SNR > SNR_crit, in seconds
      if plotcheck==1
        BS=1024;
        setup.win=[1024 256];
        ww2=setup.win(1); hh=setup.win(2);
        cs = [-90 0];

        F = figure(1); clf;
        set(gcf,'position',[20 30 ww2+100 2*hh+150]);
        hb=axes('units','pixels','position',[60 50 ww2 hh]);
        ha=axes('units','pixels','position',[60 hh+100 ww2 hh]);
        % decimate data and make spectrogram
        %y_filt2=resample(y_filt(:,1),1,10);
        %afs2 = afs/10;
        [Bp,tf,tx]=specgram(y_filt(1:(afs*2.5),1),BS,afs,hann(128),64);
        set(gcf, 'CurrentAxes', ha);
        [M,sx,sy]=adjust2Axis(Bp);
        %
        % plot figures
        image(tx,tf/1000,20*log10(abs(M)),'Cdata',cs,'parent',ha,'CDataMapping','scaled'); 
        %
        set(ha,'ydir','normal');
        set(get(ha,'xlabel'),'string','Time [s]');
        set(get(ha,'ylabel'),'string','Frequency [kHz]')
        title('Close figure to proceed.');
        tv = [0:(length(ww)-1)]*0.005; %time in sec
        hp=plot(hb,tv,cal+10*log10(vv3),'k',tv,cal+10*log10(ww),'k', 'linewidth',2);
        hold(hb,'on')
        plot(hb,tv(t1),cal+10*log10(vv3(t1)), 'r', tv(t1), cal+10*log10(ww(t1)), 'r--')
        set(get(hb,'xlabel'),'string','Time [s]');
        set(get(hb,'ylabel'),'string','Pressure level [dB // 1\muPa]')
        set(hb,'xlim',[0 2.5])
        set(hb,'ygrid','on','xgrid','on')
        
%         set(hp(1:length(frx)-1),'color',0.5*[1 1 1],'linewidth',1);

    
%         tp = [0:(length(ww)-1)]*0.005; %time in sec
%         tpa = [1:length(y_filt)]/afs; %time in sec
%         witbg = plot(tpa,y_filt./max(abs(y_filt)));
%         set(witbg,'Color',[0.6 0.6 0.6]);
%         hold on;
%         plot(tp,ww(:,1)./max(max(ww)),'k');
        waitfor(F);
        clear Bp M tf tx sx sy t1
        clear x y x_filt y_filt tend t1 ww vv3 w v3 v2 vv2
      else
          clear x y x_filt y_filt tend t1 ww vv3 w v3 v2 vv2
        end
    end
end

% %**********************************************************************************************
% %add in start times and NaN levels for the pings that were not detected or
% %not measured due to operator choice (labeled mfacoveredbysplashing, etc).
xtras =NaN*stnan;
stall = [st;stnan];
SEL = [SEL;repmat(xtras,size(SEL,2))];
SPL_pk = [SPL_pk; repmat(xtras,size(SEL,2))];
SPL_rms = [SPL_rms; repmat(xtras,size(SEL,2))];
hiSNRdur = [hiSNRdur; repmat(xtras,size(SEL,2))];
noise_rms = [noise_rms; repmat(xtras,size(SEL,2))];
noise_pk = [noise_pk; repmat(xtras,size(SEL,2))];
SNR = [SNR;repmat(xtras,size(SEL,2))];
Ts = [Ts; repmat(xtras,size(SEL,2))];
Te = [Te; repmat(xtras,size(SEL,2))];
noisestart = [noisestart; stnan-2];
% 
% %now make sure everything is in chronological order
[y,sord] = sort(stall);
st = stall(sord);
SEL = SEL(sord,:);
SPL_pk = SPL_pk(sord,:);
SPL_rms = SPL_rms(sord,:);
hiSNRdur = hiSNRdur(sord,:);
noise_rms = noise_rms(sord,:);
noise_pk = noise_pk(sord,:);
SNR = SNR(sord,:);
Ts = Ts(sord,:);
Te = Te(sord,:);
noisestart = noisestart(sord,:);
% 
SEL2 = SEL;
SEL2(isnan(SEL)) = 0;
SEL_cum = 10.*log10(cumsum(10.^(SEL2./10)));
SEL_cum(SEL_cum<10) = NaN;
%##############################################################################################
%  6.  Save results.
%##############################################################################################

if strcmp(filterbank, '3obank')
    %if 3rd octave bands are used, output will be in matrix form.  One row
    %for each received sound.  One column for each filter.  Center freq of
    %each filter is indicated in fc.
    if notransients == 1
        save( [ tag(1:2) tag(6:9) '_' 'RLs_3octbank_TransElim'],  'SEL' , 'SEL_cum' ,'SPL_pk', 'SPL_rms',  'hiSNRdur','noise_rms',  'noise_pk', 'SNR' ,'Ts', 'Te',  'st', 'noisestart', 'k', 'cf');
    else
        save( [ tag(1:2) tag(6:9) '_' 'RLs_3octbank'],  'SEL' , 'SEL_cum' ,'SPL_pk', 'SPL_rms',  'hiSNRdur','noise_rms',  'noise_pk', 'SNR' ,'Ts', 'Te',  'st', 'noisestart', 'k', 'cf');
    end
elseif strcmp(filterbank, 'bb')
    if notransients == 1
        save( [ tag(1:2) tag(6:9) '_' 'RLs_Broadband_TransElim'],  'SEL' , 'SEL_cum' ,'SPL_pk', 'SPL_rms',  'hiSNRdur','noise_rms',  'noise_pk', 'SNR' ,'Ts', 'Te',  'st', 'noisestart', 'k');
    else
        save( [ tag(1:2) tag(6:9) '_' 'RLs_Broadband'],  'SEL' , 'SEL_cum' ,'SPL_pk', 'SPL_rms',  'hiSNRdur','noise_rms',  'noise_pk', 'SNR' ,'Ts', 'Te',  'st', 'noisestart', 'k');
    end
elseif strcmp(filterbank, '3o')
    if notransients == 1
        save( [ tag(1:2) tag(6:9) '_' 'RLs_3o_TransElim'],  'SEL' , 'SEL_cum' ,'SPL_pk', 'SPL_rms',  'hiSNRdur','noise_rms',  'noise_pk', 'SNR' ,'Ts', 'Te',  'st', 'noisestart', 'k');
    else
        save( [ tag(1:2) tag(6:9) '_' 'RLs_3o'],  'SEL' , 'SEL_cum' ,'SPL_pk', 'SPL_rms',  'hiSNRdur','noise_rms',  'noise_pk', 'SNR' ,'Ts', 'Te',  'st', 'noisestart', 'k');
    end
end    

%##############################################################################################
%  Auxiliary function -- oct3dsgn from octave toolbox.
%  octave, by Christophe COUVREUR, 29 Dec 1997
%  from http://www.mathworks.com/matlabcentral/fileexchange/69-octave
%##############################################################################################

function [B,A] = oct3dsgn(Fc,Fs,N); 
% OCT3DSGN  Design of a one-third-octave filter.
%    [B,A] = OCT3DSGN(Fc,Fs,N) designs a digital 1/3-octave filter with 
%    center frequency Fc for sampling frequency Fs. 
%    The filter is designed according to the Order-N specification 
%    of the ANSI S1.1-1986 standard. Default value for N is 3. 
%    Warning: for meaningful design results, center frequency used
%    should preferably be in range Fs/200 < Fc < Fs/5.
%    Usage of the filter: Y = FILTER(B,A,X). 
%
%    Requires the Signal Processing Toolbox. 
%
%    See also OCT3SPEC, OCTDSGN, OCTSPEC.

% Author: Christophe Couvreur, Faculte Polytechnique de Mons (Belgium)
%         couvreur@thor.fpms.ac.be
% Last modification: Aug. 25, 1997, 2:00pm.

% References: 
%    [1] ANSI S1.1-1986 (ASA 65-1986): Specifications for
%        Octave-Band and Fractional-Octave-Band Analog and
%        Digital Filters, 1993.

if (nargin > 3) | (nargin < 2)
  error('Invalid number of arguments.');
end
if (nargin == 2)
  N = 3; 
end
if (Fc > 0.88*(Fs/2))
  error('Design not possible. Check frequencies.');
end
  
% Design Butterworth 2Nth-order one-third-octave filter 
% Note: BUTTER is based on a bilinear transformation, as suggested in [1]. 
pi = 3.14159265358979;
f1 = Fc/(2^(1/6)); 
f2 = Fc*(2^(1/6)); 
Qr = Fc/(f2-f1); 
Qd = (pi/2/N)/(sin(pi/2/N))*Qr;
alpha = (1 + sqrt(1+4*Qd^2))/2/Qd; 
W1 = Fc/(Fs/2)/alpha; 
W2 = Fc/(Fs/2)*alpha;
[B,A] = butter(N,[W1,W2]); 
