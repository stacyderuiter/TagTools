function    [W,WDEL] = harlequin(tag,cue,win,center,nodisp,LPF)
%
%    [W,WDEL]=harlequin(tag,cue,win,[center,nodisp,LPF])
%     Draw harlequin plot for pitch-roll-heading excerpts. The
%     excerpts extend from cues+win(1) to cues+win(2). If a
%     4th argument is given, it is used as an offset with respect
%     to win to center the tracks.
%     Optional argument nodisp disables figure generation if 1.
%     Note: uses a fixed speed. Change CS in the script to adjust this.
%     As tracklets are coloured by roll, only tracklets with |pitch|<80
%     degrees are drawn.
%
%     mark johnson, WHOI
%     majohnson@whoi.edu
%     last modified: 5 January, 2007

if nargin<3,
   help harlequin
   return
end

CS = 1.3 ;                       % nominal speed in m/s
cue = cue(:) ;

if nargin<6,
   LPF = 0.5 ;                   % movement low-pass filter cut-off in Hz
end

if nargin<5 | isempty(nodisp),
   nodisp = 0 ;
end

if nargin<4 | isempty(center),
   center = 0 ;
end

if length(center)~=length(cue),
   center = center(1)+0*cue ;
end

if any(center<win(1) | center>win(2)),
   fprintf('Argument center must be within display window win\n')
   return
end

loadprh(tag,'p','fs','Mw','Aw') ;

kcue = round(cue*fs) ;
kwin = win*fs ;
kc = round(fs*(center-win(1)))+1 ;

[b a] = butter(2,LPF/(fs/2)) ;         % movement low-pass filter
Af = filtfilt(b,a,Aw) ;                % smooth accelerometry
Mf = filtfilt(b,a,Mw) ;                % smooth magnetometry
D = extractcues(p,kcue,kwin) ;          % get depth extract
AA = extractcues(Af,kcue,kwin) ;        % get acceleration extract
MM = extractcues(Mf,kcue,kwin) ;        % get magnetometer extract

% extract smoothed pitch, roll, and heading
PP = zeros(size(AA,1),size(AA,3)) ;
RR = PP ; HH = PP ; 

if nargout==2,
   RDEL = PP ; HDEL = PP ; PDEL = PP ;
   MAGXDIFF = PP ; ZXDIFF = PP ;
   delr = zeros(size(AA,1),1) ;
   delh = delr ; delp = delr ;
   zxdiff = delr ; magxdiff = delr ;
   AN = extractcues(Aw,kcue,kwin) ;        % get acceleration extract
   MN = extractcues(Mw,kcue,kwin) ;        % get magnetometer extract
end

for kk=1:size(AA,3),
   [pp rr] = a2pr(AA(:,:,kk)) ;           % pitch and roll
   HH(:,kk) = m2h(MM(:,:,kk),pp,rr) ;     % heading
   PP(:,kk) = pp ; 
   RR(:,kk) = rr ; 
   
   if nargout==2,
      W = bodyaxes(AA(:,:,kk),MM(:,:,kk)) ;
      %for kkk=2:size(W,3),
      %   Q = squeeze(W(:,:,kkk-1))'*squeeze(W(:,:,kkk)) ;
         %delr(kkk) = -[0 1 0]*Q*[0;0;1] ;  % small angle approx
      %   delr(kkk) = -atan2(Q(2,3),Q(3,3)) ;
      %   delh(kkk) = atan2(Q(1,2),Q(1,1)) ;
      %   delp(kkk) = -asin(Q(1,3)) ;
      %end
      WN = bodyaxes(AN(:,:,kk),MN(:,:,kk)) ;
      for kkk=1:size(W,3),
         Q = squeeze(W(:,:,kkk))'*squeeze(WN(:,:,kkk)) ;
         delr(kkk) = -atan2(Q(2,3),Q(3,3)) ;
         delh(kkk) = atan2(Q(1,2),Q(1,1)) ;
         delp(kkk) = -asin(Q(1,3)) ;
      end

      RDEL(:,kk) = delr ;
      HDEL(:,kk) = delh ;
      PDEL(:,kk) = delp ;
      Xdiff = diff(squeeze(W(:,1,:))')*fs ;
      Z = squeeze(W(:,3,:))' ;
      MAGXDIFF(:,kk) = [0;sqrt(Xdiff.^2*[1;1;1])] ;
      ZXDIFF(:,kk) = [0;Z(2:end,:).*Xdiff*[1;1;1]] ;
   end
end

% make horizontal tracklets
HTR = cumsum(cos(PP).*exp(j*HH))*CS/fs ;

% center tracks and depths on center point
for k=1:length(kc),
   HTR(:,k) = HTR(:,k)-HTR(kc(k),k) ;
   DD(:,k) = D(:,k)-D(kc(k),k) ;
end

W.TRACK = HTR ;
W.DEPTH = DD ;
W.ROLL = RR ;
W.PITCH = PP ;
W.HEAD = HH ;

if nargout==2,
   WDEL.R = RDEL ;
   WDEL.H = HDEL ;
   WDEL.P = PDEL ;
   WDEL.MAGXDIFF = MAGXDIFF ;
   WDEL.ZXDIFF = ZXDIFF ;
end

if nodisp,
   return
end

% make display
% x-axis is easting, y-axis is northing
hold off,plot3(0,0,0),grid
hold on
for kk=1:length(kcue),
   if all(abs(PP(:,kk))<80/180*pi),
      scatter3(imag(HTR(:,kk)),real(HTR(:,kk)),DD(:,kk),...
         9,180/pi*abs(RR(:,kk)),'filled')
      hh = plot3(imag(HTR(1,kk)),real(HTR(1,kk)),DD(1,kk),'ko') ;
      set(hh,'MarkerSize',6,'LineWidth',1.5) ;
   end
end

SZE = max(max(abs([DD imag(HTR(:,kk)) real(HTR(:,kk))]))) ;
axis(1.2*SZE*[-1 1 -1 1 -1 1])
set(gca,'ZDir','reverse')
caxis([0 180])
