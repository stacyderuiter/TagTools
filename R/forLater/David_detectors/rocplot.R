rocplot <- function(data, sampling_rate, FUN, bktime, indices, events, ntests, testint = NULL, depth = NULL, depthm = NULL) {
  dnew <- FUN(data, sampling_rate)
  if (!is.null(depth)) {
    deep <- which(depth < depthm)
    dnew[deep] <- 0
  }
  if (is.null(testint)) {
    testint <- max(dnew)/ntests
  }
  tpevents <- ((indices/sampling_rate)/bktime)
  sr <- sampling_rate
  for (k in 1:ntests) {
    if (k == 1) {
      thresh <- testint
    } else {
      if (k == ntests) {
        thresh <- max(dnew)
      }
    }
    detections <- detect(data=dnew, sr=sr, FUN=NULL, thresh = thresh, bktime = bktime, plot_peaks = FALSE)$peak_time
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
  require(ggplot2)
  ggplot((data.frame(rates)), aes(x = False_Positive_Rate, y = True_Positive_Rate)) + geom_point() + theme_bw() + theme(axis.text=element_text(size=15), axis.title=element_text(size=15,face="bold")) + geom_smooth(se = FALSE, span = 1)
}