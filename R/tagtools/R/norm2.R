#' Compute the row-wise vector norm of X if X is a matrix. If X is a vector (row or column), v is the vector norm.
#' 
#' @param X A vector or matrix.
#' @return v The row-wise vector-norm of matrix X, i.e., the square-root of the sum of the squares for each row. If X is a vector (row or column), v is the vector norm and norm2() is equivalent to the built-in function norm(). But if X is a matrix e.g., a triaxial accelerometer or magnetometer matrix, norm() gives the overall norm of the matrix whereas norm2() gives the vector norm of each row (i.e., the field strength in the case of a magnetometer matrix).
#' @export
#' @examples 
#' sampleMatrix = matrix(c(0.2, 0.4, -0.7,-0.3, 1.1, 0.1), byrow = TRUE, nrow = 2, ncol = 3)
#' norm2(X=sampleMatrix)  
#' #Result: c(0.83066, 1.14455)

norm2 <- function(X) {
    sizearray <- dim(X)
    # If X is a vector (row or column), v is the vector norm.
    if (sizearray[1] == 1 | sizearray[2] == 1) {
        v <- sqrt(sum(X^2))
    } else {
        # If X is a matrix, v is the matrix norm.
        v <- sqrt(rowSums(abs(X)^2))
    }
    return(v)
}
