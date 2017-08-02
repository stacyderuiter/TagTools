#' Reconstruct a 3D track 
#' 
#' Reconstruct a track from pitch, heading and depth data, given a stating position. This function will use data from a tag to reconstruct a track by fitting a state space model using a Kalman filter. If no x,y observations are provided then this corresponds to a pseudo-track obtained via dead reckoning and extreme care is required in interpreting the results.
#' 
#' @param z A vector with depth over time (in meters, an observation)
#' @param phi A vector with pitch over time (in Radians, assumed as a known covariate)
#' @param psi A vector with heading over time (in Radians, assumed as a known covariate)
#' @param sf A scalar defining the sampling rate (in Hz)
#' @param r=0.001 Observation error
#' @param q1p=0.02 speed state error
#' @param q2p=0.08 depth state error
#' @param q3p=1.6e-05 x and y state error
#' @param tagonx Easting of starting position
#' @param tagony Northing of starting position
#' @param enforce=T If TRUE, then speed and depth are kept strictly positive
#' @param x Direct observations of Easting
#' @param y Direct observations of Northing
#' @seealso \code{\link{m2h},\link{a2pr}}
#' @returns A list with many elements:
#' \itemize{
#'  \item{\strong{p: }} the smoothed speeds
#'  \item{\strong{fit.ks: }} the fitted speeds
#'  \item{\strong{fit.kd: }} the fitted depths
#'  \item{\strong{fit.xs: }} the fitted xs
#'  \item{\strong{fit.ys: }} the fitted ys
#'  \item{\strong{fit.rd: }} the smoothed depths
#'  \item{\strong{fit.rx: }} the smoothed xs
#'  \item{\strong{fit.ry: }} the smoothed ys
#'  \item{\strong{fit.kp: }} the kalman a posteriori state covariance
#'  \item{\strong{fit.ksmo: }} the kalman smoother variance
#' }
#' @note Output sampling rate is the same as the input sampling rate.
#' @note Frame: This function assumes a [north,east,up] navigation frame and a [forward,right,up] local frame. In these frames, a positive pitch angle is an anti-clockwise rotation around the y-axis. A positive roll angle is a clockwise rotation around the x-axis. A descending animal will have a negative pitch angle while an animal rolled with its right side up will have a positive roll angle.
#' @export
#' @examples 
#' \dontrun{
#' p <- a2pr(A=beaked_whale$A$data) 
#'h <- m2h(M=beaked_whale$M$data,A=beaked_whale$A$data) 
#' track=track3D(z=beaked_whale$P$data,phi=p$p,psi=h$h,sf=beaked_whale$A$sampling_rate,r=0.001,q1p=0.02,q2p=0.08,q3p=1.6e-05,tagonx=1000,tagony=1000,enforce=T,x=NA,y=NA)
#' par(mfrow=c(2,1),mar=c(4,4,0.5,0.5))
#' plot(-beaked_whale$P$data,pch=".",ylab="Depth (m)",xlab="Time")
#' plot(track$fit.rx,track$fit.ry,xlab="X",ylab="Y",pch=".")
#' points(track$fit.rx[c(1,length(track$fit.rx))],track$fit.ry[c(1,length(track$fit.rx))],pch=21,bg=5:6)
#' legend("bottomright",cex=0.7,legend=c("Start","End"),col=c(5,6),pt.bg=c(5,6),pch=c(21,21))
#' 
#' 
#' }

