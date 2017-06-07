# The following is an attempt to translate Mark Johnson's msa.m matlab script, from the dtag tool box, to an R script. Note that we made no
# effort to vectorize or use apply...just changed matlab to R code keeping the same general structure. DAS and YJO, June 2017

# function m = msa(A,ref)

#      Compute the Minimum Specific Acceleration (MSA). This is the
#      absolute value of the norm of the acceleration minus 1 g, i.e.,
#		   the amount that the acceleration differs from the gravity value. 
#		   This is always equal to or less than the actual specific acceleration if
#		   A is correctly calibrated.

#		 Inputs:
#     A is a nx3 acceleration matrix with columns [ax ay az]. Acceleration can 
#		   be in any consistent unit, e.g., g or m/s^2. A can be in any frame as the
#		  MSA is rotation independent.
#	  	ref is the gravitational field strength in the same units as A. The
#		   default value is 9.81 which assumes that A is in m/s^2. Use ref=1 if the
#		   unit of A is g. 

#		 Result:
#     m is a column vector of MSA with the same number of rows as A. m has the same
#		  units as A.

#		 Example:
# 	  msa([1,-0.5,0.1;0.8,-0.2,0.6;0.5,-0.9,-0.7],1)
#		  returns: [0.122497;0.019804;0.24499]
#
#	  See Simon et al. (2012) Journal of Experimental Biology, 215:3786-3798.

#  Valid: Matlab, Octave
#  markjohnson@st-andrews.ac.uk
#  Last modified: 5 May 2017

msa <- function(A, ref) {
  require(matlab)  #for size() function
  if (nargs() < 2) {
    ref <- 9.81
  }
  # catch the case of a single acceleration vector
  if (min(c(size(A,1), size(A,2)))==1) {
    A <- t(A)
  }
  m = abs(sqrt(rowSums(A^2))-ref)
}