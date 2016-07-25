function      [y,Z] = decz(x,Z)
%
%      [y,Z] = decz(x,Z)
%     Recursive decimator
%     Initial call is [y,z] = decz(x,df)
%     Subsequent calls are [y,z] = decz(x,z)
%     Initial call can also be [y,z] = decz(x,[df,nf,frbw])
%     where df is the decimation factor
%     nf is the number of output samples spanned by the filter
%     frbw is the fractional bandwidth of the filter
%     defaults are nf=12, frbw=0.8

if ~isstruct(Z),
   frbw = 0.8 ;
   nf = 12 ;
   if length(Z)>=2,
      nf = Z(2) ;
      if length(Z)>=3,
         frbw = Z(3) ;
      end
   end

   df = Z(1) ;
   Z = struct('df',df) ;
   Z.h = fir1(df*nf,frbw/df) ;
   nh = length(Z.h) ;
   Z.n = nh ;
   npre = floor(nh*0.5) ;
   Z.z = [zeros(nh-df-npre,1);x(1:npre)] ;
   x = x(npre+1:end) ;
end

nh = Z.n ;
df = Z.df ;
[X,zz,z] = buffer(x,nh,nh-df,Z.z) ;
y = (Z.h*X)' ;
Z.z = z ;
return
