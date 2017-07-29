#' Determines the accuracy of automated event detections
#' 
#' This function is used to determine the number of true positives, false negatives, and false positives automatically detected events from tagtools (i.e. detect_peak.m) and known event occurences from manual determination methods. It also calculates the hits and false_alarms rates. This is useful for plotting ROC curves.
#' @param detections A vector containing the know times (indices from start of tag recording) at which an automatically detected event was determined to have taken place.
#' @param events A vector containing the known times (indices from start of tag recording) at which an event was known to have taken place from manual determination methods.
#' @param sampling_rate The sampling rate in Hz of the detections and events data
#' @param tpevents The number of total possible events that could have occurred throughout the time of the tag recording. Can be determined by the equation: (indices / sampling_rate) / (necessary time between events)
#' @return A list with 5 elements:
#' \itemize{
#'  \item{\strong{count_hits: }} The number of true positive detectinos
#'  \item{\strong{r: }} The number of false positive detections
#'  \item{\strong{r: }} The number of missed detections
#'  \item{\strong{r: }} The rate of true positive detections
#'  \item{\strong{r: }} The rate of false positive detections
#' }

acc_test <- function(detections, events, sampling_rate, tpevents) {
  if (nargs() < 4) {
    stop("inputs for all arguments are required")
  }
  events <- events * 5
  #determine the number of hits, false alarms, and misses
  count_hits <- 0
  count_false_alarms <- 0
  for (j in 1:length(detections)) {
    detplus <- detections[j] <= (events + (10 * sampling_rate))
    detminus <- detections[j] >= (events - (10 * sampling_rate))
    det <- which(detplus == detminus)
    if (length(det) == 1) {
      count_hits <- count_hits + 1
    } else {
      if (length(det) == 0) {
        count_false_alarms <- count_false_alarms + 1
      }
    }
  }
  count_misses <- nrow(events) - count_hits
  #calculate the hit rate and false alarm rate
  hits_rate <- count_hits / nrow(events)
  false_alarm_rate <- count_false_alarms / tpevents
  detections_acc <- list(count_hits = count_hits, count_false_alarms = count_false_alarms,
                            count_misses = count_misses, hits_rate = hits_rate, false_alarm_rate = false_alarm_rate)
  return(detections_acc)
}