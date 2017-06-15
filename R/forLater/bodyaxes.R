#' Generate the cardinal axes of an animal (i.e., the longitudinal, transverse, and ventro-dorsal) from accelerometer and magnetic field measurements. This functions generates an approximate orthonormal basis from each measurement of A and M by: (i) normalizing A and M to unit length, (ii) rotating the magnetometer measurement to the horizontal plane (Mh), (iii) computing the cross-product, N, of A and Mh to generate the third axis, (iv) transposing [Mh,N,A] to form the body axis basis.
#' 
#' @param A The acceleration matrix with columns [ax ay az]. Acceleration can be in any consistent unit, e.g., g or m/s^2.
#' @param M The magnetometer signal matrix, M=[mx,my,mz] in any consistent unit (e.g., in uT or Gauss).
#' @param fc (optional) The cut-off frequency of a low-pass filter to apply to A and M before computing the axes. The filter cut-off frequency is with respect to 1=Nyquist frequency. The filter length is 8/fc. Filtering adds no group delay. If fc is not specified, no filtering  is performed.
#' @return W The 3x3xn matrix of body axes where n is the number of rows in M and A. W(:,1,:) are the X or longitudinal (caudo-rostral) axes. W(:,2,:) are the Y or transverse (left-right) axes. W(:,3,:) are the Z or ventro-dorsal axes.
#' Output sampling rate is the same as the input sampling rate.
#' Frame: This function assumes a [north,east,up] navigation frame and a [forward,right,up] local frame. This function will only return the animal's cardinal axes if the tag was attached so that the sensor axes aligned with the animal's axes OR if the tag A and M measurements are rotated to account for the orientation of the tag on the animal (see tagorientation() and tag2animal() to do this). Otherwise, the axes returned by this function will be the cardinal axes of the tag, not the animal. 
#' @export
#' @examples 
#' W <- bodyaxes(matrix(c(-0.3, 0.52, 0.8, 22, -22, 14),
#'               byrow = TRUE, nrow = 2, ncol = 3)
#' #Result: [0.59682 -0.55182 0.58249
#' #         0.74420 0.65208 -0.14477 
#' #        -0.29994 0.51990 0.79984]

bodyaxes <- function(A, M, fc = NULL) {
    # input checks-----------------------------------------------------------
    if (missing(M) | (missing(A))) {
        stop("A and M are required inputs")
    }
    if (nrow(M) * ncol(M) == 3) {
        M <- t(M)
    }
    if (nrow(A) * ncol(A) == 3) {
        A <- t(A)
    }
    if (nrow(A) != nrow(M)) {
        print(sprintf("bodyaxes: A and M must have same number of rows  n"))
    }
    if (!is.null(fc)) {
        if (nrow(A) > (8/fc)) {
            M <- fir_nodelay(M, round(8/fc), fc)
            A <- fir_nodelay(A, round(8/fc), fc)
        }
    }
    b <- sqrt(rowSums(M^2))
    g <- sqrt(rowSums(A^2))
    # normalize M to unit magnitude
    M <- M * matlab::repmat(b^(-1), 1, 3)
    # normalize A to unit magnitude
    A <- A * matlab::repmat(g^(-1), 1, 3)
    # estimate inclination angle from the data
    I <- acos(rowSums(A * M)) - (pi/2)
    Mh <- (M + matlab::repmat(sin(I), 1, 3) * A) * matlab::repmat(cos(I)^(-1), 1, 3)
    v <- sqrt(rowSums(Mh^2))
    # normalize Mh
    Mh <- Mh * matlab::repmat(v^(-1), 1, 3)
    # for FRU axes
    N <- matrix(0, dim(Mh)[1], dim(Mh)[2])
    for (i in 1:dim(N)[1]) {
        N[i, ] <- c(Mh[i, 2] * A[i, 3] - Mh[i, 3] * A[i, 2], Mh[i, 3] * A[i, 1] - Mh[i, 1] * A[i, 3], Mh[i, 1] * A[i, 
            2] - Mh[i, 2] * A[i, 1]) * -1
    }
    W <- array(0,c(3, 3, nrow(A)))
    
    W[1, , ] <- t(Mh)
    W[2, , ] <- t(N)
    W[3, , ] <- t(A)
    return(W) 
}
