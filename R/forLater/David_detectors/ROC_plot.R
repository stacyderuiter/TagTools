ROC_plot <- function(data, sampling_rate, FUN, bktime, indices, events) {
  tpevents <- ((indices/sampling_rate)/bktime)
  sr <- sampling_rate
  detections1 <- detect(data, sr, FUN, thresh = .05, bktime, plot_peaks = FALSE, sampling_rate=sampling_rate)$peak_time
  detections2 <- detect(data, sr, FUN, thresh = .1, bktime, plot_peaks = FALSE, sampling_rate=sampling_rate)$peak_time
  detections3 <- detect(data, sr, FUN, thresh = .15, bktime, plot_peaks = FALSE, sampling_rate=sampling_rate)$peak_time
  detections4 <- detect(data, sr, FUN, thresh = .2, bktime, plot_peaks = FALSE, sampling_rate=sampling_rate)$peak_time
  detections5 <- detect(data, sr, FUN, thresh = .25, bktime, plot_peaks = FALSE, sampling_rate=sampling_rate)$peak_time
  detections6 <- detect(data, sr, FUN, thresh = .3, bktime, plot_peaks = FALSE, sampling_rate=sampling_rate)$peak_time
  detections7 <- detect(data, sr, FUN, thresh = .35, bktime, plot_peaks = FALSE, sampling_rate=sampling_rate)$peak_time
  detections8 <- detect(data, sr, FUN, thresh = .4, bktime, plot_peaks = FALSE, sampling_rate=sampling_rate)$peak_time
  detections9 <- detect(data, sr, FUN, thresh = .45, bktime, plot_peaks = FALSE, sampling_rate=sampling_rate)$peak_time
  detections10 <- detect(data, sr, FUN, thresh = .5, bktime, plot_peaks = FALSE, sampling_rate=sampling_rate)$peak_time
  detections11 <- detect(data, sr, FUN, thresh = .55, bktime, plot_peaks = FALSE, sampling_rate=sampling_rate)$peak_time
  detections12 <- detect(data, sr, FUN, thresh = .6, bktime, plot_peaks = FALSE, sampling_rate=sampling_rate)$peak_time
  detections13 <- detect(data, sr, FUN, thresh = .65, bktime, plot_peaks = FALSE, sampling_rate=sampling_rate)$peak_time
  detections14 <- detect(data, sr, FUN, thresh = .7, bktime, plot_peaks = FALSE, sampling_rate=sampling_rate)$peak_time
  detections15 <- detect(data, sr, FUN, thresh = .75, bktime, plot_peaks = FALSE, sampling_rate=sampling_rate)$peak_time
  detections16 <- detect(data, sr, FUN, thresh = .8, bktime, plot_peaks = FALSE, sampling_rate=sampling_rate)$peak_time
  detections17 <- detect(data, sr, FUN, thresh = .85, bktime, plot_peaks = FALSE, sampling_rate=sampling_rate)$peak_time
  detections18 <- detect(data, sr, FUN, thresh = .9, bktime, plot_peaks = FALSE, sampling_rate=sampling_rate)$peak_time
  detections19 <- detect(data, sr, FUN, thresh = .95, bktime, plot_peaks = FALSE, sampling_rate=sampling_rate)$peak_time
  hr1 <- acc_test(detections1, events, sampling_rate, tpevents)$hits_rate
  far1 <- acc_test(detections1, events, sampling_rate, tpevents)$false_alarm_rate
  hr2 <- acc_test(detections2, events, sampling_rate, tpevents)$hits_rate
  far2 <- acc_test(detections2, events, sampling_rate, tpevents)$false_alarm_rate
  hr3 <- acc_test(detections3, events, sampling_rate, tpevents)$hits_rate
  far3 <- acc_test(detections3, events, sampling_rate, tpevents)$false_alarm_rate
  hr4 <- acc_test(detections4, events, sampling_rate, tpevents)$hits_rate
  far4 <- acc_test(detections4, events, sampling_rate, tpevents)$false_alarm_rate
  hr5 <- acc_test(detections5, events, sampling_rate, tpevents)$hits_rate
  far5 <- acc_test(detections5, events, sampling_rate, tpevents)$false_alarm_rate
  hr6 <- acc_test(detections6, events, sampling_rate, tpevents)$hits_rate
  far6 <- acc_test(detections6, events, sampling_rate, tpevents)$false_alarm_rate
  hr7 <- acc_test(detections7, events, sampling_rate, tpevents)$hits_rate
  far7 <- acc_test(detections7, events, sampling_rate, tpevents)$false_alarm_rate
  hr8 <- acc_test(detections8, events, sampling_rate, tpevents)$hits_rate
  far8 <- acc_test(detections8, events, sampling_rate, tpevents)$false_alarm_rate
  hr9 <- acc_test(detections9, events, sampling_rate, tpevents)$hits_rate
  far9 <- acc_test(detections9, events, sampling_rate, tpevents)$false_alarm_rate
  hr10 <- acc_test(detections10, events, sampling_rate, tpevents)$hits_rate
  far10 <- acc_test(detections10, events, sampling_rate, tpevents)$false_alarm_rate
  hr11 <- acc_test(detections11, events, sampling_rate, tpevents)$hits_rate
  far11 <- acc_test(detections11, events, sampling_rate, tpevents)$false_alarm_rate
  hr12 <- acc_test(detections12, events, sampling_rate, tpevents)$hits_rate
  far12 <- acc_test(detections12, events, sampling_rate, tpevents)$false_alarm_rate
  hr13 <- acc_test(detections13, events, sampling_rate, tpevents)$hits_rate
  far13 <- acc_test(detections13, events, sampling_rate, tpevents)$false_alarm_rate
  hr14 <- acc_test(detections14, events, sampling_rate, tpevents)$hits_rate
  far14 <- acc_test(detections14, events, sampling_rate, tpevents)$false_alarm_rate
  hr15 <- acc_test(detections15, events, sampling_rate, tpevents)$hits_rate
  far15 <- acc_test(detections15, events, sampling_rate, tpevents)$false_alarm_rate
  hr16 <- acc_test(detections16, events, sampling_rate, tpevents)$hits_rate
  far16 <- acc_test(detections16, events, sampling_rate, tpevents)$false_alarm_rate
  hr17 <- acc_test(detections17, events, sampling_rate, tpevents)$hits_rate
  far17 <- acc_test(detections17, events, sampling_rate, tpevents)$false_alarm_rate
  hr18 <- acc_test(detections18, events, sampling_rate, tpevents)$hits_rate
  far18 <- acc_test(detections18, events, sampling_rate, tpevents)$false_alarm_rate
  hr19 <- acc_test(detections19, events, sampling_rate, tpevents)$hits_rate
  far19 <- acc_test(detections19, events, sampling_rate, tpevents)$false_alarm_rate
  False_Positive_Rate <- c(far1,far2,far3,far4,far5,far6,far7,far8,far9,far10,far11,far12,far13,far14,far15,far16,far17,far18,far19)
  True_Positive_Rate <- c(hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19)
  xy <- cbind(False_Positive_Rate,True_Positive_Rate)
  xy <- xy[order(xy[, 1]), ]
  xy <- rbind(c(0,0), xy, c(1,1))
  require(ggplot2)
  ggplot((data.frame(xy)), aes(x = False_Positive_Rate, y = True_Positive_Rate)) + geom_point() + theme_bw() + theme(axis.text=element_text(size=15), axis.title=element_text(size=20,face="bold")) + geom_smooth(se = FALSE, span = 0.6)
}