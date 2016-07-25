mdist <- function(data,fs, smoothDur, overlap, consec, cumSum, expStart, expEnd, 
                  baselineStart, baselineEnd, parallel, BL.COV){
#calculate Mahalanobis distance for a multivariate time series.
#-----------------------------------------------------------
#INPUTS 
#data          A data frame or matrix with one row for each time point.  
#               Note that the Mahalanobis distance calculation should be 
#               carried out on continuous data only, so if your data contain 
#               logical, factor or character data, proceed at your own 
#               risk...errors (or at least meaningless results) will probably ensue.
#fs            The sampling rate in Hz (data should be regularly sampled). 
#               If not specified it will be assumed to be 1 Hz.
#smoothDur     The length, in minutes, of the window to use for calculation 
#               of "comparison" values. If not specified or zero, there 
#               will be no smoothing (a distance will be calculated for each data observation).
#overlap       The amount of overlap, in minutes, between consecutive "comparison" 
#               windows. smooth_dur - overlap will give the time resolution of the 
#               resulting distance time series. If not specified or zero, 
#               there will be no overlap.  Overlap will also be set to zero if 
#               smoothDur is unspecified or zero.
#consec        Logical. If consec=TRUE, then the calculated distances are between
#               consecutive windows of duration smoothDur, sliding forward over 
#               the data set by a time step of (smoothDur-overlap) minutes.  
#               If TRUE, baselineStart and baselineEnd inputs will be used to define
#               the period used to calculate the data covariance matrix. Default is consec=FALSE.  
#cumSum        Logical.  If cum_sum=TRUE, then output will be the cumulative 
#               sum of the calculated distances, rather than the distances themselves. 
#               Default is cum_sum=FALSE.
#expStart      Start times (in seconds since start of the data set) of the experimental exposure period(s).  
#expEnd        End times (in seconds since start of the data set) of the experimental exposure period(s).
#                 If either or both of exp_start and exp_end are missing, the distance will be
#                 calculated over whole dataset and full dataset will be assumed to be baseline.
#baselineStart Start time (in seconds since start of the data set) of the baseline period 
#               (the mean data values for this period will be used as the 'control' to which all 
#               "comparison" data points (or windows) will be compared. if not specified, 
#               it will be assumed to be 0 (start of record).
#baselineEnd   End time (in seconds since start of the data set) of the baseline period.  
#               If not specified, the entire data set will be used (baseline_end will 
#               be the last sampled time-point in the data set).
#parallel       logical.  run in parallel?  NOT IMPLEMENTED YET.  would only help if I figured out how to do rollapply in parallel...
#       
#OUTPUT
#D             Data frame containing results
#D$t           Times, in seconds since start of dataset, at which Mahalanobis distances are 
#               reported. If a smoothDur was applied, then the reported times will be the 
#               start times of each "comparison" window.
#D$dist        Mahalanobis distances between the specified baseline period and 
#               the specified "comparison" periods             


require(stats) #for mahalanobis
require(zoo) # for rollapply

#Input checking
#---------------------------------------
if(missing(fs)){fs <- 1}
if(missing(smoothDur)){smoothDur <- 0}
if(missing(overlap) | smoothDur == 0){overlap <- 0}
if(missing(consec)) {consec=FALSE}
if(missing(cumSum)){cumSum=FALSE}
if(missing(expStart) | missing(expEnd)){
    expStart <- na
    expEnd   <- na}
if(missing(baselineStart)){baselineStart <- 0}
if(missing(baselineEnd)){baselineEnd <- floor(nrow(data)/fs)}
if(missing(parallel)){parallel=FALSE}
if(missing(BL.COV)){BL.COV=FALSE}

############################################################
# preliminaries - conversion, preallocate space, etc.
############################################################
es <- floor(fs*expStart) + 1        #start of experimental period in samples
ee <- ceiling(fs*expEnd)            #end of experimental period in samples
bs <- floor(fs*baselineStart) + 1   #start of baseline period in samples
be <- min( ceiling(fs*baselineEnd) , nrow(data) ) #end of baseline period in samples
W<-max(1,smoothDur*fs*60)           #window length in samples
O<-overlap*fs*60                    #overlap between subsequent window, in samples
N<-ceiling(nrow(data)/(W-O))          #number of start points at which to position the window -- start points are W-O samples apart
k <- matrix(c(1:N),ncol=1)          #index vector
ss <- (k-1)*(W-O) + 1               #start times of comparison windows, in samples
ps <- ((k-1)*(W-O) + 1) + smoothDur*fs*60/2             #mid points of comparison windows, in samples (times at which distances will be reported)
t <- ps/fs                          #mid-point times in seconds
ctr <- colMeans(data[bs:be,], na.rm=T)       #mean values during baseline period
if (BL.COV){
  bcov <- cov(data[bs:be,], use="complete.obs")           #covariance matrix using all data in baseline period
}else{
  bcov <- cov(data, use="complete.obs")
}
  
#parallel computing stuff
#if(parallel=TRUE){
#require(foreach) #for plyr in parallel
#require(parallel) #for parallel
#n.cores<-detectCores()
#cl <- makeCluster(n.cores)
#}

############################################################
# Calculate distances!
############################################################
Ma <- function(d,Sx)#to use later...alternate way of calc Mdist
    #d is a row vector of pairwise differences between the things you're comparing
    #Sx is the inverse of the cov matrix
        { sum((d %*% Sx) %*% d)}


if(consec==FALSE){
        #doing the following with apply type commands means it could be executed in parallel if needed...
        comps <- rollapply(data, width = W, mean, by= W-O, by.column=TRUE, align="left", fill=NULL, partial=TRUE, na.rm=T)#rolling means, potentially with overlap
        d2 <- apply(comps, MARGIN=1, FUN=mahalanobis, cov=bcov, center=ctr, inverted=FALSE)
                }
else {
        i.bcov <- solve(bcov) #inverse of the baseline cov matrix
        ctls <- rollapply(data, width = W, mean, by= W-O, by.column=TRUE, align="left", fill=NULL, partial=TRUE, na.rm=T)#rolling means, potentially with overlap
        comps <- rbind( ctls[2:nrow(ctls),] , NA*vector(mode="numeric",length=ncol(data)) ) #compare a given control window with the following comparison window.
        pair.diffs <- as.matrix(ctls-comps)
        d2 <- apply(pair.diffs, MARGIN=1, FUN=Ma, Sx=i.bcov)
        d2 <- c(NA, d2[1:(length(d2)-1)]) #first dist should be at midpoint of first comp window
                     }

#stop cluster if working in parallel
#if(parallel=TRUE){
#stopCluster(cl)
#}

#functions return squared Mahalanobis dist so take sqrt
dist<-sqrt(d2) 

#note: should probably erase the values for partial windows and replace with NAs.  
#because the distances get bigger for partial windows, not b/c of change, but because of less averaging...
dist[t > (nrow(data)/fs - smoothDur*60)] <- NA

#Calculate cumsum of distances if requested
if(cumSum==TRUE){
  dist<-cumsum(dist)
  }#this is kind of silly. maybe it'll be more use having this in here if we decide to calculate the cumsum after a specified start time, e.g. from start of exposure...or maybe just better to do later in plotting routines.

#Ta-Da!
D <- data.frame(t,dist)
return(D)
}
