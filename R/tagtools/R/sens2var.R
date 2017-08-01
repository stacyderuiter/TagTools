#'  Extract data from a sensor structure.
#'  
#'  This function extracts loose data variables from tag sensor data lists.
#'  It can also be used to check two sensor data lists for compatibility (i.e., same duration and sampling rate).
#'  
#'  @param Sx A tag sensor data data structure (for example, an entry in an animaltag object returned by \code{\link{load_nc}}).
#'  @param Sy (optional) A second tag sensor data structure. Include if you want to check two tag sensor data streams for compatibility in terms of duration and sampling rate. 
#'  @param regular (optional) Logical. Default is FALSE. Should \code{Sx} be checked to see whether it was regularly sampled?
#'  
#'  @return A list with entries:
#'  \itemize{
#'    \item{\code{X: }} {Data vector or matrix from sensor \code{Sx}, with the same units of measure and sampling rate as in \code{Sx}. NULL if \code{regular} is TRUE and the data \code{Sx} are not regularly sampled, or if \code{Sx} is not a tag sensor data list.
#'    \item{\code{Y: }} {Data vector or matrix from sensor \code{Sy}, with the same units of measure and sampling rate as in \code{Sx}.  NULL unless \code{Sy} was input, and NULL if \code{Sy} is not a tag sensor data list.}
#'    \item{\code{fs: }} {sampling rate of the sensor data in Hz (samples per second), if \code{Sx} was regularly sampled.}
#'    \item{\code{t: }} {Times (in seconds) of irregularly sampled data. The time reference (i.e., the 0 time) is with respect to the start time of the data in the sensor structure. NULL unless \code{Sx} had irregular sampling and \code{Sx} is a tag sensor data list.
#'    \item{\code{sampling: }} {NULL unless input \code{regular} is TRUE. 'regular' if sampling of \code{Sx} was regular, 'irregular' if it was irregular.}
#'  }
#'  
#'  @examples
#'  \dontrun{# regularly sampled data
#'  s2vout = sens2var(Sx)     
#'  # irregularly sampled data
#'      s2vout = sens2var(Sx)          
#'      # regularly sampled data, compatibility check
#'      s2vout = sens2var(Sx,Sy)       
#'      # irregularly sampled data, compatibility check
#'      s2vout = sens2var(Sx,Sy) 
#'      loadnc('testset3')
#'      PCAdata = sens2var(PCA)
#'      }     
#'  @note This function is provided for the compatibility checking functionality and for parallel operation with the matlab/octave tag toolkit. However, in R loose variables in the workspace are less commonly used in R, and an R function does not return multiple objects as matlab functions can. Thus, the result of "unpacking" a sensor list is the same data...stored in different and less well documented list (pretty useless).      
#'  

sens2var <- function(Sx,Sy=NULL,regular=NULL){

  rm(X, Y, fs)
  if (missing(Sx)){
    stop('sens2var requires at least 1 input - see ?sens2var')
  }

  if (!(is.list(Sx) && 'data' %in% names(Sx) && 'sampling' %in% names(Sx))){
    stop(' Error: input argument must be a sensor structure\n') ;
  }

if (is.null(Sy) && is.null(regular)){
  sampling=NULL
  Sy = NULL
}else{
  if (is.null(regular)){
    sampling=NULL
  }
}

if (!is.null(Sy)){
  if (!(is.list(Sy) || 'data' %in% names(Sy) || 'sampling' %in% names(Sy))){
    stop('Input argument Sy must be a sensor structure.\n') ;
  }
}

R = c(1,1)*grepl('regular', Sx$sampling)

if (is.null(Sy)){
  R[2] = grepl('regular', Sy$sampling) 
}

if (!is.null(regular) && regular && sum(R)<2){
  stop(' Error: input argument must be regularly sampled\n') ;
}

if (sum(R)==1){
  stop(' Error: input arguments must both be sampled in the same way (regular or irregular)\n') ;
} 

if (R(1)){
  X = Sx$data
  fs = Sx$sampling_rate
}else{
  t <- Sx$data[,1] 
  if (dim(Sx$data)[2]>1){
    X <- Sx$data[,c(2:ncol(Sx$data))]
  }else{
    X = rep(1, length(fs))
  }
}   
  
# here on for two input variables
if (R(2)){
  if (fs != Sy$sampling_rate){
    stop('inputs Sx and Sy must both have the same sampling rate.\n')
    X <- NULL
    Y <- NULL
    fs <- NULL
  }
  Y <- Sy$data
}else{
  if (ncol(Sy$data)>1){
    Y <- Sy$data[,2:ncol(Sy)]
  }else{
    Y <- matrix(1, nrow=nrow(Sy$data), ncol=1)
  }
}

if (min(nrow(X), length(X)) != min(nrow(Y), length(Y))){
  stop('Error: inputs Sx and Sy must both have the same number of samples')
  X <- NULL
  Y <- NULL
  fs <- NULL
  t <- NULL
}

return(list(X=X,Y=Y,t=t,fs=fs))
}