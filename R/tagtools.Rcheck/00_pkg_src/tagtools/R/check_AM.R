#' Compute field intensity of tag acceleration and magnetometer data.
#' 
#' Compute field intensity of acceleration and magnetometer data,
#'  and the inclination angle of the magnetic field. 
#'  This is useful for checking the quality of a calibration, 
#'  for detecting drift, and for validating the mapping
#'  of the sensor axes to the tag axes.
#'  
#' @param A  An accelerometer sensor structure or matrix with columns [ax ay az]. Acceleration can be in any consistent unit, e.g., g or m/s^2.
#' @param M  A magnetometer sensor structure or matrix, M=[mx,my,mz] in any consistent  unit (e.g., in uT or Gauss).
#' @param fs  (optional) The sampling rate of the sensor data in Hz (samples per second). This is only needed if A and M are not sensor structures and filtering is required.
#' @param find_incl (optional; logical) Should inclination be computed and returned? Default is TRUE.
#' 
#' @return If find_incl is false, then the matrix fstr is returned. Otherwise, check_AM returns a list with elements:
#' \itemize{
#'    \item{\code{fstr, }} {The estimated field intensity of A and or M in the same units as A and M.
#'          fstr is a vector or a two column matrix. If only one type of data is input, 
#'          fstr will be a column vector. If both A and M are input, fstr will have two columns
#'          with the field strength of A in the 1st column and the field strength of M in the
#'          2nd column.}
#'    \item{\code{incl, }} {The estimated field inclination angle (i.e., the angle with respect to the 
#'    horizontal plane) in radians. incl is a column vector. By convention, a field 
#'    vector pointing below the horizon has a positive inclination angle. This is only 
#'    returned if the function is called with both A and M data.}
#' }
#' @details The sampling rate of fstr and incl is the same as the input sampling rate. 
#' This function automatically low-pass filters the data with a cut-off frequency
#'  of 5 Hz if the sampling rate is greater than 10 Hz.
#'  Frame: This function assumes a [north,east,up] navigation frame and a
#'  [forward,right,up] local frame.
#' @examples 
#' \dontrun{
#' AMcheck <- check_AM(A=matrix(c(-0.3,0.52,0.8), nrow=1),
#'                     M=matrix(c(22,-22,14), nrow=1),
#'                     fs=1)
#' #returns AMcheck$fstr = 1.0002, 34.11744 and AMcheck$incl = 0.20181 radians
#' }
#' @export
check_AM <- function(A,M=NULL,fs=NULL, find_incl=TRUE){
  fc <- 5             # low pass filter frequency in Hz
  
  if (is.list(A)){
  if (!is.null(M)){
    if (identical(A$sampling_rate, M$sampling_rate) & 
        nrow(A$data) == nrow(M$data)){
      fs <- A$sampling_rate
      A <- A$data
      M <- M$data
    }
  }else{
    fs <- A$sampling_rate
    A <- A$data
  }
  if (length(A)==0){
  stop('No data found in input argument A')
  }
  }else{
    if (is.null(M)& is.null(fs)){
      stop('fs is a required input to check_AM if A is not a tag sensor data list.')
    }
  
  if (is.null(fs)){
  if (length(M) == 1){
  fs <- M 
  M <- NULL 
  }else{
    em <- ' Need to specify sampling frequency for matrix arguments'
    stop(em)
  }
  }
}#end of if A is a list	
  
  # check for single vector inputs
  if (length(M)==3){
  M <- matrix(M, nrow=1)
  }
  
  if (length(A)==3){
    A <- matrix(A, nrow=1)
  }
  
  # check that sizes of A and M are compatible
  if (nrow(A)!=nrow(M)){
  n <- min(c(nrow(A),nrow(M)))
  A <- A[c(1:n),]
  M <- M[c(1:n),]
  }
  
  if (fs>10){
  nf <- round(4*fs/fc)
  if (nrow(A)>nf){
  M = fir_nodelay(M,nf,fc/(fs/2))
  A = fir_nodelay(A,nf,fc/(fs/2)) 
  }
  }
  
  # compute field intensity of first input argument
  fstr <- sqrt(apply(X=A^2, MARGIN=1,FUN=sum))
  fstr <- matrix(fstr, ncol=1)
  if (!is.null(M)){
    # compute field intensity of second input argument
    fstr2 <- sqrt(apply(X=M^2, MARGIN=1,FUN=sum))
    fstr2 <- matrix(fstr2, ncol=1)
    fstr <- cbind(fstr, fstr2)
  }
  
  if (find_incl==TRUE & !is.null(M)){
    AMprod <- matrix(apply(A*M,MARGIN=1, FUN=sum), ncol=1)
    incl <- -Re(asin(AMprod/(fstr[,1]*fstr[,2])))
  return(list(fstr=fstr,incl=incl))
  }else{
    return(fstr)
  }
  
}#end of function