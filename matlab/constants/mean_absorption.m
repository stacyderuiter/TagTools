function    a = mean_absorption(freq,r,depth,Ttab)

%     a = mean_absorption(freq,r,depth)
%	   or
%     a = mean_absorption(freq,r,depth,Ttab)
%     Calculate the mean sound absorption in salt water over a frequency range.
%
%		Inputs:
%		freq specifies the frequency range, freq = [fmin,fmax] ins Hz.
%       For a single frequency, use a scalar value for freq.
%		r is the path (slant) length in metres
%		depth is the depths covered by the path. This can be a single
%		  value for a horizontal path or a two component vector i.e., 
%		  depth=[dmax,dmin] for a path that extends between two depths.
%     Ttab is the temperature (a scalar) in degrees C or specifies a
%		  temperature profile Ttab = [depth, tempr] where depth and tempr
%		  are equal-sized column vectors. 
%		  Default value is an isothermal profile of 13 degrees.
%
%		Returns:
%		a is the mean sound absorption over the path in dB.
%
%		Example:
%		 mean_absorption([25e3 60e3],1000,[0 700])   % returns 0.04355 dB/m
%
%     After Kinsler and Frey pp. 159-160
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     Last modified: 4 May 2017

a = [] ;
if nargin<3,
   help mean_absorption ;
	return
end

if nargin<4,
   tempr = 13 ;
elseif length(Ttab)==1,
   tempr = Ttab ;
end

if length(depth)>1,
   depth = linspace(min(depth),max(depth),50) ;
   if nargin == 4 && length(Ttab)>1,
      tempr = interp1(Ttab(:,1),Ttab(:,2),depth) ;
   else
		tempr = repmat(tempr,size(depth,1),size(depth,2)) ;
   end
end

% handle case of a single frequency
if length(freq)==1,
   a = r*mean(absorption(freq,tempr,depth)) ;
   return
end

% handle a range of frequencies
f = linspace(min(freq),max(freq),50) ;
aa = zeros(length(depth),length(f)) ;
for k=1:length(depth),
   aa(k,:) = absorption(f,tempr(k),depth(k)) ;
end
aa = mean(aa,1) ;
a = zeros(length(r),1) ;
for kk=1:length(r),
   a(kk) = -10*log10(mean(10.^(-aa*r(kk)/10))) ;
end
return
