function    image_irreg(x,y,R)

%     image_irreg(x,y,R)
%     Plot an image with an irregular grid. This is useful for plotting matrix
%		data (i.e., sampled data that is a function of two parameters) in which
%		one or both of the sampling schemes is not regularly spaced. imageirreg
%		plots R(i,j) as a coloured patch centered on x(i),y(j) and with dimension
%		determined by x(i)-x(i-1) and y(i)-y(i-1).
%
%		Inputs:
%		x is a vector with the horizontal axis coordinates of each value in R.
%		y is a vector with the vertical axis coordinates of each value in R.
%		R is a matrix of measurements to display. The values in R are converted to
%		 colours in the current colormap and caxis. R must be length(x) by length(y).
%		 Use NaN to have a patch not display.
%
%
%		Example:
%		 TBD
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     Last modified: 8 June 2017

if nargin<3,
   help image_irreg
   return
end

x = x(:)' ;
y = y(:)' ;
if length(x)~=size(R,1) | length(y)~=size(R,2),
   fprintf('Error: R must be length(x) by length(y)\n')
   return
end

xdiff = [diff(x) x(end)-x(end-1)] ;
X = [0;0;1;1]*xdiff+ones(4,1)*x ;

Y = [0;1;1;0]*ones(1,length(x)) ;
ydiff = [diff(y) y(end)-y(end-1)] ;
for k=1:length(y),
   zk=find(~isnan(R(:,k))) ;
   patch(X(:,zk),ydiff(k)*Y(:,zk)+y(k),R(zk,k)') ;
end

shading flat
axis tight
box on
