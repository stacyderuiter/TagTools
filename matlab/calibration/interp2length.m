function   y = interp2length(X,fsin,fsout,nout)

%     Y = interp2length(X,Z)     % X and Z are both sensor structures
%     or
%     Y = interp2length(X,fsin,fsout)
%     or
%     Y = interp2length(X,fsin,fsout,nout)
%     
%     Interpolate regularly sampled data to increase its 
%     sampling rate and match its length to another variable.
%
%     Inputs:
%     X is a sensor structure, vector or matrix. If x is or contains
%      a matrix, each column is treated as an independent signal.
%     fsin is the sampling rate in Hz of the data in X. This is only
%      needed if X is not a sensor structure.
%     Z is a sensor structure whos sampling rate and length is to be
%      matched.
%     fsout is the required new sampling rate in Hz. This is only needed
%      if Z is not given.
%     nout is an optional length for the output data. If
%      nout is not given, the output data length will be
%      the input data length * fsout/fsin.
%
%     Returns:
%     Y is a sensor structure, vector or matrix of interpolated data 
%      with the same number of columns as X.
%
%		Example:
%		 TBD
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     last modified: 24 June 2018
%     added support for sensor structures

Y = [] ;
if nargin<2,
   help interp2length
   return
end

if isstruct(X),
   if isstruct(fsin),   % inter2length(X,Z)
      [z,fsout] = sens2var(fsin) ;
      nout = size(z,1) ;
   else
      if nargin==3,     % inter2length(X,fsout,nout)
         nout = fsout ;
      else
         nout = [] ;    % inter2length(X,fsout)
      end
      fsout = fsin ;
   end
   [x,fsin] = sens2var(X) ;
else
   x = X ;
   if nargin<3,
      help interp2length
      return
   end
   if nargin<4,
      nout = [] ;
   end
end

if fsin==fsout,     % if sampling rates are the same, no need to interpolate,
                    % just make sure the length is right
   y = x ;
   if ~isempty(nout),
      if size(y,1)<nout,
         y(end+1:nout,:) = y(end,:) ;
      elseif size(y,1)>nout,
         y = y(1:nout,:) ;
      end
   end
   return
end

intf = fsout/fsin ;
if intf == round(intf), % if the sampling rate ratio is an integer,
                        % use integer-ratio interpolation
   y = zeros(intf*size(x,1),size(x,2)) ;
   for k=1:size(x,2),
      y(:,k) = interp(x(:,k),intf) ;
   end
   if ~isempty(nout),
      if size(y,1)<nout,       % make sure the resulting size is right
         y(end+1:nout,:) = repmat(y(end,:),nout-size(y,1),1) ;
      elseif size(y,1)>nout,
         y = y(1:nout,:) ;
      end
   end
else                    % if interpolation factor is not an integer,
                        % use linear interpolation
   if isempty(nout),
      nout = floor(size(x,1)*fsout/fsin) ;
   end
   y = interp1((0:size(x,1)-1)'*(1/fsin),x,(0:nout-1)'*(1/fsout)) ;
end

if isstruct(X),
   X.sampling_rate = fsout ;
   h = sprintf('inter2length(%f,%f)',fsin,fsout) ;
	if ~isfield(X,'history') || isempty(X.history),
		X.history = h ;
	else
		X.history = [X.history ',' h] ;
   end
   X.data = y ;
   y = X ;
end
