function    [x,fs,xr1,xr2] = d3swvread_old(fname)
%
%    [x,fs,xr1,xr2] = d3swvread_old(fname)
%     For sensor sequence:
%     x = [gx,ax,gy,ay,gz,az,gax,gay,vr1,vr0]
%     where:
%     vr1 = gaz,gr1,gaz,gr2,gaz,gt1,gaz,gt2
%     vr0 = p,pbsense,p,pb-th,p,pb-,p,pb-th
%     and:
%     fs  = rate for x
%     xr1 = [gaz,p] (sampling rate is fs/2)
%     xr2 = [gr1,gr2,gt1,gt2,pbsense,pb-th,pb-,pb-th]
%            (sampling rate is fs/8)
%
%     NOTE: Old version for initial D3 - will be removed.

[x,fs] = wavread(fname) ;
fs = fs*size(x,2)/10000 ;
k = find(x<0) ;
x(k) = x(k)+2 ;
x = x-1 ;
x = reshape(x',10,[])' ;
xr1 = reshape(x(:,9),8,[])' ;
xr2 = reshape(x(:,10),8,[])' ;
xx1 = reshape(xr1(:,1:2:8)',[],1) ;
xx2 = reshape(xr2(:,1:2:8)',[],1) ;
xr2 = [xr1(:,2:2:8) xr2(:,2:2:8)] ;
xr1 = [xx1 xx2] ;
