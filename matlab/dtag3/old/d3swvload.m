function    [x,fs,xr1,xr2] = d3swvload(fname)
%
%    [x,fs,xr1,xr2] = d3swvload(fname)
%

[x,fs] = wavread(fname) ;
fs = fs*size(x,2)/12000 ;
k = find(x<0) ;
x(k) = x(k)+2 ;
x = x-1 ;
x = reshape(x',12,[])' ;
xr1=reshape(x(:,11),4,[])' ;
xr2=reshape(x(:,12),4,[])' ;
