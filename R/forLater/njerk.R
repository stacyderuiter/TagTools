#' Compute the norm-jerk from triaxial acceleration data.
#' 
#' @param A An nx3 acceleration matrix with columns [ax ay az]. Acceleration can be in any consistent unit, e.g., g or m/s^2. A can be in any frame as the norm-jerk is rotation independent. A must have at least 2 rows (i.e., n>=2).
#' @param fs The sampling rate in Hz of the acceleration signals. This is used to estimate the differential by a first-order difference.
#' @return The norm-jerk from triaxial acceleration data in the form of a column vector with the same number of rows as in A. The norm-jerk is ||dA/dt||, where ||x|| is the 2-norm of x, i.e., the square-root of the sum of the squares of each axis. If the unit of A is m/s^2, the norm-jerk has unit m/s^3. If the unit of A is g, the norm-jerk has unit g/s. As j is the norm of the jerk, it is always positive or zero (if the acceleration is constant). The final value in j is always 0 because the last finite difference cannot be calculated.
#' @examples 
#' sampleMatrix = matrix(c(1, 2, 3, 2, 2, 4, 1, -2, 4, 4, 4, 4), byrow = TRUE, nrow = 4, ncol = 3)
#' njerk(sampleMatrix, 5)  
#' result is: c(7.0711, 20.6155, 33.541, 0)

njerk <- function(A, fs) {
    j <- c(fs * sqrt(rowSums(diff(A)^2)), 0)
    return(j)
}
