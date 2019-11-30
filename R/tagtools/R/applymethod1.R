#' Apply PRH predictor method 1
#' 
#' This is a helper function for the function prh_predictor1 which most users should use rather than this one.
#' @param A Acceleration data
#' @param sampling_rate sampling rate in Hz
#' @param ss matrix with information about segment timing
#' @noRd

applymethod1 <- function(A, sampling_rate, ss){
  # For logging-diving dive edges (descending or ascending)
  # Chooses p0 and r0 for a horizontal whale during the logging
  # segment (Ak1) and chooses h0 to minimize the mean-squared
  # y-axis acceleration in the diving segment (Ak2).
  
  ks1 <- c( (round(ss[1]*sampling_rate) +1) : round(ss[2]*sampling_rate))
  ks2 <- c((round(ss[3]*sampling_rate)+1) : round(ss[4]*sampling_rate))
  
  Ak1 <- A[ks1,]
  Ak2 <- A[ks2,]
  # mean acceleration in logging segment
  Am1 <- matrix(apply(Ak1, 2, mean), nrow = 3) 
  pitch_roll <- tagtools::a2pr(Am1) # corresponding p0 and r0
  prh <- matrix(c(pitch_roll$p, pitch_roll$r), ncol = 2)
  prh <- cbind(prh,0) 
  # transformation to remove p0 and r0 from A
  Q <- tagtools::euler2rotmat(prh[,1], prh[,2], prh[,3]) 
  # transformed acceleration in diving segment
  At2 <- Ak2 %*% t(Q) 
  
  # sum-of-squares needed for ls algorithm
  AA <- matrix(apply(cbind((At2[,1:2])^2, At2[,1] * At2[,2]),
                     MARGIN = 2, FUN = sum),
               nrow = 1)
  
  # 2 quadrant atan - determine the correct quadrant later from context
  h2 <- atan( 2*AA[3] / (matrix(AA[1, 1:2], nrow = 1) %*% matrix(data = c(-1,1), nrow = 2) ) )
  
  # check that this is a minimum - if not add 180 degrees
  if ( matrix(AA[1, 1:2], nrow = 1)  %*%
       matrix(data = c(1,-1), nrow = 2) *
       cos(h2) - 
       2*AA[,3] * 
       sin(h2) < 0){
    h2 <- h2 + pi
  }
  # actual h0 is half of h2
  prh[3] = h2/2
  
  #**************************************************
  # quality metrics
  #**************************************************
  
  # 1. Residual squared error for the chosen h0
  se <- matrix(AA[1:2], nrow = 1) %*%
    matrix(data = c(1,1), nrow = 2) / 2 + 
    matrix(AA[1:2], nrow = 1) %*%
    matrix(data = c(-1,1), nrow = 2) %*% 
    cos(h2)/2 + AA[3]*sin(h2)
  
  # 2. energy ratio between plane-of-motion and axis of rotation 
  QQ <- t(Ak2) %*% Ak2 # form outer product of acceleration in diving segment
  if (any(is.na(QQ))){
    prh <- NULL
    return()
  }
  
  # break into eigen-axes: assuming that the motion is mostly planar,
  # the eigenvalues of QQ will indicate how planar: the largest two eigenvalues
  # describe the energy in the plane of motion; the smallest eigenvalue
  # describes the energy in the invariant direction i.e., the axis of rotation.
  
  svd_out <- svd(QQ)    
  # if the inverse condition cc>~0.05, the motion in Ak2
  # is more three-dimensional than two-dimensional
  cc <- diag(svd_out$d)[3,3]/diag(svd_out$d)[2,2] 
  # collect the quality metrics
  prh[4] <- mean(c(cc, sqrt(se/nrow(Ak2)))) 
  
  # check that h0 is not 180 degrees out by checking that the sign of the
  # pitch is correct for the dive edge - descent is pitch down, ascent is
  # pitch up.
  
  # make final transformation matrix
  Q <- tagtools::euler2rotmat(prh[1], prh[2], prh[3]) 
  # animal frame acceleration for the segment
  Aa <- Ak2 %*% t(Q) 
  if (median(sign(Aa[,1])) != ss[5]){
    # if incorrect, add/subtract 180 degrees
    prh[3] <- (prh[3]-pi) %% (2*pi)  
  }
  
  # by convention, constrain r0 and h0 to the interval -pi:pi
  for (k in c(2:3)){
    if (abs(prh[k]) > pi){
      prh[k] <- prh[k] - sign(prh[k])*2*pi
    }
  }
  return(prh)
}# end of applymethod1 function def

