function    PRH = prh_predictor2(P,A,fs,MAXD)
%
%    PRH = prh_predictor2(P,A,fs)				% P and A are matrices
%	  or
%    PRH = prh_predictor2(P,A,fs,MAXD)			% P and A are matrices
%	  or
%    PRH = prh_predictor2(P,A)					% P and A are sensor structures
%	  or
%    PRH = prh_predictor2(P,A,MAXD)				% P and A are sensor structures
%    
%     Predict the tag position on a diving animal parameterized by p0, r0, and
%     h0, the cannonical angles between the principal axes of the tag and the animal.
%		The tag orientation on the animal can change with time and this function
%		provides a way to estimate the orientation at the start and end of each suitable
%		dive. The function critically assumes that the animal makes a sequence of short 
%		dives between respirations and that the animal remains upright (i.e., does not roll)
%		during these shallow dives. See prh_predictor1 for a method more suitable to animals
%		that rest horizontally at the surface.
%		The function provides a graphical interface showing the estimated tag-to-animal
%		orientation throughout the deployment. Follow the directions above the top panel
%		of the figure to edit or delete an orientation estimate.
%
%		Inputs:
%     P is a dive depth vector or sensor structure with units of m H2O.
%     A is an acceleration matrix or sensor structure with columns [ax ay az]. 
%		 Acceleration can be in any consistent unit, e.g., g or m/s^2, and must have the
%		 same sampling rate as P.
%     fs is the sampling rate of the sensor data in Hz (samples per second). This is
%		 only needed if A and M are not sensor structures.
%		MAXD is the optional maximum depth of near-surface dives. The default value is 10 m.
%		 This is used to find contiguous surface intervals suitable for analysis.
%
%     Returns:
%	   PRH = [cue,p0,r0,h0,q,length] with a row for each dive edge analysed.
%      cue is the time in second-since-tagon of the dive edge analysed.
%		 [p0,r0,h0] are the deduced tag orientation angles in radians.
%		 q is the quality indicator with a low value (e.g., <0.05) indicating
%		  that the data fit more consistently with the assumptions of the method.
%
%		Example:
%		 See animaltags.org for examples of how to use this function.
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     Modified: 13 Feb 2020 - fixed a couple of minor bugs
%               19 July 2021 - improved segment splitting and added 'a'
%               feature

MINSEG = 30 ;		% minimum surface segment length in seconds
MAXSEG = 300 ;		% maximum surface segment length in seconds
GAP = 5 ;			% keep at least 5s away from a dive edge
PRH = [] ; 

if nargin<2,
   help prh_predictor2
   return
end

if isstruct(P),
   MAXD = fs ;
	[P,A,fs] = sens2var(P,A,'regular') ;
	if isempty(P),	return, end
else
	if nargin<3,
		help prh_predictor2
		return
	end
end

if fs>=7.5,
	df = round(fs/5) ;
	P = decdc(P,df) ;
	A = decdc(A,df) ;
	fs = fs/df ;
end

A = A.*repmat(norm2(A).^(-1),1,3) ; 	% normalise A to 1 g
v = depth_rate(P,fs,0.2) ;					% vertical speed

if isempty(MAXD),
	MAXD = 10 ;
elseif size(MAXD,2)==6,
   S = [MAXD(:,1) MAXD(:,1)+MAXD(:,6)] ;
   MAXD = [] ;
else
   MAXD = max(MAXD(1),2) ;
end
	
