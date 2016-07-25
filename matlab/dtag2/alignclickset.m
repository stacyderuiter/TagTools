function    CLA = alignclickset(tag,CL,type,FILT,CLA,NOALIGN)
%
%   CLA = alignclickset(tag,CL,type,FILT,CLA,NOALIGN)   
%     Interactive alignment tool for focal clicks
%     tag is the tag deployment string e.g., 'sw03_207a'
%     CL is a vector of unaligned click cues
%     type is 'rc' or 'bz' for regular click or buzz.
%     CLA is the output from a previous call to alignclickset for 
%        multiple sessions.
%     Optional NOALIGN disables automatic click alignment
%     algorithm if set to 1. Default is 0.
%
%   CLA is the aligned cue matrix containing the following elements:
%     [cue wbAoA wbq xcAoA xcq]
%
%  mark johnson, WHOI
%  majohnson@whoi.edu
%  last modified: 3 Nov. 2005


AoA_factor = 1500/0.025 ;     % sound speed / hydrophone spacing
FINDPOS = 1 ;
N = 5 ;

len = 20 ;                    % number of clicks per frame to analyze
srch = [-0.0015 0.002] ;      % search time interval in seconds referenced to each click
tdisp = [-0.0008 0.0018] ;    % time interval to display

if nargin<4 | isempty(FILT),
   FILT = [5000 20000] ;           % click bandpass filter cut-off frequency in Hz
end

if nargin<6,
   NOALIGN = 0 ;
end

if nargin<2,
   help alignclickset
   CLA = [] ;
   return
end

% find sampling rate
[c t s id fs] = tagcue(tag) ;
fs = fs(1) ;

if nargin<3 | ~isequal(type,'bz'),  % settings for a regular click
   PKRAT = 0.7 ;                 % fraction of peak value to use as threshold for detector
   win = -15:50 ;                % sample window to use in AoA computation
else
   PKRAT = 0.9 ;                 % settings for a buzz click
   win = -15:50 ;                % sample window to use in AoA computation
end

[b a] = butter(6,FILT/(fs/2)) ;    % make a bandpass filter for lookupcues
filt.b = b ; filt.a = a ; filt.offset = abs(srch(1)) ;
nz = -round(srch(1)*fs) ;
T = 1000/fs ;                    % display units - milliseconds

% initialize
if nargin==5 & ~isempty(CLA),
   k = nearest(CL,max(CLA(:,1)),abs(srch(1)))+1 ;
   if isnan(k),
      fprintf(' No next click found in CL\n') ;
   end
else
   k = 1 ;
   CLA = [] ;
end

