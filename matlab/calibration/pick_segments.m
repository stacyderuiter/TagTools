function		S = pick_segments(X,fs,S)

%		S = pick_segments(X)				% X is a sensor structure
%		or
%		S = pick_segments(X,S)			% X is a sensor structure
%		or
%		S = pick_segments(X,fs)			% X is a vector or matrix
%		or
%		S = pick_segments(X,fs,S)		% X is a vector or matrix
%
%		Graphical user interface tool to pick regions of interest in a data plot.
%		The data in X is plotted against time and boxes can be drawn around segments.
%		Hold down a mouse button to drag rectangles around segments.
%		If a new rectangle overlaps an existing one, they are summed.
%		Press keys to get the following functions:
%		'q'	Quit
%		'x'	Zoom out centred at the current pointer position
%		'z'	Zoom in centred at the current pointer position
%		'a'	Return to original full view
%		'd'	Delete the rectangle at the current pointer position
%		'1'	Move the left-hand edge of the rectangle to the current pointer position
%		'2'	Move the right-hand edge of the rectangle to the current pointer position
%		For d,1 and 2, the pointer must be within a rectangle.
%
%		Inputs:
%		X is a sensor structure or a vector or matrix of data. X can be any kind
%		 of data and at any sampling rate.
%		fs is the sampling rate in Hz of the data in X. Only include fs if X is not
%		 a sensor structure.
%		S is the optional result from a previous call of pick_segments. This enables
%		 iterative editing of segments and adding new segments.
%
%		Returns:
%		S is a two column matrix with the time in seconds of the start (1st column)
%		 and end (2nd column) of each selected segment.
%
%		Example:
%		S=pick_segments(M) ;
%		M.cal_exclude=S ;
%		[MM,mc] = auto_cal_mag(M,CAL.MAG,45,T) ;
%
%		To edit the segments and re-run the calibration:
%		S=pick_segments(M,S) ;
%		M.cal_exclude=S ;
%		[MM,mc] = auto_cal_mag(M,CAL.MAG,45,T) ;
%
%     markjohnson@bio.au.dk
%     Last modified: Jan 2022 - added exclusion table option


if isstruct(X),
	if nargin==1,
		S = [] ;
	else
		S = fs ;
	end
	[X,fs] = sens2var(X) ;
elseif nargin<3,
	S = [] ;
end

figure(1),clf
plott(X,fs) ;
ax = gca ;
set(gcf,'Pointer','crosshair');
set(gcf,'WindowButtonMotionFcn',@(o,e) dummy());
xm = get(ax,'UserData') ;
hold on
H = plot_segments([],S/xm) ;
set(gcf,'Units','normalized')
pos = get(ax,'Position') ;
xlorig = get(ax,'XLim') ;
ax_norm = pos(1)+[0 pos(3)] ;
disableDefaultInteractivity(ax)
set(ax,'Interactions',[],'Toolbar',[])
zoom off

while 1
	drawnow
	if waitforbuttonpress,
		button = get(gcf,'CurrentCharacter');
		pt = get(ax,'CurrentPoint') ;
		x = pt(1,1)*xm ;
		switch button
			case 'z'
				xl = get(ax,'XLim') ;
				xl = x/xm+diff(xl)/4*[-1 1] ;
				xl(1) = max(xl(1),xlorig(1)) ;
				xl(2) = max(xl(2),xlorig(2)) ;
				set(ax,'XLim',xl) ;
			case 'x'
				xl = get(ax,'XLim') ;
				xl = x/xm+diff(xl)*[-1 1] ;
				xl(1) = max(xl(1),xlorig(1)) ;
				xl(2) = max(xl(2),xlorig(2)) ;
				set(ax,'XLim',xl) ;
			case 'a'
				set(ax,'XLim',xlorig) ;
			case 'd'
				if ~isempty(S),
					kl = find(x>=S(:,1) & x<=S(:,2)) ;
					if ~isempty(kl),
						S(kl,1:2) = NaN ;
					end
					H = plot_segments(H,S/xm) ;
				end
			case '1'
				if ~isempty(S),
					kl = find(x>=S(:,1) & x<=S(:,2)) ;
					if ~isempty(kl),
						S(kl,1) = x ;
					end
					H = plot_segments(H,S/xm) ;
				end
			case '2'
				if ~isempty(S),
					kl = find(x>=S(:,1) & x<=S(:,2)) ;
					if ~isempty(kl),
						S(kl,2) = x ;
					end
					H = plot_segments(H,S/xm) ;
				end
			case 'q'
				break
		end

	else
		pt = rbbox ;
		% convert figure units into axis units
		xax = get(ax,'XLim') ;
		x = sort(interp1(ax_norm,xax,pt(1)+[0 pt(3)]))*xm ;
		x(1) = max(x(1),0) ;
		x(2) = min(x(2),size(X,1)/fs) ;
		% check for overlaps with extant segments
		if isempty(S),
			S(1,1:2) = x ;
		else
			kl = find(x(1)>=S(:,1) & x(1)<=S(:,2)) ;
			if ~isempty(kl),
				S(kl(1),2) = max(S(kl(1),2),x(2)) ;
			end
			kr = find(x(2)>=S(:,1) & x(2)<=S(:,2)) ;
			if ~isempty(kr),
				S(kr(1),1) = min(S(kr(1),1),x(1)) ;
			end
			if isempty(kl)&isempty(kr),
				S(end+1,1:2) = x ;
			end
		end
		H = plot_segments(H,S/xm) ;	
   end
end
enableDefaultInteractivity(ax)
set(gcf,'Pointer','arrow');
set(gcf,'WindowButtonMotionFcn','');

S = S(~isnan(S(:,1)),:) ;
[s,I] = sort(S(:,1)) ;
S = S(I,:) ;
return


function	H = plot_segments(H,S)
%
yl = get(gca,'YLim') ;
yy = mean(yl)+0.45*diff(yl)*[-1 1] ;
y = [yy([1 1 2 1]);yy([2 1 2 2])] ;
for k=1:size(H,1),
	set(H(k,1),'XData',S(k,1)*[1 1]) ;
	set(H(k,2),'XData',S(k,1:2)) ;
	set(H(k,3),'XData',S(k,1:2)) ;
	set(H(k,4),'XData',S(k,2)*[1 1]) ;
end
for k=size(H,1)+1:size(S,1),
	x = [S(k,[1 1 1 2]);S(k,[1 2 2 2])] ;
	H(k,:) = plot(x,y,'k') ;
end
return

function dummy()
% do nothing, this is there to update the GINPUT WindowButtonMotionFcn. 
return

