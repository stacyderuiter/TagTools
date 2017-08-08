function    m = msa(A,ref)

%      m = msa(A)             % A is a sensor structure
%      or
%      m = msa(A,ref)			% A is a matrix
%
%      Compute the Minimum Specific Acceleration (MSA). This is the
%      absolute value of the norm of the acceleration minus 1 g, i.e.,
%		 the amount that the acceleration differs from the gravity value. 
%		 This is always equal to or less than the actual specific acceleration if
%		 A is correctly calibrated.
%
%		 Inputs:
%      A is an acceleration sensor structure or a matrix with columns [ax ay az]. 
%		  Acceleration can be in any consistent unit, e.g., g or m/s^2. A can be in 
%		  any frame as the MSA is rotation independent.
%		 ref is the gravitational field strength in the same units as A. This is not
%		  needed if A is a sensor structure. If A is a matrix, the default value is
%		  9.81 which assumes that A is in m/s^2. Use ref=1 if the unit of A is g. 
%
%		 Result:
%      m is a column vector of MSA with the same number of rows as A. m has the same
%		  units as A.
%
%		 Example:
%		  msa([1,-0.5,0.1;0.8,-0.2,0.6;0.5,-0.9,-0.7],1)
%		  returns: [0.122497;0.019804;0.24499]
%
%	   See Simon et al. (2012) Journal of Experimental Biology, 215:3786-3798.
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     Last modified: 5 May 2017

m = [] ;
if nargin<1,
   help msa
   return
end	

if nargin<2,
	ref = 9.81 ;
end

if isstruct(A),
	A = sens2var(A) ;
   if isempty(A),
      return
   end
	if nargin==1 && isfield(A,'unit'),
      if strncmpi(A.unit,'g',1),
         ref = 1 ;
		end
	end
end	

% catch the case of a single acceleration vector
if min([size(A,1) size(A,2)])==1,
   A = A(:)' ;
end

m = abs(sqrt(sum(A.^2,2))-ref) ;