while k<size(CL,1),
   if ~isempty(CLA),
      kk = find(CLA(:,1)<CL(k,1)) ;       % in case we stepped backwards, eliminate aligned
      CLA = CLA(kk,:) ;                   % clicks ahead of the prompt
   end

   K = k+(0:min([len-1 size(CL,1)-k]))' ;    % get cues for next set of clicks
   k = K(end)+1 ;
   fprintf('reading next %d clicks\n',length(K)) ;
   X = lookupcues(tag,CL(K),srch,filt) ;     % read the clicks
   if isempty(X), return; end

   X1 = squeeze(X(:,1,:)) ;               % get real signal on channel 1
   nsamps = size(X1,1) ;
   H1 = hilbert(X1) ;                     % and hilbert-tranform both channels for AoA calculation
   H2 = hilbert(squeeze(X(:,2,:))) ;
   OFFS = 0*K ;                           % a priori offsets are 0
   S = zeros(length(K),4) ;               % space for storing AoA parameters
   for kk=1:length(K),              % for each click in the current set
      if ~NOALIGN,
         r = X1(:,kk) ;                % extract click signal
         if FINDPOS,                   % choose threshold
            [dec nn] = max(r) ;
         else
            [dec nn] = min(r) ;
         end

         % find best estimate of click start cue
         n = 1+min(find(r(2:end-1)>PKRAT*abs(dec) & r(1:end-2)<r(2:end-1) & r(3:end)<r(2:end-1))) ;
         if ~isempty(n),
            OFFS(kk) = n-nz ;    % OFFS is the sample offset from 0 to the detect
         else
            OFFS(kk) = nn-nz ;   % if there is no better estimate, just use min or max point
         end
      end
      
      ks = fixwin(nz+win+OFFS(kk),nsamps) ;    % determine AoA sample window

      % compute AoA using two methods
      [td1,q1] = wb_tdoa(H1(ks,kk),H2(ks,kk)) ;
      [td2,q2] = xc_tdoa(H1(ks,kk),H2(ks,kk)) ;
      aa = 180/pi*real(asin([td1 td2]/fs*AoA_factor)) ;  % convert samples delay into angle
      S(kk,:) = [aa(1) q1 aa(2) q2] ;
   end

   NX1 = X1.*(ones(nsamps,1)*max(abs(H1)).^(-1)) ;   % normalize clicks
   next = 0 ;
   cla = CL(K)+OFFS/fs ;      % initial aligned click cues
   GOOD = 1+0*K ;             % all clicks in set are initially good (i.e., accepted)

   while next==0,             % interaction loop - continue until set is accepted
      kg = find(GOOD) ;       % find all of the currently accepted clicks in the set
      figure(2),clf           % plot their AoA and quality metrics on figure 2
      subplot(211)
      plot(cla(kg),S(kg,[1 3]),'.-'), grid
      title('AoA in degrees')
      subplot(212)
      plot(cla(kg),[S(kg,2) 1-S(kg,4)],'.-'),grid
      xlabel('click cue'),title('AoA metric 0=optimum, 0.25=poor')
      set(gca,'YLim',[0 0.5])

      figure(1),clf           % plot the click waveforms on figure 1
      plot(((1:nsamps)'*ones(1,length(K))-ones(nsamps,1)*OFFS'-nz)*T,...
            NX1+ones(nsamps,1)*(1:length(K))) ;
      hold on, grid on
      plot([1;1]*[min(win) max(win)]*T,get(gca,'YLim')'*[1 1],'k')
      title(sprintf(' %d to %d of %d, cue %5.1f', K(1),K(end),length(CL),CL(K(1)))) ;
      xlabel('time in ms'),ylabel('click in set')
      set(gca,'XLim',tdisp*1000,'YLim',[0 len+1]) ;
      plot(min(get(gca,'XLim'))*0.9*ones(length(kg),1),kg,'k*') ;

      [xr yr button] = ginput(1) ;
      if button=='t',                      % click above image to start a new sequence
         kk = round(yr) ;
         if kk>=1 & kk<=length(GOOD),
            GOOD(kk) = ~GOOD(kk) ;
         end

      elseif button==1
         kk = round(yr) ;
         if kk>=1 & kk<=length(GOOD),
            OFFS(kk) = OFFS(kk)+round(xr/T) ;
            cla = CL(K)+OFFS/fs ;
            ks = fixwin(nz+win+OFFS(kk),nsamps) ;
            [td1,q1] = wb_tdoa(H1(ks,kk),H2(ks,kk)) ;
            [td2,q2] = xc_tdoa(H1(ks,kk),H2(ks,kk)) ;
            aa = 180/pi*real(asin([td1 td2]/fs*AoA_factor)) ;
            S(kk,:) = [aa(1) q1 aa(2) q2] ;
         end

      elseif button=='m'
         OFFS = OFFS+round(xr/T) ;
         cla = CL(K)+OFFS/fs ;
         for kk=1:length(GOOD),
            ks = fixwin(nz+win+OFFS(kk),nsamps) ;
            [td1,q1] = wb_tdoa(H1(ks,kk),H2(ks,kk)) ;
            [td2,q2] = xc_tdoa(H1(ks,kk),H2(ks,kk)) ;
            aa = 180/pi*real(asin([td1 td2]/fs*AoA_factor)) ;
            S(kk,:) = [aa(1) q1 aa(2) q2] ;
         end

      elseif button=='f',
         next = 1 ;
      elseif button=='b',
         k = max([1 K(1)-len]) ;
         next = 1 ;
         GOOD = 0*GOOD ;
      elseif button=='q',    
         next = 2 ;
      end
      
      if next>0,
         kg = find(GOOD) ;
         if ~isempty(kg),
            CLA = [CLA; cla(kg) S(kg,:)] ;
         end
         save alignclickset_Recover CLA
         if next == 2,
            [cc I] = sort(CLA(:,1)) ;
            CLA = CLA(I,:) ;
            return
         end
      end
   end
end


function    k = fixwin(k,nmax)
%
%
k = round(k) ;       % integer indices
if k(1)<1,
   k = k-k(1)+1 ;
   %fprintf(' Warning: win forced away from edge\n') ;
elseif k(end)>nmax,
   k = k+nmax-k(end) ;
   %fprintf(' Warning: win forced away from edge\n') ;
end
return
