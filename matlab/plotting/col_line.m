function    h = col_line(x,y,c)

%     h = col_line(x,y,c)
%     Plot coloured line(s) in 2 dimensions in the current figure.
%
%		Inputs:
%		x is a vector or matrix of points on the horizontal axis.
%		y is a vector or matrix of points on the vertical axis.
%		c is a vector or matrix of values representing the colour to draw
%		  at each point.

%		Result:
%		h is a vector of patch handles which can be used with 'set' to change
%		properties of the line. For example: set(h,'LineWidth',8) will make the
%		line wider.
%
%     x, y and c must all be the same size. If x, y, and c are matrices, 
%		one line is drawn for each column. The color axis will by default span the
%		range of values in c, i.e., caxis will be [min(min(c)) max(max(c))]. This
%		can be changed by calling caxis after colline.
%
%		Example:
%		 T = cumsum(randn(1000,2)) ;
%		 col_line(T(:,1),T(:,2),(1:size(T,1))') ;
% 	    Draws a a random walk in the current figure coloured by sample number.
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     Last modified: 8 June 2017

if nargin<3,
	help col_line
	return
end
	
M = [size(x) size(y) size(c)] ;
if any(M==1),
   x = x(:) ;
   y = y(:) ;
   c = c(:) ;
end

h = zeros(size(x,2),1) ;
for k=1:size(x,2),
   h(k) = patch('xdata',[x(:,k);NaN],'ydata',[y(:,k);NaN],'cdata',[c(:,k);NaN],...
          'linestyle','-','edgecolor','flat');
end
set(h,'LineWidth',3) ;