track3D=function(z,phi,psi,sf,r=0.001,q1p=0.02,q2p=0.08,q3p=1.6e-05,tagonx,tagony,enforce=T,x,y){
  #-------------------------------------------------------
  #-------------------------------------------------------
  # The underlying state space model being fitted to the data is described in
  # "Estimating speed using the Kalman filter... and beyond", equations 5 and 6
  # a LATTE internal report available from TAM
  #-------------------------------------------------------
  #-------------------------------------------------------
  #inputs:
  #   z (was p in MJ code) is a vector of depths
  #   phi (was pitch in MJ code) is a vector of pitchs
  #   psi is a vector of headings
  #   sf (was fs in MJ code) is the sampling frequency, in Hz
  #   r observation error (in depth)
  #   q1p state error (in speed)
  #   q2p state error (in depth)
  #   q3p state error (in x and y)
  # tagonx,tagony is the location, in x,y, where the DTag started recording
  #   enforce   if TRUE (the default) the speed and depth estimates are kept strictly non negative
  #             note this is intuitively nice, but makes this no longer a proper KF
  #-------------------------------------------------------
  #-------------------------------------------------------
  #number of times each observation was observed
  n=length(z)
  #defining some required quantities
  #note currently these are constants
  #measument error in depth
  r1 = r
  r2= matrix(c(0.001,0,0,0,5,0,0,0,5),3,3,byrow=T)
  #state error in speed
  q1 = (q1p/sf)^2
  #state error in depth
  q2 = (q2p/sf)^2
  #state error in x
  #q3 = (q1p/sf)^2
  q3=q3p
  #state error in y
  #q3 = (q1p/sf)^2
  #sampling period
  SP = 1/sf
  #state transition matrix entry (2,1) - see equation 7
  Gt.2.1 = -sin(phi)/sf
  #state transition matrix entry (3,1) - see equation 7
  Gt.3.1 = (cos(phi)*sin(psi))/sf
  #state transition matrix entry (4,1) - see equation 7
  Gt.4.1 = (cos(phi)*cos(psi))/sf
  #initial states, pitch = 1, and depth = initial observed depth
  #TAM?: why start pitch at 1? why the different "conceptual" choice
  # for pitch and depth?
  shatm=matrix(c(1,z[1],tagonx,tagony),4,1)
  # state noise matrix
  Q=matrix(c(q1,0,0,0,0,q2,0,0,0,0,q3,0,0,0,0,q3),4,4,byrow=T)
  #observation matrix (a vector here)
  H1=matrix(c(0,1,0,0),1,4)
  H2=matrix(c(0,1,0,0,0,0,1,0,0,0,0,1),3,4,byrow=T)
  # initial state covariance matrix
  # says how much we trust initial values of s and p?
  Pm=matrix(c(0.01,0,0,0,0,r,0,0,0,0,0.01,0,0,0,0,0.01),4,4,byrow=T)
  # place to store state predictions
  skal = matrix(0,nrow=4,ncol=n)
  # object for storing the kalman a posteriori state covariance (2x2xn)
  Ps = array(data = 0, dim = c(4,4,n))
  # note all other variance-covariance matrices have th same stucture/dimensions
  # Pms is the a priori state variance-covariance matrix
  Pms=Ps
  # Psmo is the smoothing variance-covariance matrix
  Psmo=Ps
  #implementing the kalman Filter
  for (i in 1:n){
    # make state transition matrix
    Ak=matrix(c(1,0,0,0,Gt.2.1[i],1,0,0,Gt.3.1[i],0,1,0,Gt.4.1[i],0,0,1),4,4,byrow=T)
    #after the initial state only
    #(hence this bit is ONLY not evaluated for the inital state)
    if (i>1) {
      # update a priori state cov
      Pm = Ak%*%P%*%t(Ak) + Q
      #a priori state estimate
      shatm = Ak%*%shat
    }
    # compute kalman gain
    if (is.na(x[i])) {
      H=H1
      r=r1} else {
        H=H2
        r=r2
      }
    
    K = Pm%*%t(H)%*%solve(H%*%Pm%*%t(H)+r)
    # a posteriori state estimates
    if (is.na(x[i])) {
      shat = shatm + K%*%(z[i]-H%*%shatm)
    } else {
      shat = shatm + K%*%(matrix(c(z[i],x[i],y[i]),nrow=3,ncol=1)-H%*%shatm)
    }
    # forcing speed and depth always to be positive
    #TAM?: must be a smarter way to do this ????
    if (enforce==T){
      shat[1:2] =  ifelse(shat[1:2]<0,0,shat[1:2])}
    # a posteriori state cov
    P = (diag(4)-K%*%H)%*%Pm ;
    #store results of iteration
    skal[,i] = shat
    Pms[,,i] = Pm
    Ps[,,i] = P
  }
  #object to hold the states smoothed by the Rauch smoother
  srau = matrix(0,nrow=4,ncol=n)
  #note that for the last point
  #no smoothing possible, it's the point itself
  srau[,n] = shat
  # and the same for the variance-covariance
  # which is the same as that of the filtering
  # as per wording just after equation 8.85 in Gannot & Yeredor 2008
  Psmo[,,n]=Ps[,,n]
  # Kalman/Rauch smoother
  # so now we are moving backwards
  for (i in n:2){
    # make state transition matrix
    Ak=matrix(c(1,0,0,0,Gt.2.1[i-1],1,0,0,Gt.3.1[i-1],0,1,0,Gt.4.1[i-1],0,0,1),4,4,byrow=T)
    # smoother gain - equation 8.69 in Gannot & Yeredor 2008
    K=Ps[,,i-1]%*%t(Ak)%*%solve(Pms[,,i])
    # smooth state - (supposedly) equation 8.68 in Gannot & Yeredor 2008
    srau[,i-1] = skal[,i-1]+K%*%(srau[,i]-Ak%*%skal[,i-1])
    #smoother variance - equation 8.85 in Gannot & Yeredor 2008
    Psmo[,,i-1]=Ps[,,i-1]-K%*%(Pms[,,i]-Psmo[,,i])%*%t(K)
  }
#return required outputs
    return(list(speeds=srau[1,],fit.ks=skal[1,],fit.kd = skal[2,],fit.kx = skal[3,],fit.ky = skal[4,],fit.rd = srau[2,],
              fit.rx = srau[3,],fit.ry = srau[4,],fit.kp=Ps,fit.ksmo=Psmo))
}
