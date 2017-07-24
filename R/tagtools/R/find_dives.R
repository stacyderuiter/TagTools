#' Find time cues for dives
#' 
#' This function is used to find the time cues for the start and end of either dives in a depth record or flights in an altitude record.
#' @param p A depth or altitude time series (vector) in meters.
#' @param fs The sampling rate of the sensor data in Hz (samples per second).
#' @param mindepth The threshold in meters at which to recognize a dive or flight. Dives shallow or flights lower than mindepth will be ignored.
#' @param surface (optional) The threshold in meters at which the animal is presumed to have reached the surface. Default value is 1. A smaller value can be used if the dive/altitude data are very accurate and you need to detect shallow dives/flights.
#' @param findall (optional) When 1 forces the algorithm to include incomplete dives at the start and end of the record. Default is 0 which only recognizes complete dives.
#' @return T is a structure array with size equal to the number of dives/flights found. The fields of T are: start (time in seconds of the start of each dive/flight), end (time in seconds of the start of each dive/flight), max (maximum depth/altitude reached in each dive/flight), tmax	(time in seconds at which the animal reaches the max depth/altitude). If there are n dives/flights beyond mindepth in p, then T will be a structure containing n-element vectors.
#' @export

find_dives <- function(p, fs, mindepth, surface = NULL, findall = NULL) {
  if (missing(mindepth)) {
    stop("inputs for p, fs, and mindepth are all required")
  }
  if (is.null(surface)) {
    surface <- 1          #maximum p value for a surfacing
  }
  if (is.null(findall)) {
    findall <- 0 
  }
  searchlen <- 20         #how far to look in seconds to find actual surfacing
  dpthresh <- 0.25        #vertical velocity threshold for surfacing
  dp_lp <- 0.5           #low-pass filter frequency for vertical velocity
  #find threshold crossings and surface times
  tth <- which(diff(p > mindepth) > 0)
  tsurf <- which(p < surface)
  ton <- 0 * tth
  toff <- ton 
  k <- 0 
  empty <- integer(0)
  #sort through threshold crossings to find valid dive start and end points
  for (kth in 1:length(tth)) {
    if (all(tth[kth] > toff)) {
      ks0 <- which(tsurf < tth[kth])
      ks1 <- which(tsurf > tth[kth])
      if (!missing(findall) | ((!identical(ks0, empty)) & (!identical(ks1, empty)))) {
        k <- k + 1
        if (identical(ks0, empty)) {
          ton[k] <- 1
        } else {
          ton[k] <- max(tsurf[ks0])
        }
        if (identical(ks1, empty)) {
          toff[k] <- length(p)
        } else {
          toff[k] <- min(tsurf[ks1])
        }
      }
    }
  }
  #truncate dive list to only dives with starts and stops in the record
  ton <- ton[1:k]
  toff >- toff[1:k]
  #filter vertical velocity to find actual surfacing moments
  n <- round(4 * fs / dp_lp)
  dp <- fir_nodelay(matrix(c(0, diff(p)), ncol = 1) * fs, n, dp_lp / (fs / 2))
  #for each ton, look back to find last time whale was at the surface
  #for each toff, look forward to find next time whale is at the surface
  dmax <- matrix(0, length(ton), 2)
  for (k in 1:length(ton)) {
    ind <- ton[k] + (-round(searchlen * fs):0)
    ind <- ind[which(ind > 0)]
    ki = max(which(dp[ind] < dpthresh)) 
    if (identical(ki, empty)) {
      ki <- 1
    }
    ton[k] = ind[ki] ;
    ind <- toff[k] + (0:round(searchlen * fs)) 
    ind <- ind[which(ind <= length(p))] 
    ki <- min(which(dp[ind] > -dpthresh))
    if (identical(ki, empty)) {
      ki <- 1
    }
    toff[k] <- ind[ki]
    dm <- max(p[ton[k]:toff[k]])
    km <- which.max(p[ton[k]:toff[k]])
    dmax[k, ] <- c(dm, ((ton[k] + km - 1) / fs))
  }
  #assemble output
  t0 <- cbind(ton,toff)
  t1 <- t0 / fs
  t2 <- dmax
  t <- cbind(t1, t2)
  t <- matrix(t[stats::complete.cases(t)], byrow = FALSE, ncol = 4)
  T.start <- t[, 1]
  T.end <- t[, 2]
  T.max <- t[, 3]
  T.tmax <- t[, 4]
  T <- list(start = T.start, end = T.end, max = T.max, tmax = T.tmax)
  return(T)
}