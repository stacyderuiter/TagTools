 #The following is an attempt to translate Mark Johnson's finddives.m matlab script, 
#from the dtag tool box, to an R script.
#note that I made no effort to vectorize or use apply...just changed matlab to R code keeping the same general structure.
# SDR, March 2014
# function    T = finddives(p,fs,th,surface,findall)
# %
# %    T = finddives(p,fs,[th,surface,findall])
# %    Find time cues for the edges of dives.
# %    p is the depth time series in meters, sampled at fs Hz.
# %    th is the threshold in m at which to recognize a dive - dives
# %    more shallow than th will be ignored. The default value for th is 10m.
# %    surface is the depth in meters at which it is considered that the
# %    animal has reached the surface. Default value is 1.
# %    findall = 1 forces the algorithm to include incomplete dives at the
# %    start and end of the record. Default is 0
# %    T is the matrix of cues with columns:
#   %    [start_cue end_cue max_depth cue_at_max_depth mean_depth mean_compression]
# %
# %    If there are n dives deeper than th in p, then T will be an nx6 matrix. Partial
# %    dives at the beginning or end of the recording will be ignored - only dives that
# %    start and end at the surface will appear in T. 
# %
# % Copyright (C) 2005-2013, Mark Johnson
# % This is free software: you can redistribute it and/or modify it under the
# % terms of the GNU General Public License as published by the Free Software 
# % Foundation, either version 3 of the License, or any later version.
# % See <http://www.gnu.org/licenses/>.
# %
# % This software is distributed in the hope that it will be useful, but 
# % WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# % or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License 
# % for more details.
# %
# % markjohnson@st-andrews.ac.uk
# % last modified: 27 Jan 2013 - replaced filtfilt with fir_nodelay

finddives <- function(p,fs,th,surface,findall){
  #input checking
  if (missing(p) | missing(fs)) warning('too few input arguments to finddives!')
  #default value for threshold minimum depth to define dives = 10m
  if (missing(th) | is.na(th) | is.null(th)) th <- 10 
  #default value for surfacing at the end of the dive is depth = 1m
  if (missing(surface) | is.na(surface) | is.null(surface)) surface <- 1
  #default is NOT to find partial dives at start/end of recording
  if (missing(findall) | sum(is.na(findall))>=1 | sum(is.null(findall))>=1 ) findall <- 0
  if (fs > 1000) warning(paste('Suspicious fs of ', as.char(round(fs)), 'Hz - check...', sep=""))

  #define constants
  searchlen <- 20        #how far to look in seconds to find actual surfacing
  dpthresh <- 0.25       # vertical velocity threshold for surfacing
  dp_lp <- 0.5           # low-pass filter frequency for vertical velocity

  #first remove any NaN at the start of p
  #(these are used to mask bad data points and only occur in a few data sets)
  kgood <- which(!is.na(p))
  p = p[kgood] 
  tgood = (min(kgood)-1)/fs
  
  #find threshold crossings and surface times
  tth <- which(diff(p>th)>0) 
  tsurf <- which(p<surface) 
  ton <- 0*tth 
  toff <- ton 
  k <- 0 ;
  
  #sort through threshold crossings to find valid dive start and end points
  for (kth in c(1:length(tth))){
  if (all(tth[kth]>toff)){
  ks0 <- which(tsurf<tth[kth])
  ks1 <- which(tsurf>tth[kth])
  if (findall || (length(ks0)>0 && length(ks1)>0) ){
  k <- k+1 
  ifelse(length(ks0)==0,
         ton[k] <- 1, 
         ton[k] <- max(tsurf[ks0]))
  ifelse(length(ks1)==0,
         toff[k] <- length(p),
         toff[k] <- min(tsurf[ks1]))
  } #if findall is true, or if it's a complete dive
  } #??
  }#loop over kth (threshold crossings)
  
  #truncate dive list to only dives with starts and stops in the record
  ton = ton[c(1:k)]
  toff = toff[c(1:k)]

  #filter vertical velocity to find actual surfacing moments
  n = round(4*fs/dp_lp)
  dp = fir_nodelay( x=c(0,diff(p))*fs, n=n, fp=dp_lp/(fs/2) )$y
  
  #for each ton, look back to find last time whale was at the surface
  #for each toff, look forward to find next time whale is at the surface
  dmax <- matrix(data=0,nrow=length(ton),ncol=2)
  for (k in c(1:length(ton))) {
    ind <- ton[k] + seq(from=-round(searchlen*fs), to=0) 
    ind <- ind[ind>0]
    ki <- suppressWarnings(max(which(dp[ind]<dpthresh))) 
    if (is.infinite(ki)) ki <- 1 #ki will be -Inf if no entries in dp are <dpthresh
    ton[k] <- ind[ki]
    ind <- toff[k] + seq(from=0, to=round(searchlen*fs))
    ind <- ind[which(ind<=length(p))]
    ki <- suppressWarnings(min(which(dp[ind]>-dpthresh)))
    if (is.infinite(ki)) ki<-1 #ki will be +Inf if no entries in dp are > -dpthresh
    toff[k] = ind[ki]
    km <- which.max(p[ton[k]:toff[k]])
    dm <- p[km + ton[k]]
    dmax[k,] = c(dm,  (ton[k]+km-1)/fs+tgood)   
  }
  
  #measure & assemble dive statistics
  dives <- data.frame(start.cue=ton/fs+tgood, 
                  end.cue=toff/fs+tgood,
                  max.depth=dmax[,1],
                  max.depth.cue=dmax[,2])
  for (k in c(1:length(ton))){
  pdive = p[c(ton[k]:toff[k])] ;
  dives$mean.depth[k] = mean(pdive) ;
  dives$mean.comp[k] = mean((1+0.1*pdive)^(-1))
  }
  return(dives)
}#end of finddives function









