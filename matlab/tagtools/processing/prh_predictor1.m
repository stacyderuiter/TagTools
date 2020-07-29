function    PRH = prh_predictor1(P,A,fs,TH,DIR)
%
%    PRH = prh_predictor1(P,A,fs)				% P and A are matrices
%	  or
%    PRH = prh_predictor1(P,A,fs,TH)         % P and A are matrices
%	  or
%    PRH = prh_predictor1(P,A,fs,TH,DIR)		% P and A are matrices
%	  or
%    PRH = prh_predictor1(P,A)					% P and A are sensor structures
%	  or
%    PRH = prh_predictor1(P,A,TH)            % P and A are sensor structures
%	  or
%    PRH = prh_predictor1(P,A,TH,DIR)			% P and A are sensor structures
%    
%     Predict the tag position on a diving animal parameterized by p0, r0, and
%     h0, the cannonical angles between the principal axes of the tag and the animal.
%		The tag orientation on the animal can change with time and this function
%		provides a way to estimate the orientation at the start and end of each suitable
%		dive. The function critically assumes that the animal rests horizontally at the
%		surface (at least on average) and dives steeply away from the surface without an
%		initial roll. If ascents are processed, there must also be no roll in the last 
%		seconds of the ascents. See prh_predictor2 for a method more suitable to animals
%		that make short dives between respirations.
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
%		 only needed if neither A nor M are sensor structures.
%     TH is an optional minimum dive depth threshold (default is 100m). Only the descents
%		 at the start of dives deeper than TH will be analysed (and the ascents at the end of 
%		 dives deeper than TH if ALL is true).
%     DIR is an optional dive direction constraint. The default (and if DIR=0) is to only 
%		 analyse descents as these tend to give better results. But if DIR=1, both descents 
%		 and ascents are analysed.
%
%     Returns:
%	   PRH = [cue,p0,r0,h0,q] with a row for each dive edge analysed.
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
%     Last modified: 15 Nov 2019

SURFLEN = 30 ;		% target surface segment length in seconds
DIVELEN = 15 ;		% target dive segment length in seconds
GAP = 4 ;			% keep at least 4s away from a dive edge
PRH = [] ; 

if nargin<3,
   help prh_predictor1
   return
end

if isstruct(P),
	if nargin>3,
		DIR = TH ;
	else
		DIR = [] ;
	end
	if nargin>2,
		TH = fs ;
	else
		TH = [] ;
   end
	[P,A,fs] = sens2var(P,A,'regular') ;
	if isempty(P),	return, end

else
	if nargin<5,
		DIR = [] ;
	end
	if nargin<4,
		TH = [] ;
	end
	if nargin<3,
		help prh_predictor1
		return
	end
end

if isempty(TH),
   TH = 100 ;           % default dive depth threshold
end

if isempty(DIR),
   DIR = 0 ;       		% default is to analyse ascents and descents
end

if fs>=7.5,
	df = round(fs/5) ;
	P = decdc(P,df) ;
	A = decdc(A,df) ;
	fs = fs/df ;
end

A = A.*repmat(norm2(A).^(-1),1,3) ; 	% normalise A to 1 g
T = find_dives(P,fs,TH,2) ;

if isempty(T),
   fprintf(' No dives deeper than %4.0f found\n', TH) ;
   return
end

T.end = T.end+GAP ;

% make descent analysis segments
S = repmat(T.start,1,4)+repmat([-SURFLEN-GAP -GAP GAP GAP+DIVELEN],length(T.start),1) ;
S(:,end+1) = -1 ;		% descent indicator

if DIR==1,		% make ascent segments
	SS = repmat(T.end,1,4)+repmat([GAP SURFLEN+GAP -GAP-DIVELEN -GAP],length(T.end),1) ;
	SS(:,end+1) = 1 ;		%ascent indicator
	S = [S;SS] ;
	[s,I] = sort(S(:,1)) ;	% sort segments into numerical order
	S = S(I,:) ;
end

PRH = NaN(size(S,1),5) ;

for k=1:size(S,1),	% apply prh inference method on segments
   prh = applymethod1(A,fs,S(k,:)) ;
	if isempty(prh), continue, end
	PRH(k,:) = [mean(S(k,1:2)) prh] ;
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
            ss = plot_fig2(A,fs,S(k,:),PRH(k,:)) ;
            if isempty(ss),
               z = [1:k-1 k+1:size(S,1)] ;
               S = S(z,:) ;
               PRH = PRH(z,:) ;
            else
               S(k,:) = ss ;
               prh = applymethod1(A,fs,ss) ;
               PRH(k,:) = [mean(ss(1:2)) prh] ;
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


function    prh = applymethod1(A,fs,ss)
%     For logging-diving dive edges (descending or ascending)
%     Chooses p0 and r0 for a horizontal whale during the logging
%     segment (Ak1) and chooses h0 to minimize the mean-squared
%     y-axis acceleration in the diving segment (Ak2).
%

