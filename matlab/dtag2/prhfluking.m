function    PRH = prhfluking(p,A,fs,cue)
%
%    PRH = prhfluking(p,A,fs,cue)
%     EXPERIMENTAL !!!
%     Predict the tag position on the whale parameterized by p0, r0, and
%     h0, the cannonical angles between the whale and the tag principal axes.
%     p is the measured depth vector (from the prh file).
%     A is the measured (i.e., tag-frame) accelerometer matrix.
%     fs is the sensor sampling rate.
%     TH is an optional dive depth threshold (default is 500m).
%     DIR is an optional dive direction constraint. DIR='ascent' rejects
%     descents for analysis. DIR='descent' rejects ascents. The default
%     behaviour accepts both dive directions.
%
%     Returns PRH = [cue,p0,r0,h0,dir,quality] with a row for each dive edge
%     analyzed. cue is the second-since-tagon of the dive edge. [p0,r0,h0]
%     are the deduced tag orientation angles in radians. 'dir' is the dive
%     direction: 1 is an ascent, -1 is a descent. 'quality' is one or more
%     columns of quality metrices depending on the method employed.
%
%     Two methods are supported:
%      Method 1 is suitable for logging-diving animals, e.g. sperm whales
%      Method 2 is suitable for whales that make short dives while
%      respiring, e.g., beaked whales.
%
%     mark johnson, WHOI
%     majohnson@whoi.edu
%     Last modified: September 2006

MARGIN = 30 ;
FH = [0.3 1.5] ;                    % high pass filter cut-off for fluking

PRH = [] ; 
if nargin<4,
   help prhfluking
   return
end

if length(cue)==2,
   LEN = abs(diff(cue)) ;
else
   LEN = 60 ;
end
CUE = cue(1) ;

[bb aa] = butter(4,FH/(fs/2)) ;
figure(1),clf
subplot(311), plot((1:length(p))/fs,p), set(gca,'YDir','reverse'), grid
axis tight
done = 0 ;

