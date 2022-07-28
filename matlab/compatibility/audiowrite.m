function    audiowrite(varargin)

%		audiowrite(varargin)
%		Compatibility tool for versions of Matlab <2015.
%     Useage: audiowrite(filename,y,fs,nbits)

wavwrite(varargin{[2:end,1]}) ;