ks1 = round(ss(1)*fs)+1:round(ss(2)*fs) ;
ks2 = round(ss(3)*fs)+1:round(ss(4)*fs) ;
Ak1 = A(ks1,:) ;
Ak2 = A(ks2,:) ;
Am1 = mean(Ak1)' ;           % mean acceleration in logging segment
[p0,r0] = a2pr(Am1) ;        % corresponding p0 and r0
prh = [p0,r0,0] ;
Q = euler2rotmat(prh) ;      % transformation to remove p0 and r0 from A
At2 = Ak2*Q' ;               % transformed acceleration in diving segment

AA = sum([At2(:,1:2).^2 At2(:,1).*At2(:,2)]) ;  % sum-of-squares needed for ls algorithm

% 2 quadrant atan - determine the correct quadrant later from context
h2 = atan(2*AA(3)/(AA(1:2)*[-1;1])) ;

% check that this is a minima - if not add 180 degrees
if AA(1:2)*[1;-1]*cos(h2)-2*AA(:,3)*sin(h2)<0,
   h2 = h2+pi ;
end

prh(3) = h2/2 ;            % actual h0 is half of h2

% Quality metrices:
% 1. Residual squared error for the chosen h0
se = AA(1:2)*[1;1]/2+AA(1:2)*[-1;1]*cos(h2)/2+AA(3)*sin(h2) ;

% 2. energy ratio between plane-of-motion and axis of rotation 
QQ = Ak2'*Ak2 ;            % form outer product of acceleration in diving segment
if any(isnan(QQ))
   prh = [] ;
   return 
end

% break into eigen-axes: assuming that the motion is mostly planar,
% the eigenvalues of QQ will indicate how planar: the largest two eigenvalues
% describe the energy in the plane of motion; the smallest eigenvalue
% describes the energy in the invariant direction i.e., the axis of rotation.

[V,D] = svd(QQ) ;    
cc = D(3,3)/D(2,2) ;       % if the inverse condition cc>~0.05, the motion in Ak2
                           % is more three-dimensional than two-dimensional

prh(4) = mean([cc,sqrt(se/size(Ak2,1))]) ;	% collect the quality metrices

% check that h0 is not 180 degrees out by checking that the sign of the
% pitch is correct for the dive edge - descent is pitch down, ascent is
% pitch up.
Q = euler2rotmat(prh(1:3)) ;	% make final transformation matrix
Aa = Ak2*Q' ;						% animal frame acceleration for the segment
if mode(sign(Aa(:,1))) ~= ss(5),
   prh(3) = rem(prh(3)-pi,2*pi) ;   % if incorrect, add/subtract 180 degrees
end

% by convention, constrain r0 and h0 to the interval -pi:pi
for k=2:3,
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
title('type e to edit, x to delete, z or Z to zoom in/out, or q to quit')
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


function		seg = plot_fig2(A,fs,seg,prh)
%
YEXT = 12.5 ;           % vertical extent of accelerometry plots +/-m/s^2
rctx = [0 1 1 0;1 1 0 0] ;
rcty = [0 0 1 1;0 1 1 0] ;

while 1,
	figure(2),clf
	xl = [min(seg(1:4))-30 max(seg(1:4))+30] ;
	Aw = A*euler2rotmat(prh(2:4))' ;
	subplot(211)
	plot((1:size(A,1))/fs,A*9.81), set(gca,'XLim',xl), grid
	ylabel('Tag frame A, m/s^2')
	set(gca,'YLim',YEXT*[-1 1],'XLim',xl,'XTickLabel',[]) ;
	hold on
	plot(diff(seg(1:2))*rctx+seg(1),0.9*YEXT*(2*rcty-1),'k') ;
	plot(diff(seg(3:4))*rctx+seg(3),0.9*YEXT*(2*rcty-1),'k') ;
	title('type 1, 2, 3 or 4 to change segments, x to erase, or q to quit')
	subplot(212)
	plot((1:size(A,1))/fs,Aw*9.81), set(gca,'XLim',xl), grid
	ylabel('Animal frame A, m/s^2')
	set(gca,'YLim',YEXT*[-1 1],'XLim',xl) ;
	hold on
	plot(diff(seg(1:2))*rctx+seg(1),0.9*YEXT*(2*rcty-1),'k') ;
	plot(diff(seg(3:4))*rctx+seg(3),0.9*YEXT*(2*rcty-1),'k') ;
	mess = sprintf('%s  p0=%3.1f  r0=%3.1f  h0=%3.1f  quality=%4.3f', ...
            prh(1),prh(2:4)*180/pi,prh(5)) ;
	title(mess,'FontSize',12) ;
	[gx,gy,butt] = ginput(1) ;
	gx = max(min(gx,size(A,1)/fs),0) ;
	if ismember(butt,'1234'),
		ss = butt-'1'+1 ;		% convert button into index 1..4
		if seg(5)<0,			% if this is a descent, the index is correct
			seg(ss) = gx ;
		else						% if it an ascent, swap 3,4 with 1,2
			seg(rem(ss+1,4)+1) = gx ;
		end
   else
      if butt=='x',
         seg = [] ;
      end
      figure(1)
      return
	end
	prh(2:end) = applymethod1(A,fs,seg) ;
end
return
