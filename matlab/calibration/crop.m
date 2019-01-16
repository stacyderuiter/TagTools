function    [Y,T,tcues] = crop(X,fs)

%		Y = crop(X)				% X is a sensor structure
%		or
%		[Y,tcues] = crop(X,fs)			% X is a regularly sampled vector or matrix
%		or
%		[Y,T,tcues] = crop(X,T)			% X is a regularly sampled vector or matrix
%
%		Interactive data cropping tool. This function plots the input data #
%		and allows the user to select start and end times for cropping.
%
%     Inputs:
%     X is a sensor structure, vector or matrix. X can be regularly or
%		 irregularly sampled data in any frame and unit.
%     fs is the sampling rate of X in Hz. This is only needed if
%		 X is not a sensor structure and X is regularly sampled.
%		T is a vector of sampling times for X. This is only needed if X is
%		 not a sensor structure and X is not regularly sampled.
%
%     Results:
%     Y is a sensor structure, vector or matrix containing the cropped data segment.
%		 If the input is a sensor structure, the output will also be. The output has
%		 the same units, frame and sampling characteristics as the input.
%     T is a vector of sampling times for Y. This is only returned if X is irregularly
%	    sampled and X is not a sensor structure. If X is a sensor structure, the sampling
%		 times are stored in the structure.
%		tcues is a two-element vector containing the start and end time cue
%		 in seconds of the data segment kept, i.e., tcues = [start_time, end_time].
%
%		Example:
%		 loadnc('testset3')
%		 Pc = crop(P);		% interactively select a section of data
%		 plott(Pc)
%		 % plot shows the cropped section
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     Last modified: 28 July 2017

T = [] ;
if nargin<1,
	help crop
	return
end
	
if isstruct(X),
	[x,fs] = sens2var(X) ;
	if isempty(x), return, end
else
	if nargin<2,
		help crop
		return
	end
	x = X ;
	if size(x,1)==1,		% make sure x is a column vector
		x = x(:) ;
	end
end

clf					% clear the current figure
if length(fs)>1,
	plot(fs,x,'.') ;
else
	plot((1:size(x,1))/fs,x) ;
end
xlabel('Time (seconds)') ;
ht = title('Position the cursor and type s or e to adjust start or end. Type q to finish') ;
set(ht,'color','r','fontsize',12)

zoom off
if length(fs)>1,
	tcues = [min(T) max(T)] ;
else
	tcues = [0 size(x,1)/fs] ;
end

LIMS = tcues ;
hold on
hs = plot([1;1]*tcues(1),get(gca,'YLim'),'g') ;
set(hs,'LineWidth',1.5) ;
hsm = plot(tcues(1),mean(get(gca,'YLim')),'g>') ;
set(hsm,'MarkerSize',12,'MarkerFaceColor','g') ;

he = plot([1;1]*tcues(2),get(gca,'YLim'),'r') ;
set(he,'LineWidth',1.5) ;
hem = plot(tcues(2),mean(get(gca,'YLim')),'r<') ;
set(hem,'MarkerSize',12,'MarkerFaceColor','r') ;

while 1,
   [t,y,s] = ginput(1) ;
	if isempty(t), break, end
   s = char(s) ;
   switch char(s),
      case 's'
         tcues(1) = max(LIMS(1),min(t,tcues(2))) ;
         set(hs,'XData',tcues(1)*[1 1]) ;
         set(hsm,'XData',tcues(1)) ;
      case 'e'
         tcues(2) = min(LIMS(2),max(t,tcues(1))) ;
         set(he,'XData',tcues(2)*[1 1]) ;
         set(hem,'XData',tcues(2)) ;
		case 'q'
			break
   end
end

hold off
if isstruct(X),
	Y = crop_to(X,tcues) ;
	T = tcues ;
else
	[Y,T] = crop_to(x,fs,tcues) ;
	if length(fs)==1,
		T = tcues ;
	end
end
return
