#' Find time cues for dives
#' 
#' This function is used to find the time cues for the start and end of either dives in a depth record or flights in an altitude record.
#' @param p A depth or altitude time series (a sensor data list or  a vector) in meters.
#' @param sampling_rate The sampling rate of the sensor data in Hz (samples per second).
#' @param mindepth The threshold in meters at which to recognize a dive or flight. Dives shallow or flights lower than mindepth will be ignored.
#' @param surface (optional) The threshold in meters at which the animal is presumed to have reached the surface. Default value is 1. A smaller value can be used if the dive/altitude data are very accurate and you need to detect shallow dives/flights.
#' @param findall (optional) When 1 forces the algorithm to include incomplete dives at the start and end of the record. Default is 0 which only recognizes complete dives.
#' @return T is a data frame with one row for each dive/flight found. The columns of T are: start (time in seconds of the start of each dive/flight), end (time in seconds of the start of each dive/flight), max (maximum depth/altitude reached in each dive/flight), tmax	(time in seconds at which the animal reaches the max depth/altitude). 
#' @export
#' @examples 
#' BW <- beaked_whale
#' T <- find_dives(p = BW$P$data, sampling_rate = BW$P$sampling_rate, mindepth = 5, surface = 2, findall = NULL)

find_dives <- function(p, mindepth, sampling_rate = NULL, surface = 1, findall = 0) {
  if (nargs() < 2) {
    stop("inputs for p and mindepth are required for find_dives()")
  }
  if (is.list(p)) {
    sampling_rate <- p$sampling_rate
    p <- p$data
    if (is.null(p)) {
      stop("p cannot be an empty vector")
    }
  } else {
    if (nrow(p) == 1) {
      p <- t(p)
    }
    if (is.null(sampling_rate)) {
      stop("sampling_rate is required when p is a vector")
    }
  }
  
  searchlen <- 20         #how far to look in seconds to find actual surfacing
  dpthresh <- 0.25        #vertical velocity threshold for surfacing
  dp_lp <- 0.5           #low-pass filter frequency for vertical velocity
  #find threshold crossings and surface times
  tth <- which(diff(p > mindepth) > 0)
  tsurf <- which(p < surface)
  
  dive_start <-  Vectorize(function(tth, tsurf, findall){
    min_st <- ifelse(findall, 1, NA)
    ton <- ifelse( sum(which(tsurf < tth)) == 0, min_st, max(tsurf[tsurf < tth]))
  }, vectorize.args = "tth")
  
  dive_end <-  Vectorize(function(tth, tsurf, p, findall){
    max_et <- ifelse(findall, length(p), NA)
    toff <- ifelse( sum(which(tsurf > tth)) == 0, max_et, min(tsurf[tsurf > tth]) )
  }, vectorize.args = "tth")
  
  T <- data.frame(tth = tth) %>%
    dplyr::mutate(ton = dive_start(tth, tsurf, findall),
                  toff = dive_end(tth, tsurf, p, findall)) %>%
    #truncate dive list to only dives with starts and stops in the record (respecting findall)
    na.omit()
  
  #filter vertical velocity to find actual surfacing moments
  n <- round(4 * sampling_rate / dp_lp)
  dp <- fir_nodelay(matrix(c(0, diff(p)), ncol = 1) * sampling_rate, n, dp_lp / (sampling_rate / 2))
  
 #WORKING HERE
  
  #for each ton, look back to find last time whale was at the surface
  #for each toff, look forward to find next time whale is at the surface
  last_surf <-  Vectorize(function(ton, dp, searchlen, sampling_rate){
    search_win <- ton + (- min(c(ton,round(searchlen * sampling_rate))):0)
    ton <- ifelse( sum(dp[search_win] < dpthresh) == 0, search_win[1], tail(search_win[dp[search_win] < dpthresh], 1))
  }, vectorize.args = "ton")
  
  next_surf <-  Vectorize(function(toff, dp, searchlen, sampling_rate, p){
    search_win <- toff + (0:min(c(length(p)-toff+1,round(searchlen * sampling_rate))))
    toff <- ifelse( sum(dp[search_win] > -dpthresh) == 0, search_win[1], head(search_win[dp[search_win] > -dpthresh],1))
  }, vectorize.args = "toff")
  
  vmax <- Vectorize(function(p, ton, toff){which.max(p[ton:toff])}, 
                    vectorize.args = c('ton', 'toff'))
  
  T <- T %>%
    mutate(ton = last_surf(ton, dp, searchlen, sampling_rate),
           toff = next_surf(toff, dp, searchlen, sampling_rate, p),
           tmax = vmax(p, ton, toff),
           max = p[ton + tmax - 1],
           start = ton/sampling_rate,
           end = toff/sampling_rate,
           tmax = (ton+tmax-1)/sampling_rate
    ) %>%
    select(start, end, max, tmax)
  
  
  return(T)
}
