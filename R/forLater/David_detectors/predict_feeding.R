#' Automated detection of feeding events based from velocity data.
#' 
#' @param s The speed vector in m/s.
#' @param fs The sampling rate in Hz of the speed signal vector.
#' @return feeding_events A list of feeding event times (sec) and their respective maximum speed estimates (m/s).
#' @note Source: Thomas Doniol-Valcroze, Véronique Lesage, Janie Giard, Robert Michaud; Optimal foraging theory predicts diving and feeding strategies of the largest marine predator. Behav Ecol 2011; 22 (4): 880-888. doi: 10.1093/beheco/arr038

predict_feeding <- function(s, fs) {
  if (missing(fs)) {
    stop("Inputs for s and fs are both required")
  }
  
  #chunk s vector into sections the size of fs (one second)
  speedsec <- buffer(s, fs, 0, nodelay = TRUE)
  ssec <- matrix(0, ncol(speedsec), 1)
  for (h in 1:ncol(speedsec)) {
    ssec[h] <- mean(speedsec[, h])
  }
  
  #calculate threshold to be used in first round of filtering through s
  thresh <- stats::quantile(ssec, c(.95))
  
  #find where s is greater than the 95 percentile
  sp <- which(ssec >= thresh)
  
  #find when four consecutive seconds of s are below thresh following sp
  dsp <- which(diff(sp) >= 4)
  
  #determine mean s of all determined acceleration and deceleration periods
  st <- sp[dsp]
  md <- matrix(0, length(st), 1)
  for (i in 1:length(st)) {
    md[i] <- mean(ssec[(st[i] + 1):(st[i] + 11)])
  }
  ma <- matrix(0, length(dsp), 1)
  for (j in 1:length(dsp)) {
    if (dsp[j] == dsp[1]) {
      ma[j] <- mean(ssec[sp[1]:sp[dsp[j]]])
    } else {
      ma[j] <- mean(ssec[sp[dsp[j - 1] +1]:sp[dsp[j]]])
    }
  }
  
  #find feeding events
  feeding_times <- which((ma / md) <= 0.5)
  feeding_speeds <- ssec[feeding_times]
  
  #create list containing feeding times and their respective speeds
  feeding_events <- list(feeding_times = feeding_times, feeding_speeds = feeding_speeds)
  
  return(feeding_events)
}