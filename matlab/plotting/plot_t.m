function    [ax,h]=plot_t(varargin)

%     [ax,h]=plot_t(X)			% X is a sensor structure
%	   or
%     [ax,h]=plot_t(X,r)			% X is a sensor structure
%	   or
%     [ax,h]=plot_t(X,fsx)		% X is a vector or matrix of sensor data
%	   or
%     [ax,h]=plot_t(X,fsx,r)	% X is a vector or matrix of sensor data
%	   or
%     [ax,h]=plot_t(X,Y,...)	% X, Y etc are sensor structures
%	   or
%     [ax,h]=plot_t(X,fsx,Y,fsy,...)	% X, Y etc are vectors or matrices of sensor data
%     Plot sensor time series against time in a single or multi-paneled figure with linked
%	   x-axes. This is useful for comparing measurements across different sensors. The
%		time axis is automatically displayed in seconds, minutes, hours, or days according
%		to the span of the data.
%
%	   Inputs:
%		X, Y, etc, are sensor structures or vectors/matrices of time series data.
%		fsx, fsy, etc, are the sampling rates in Hz for each data object. Sampling rates
%		 are not needed when the data object is a sensor structure.
%		r is an optional argument which can be used reverse the direction of the y-axis 
%		 for the data object that it follows if r='r'. This is useful for plotting dive 
%		 profiles which match the physical situation i.e., with greater depths lower in 
%	    the display. If r is a number, it specifies the number of seconds time offset 
%		 for the preceding data object. A positive value means that these data were collected
%		 later than the other objects and so should be plotted more to the right-hand side.
%
%		Returns:
%   	ax is a vector of handles to the axes created.
%		h is a cell array of vectors of handles to the lines plotted. There is a cell of
%		 handles for each axis.
%
%		This is a flexible plotting tool which can be used to display and explore sensor
%		data with different sampling rates on a uniform time grid. Zooming any of the
%	   panels should cause all of the panels to zoom in or out to match the x-axis.
%
%		Example:
%		 loadncdf('testdata1');
%		 plot_t(P,'r',A,M)				% plot depth, acceleration and magnetometer
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     Last modified: 8 June 2017

ax=[]; h=[];
if nargin<1,		% must have at least one input argument
   help plot_t
   return
end

brk = [0,2e3,2e4,5e5] ;		% break points for plots in seconds, mins, hours, days
div = [1 60 3600 24*3600] ;	% corresponding time multipliers
L = {'s','min','hr','day'} ;	% and xlabels

% each data object can have one or two qualifying arguments. Scan through varargin
% to find the objects and their qualifiers.
X = {} ; fsrt = zeros(length(varargin),4) ;
for k=1:nargin,
	x = varargin{k} ;
	if isstruct(x),		% this input is a sensor structure
		if isfield(x,'fs') && isfield(x,'data'),
			X{end+1} = x.data ;
			fs(length(X),1) = x.fs ;
		else
			fprintf('Error: sensor structure must have data and fs fields\n') ;
			return
		end
	elseif size(x,1)>1 || size(x,2)>1,	% this input is a vector or matrix
		X{end+1} = x ;
		
	else		% this input is a qualifier
		if ischar(x),
			fsrt(length(X),2) = x(1)=='r' ;
		else
			if fsrt(length(X),1)==0,
				fsrt(length(X),1) = x ;
			else
				fsrt(length(X),3) = x ;
			end
		end
	end
end

fsrt = fsrt(1:length(X),:) ;
if any(fsrt(:,1)==0),
	fprintf('Error: sampling rate undefined for data object %d\n',find(fsrt(:,1)==0,1)) ;
	return
end
	
ax = zeros(length(X),1) ;
ns = 0 ;
for k=1:length(X),
   ax(k) = subplot(length(X),1,k) ;
	ns = max(ns,size(X{k},1)/fsrt(k,1)+fsrt(3)) ;
end

for divk=length(brk):-1:1,
   if ns>=brk(divk), break, end
end

ddiv = div(divk) ;
xlims = [min(fsrt(:,3))/ddiv ns/ddiv] ;
h = {} ;
for k=1:length(X),		% now we are ready to plot
	axes(ax(k)) ;
	h{k}=plot(((1:size(X{k},1))/fsrt(k,1)+fsrt(k,3))*(1/ddiv),X{k}); grid
	set(ax(k),'XLim',xlims)
	if fsrt(k,2)==1,
		set(ax(k),'YDir','reverse') ;
	end
end

xlab = sprintf('Time (%s)',L{divk}) ;
xlabel(ax(end),xlab) ;
linkaxes(ax,'x')
