function   y = interp2length(x,fsin,fsout,nout)

%     y = interp2length(x,fsin,fsout)
%     or
%     y = interp2length(x,fsin,fsout,nout)
%     
%     Interpolate a vector or matrix of regularly sampled
%     data to increase its sampling rate and restrict its
%     length.
%
%     Inputs:
%     x is a vector or matrix. If x is a matrix, each
%      column is treated as an independent signals.
%     fsin is the sampling rate in Hz of the data in x.
%     fsout is the required new sampling rate in Hz.
%     nout is an optional length for the output data. If
%      nout is not given, the output data length will be
%      the input data length * fsout/fsin.
%
%     Returns:
%     y is a vector or matrix of interpolated data with the 
%      same number of columns as x.
%
%		Example:
%		 TBD
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     last modified: 2 Aug 2017

y = [] ;
if nargin<3,
   help interp2length
   return
end

if fsin==fsout,     % if sampling rates are the same, no need to interpolate,
                    % just make sure the length is right
   y = x ;
   if nargin>3,
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
   if nargin>3,
      if size(y,1)<nout,       % make sure the resulting size is right
         y(end+1:nout,:) = repmat(y(end,:),nout-size(y,1),1) ;
      elseif size(y,1)>nout,
         y = y(1:nout,:) ;
      end
   end
else                    % if interpolation factor is not an integer,
                        % use linear interpolation
   if nargin==3,
      nout = floor(size(x,1)*fsout/fsin) ;
   end
   y = interp1((0:size(x,1)-1)'*(1/fsin),x,(0:nout-1)'*(1/fsout)) ;
end
