function    [x,fs]=audioread(varargin)

%		[x,fs]=audioread(varargin)
%		Compatibility tool for versions of Matlab <2015.

if length(varargin)>=2 && strcmp(varargin{2},'size'),
   fprintf('audioread does not accept size argument\n') ;
   x = []; fs = [] ;
   return
end
[x,fs] = wavread(varargin{:}) ;
