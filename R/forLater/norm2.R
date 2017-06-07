#The following is an attempt to translate Mark Johnson's norm2.m matlab script, 
#from the dtag tool box, to an R script.
#Note that we made no effort to vectorize or use apply...just changed matlab to R code keeping the same general structure.
#DAS and YJO, June 2017

#function     v = norm2(X)

#    Returns the row-wise 2-norm of matrix X, i.e., the square-root
#		 of the sum of the squares for each row. If X is a vector, norm2()
#	   is equivalent to the built-in function norm(). But if X is a matrix
#		 e.g., a triaxial accelerometer or magnetometer matrix, norm() gives
#		 the overall norm of the matrix whereas norm2() gives the vector norm
#		 of each row (i.e., the field strength in the case of a magnetometer
#    matrix.

#    Input:
#    X is a vector or matrix.

#    Returns:
#    v is the row-wise vector norm of X if X is a matrix. If X is a vector
#    (row or column), v is the vector norm.

#    Example:
#    sampleMatrix = matrix(c(0.2, 0.4, -0.7,-0.3, 1.1, 0.1) byrow = TRUE, nrow = 2, ncol = 3)
#    v = norm2(sampleMatrix)
#    returns: v = c(0.83066, 1.14455)

#  Valid: Matlab, Octave
#  markjohnson@st-andrews.ac.uk
#  Last modified: 10 May 2017

norm2 <- function(X){
  sizearray <- dim(X)
  if (sizearray[1] == 1 | sizearray[2] == 1){
    v <- sqrt(sum(X^2))
  }
  else{
    v <- sqrt(rowSums(abs(X)^2))
  }
  v
}