function    [rho,p] = trimspearmanR(x,y,n)
%
%    [rho,p] = trimspearmanR(x,y,n)
%     Trim the n extreme points from the top and bottom of
%     each of vectors x and y and then perform the Spearman
%     R test of x against y.
%     Return the r^2 and p value.
%

if nargin<2,
   help trimspearmanR
   return
end

if nargin==3 & n>0,
   D = trimdata([x,y],n) ;
end

k = find(~isnan(D(:,1)+D(:,2))) ;
[rho,p] = spearmanr(D(k,2),D(k,1)) ;
