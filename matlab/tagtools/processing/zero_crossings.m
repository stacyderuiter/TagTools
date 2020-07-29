function    [K,s,KK] = zero_crossings(x,TH,Tmax)
%
%    	 [K,s,KK] = zero_crossings(x,TH,Tmax)
%      Find zero-crossings in a vector using a hysteretic detector. This is 
%		 useful, e.g., to locate cyclic postural changes due to propulsion.
%	
%		 Inputs:
%		 x is a vector of data. This can be from any sensor and with any sampling rate.
%    	 TH is the magnitude threshold for detecting a zero-crossing. A zero-crossing
%		  is only detected when values in x pass from -TH to +TH or vice versa.
%      Tmax is the (optional) maximum duration in samples between threshold 
%       crossings. To be accepted as a zero-crossing, the signal must pass from below 
%       -TH to above TH, or vice versa, in no more than Tmax samples. This is useful
%		  to eliminate slow transitions. If Tmax is not given, there is no limit on the
%		  number of samples between threshold crossings.
%  
%      Result:
%		 K is a vector of cues (in samples) to zero-crossings in x.
%		 s is a vector containing the sign of each zero-crossing (1 = positive-going, 
%		  -1 = negative-going). s is the same size as K. If no zero-crossings are found
%		  K and s will be empty
%
%		Example:
%		 [K,s] = zero_crossings(sin(2*pi*0.033*(1:100)'),0.3)
% 	    returns: K=[15,30,45,61,76,91]'
%					 s=[-1,1,-1,1,-1,1]'
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     Last modified: 27 June 2018
%     sped up processing for long data sets
%     21 Jan 2019 minor edits

K = [] ; s = [] ; KK = [] ;

if nargin<2,
   help zero_crossings
   return
end

if nargin<3,
   Tmax = [] ;
end
	
% find all positive and negative threshold crossings
xtp = diff(x>TH(1)) ;
xtn = diff(x<-TH(1)) ;
kpl = find(xtp>0)+1 ;  % leading edges of positive threshold crossings
kpt = find(xtp<0) ;  % trailing edges of positive threshold crossings
knl = find(xtn>0)+1 ;  % leading edges of negative threshold crossings
knt = find(xtn<0) ;  % trailing edges of negative threshold crossings

% find valid positive-going zero-crossings
k = [[knt -ones(length(knt),1)];[kpl ones(length(kpl),1)]] ;
[z,I] = sort(k(:,1)) ;
k = k(I,:) ;
kz = find(diff(k(:,2))>1.5) ;
kz = reshape([kz';kz'+1],[],1) ;
k = k(kz,:) ;
kkp = reshape(k(:,1),2,[])' ;
kp = 0.5*sum(kkp,2) ;
if ~isempty(Tmax),
   dp = diff(k(:,1)) ;
   dp = dp(1:2:end) ;
   kp = kp(dp<Tmax(1)) ;
end

% find valid negative-going zero-crossings
k = [[kpt -ones(length(kpt),1)];[knl ones(length(knl),1)]] ;
[z,I] = sort(k(:,1)) ;
k = k(I,:) ;
kz = find(diff(k(:,2))>1.5) ;
kz = reshape([kz';kz'+1],[],1) ;
k = k(kz,:) ;
kkn = reshape(k(:,1),2,[])' ;
kn = 0.5*sum(kkn,2) ;
if ~isempty(Tmax),
   dn = diff(k(:,1)) ;
   dn = dn(1:2:end) ;
   kn = kn(dn<Tmax(1)) ;
end

% combine positive- and negative- going zero crossings
kz = [[kn -ones(length(kn),1)];[kp ones(length(kp),1)]] ;
kk = [kkn;kkp] ;
[z,I] = sort(kz(:,1)) ;
kz = kz(I,:) ;
KK = kk(I,:) ;
K = kz(:,1) ;
s = kz(:,2) ;
return 

% old slow way of doing it
K = zeros(length(kpl)+length(knl),3) ; % prepare space for the results
cnt = 0 ;
if min(kpl)<min(knl),      % find which direction zero-crossing comes first
   SIGN = 1 ;
else
   SIGN = -1 ;
end

while 1,
   if SIGN==1,
      if isempty(kpl), break, end
      kk = max(find(knt<=kpl(1))) ;
      if ~isempty(kk),
         cnt = cnt+1 ;
         K(cnt,:) = [knt(kk),kpl(1),SIGN] ;
         knt = knt(kk+1:end) ;
         knl = knl(knl>kpl(1)) ;
         kpl = kpl(2:end) ;
      end
      SIGN = -1 ;

   else
      if isempty(knl), break, end
      kk = max(find(kpt<=knl(1))) ;
      if ~isempty(kk),
         cnt = cnt+1 ;
         K(cnt,:) = [kpt(kk),knl(1),SIGN] ;
         kpt = kpt(kk+1:end) ;
         kpl = kpl(kpl>knl(1)) ;
         knl = knl(2:end) ;
      end
      SIGN = 1 ;
   end
end
K = K(1:cnt,:) ;

if nargin==3,
   k = find(K(:,2)-K(:,1)<=Tmax(1)) ;
   K = K(k,:) ;
end

s = K(:,3) ;
KK = K(:,1:2) ;
X = [x(K(:,1)) x(K(:,2))] ;
K = (X(:,2).*K(:,1)-X(:,1).*K(:,2))./(X(:,2)-X(:,1)) ;
