function    audiowrite(varargin)

%		audiowrite(varargin)
%		Compatibility tool for versions of Matlab <2015.

wavwrite(varargin{[2:end,1]}) ;
