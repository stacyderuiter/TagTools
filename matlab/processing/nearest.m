function    [kx,mind] = nearest(X,Y,maxdist,direction)
%
%    [kx,mind] = nearest(X,Y,[maxdist,direction])
%    Find the index of the nearest element in vector X to each element in
%      vector Y. X and Y must be column vectors and may have real or complex 
%      elements. For complex elements, the abs of the difference between X 
%      and Y is used.
%    If maxdist is specified, only elements within +/-maxdist are
%      considered. Use maxdist=NaN to always return nearest element.
%    direction specifies the direction in the vector X to look for the
%      nearest element. direction>0 looks forward while direction<0 looks
%      backwards. Default is to look both ways and pick the closest value
%      (i.e., direction = 0).
%
%    Returns:
%    kx is the index in X of the nearest element to each element in Y. It has
%      the same size as Y. The corresponding value in kx is set to NaN if there 
%      is no nearest element in X that meets the maxdist and direction criteria.
%    mind is the distance from each element of Y to the closest element in
%      X, irrespective of maxdist. kx and mind are both the same size as Y.
%
%    This function is part of the ANIMAL SEPARATION toolbox. It is licensed under the
%    GNU General Public License. See the file for licence information.
%
%    markjohnson@st-andrews.ac.uk
%    Last modified: 21 May 2018
%     improved performance for really big arrays

% Copyright (C) 2005-2014, Mark Johnson
% This is free software: you can redistribute it and/or modify it under the
% terms of the GNU General Public License as published by the Free Software 
% Foundation, either version 3 of the License, or any later version.
% See <http://www.gnu.org/licenses/>.
%
% This software is distributed in the hope that it will be useful, but 
% WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
% or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License 
% for more details.

kx = [] ; mind = [] ;

if nargin<2,
   help nearest
   return
elseif nargin<3,
   maxdist = NaN ;
end

if nargin<4,
   direction = 0 ;
end

if size(X,2)+size(Y,2)>2,
   fprintf('X and Y must be column vectors\n') ;
   return
end

if isempty(X),
   kx = NaN*ones(length(Y),1) ;
   mind = kx ;

elseif ~isempty(Y),
   if length(X)==1,
      X = X*[1;1] ;
   end

   k = 0 ;
   while 1,
      nn = min(length(Y)-k,ceil(50e6/length(X))) ;
      if nn<=0, break, end
      D = repmat(Y(k+(1:nn))',size(X,1),1)-repmat(X,1,nn) ;
      if direction>0,
         D(D>0) = NaN ;
         [mind1 n] = min(abs(D)) ;
      elseif direction<0,
         D(D<0) = NaN ;
         [mind1 n] = min(abs(D)) ;
      else
         [mind1 n] = min(abs(D)) ;
      end

      mind1 = mind1';
      n(isnan(mind1)) = NaN ;
      if ~isnan(maxdist),
         n(mind1>maxdist) = NaN ;
      end
      kx(k+(1:nn)) = n' ;
      k = k+nn ;
   end
end
