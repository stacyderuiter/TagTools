function    [y,h] = dmoncleanup(x,lambda,thr,h,NOPOSTEMPH)
%
%    [y,h] = dmoncleanup(x,lambda,thr,h,NOPOSTEMPH)
%

if nargin<1,
   dmoncleanup ;
end

if nargin<2 | isempty(lambda),
   lambda = 0.0001 ;
end

if nargin<3 | isempty(thr),
   thr = 100 ;
end

N = 48 ;
FS = 96e3 ;

if nargin<4 | isempty(h),
   h = zeros(N,1) ;
end

[b,a] = butter(1,[10e3 40e3]/(FS/2)) ;      % make an equalizing filter
f = [1 0.98 0.98^2] ;
b = b.*f ; a = a.*f ;               % move the poles and zeros inside the unit circle

xf = filter(b,a,x) ;
y = zeros(length(x),1) ;
bl = floor(length(x)/N) ;
R = hadamard(N) ;
blk = (0:bl-1)*N ;

for k=1:bl,
   kk = blk(k)+(1:N) ;
   e = xf(kk)-R*h ;
   y(kk) = e ;
   if std(e)<thr,
      h = h + R'*(lambda*e) ;
   end
end

if nargin<4,
   y = filter(a/b(1),b/b(1),y) ;
end
