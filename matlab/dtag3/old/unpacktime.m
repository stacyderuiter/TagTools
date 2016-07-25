function    T = unpacktime(N)
%
%    T = unpacktime(N)
%

% how many digit-pairs to extract
n = ceil(log10(max(N)))/2 ;

for k=1:n,
   dp = 10^(2*(n-k)) ;
   T(:,k) = floor(N/dp) ;
   N = rem(N,dp) ;
end
