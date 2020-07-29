function    a = absorption(f,T,d)

%    a = absorption(f,T,d)
%     Absorption coefficient for sound in seawater
%     f is frequency in Hz
%     T is temperature, degrees C
%     d is depth, m
%
%		Returns:
%		a is the sound absorption in dB per metre.
%
%     Input arguments can be scalars, or a mixture
%     of vectors and scalars as long as each argument
%     is either a vector of length nx1 (with n being the
%		same for all vector arguments) or a scalar.
%
%		Example:
%		 absorption(140e3,13,10)
%
%     After Kinsler and Frey pp. 159-160
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     Last modified: 4 May 2017

a = [] ;
if nargin<3,
   help absorption
   return
end

Ta = T+273 ;
Pa = 1+d/10 ;
f1 = 1.32e3*Ta.*exp(-1700./Ta) ;
f2 = 1.55e7*Ta.*exp(-3052./Ta) ;
A = 8.95e-8*(1+2.3e-2*T-5.1e-4*T.^2) ;
B = 4.88e-7*(1+1.3e-2*T).*(1-0.9e-3*Pa) ;
C = 4.76e-13*(1-4.0e-2*T+5.9e-4*T.^2).*(1-3.8e-4*Pa) ;

a = A.*f1.*f.^2./(f1.^2+f.^2)+B.*f2.*f.^2./(f2.^2+f.^2)+C.*f.^2 ;
