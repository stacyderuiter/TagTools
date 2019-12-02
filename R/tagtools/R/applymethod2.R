#' Apply PRH predictor method 2
#' 
#' This is a helper function for the function prh_predictor2 which most users should use rather than this one.
#' @param A Acceleration data
#' @param sampling_rate sampling rate in Hz
#' @param ss matrix with information about segment timing
#' @noRd

applymethod2 <- function(A, v, sampling_rate, ss){
  #     For animals that do sequences of roll-free shallow dives.
  #     Chooses r0 and h0 to minimize the mean-squared
  #     y-axis acceleration in segment As and then chooses
  #     p0 for a mean pitch angle of 0.
  
  # break into eigen-axes: assuming that the motion is mostly planar,
  # the eigenvalues of QQ will indicate how planar: the largest two eigenvalues
  # describe the energy in the plane of motion; the smallest eigenvalue
  # describes the energy in the invariant direction i.e., the axis of
  # rotation
  
  ks <- c( (round(ss[1]*sampling_rate) +1) : round(ss[2]*sampling_rate))
  
  As <- A[ks,]
  vs <- v[ks]
  
  # energy ratio between plane-of-motion and axis of rotation 
  QQ <- t(As) %*% As  # form outer product of acceleration
  if (any(is.na(QQ))){
    prh <- NULL
    return(prh) 
  }
  
  svd_out <- svd(QQ)
  # if the inverse condition cc>~0.05, the motion in Ak2
  # is more three-dimensional than two-dimensional
  pow <- diag(svd_out$d)[3,3]/diag(svd_out$d)[2,2] 
  
  # axis of rotation to restore V to tag Y axis
  aa <- acos(matrix(c(0, 1, 0), nrow = 1) %*% svd_out$v[,3])
  Phi <- pracma::cross(matrix(c(0,1,0), ncol = 1), matrix(svd_out$v[,3], ncol = 1)) / rep(sin(aa),3)
  S <- rbind(cbind(0, -Phi[3], Phi[2]),
             cbind(Phi[3], 0, -Phi[1]),
             cbind(-Phi[2], Phi[1],0 ))	# skew matrix
  ## non-conformable args error here
  # mat is Q = eye(3)+(1-cos(aa))*S*S-sin(aa)*S ;
  Q <-  diag(3) + matrix(1-cos(aa), nrow = 3, ncol = 3) * S %*% S - matrix(sin(aa), nrow = 3, ncol = 3) * S # generate rotation matrix for rotation 
  # of aa degrees around axis Phi
  am <- matrix(apply(As, 2, mean), nrow = 1) %*% t(Q)
  p0 <- atan2(am[1], am[3])
  Q <- euler2rotmat(p = p0, r = 0, h = 0) %*% Q
  prh <- cbind(asin(Q[3,1]), atan2(Q[3,2], Q[3,3]), atan2(Q[2,1], Q[1,1]))

  aa <- As %*% matrix(Q[2,], ncol = 1)
  prh[4] <- mean(c(pow, stats::sd(aa)))
  
  # check that h0 is not 180 degrees out by checking that the regression
  # between Aa[,1] and depth_rate is negative.
  Q <- euler2rotmat(prh[1], prh[2], prh[3]) # make final transformation matrix
  Aa <- As %*% t(Q) # animal frame acceleration for the segment
  pp <- coef(lm(vs ~ Aa[,1]))[2]
  if (pp >0){
    prh[3] = (prh[3]-pi) %% (2*pi) # if incorrect, add/subtract 180 degrees
  }
  
  # by convention, constrain r0 and h0 to the interval -pi:pi
  for (k in c(2:3)){
    if (abs(prh[k]) > pi){
      prh[k] <- prh[k] - sign(prh[k])*2*pi
    }
  }
  
  return(prh)
}# end of applymethod2 function def

