rates_test <- function(data, sampling_rate, FUN, bktime, indices, events, ntests, testint) {
  tpevents <- ((indices/sampling_rate)/bktime)
  sr <- sampling_rate
  for (k in 1:ntests) {
    if (k == 1) {
      thresh <- testint
    } else {
      if (k == ntests) {
        thresh <- max(njerk(data, sampling_rate))
      }
    }
    detections <- detect(data, sr, FUN, thresh, bktime, plot_peaks = FALSE, sampling_rate=sampling_rate)$peak_time
    True_Positive_Rate <- acc_test(detections, events, sampling_rate, tpevents)$hits_rate
    False_Positive_Rate <- acc_test(detections, events, sampling_rate, tpevents)$false_alarm_rate
    thresh <- thresh + testint
    if (k == 1) {
      pts <- rbind(c(0,0), c(True_Positive_Rate,False_Positive_Rate))
    } else {
      pts <- rbind(pts, c(True_Positive_Rate,False_Positive_Rate))
    }
  }
  pts <- rbind(pts, c(1,1))
  True_Positive_Rate <- pts[, 1]
  False_Positive_Rate <- pts[, 2]
  rates <- cbind(True_Positive_Rate, False_Positive_Rate)
  return(rates)
}