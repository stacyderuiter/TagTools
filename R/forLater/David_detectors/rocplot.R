rocplot <- function(data, sampling_rate, FUN, bktime, indices, events, ntests, testint) {
  tpevents <- ((indices/sampling_rate)/bktime)
  sr <- sampling_rate
  for (k in 1:ntests) {
    if (k == 1) {
      thresh <- testint
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
  pts <- pts[order(pts[, 1]), ]
  require(ggplot2)
  ggplot((data.frame(pts)), aes(x = False_Positive_Rate, y = True_Positive_Rate)) + geom_point() + theme_bw() + theme(axis.text=element_text(size=15), axis.title=element_text(size=20,face="bold")) + geom_smooth(se = FALSE, span = 0.6)
}