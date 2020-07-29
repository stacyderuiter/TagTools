function    v = sound_speed(T,D,S)

%    v = sound_speed(T,D,[S])
%    Sound speed estimate using Coppens equation
%    Range of validity: temperature 0 to 35 °C, salinity 0 to 45 parts per
%    thousand, depth 0 to 4000 m
%        T = temperature in degrees C
%        D = depth in meters (defaults to 1 m)
%        S = salinity in part-per-thousand (defaults to 35 ppt)
%	  Returns:
%        v is sound speed in m/s
%    Source:
%    http://resource.npl.co.uk/acoustics/techguides/soundseawater/content.html#UNESCO
%    
%	  Example:
%		sound_speed(8,1000,34)   % returns 1497.7 m/s

%    Valid: Matlab, Octave
%    markjohnson@st-andrews.ac.uk
%    Last modified: 4 May 2017

v = [] ;
if nargin<1,
   help sound_speed
   return
end

if nargin==1 || isempty(D),
   D = 1 ;     % 1 m depth
end
   
if nargin<=2 || isempty(S),
   S = 35 ;     % ppt
end

%v = 1449.2+4.6*T-0.055*T.^2+0.00029*T.^3+(1.34-0.01*T).*(S-35)+0.016*D ;
t = T/10 ; D = D/1000 ;
v0 = 1449.05 + 45.7*t - 5.21*t.^2 + 0.23*t.^3 + (1.333 - 0.126*t + 0.009*t.^2).*(S - 35) ;
v = v0 + (16.23 + 0.253*t).*D + (0.213-0.1*t).*D.^2 + (0.016 + 0.0002*(S-35)).*(S - 35).*t.*D ;
