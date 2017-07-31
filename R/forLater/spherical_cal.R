spherical_cal <- function(X,n,method){
  #     [Y,G] = spherical_cal(X)
  #		or
  #     [Y,G] = spherical_cal(X,n)
  #		or
  #     [Y,G] = spherical_cal(X,n,method)
  #		Deduce the calibration constants for a triaxial field sensor,
  #		such as an accelerometer or magnetometer, based on movement data.
  #		This can be used to do a 'bench' calibration of a sensor.
  #
  #		Inputs:
  #     X is the segment of triaxial sensor data to calibrate. It must
  #		 be a 3-column matrix. X can come from any triaxial field sensor
  #		 and can be in any unit and any frame.
  #     n is the target field magnitude e.g., 9.81 for accelerometer 
  #      data using m/s2 as the unit.
  #     method is an optional string selecting the type of calibration.
  #		 The default is to calibrate for offset and scaling only. Other
  #		 options are:
  #      'gain' adjust gain of axes 2 and 3 relative to 1.
  #      'cross' adjust gain and remove cross-axis correlations
  #
  #		Results:
  #     Y is the matrix of converted sensor values. These will have the same
  #		 units as for input argument n. The size of Y is the same as the size
  #		 of X and it has the same frame and sampling rate.
  #     G is the calibration structure containing fields:
  #		G.poly is a matrix of polynomials. The first column of G.poly is the 
  #		 three scale factors applied to the columns of X. The second column 
  #		 is the offset added to each column of X after scaling.
  #		G.cross is a 3x3 matrix of cross-factors. If there are no cross-terms, this
  #		 is the identity matrix. Off-axis terms correct for cross-axis sensitivity.
  #
  #		The function reports the residual and the axial balance of the data.
  #		A low residual e.g., <5% indicates that the data can be calibrated
  #		well and there is not much noise. The axial balance indicates whether
  #		the movement in X is suitable for data-driven calibration. If the
  #		movement covers all directions fairly equally, the axial balance will
  #		be high. A balance <20% may lead to unreliable calibration. For bench
  #		calibrations, a high axial balance is achieved by rotating the sensor
  #		through the full 3-dimensions.
  #		Sampling rate and frame of Y are the same as the input data so Y
  #		has the same size as X. The units of Y are the same as the units used for n. 
  #		If n is not specified, the units of Y are the same as for the input data.
  #		It is a good idea to low-pass filter and/or remove outliers from
  #		the sensor data before using this function to reduce errors from 
  #		specific acceleration and sensor noise. 
  #		Notes: this function uses a Simplex search for optimal calibration parameters
  #		and so can be slow if the data size is large. For this reason it is most
  #		suitable for bench calibrations rather than field data.
  #		This function is only usable for field sensors. It will not work
  #		for gyroscope data.
  
  #		Example:
  #		 C = spherical_cal()
  # 	    returns: C=?.
  #
  #     Valid: Matlab, Octave
  #     markjohnson@st-andrews.ac.uk
  #     Last modified: 10 May 2017
  G = c()
  Y= c()
  if(missing(X)){
    stop("X is required for sphreical cal!")
  }
  if(missing(n)){
    n = c()
  }
  if(missing(method)){
    method = c()
  }
  # remove any rows in X with NaNs
  X <- X[!is.na(X),]
  nv1 <- 3 ;		# number of variables for offset
  nv2 <- 5 ;		# number of variables for gain and offset
  nv3 <- 8 ;		# number of variables for gain, offset and cross
  
  
  # start by estimating offsets using linear least squares. This ensures
  # that the iterative search starts fairly close to a solution.
  bsq <- rowSums(X^2)
  XX <- c(2*X, matrix(1,nrow(X),1))
  R <- t(XX)*XX 
  P<- sum(pracma::repmat(bsq,1,4)*XX)
  H <- -solve(R)*t(P)
  offs <- H[1:3] 
  X <- X + pracma::repmat(t(offs),nrow(X),1) 
  # now try up to three calibration scenarios using simplex search
  C <- matrix(0,nv3,3)
  C[1:nv1,1] <- stats::optim(matrix(0,nv1,1), ccost( C[1:nv1,1],X), method = "Nelder-Mead") # offset only cal
  if(identical(method,'gain') | identical(method,'cross')){
    C[1:nv2,2] <- optim(C[1:nv2,1],ccost(C[1:nv2,2],X), method = "Nelder-Mead") ;	# offset and gain cal
  }
  if(identical(method,'cross')){
    C[,3] <- optim(C[,2], ccost(C[,3],X), method = "Nelder-Mead") ;		# offset, gain and cross cal
  }
  k <- which.min(ccost(C,X))   		# pick the best performer
  C <- C[,k] 
  listYC <- appcal(X,C) # apply the calibration
  Y <- listYC$Y
  nn = norm2(Y) 
  print(sprintf('Residual: %2.1f',100*sd(nn)/mean(nn))) 
  R = t(Y) %*% Y 
  print(sprintf('Axial balance: %2.1f',100/rcond(R))) 
  
  if(length(n) != 0){
    sf <- n/mean(nn) 
    Y <- Y %*% sf 
  }
  else{
    sf <- 1
  }
  G$poly <- c((1+C[,ncol(C)-1])%*%sf, (offs+C[,1])%*%sf)
  G$cross <- 0.5*rbind(c(2, C[1,ncol(C)], C[3,ncol(C)]), c(C[1,ncol(C)], 2, C[2,ncol(C)]),c(C[3,ncol(C)], C[2,ncol(C)], 2))
  return(list(Y = Y, G = G))
}

ccost <- function(C,X){
  for(k in 1:ncol(C)){
    n <- sqrt(rowSums(appcal(X,C[,k])$Y^2)) ;
    p[k] <- sd(n)/mean(n) ;
  }
  return(p)
}

appcal<- function(X,C){
  # C is a vector of up to 8 parameters
  # Only the first of these may be provided - the remainder are 0.
  C[length(C)+1:8] = 0 ;
  C <- rbind(C[1:length(C)-5],0,C[length(C)+(-4:0)])		# add the col1 fixed gain of 0
  C <- as.matrix(C,nrow = 3)
  #	At this point:
  #	C(:,1) are the offsets for each column of X
  #	C(:,2) are the gain adjustments for each column of X (column 1 is always 0)
  #	C(:,3) are the cross terms
  Y <- X%*%diag(1+C[,ncol(C)-1])+pracma::repmat(t(C[,1]),nrow(X),1) ;
  xcm <- 0.5*rbind(c(2, C[1,ncol(C)], C[3,ncol(C)]),c(C[1,ncol(C)], 2, C[2,ncol(C)]),c(C[3,ncol(C)], C[2,ncol(C)], 2))
  Y <- Y %*% xcm ;
  return(list(Y= Y,C= C))  
}
            

               
               

    
               
               

               
               

                                               
                                               