if ~isempty(MAXD),
   fprintf('Finding dives > %d meters\n',MAXD);
   T = find_dives(P,fs,MAXD) ; 	% find dives more than MAXD from the surface
   if isempty(T),
      fprintf(' No dives deeper than %d found in dive profile - change MAXD\n',MAXD) ;
      return
   end
   fprintf('Found %d dives\n',length(T.start));

   T.start = T.start-GAP ;
   T.end = T.end+GAP ;

   % check if there is a segment before first dive and after last dive
   s1 = [max(T.start(1)-MAXSEG,0),T.start(1)] ;
   se = [T.end(end),min(T.end(end)+MAXSEG,(length(P)-1)/fs)] ;
   k = find(P(round(fs*s1(1))+1:round(fs*s1(2)))>MAXD,1,'last') ;
   if ~isempty(k),
      s1(1) = s1(1)+k/fs ;
   end
   k = find(P(round(fs*se(1))+1:round(fs*se(2)))>MAXD,1) ;
   if ~isempty(k),
      se(2) = se(1)+(k-1)/fs ;
   end
   S = [s1;[T.end(1:end-1) T.start(2:end)];se] ;
   S = S(find(diff(S,[],2)>MINSEG),:) ;

   fprintf('Breaking up surface intervals\n');
   % break up long surfacing intervals
   k = find(diff(S,[],2)>=2*(MAXSEG+MINSEG)) ;
   n = floor((S(k,2)-S(k,1))/(MAXSEG+MINSEG)) ;
   for kk=1:length(k),
      S(end+(1:n(kk)),:) = repmat(S(k(kk),1)+(1:n(kk))'*(MAXSEG+MINSEG),1,2)+repmat([0 MAXSEG],n(kk),1) ;
   end
   S(k,2) = S(k,1)+MAXSEG ;
   [s,I] = sort(S(:,1)) ;
   S = S(I,:) ;
   fprintf('Found %d surface intervals\n',size(S,1));
end

% check for segments with sufficient variation in orientation
V = zeros(size(S,1),1) ;
for k=1:size(S,1),
   ks = round(S(k,1)*fs)+1:round(S(k,2)*fs) ;
   V(k) = norm(std(A(ks,:))) ;
end

if ~isempty(MAXD),
   thr = nanmedian(V)+1.5*iqr(V)*[-1 1] ;
   S = S(V>thr(1) & V<thr(2),:) ;
end
PRH = NaN(size(S,1),6) ;

if isempty(S),
   fprintf('No suitable surface analysis intervals found - check data\n') ;
   return
end

fprintf('Applying method 2\n');
for k=1:size(S,1),	% apply prh inference method on segments
   prh = applymethod2(A,v,fs,S(k,:)) ;
	if isempty(prh), continue, end
	PRH(k,:) = [S(k,1) prh S(k,2)-S(k,1)] ;
end

figure(1),clf
plot_fig1(P,fs,PRH) ;

while 1,                % user input to adjust results
   [gx,gy,butt] = ginput(1) ;
	k = nearest(PRH(:,1),gx) ;
	if butt==1,
      fprintf(' %d: %3.1f degrees\n',round(gx),gy) ;
   else
		switch butt
         case {'q','Q'}
            break ;
			case 'e'
				ss = plot_fig2(A,v,fs,S(k,:),PRH(k,:)) ;
				if isempty(ss),
				   z = [1:k-1 k+1:size(S,1)] ;
               S = S(z,:) ;
               PRH = PRH(z,:) ;
				else
					S(k,:) = ss ;
					prh = applymethod2(A,v,fs,ss) ;
					PRH(k,:) = [ss(1) prh diff(ss)] ;
				end
 				plot_fig1(P,fs,PRH) ;
        case 'a'
            ss = gx+MINSEG*[-1,1] ;
			   prh = applymethod2(A,v,fs,ss) ;
				ss = plot_fig2(A,v,fs,ss,[mean(ss) prh]) ;
				if ~isempty(ss),
					prh = applymethod2(A,v,fs,ss) ;
               S(end+1,:) = ss ;
					PRH(end+1,:) = [ss(1) prh diff(ss)] ;
               [s,I] = sort(S(:,1)) ;
               S = S(I,:);
               PRH = PRH(I,:) ;
				end
				plot_fig1(P,fs,PRH) ;
        case 'x'
				z = [1:k-1 k+1:size(S,1)] ;
				S = S(z,:) ;
            PRH = PRH(z,:) ;
				plot_fig1(P,fs,PRH) ;
			case 'z'
				xl = get(gca,'XLim') ;
				xl = gx+diff(xl)/4*[-1 1] ;
				xl(1) = max(xl(1),0) ;
				xl(2) = min(xl(2),length(P)/fs) ;
				subplot(311),set(gca,'XLim',xl) ;
				subplot(312),set(gca,'XLim',xl) ;
				subplot(313),set(gca,'XLim',xl) ;
			case 'Z'
				xl = get(gca,'XLim') ;
				xl = gx+diff(xl)*[-1 1] ;
				xl(1) = max(xl(1),0) ;
				xl(2) = min(xl(2),length(P)/fs) ;
				subplot(311),set(gca,'XLim',xl) ;
				subplot(312),set(gca,'XLim',xl) ;
				subplot(313),set(gca,'XLim',xl) ;
      end
	end
end
return


function    prh = applymethod2(A,v,fs,ss)
%     For animals that do sequences of roll-free shallow dives.
%     Chooses r0 and h0 to minimize the mean-squared
%     y-axis acceleration in segment As and then chooses
%     p0 for a mean pitch angle of 0.

% break into eigen-axes: assuming that the motion is mostly planar,
% the eigenvalues of QQ will indicate how planar: the largest two eigenvalues
% describe the energy in the plane of motion; the smallest eigenvalue
% describes the energy in the invariant direction i.e., the axis of
% rotation

ks = round(ss(1)*fs)+1:round(ss(2)*fs) ;
As = A(ks,:) ;
vs = v(ks) ;

% energy ratio between plane-of-motion and axis of rotation 
QQ = As'*As ;            % form outer product of acceleration
if any(isnan(QQ))
   prh = [] ;
   return 
end

[V,D] = svd(QQ) ;          
pow = D(3,3)/D(2,2) ;   % if the inverse condition pow>~0.05, the motion in As
                        % is more three-dimensional than two-dimensional

% axis of rotation to restore V to tag Y axis
aa = acos([0 1 0]*V(:,3)) ;
Phi = cross([0;1;0],V(:,3))/sin(aa) ;
S = [0,-Phi(3),Phi(2);Phi(3),0,-Phi(1);-Phi(2),Phi(1),0] ;	% skew matrix
Q = eye(3)+(1-cos(aa))*S*S-sin(aa)*S ;    % generate rotation matrix for rotation 
                                          % of aa degrees around axis Phi
am = mean(As)*Q' ;
p0 = atan2(am(1),am(3)) ;
Q = euler2rotmat([p0 0 0])*Q ;
prh = [asin(Q(3,1)) atan2(Q(3,2),Q(3,3)) atan2(Q(2,1),Q(1,1))] ;

aa = As*Q(2,:)' ;
prh(4) = mean([pow,std(aa)]) ;

% check that h0 is not 180 degrees out by checking that the regression
% between Aa(:,1) and depth_rate is negative.
Q = euler2rotmat(prh(1:3)) ;	% make final transformation matrix
Aa = As*Q' ;						% animal frame acceleration for the segment
pp = polyfit(Aa(:,1),vs,1) ;
if pp(1)>0,
   prh(3) = rem(prh(3)-pi,2*pi) ;   % if incorrect, add/subtract 180 degrees
end

for k=2:3,		% by convention, constrain r0 and h0 to the interval -pi:pi
   if abs(prh(k))>pi,
      prh(k) = prh(k)-sign(prh(k))*2*pi ;
   end
end
return


function		plot_fig1(P,fs,PRH)
%				
figure(1)
if isempty(get(gcf,'Children')),
	xl = [0 length(P)/fs] ;
else
	xl = get(gca,'XLim') ;
end

subplot(311)
plot((1:length(P))/fs,P), set(gca,'YDir','reverse'), grid
ylabel('Depth, m')
set(gca,'XLim',xl,'XTickLabel',[]) ;
title('type e to edit, x to delete, z or Z to zoom in/out, a to add a segment, or q to quit')
subplot(312)
plot(PRH(:,1),PRH(:,2:4)*180/pi,'*-'), grid
set(gca,'XLim',xl,'XTickLabel',[])
ylabel('PRH, degrees')
subplot(313)
plot(PRH(:,1),min(PRH(:,5),0.15),'*-'), grid
set(gca,'XLim',xl,'YLim',[0 0.15])
xlabel('time cue')
ylabel('Quality')
return


function		seg = plot_fig2(A,v,fs,seg,prh)
%
YEXT = 12.5 ;           % vertical extent of accelerometry plots +/-m/s^2
rctx = [0 1 1 0;1 1 0 0] ;
rcty = [0 0 1 1;0 1 1 0] ;
while 1,
	figure(2),clf
	xl = seg+[-30 30] ;
	Aw = A*euler2rotmat(prh(2:4))' ;
	subplot(211)
	plot((1:size(A,1))/fs,A*9.81), set(gca,'XLim',xl), grid
	ylabel('Tag frame A, m/s^2')
	set(gca,'YLim',YEXT*[-1 1],'XLim',xl,'XTickLabel',[]) ;
	hold on
	plot(diff(seg(1:2))*rctx+seg(1),0.9*YEXT*(2*rcty-1),'k') ;
	title('type 1 or 2 to change segments, x to erase, or q to quit')
	subplot(212)
	plot((1:size(A,1))/fs,Aw*9.81), set(gca,'XLim',xl), grid
	ylabel('Animal frame A, m/s^2')
	set(gca,'YLim',YEXT*[-1 1],'XLim',xl) ;
	hold on
	plot(diff(seg(1:2))*rctx+seg(1),0.9*YEXT*(2*rcty-1),'k') ;
	mess = sprintf('%s  p0=%3.1f  r0=%3.1f  h0=%3.1f  quality=%4.3f', ...
            prh(1),prh(2:4)*180/pi,prh(5)) ;
	title(mess,'FontSize',12) ;
	[gx,gy,butt] = ginput(1) ;
	gx = max(min(gx,size(A,1)/fs),0) ;
	if butt=='1',
		seg(1) = gx ;
	elseif butt=='2',
		seg(2) = gx ;
	else
      if butt=='x',
         seg = [] ;
      end
      figure(1)
      return
	end
	prh(2:5) = applymethod2(A,v,fs,seg) ;
end
return
