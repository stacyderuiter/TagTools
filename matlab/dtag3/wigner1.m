function [wig, t, f] = wigner1(x, fs, nfreq)
% wigner1 -- Compute samples of the (type I) Wigner distribution.
%
%  Usage
%    [tfd, t, f] = wigner1(x, fs, nfreq)
%
%  Inputs
%    x      signal vector.  wigner1 assumes that x is sampled at the Nyquist
%           rate and uses sinc interpolation to oversample by a factor of 2.
%           If there are two columns then a cross Wigner distribution is
%           computed.
%    fs     sampling frequency of x (optional, default is 1 sample/second)
%    nfreq  number of samples to compute in the frequency direction, must
%           be at least 2*length(x) (optional, defaults to 2*length(x))
%
%  Outputs
%    tfd  matrix containing the Wigner distribution of signal x.  If x has
%         length N, then tfd will be 2N by 2N. (optional)
%    t    vector of sampling times (optional)
%    f    vector of frequency values (optional)
%
% If no output arguments are specified, then the Wigner distribution is
% displayed using ptfd(tfd, t, f).

% Copyright (C) -- see DiscreteTFDs/Copyright

%--
% handle input
%--

N = length(x);

error(nargchk(1, 3, nargin));

if nargin < 3
        nfreq = 2 * N;
end

if nargin < 2
        fs = 1;
end

if nfreq < 2 * N
        error('nfreq must be at least 2*length(x)')
end

%--
% setup
%--

% create the temporal acf for positive tau

acf = lacf1(x);

N = 2 * N; % width of acf

acf = [acf ; zeros(nfreq+1-N, N) ; conj(flipud(acf(2:N/2,:)))]; % negative tau

%--
% compute distribution and output grids
%--

wig = real(fft(acf))/N;

wig = tfdshift(wig);

t = 1/(2*fs) * (0:N-1);

f = -fs/2:fs/nfreq:fs/2; f = f(1:nfreq);

%--
% display result if output not requested
%--

if ~nargout
        ptfd(wig, t, f); clear wig
end

% Hide details
% 
% Change log
% r1417 by harold.figueroa on Nov 19, 2008   Diff
% 
% an experiment trying to create a base for
% TFD features, the DTFD toolbox needs quite
% a bit of work if we intend to apply it to
% real data.
% 
% Go to: 	
% 
% Older revisions
% r862 by harold.figueroa on Dec 4, 2007   Diff
% All revisions of this file
% 
% File info
% Size: 1685 bytes, 77 lines
% View raw file