while done<2,                % for each dive edge
   done = 0 ;
   segs = CUE+[0 LEN] ;       % initial segment size

   while ~done,                     % continue with this edge until we are happy
      % select segments of data for analysis
      k = round(segs(1)*fs:segs(2)*fs) ;    % analysis segment
      % display segment
      kk = nanmax([1 k(1)-MARGIN*fs]):nanmin([length(p) k(end)+MARGIN*fs]) ;
      AA = A(kk,:) ;
      dp = diff(p(k)) ;
      if mean(dp)>std(detrend(dp)),
         dir = -sign(mean(dp)) ;    % animal is ascending or descending
      else
         dir = 0 ;
      end

      % apply prh inference method on segments
      npre = round(2*fs/FH(1)) ;
      kp = k(1)-npre:k(end) ;
      [prh,Q,pow] = applymethod(A(kp,:),npre,dir,bb,aa) ;
      nPRH = [PRH ; segs(1),prh,dir,pow(1)] ;

      % plot uncorrected data and analysis segments
      plotresults(AA,AA*Q',kk/fs,segs,nPRH) ;

      % report results
      ss = sprintf('p0=%3.1f  r0=%3.1f  h0=%3.1f  cond=%4.3f  rms=%4.3f', ...
            prh*180/pi,pow) ;
      title(ss,'FontSize',12) ;

      [x,y,butt] = ginput(1) ;
      if isempty(butt), butt = 'f' ; end

      if butt==1,
         [m n] = min(abs(segs-x)) ;     % find nearest segment edge to x
         segs(n) = min([length(p) max([1 round(fs*x)])])/fs ;   % constrain to within record

      else switch butt
         case 'q'
                  done = 2 ;
         case 'x'
                  done = 1 ;
         otherwise   % store and report results
                  PRH = nPRH ;
                  % report results
                  fprintf('cue=%6.0f\tp0=%3.1f, r0=%3.1f, h0=%3.1f, cond=%4.3f, rms=%4.3f\n',...
                        segs(1),prh*180/pi,pow) ;
                  done = 1 ;
         end
      end
      if done~=0,
         CUE = segs(2) ;
      end
   end
end



function    [prh,Q,pow] = applymethod(A,np,dir,bb,aa)
%
%     For rolling-surfacing (descending or ascending)
%     Chooses r0 and h0 to minimize the mean-squared
%     y-axis acceleration in segment Ak1 and then chooses
%     p0 for a mean pitch angle of 0. Segment Ak2 is not used.
%

% break into eigen-axes: assuming that the motion is mostly planar,
% the eigenvalues of QQ will indicate how planar: the largest two eigenvalues
% describe the energy in the plane of motion; the smallest eigenvalue
% describes the energy in the invariant direction i.e., the axis of
% rotation

% high-pass filter accelerometer signals
Af = filter(bb,aa,A) ;
Af = Af(np:end,:) ;
A = A(np:end,:) ;

% energy ratio between plane-of-motion and axis of rotation 
QQ = Af'*Af ;              % form outer product of filtered accelerations
[V,D] = svd(QQ) ;          
pow = D(3,3)/D(2,2) ;      % if the inverse condition cc>~0.05, the motion in Ak2
                           % is better described as three-dimensional than
                           % two-dimensional

% axis of rotation to restore V to tag Y axis
aa = acos([0 1 0]*V(:,3)) ;
Phi = cross([0;1;0],V(:,3))/sin(aa) ;
S = skew(Phi) ;
Q = eye(3)+(1-cos(aa))*S*S-sin(aa)*S ;    % generate rotation matrix for rotation 
                                          % of aa degrees around axis Phi
am = mean(A)*Q' ;
p0 = atan2(am(1),am(3)) ;
p0=0 ;
Q = makeT([p0 0 0])*Q ;
prh = [asin(Q(3,1)) atan2(Q(3,2),Q(3,3)) atan2(Q(2,1),Q(1,1))] ;

aa = Af*Q(2,:)' ;
pow(2) = std(aa) ;
Q = makeT(prh) ;                          % make transformation matrix

% check that h0 is not 180 degrees out by checking that the sign of the
% pitch is correct for the dive edge - descent is pitch down, ascent is
% pitch up.

if dir~=0,
   if sign(mean(A*Q(1,:)')) ~= dir,
      prh(3) = rem(prh(3)-pi,2*pi) ;   % if incorrect, add/subtract 180 degrees
      Q = makeT(prh) ;
   end
end

% by convention, constrain r0 and h0 to the interval -pi:pi
for k=2:3,
   if abs(prh(k))>pi,
      prh(k) = prh(k)-sign(prh(k))*2*pi ;
   end
end
return


function    plotresults(Au,Al,tt,segs,PRH) ;
%
%

figure(1)
subplot(311), XL = get(gca,'XLim') ;
subplot(312), plot(PRH(:,1),PRH(:,2:4)*180/pi,'*-'); grid, set(gca,'XLim',XL)
hold on, plot(PRH(end,1),PRH(end,2:4)*180/pi,'o'), hold off
subplot(313), plot(PRH(:,1),PRH(:,6),'*-'); grid, set(gca,'XLim',XL,'YLim',[0 0.1])
hold on, plot(PRH(end,1),PRH(end,6),'o'), hold off
figure(2)

YEXT = 1.25 ;           % vertical extent of accelerometry plots +/-g
rctx = [0 1 1 0;1 1 0 0] ;
rcty = [0 0 1 1;0 1 1 0] ;

figure(2),clf
subplot(211),plot(tt,Au),grid,hold on
set(gca,'YLim',YEXT*[-1 1],'LineWidth',1,'XLim',round(tt([1 end]))) ;
ylabel('A, g'), title('Tag-frame accelerometer signals')

plot(diff(segs(1:2))*rctx+segs(1),0.9*YEXT*(2*rcty-1),'k') ;

% plot corrected accelerometer vector for the interval
subplot(212),hz = plot(tt,Al); grid,hold on
set(gca,'YLim',YEXT*[-1 1],'LineWidth',1,'XLim',round(tt([1 end]))) ;
xlabel('time cue'), ylabel('A, g')
return
