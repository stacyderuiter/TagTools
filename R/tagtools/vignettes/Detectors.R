## ---- echo=FALSE--------------------------------------------------------------
acc_test <- function(detections, events, sampling_rate, tpevents) {
  if (nargs() < 4) {
    stop("inputs for all arguments are required")
  }
  if (is.character(events)) {
    detections_acc <- list(count_hits = 0, count_false_alarms = length(detections),
                           count_misses = NA, hits_rate = 0, false_alarm_rate = 1)
  } else {
    count_hits <- 0
    count_false_alarms <- 0
    e <- as.numeric(events)
    for (j in 1:length(detections)) {
      detplus <- detections[j] <= (e + (5 * sampling_rate))
      detminus <- detections[j] >= (e - (5 * sampling_rate))
      det <- which(detplus == detminus)
      e1 <- e[detections[j] >= (e + (5 * sampling_rate))]
      e2 <- e[detections[j] <= (e - (5 * sampling_rate))]
      e <- c(e1, e2)
      if (length(det) == 1) {
        count_hits <- count_hits + 1
      } else {
        if (length(det) == 0) {
          count_false_alarms <- count_false_alarms + 1
        }
      }
    }
    count_misses <- length(events) - count_hits
    # calculate the hit rate and false alarm rate
    hits_rate <- count_hits / length(events)
    false_alarm_rate <- count_false_alarms / tpevents
    detections_acc <- list(count_hits = count_hits, 
                           count_false_alarms = count_false_alarms,
                           count_misses = count_misses, hits_rate = hits_rate,
                           false_alarm_rate = false_alarm_rate)
  }
  return(detections_acc)
}

## ---- echo=FALSE--------------------------------------------------------------
detect <- function(data, sr, FUN = NULL, thresh = NULL, bktime = NULL, plot_peaks = NULL, ...) {
  if (missing(data) | missing(sr)) {
    stop("inputs for data and sr are both required")
  }
  
  # apply function specified in the inputs to data
  if (!is.null(FUN)) {
    dnew <- FUN(data,  ...)
  } else {
    dnew <- data
  }
  # set default threshold level
  if (is.null(thresh) == TRUE) {
    thresh <- stats::quantile(dnew, c(0.99))
  }
  
  if (is.null(plot_peaks) == TRUE) {
    plot_peaks <- TRUE
  }
  
  if (thresh > max(dnew)) {
    stop("Threshold level is greater the the maximum of the signal. No peaks are detected.")
  }
  
  # create matrix for data and corresponding sampling number
  d1 <- matrix(c(1:length(dnew)), ncol = 1)
  d2 <- matrix(dnew, ncol = 1)
  d <- cbind(d1, d2)
  
  # determine peaks that are above the threshold
  pt <- d[, 2] >= thresh
  pk <- d[pt, ]
  
  # is there more than one peak?
  if (length(pk) == 2) {
    start_time <- pk[1]
    end_time <- pk[1]
    peak_time <- pk[1]
    peak_max <- pk[2]
    thresh <- thresh
    bktime <- as.numeric(bktime)
  } else {
    # set default blanking time
    if (is.null(bktime)) {
      dpk <- diff(pk[, 1])
      bktime <- stats::quantile(dpk, c(.8))
    } else {
      bktime <- as.numeric(bktime * sr)
    }
    
    # determine start times for each peak
    dt <- diff(pk[, 1])
    pkst <- c(1, (dt >= bktime))
    start_time <- pk[(pkst == 1), 1]
    
    # determine the end times for each peak
    if (sum(pkst) == 1) {
      if (dnew[length(dnew)] > thresh) {
        start_time <- c()
        end_time <- c()
      } else {
        if (dnew[length(dnew)] <= thresh) {
          end_time <- pk[nrow(pk), 1]
        }
      }
    }
    if (sum(pkst) > 1) {
      if (pkst[length(pkst)] == 0) {
        if (dnew[length(dnew)] <= thresh) {
          ending <- which(pkst == 1) - 1
          end_time <- c(pk[ending[2:length(ending)], 1], pk[nrow(pk), 1])
        } else {
          if (dnew[length(dnew)] > thresh) {
            ending <- which(pkst == 1) - 1
            end_time <- c(pk[ending[2:length(ending)], 1], pk[nrow(pk), 1])
            # if the last peak does not end before the end of recording, the peak is removed from analysis
            start_time <- start_time[1:length(start_time - 1)]
            end_time <- end_time[1:length(end_time - 1)]
          }
        } 
      } else {
        if (pkst[length(pkst)] == 1) {
          ending <- which(pkst == 1) - 1
          end_time <- c(pk[ending[2:length(ending)], 1], pk[nrow(pk), 1])
        }
      }
    }
    
    # determine the time and maximum of each peak
    peak_time <- matrix(0, length(start_time), 1)
    peak_max <- matrix(0, length(start_time), 1)
    if (is.null(start_time) & is.null(end_time)) {
      peak_time <- c()
      peak_max <- c()
    } else {
      for (a in 1:length(start_time)) {
        td = dnew[start_time[a]:end_time[a]]
        m <- max(td)
        mindex <- which.max(td)
        peak_time[a] <- mindex + start_time[a] - 1
        peak_max[a] <- m
      }
    }  
    
    bktime <- bktime / sr
  }
  
  # create a list of start times, end times, peak times, peak maxima, thresh, and bktime
  peaks <- list(start_time = start_time, end_time = end_time, 
                peak_time = peak_time, peak_max = peak_max, 
                thresh = thresh, bktime = bktime)
  
  
  if (plot_peaks == TRUE) {
    # create a plot which allows for the thresh and bktime to be manipulated
    graphics::plot(dnew, type = "l", col = "blue", xlim = c(0, length(dnew)), ylim = c(0, max(dnew)))
    print("GRAPH HELP: For changing only the thresh level, click once within the plot and then click finish or push escape or push escape to specify the y-value at which your new thresh level will be. For changing just the bktime value, click twice within the plot and then click finish or push escape to specify the length for which your bktime will be. To change both the bktime and the thresh, click three times within the plot: the first click will change the thresh level, the second and third clicks will change the bktime. To return your results without changing the thresh and bktime from their default values, simply click finish or push escape.")
    x <- peaks$peak_time
    y <- peaks$peak_max
    graphics::par(new = TRUE)
    graphics::plot(x, y, pch = 9, type = "p", col = "orange", xlim = c(0, length(dnew)), ylim = c(0, max(dnew)), cex = .75)
    graphics::abline(a = thresh, b = 0, col = "red", lty=2)
    pts <- graphics::locator(n = 3)
    if (length(pts$x) == 3) {
      thresh <- pts$y[1]
      bktime <- max(pts$x[2:3]) - min(pts$x[2:3])
      peaks <- detect_peaks(dnew, sr, FUN = NULL, 
                            thresh, bktime, plot_peaks = FALSE)
    } else {
      if (length(pts$x) == 1) {
        thresh <- pts$y[1]
        peaks <- detect_peaks(dnew, sr, FUN = NULL, 
                              thresh = thresh, plot_peaks = FALSE)
      } else {
        if (length(pts$x) == 2) {
          bktime <- max(pts$x) - min(pts$x)
          peaks <- detect_peaks(dnew, sr, FUN = NULL, bktime = bktime, 
                                plot_peaks = FALSE)
        } else {
          peaks <- detect_peaks(dnew, sr, FUN = NULL, thresh, bktime, 
                                plot_peaks = FALSE)
        }
      }
    }
    graphics::plot(dnew, type = "l", col = "blue", 
                   xlim = c(0, length(dnew)), ylim = c(0, max(dnew)))
    x <- peaks$peak_time
    y <- peaks$peak_max
    graphics::par(new = TRUE)
    graphics::plot(x, y, pch = 9, type = "p", col = "orange", 
                   xlim = c(0, length(dnew)), ylim = c(0, max(dnew)), 
                   cex = .75)
    graphics::abline(a = thresh, b = 0, col = "red", lty=2)
  } else {
    return(peaks)
  }
  return(peaks)
}

## ---- echo=FALSE--------------------------------------------------------------
rates_test <- function(data, sampling_rate, FUN, bktime, 
                       indices, events, ntests, testint = NULL, 
                       depth = NULL, depthm = NULL) {
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
    detections <- detect(data=dnew, sr=sr, FUN=NULL, thresh = thresh, 
                         bktime = bktime, plot_peaks = FALSE)$peak_time
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

## ---- echo=FALSE, results='hide', message=FALSE, warning=FALSE----------------
library(readr)
bw11_210a_tagdata <- readr::read_csv('http://sldr.netlify.com/data/bw11_210a_tagdata.csv')
Aw <- cbind(bw11_210a_tagdata$Awx, bw11_210a_tagdata$Awy, bw11_210a_tagdata$Awz)
sampling_rate <- bw11_210a_tagdata$fs[1]  

## -----------------------------------------------------------------------------
head(Aw, 5)
head(sampling_rate)

## ---- fig.width=7, fig.height=5, message=FALSE--------------------------------
library(tagtools)
jerk <- njerk(A = Aw, sampling_rate = sampling_rate)
X <- list(jerk = jerk)
plott(X, 5, line_colors = "blue") 

## -----------------------------------------------------------------------------
jerk <- jerk[1:63000]

## ---- results='hide'----------------------------------------------------------
sr <- bw11_210a_tagdata$fs[1]  

## ---- message = FALSE, eval = FALSE-------------------------------------------
#  detect_peaks(data = jerk, sr = sr, FUN = NULL,
#                   thresh = NULL, bktime = NULL, plot_peaks = TRUE)

## ---- include = FALSE---------------------------------------------------------
peaks <- detect_peaks(data = Aw[1:63000, ], sr = sr, FUN = njerk, thresh = NULL, bktime = NULL, plot_peaks = TRUE, sampling_rate = sampling_rate)

## ---- echo = FALSE, fig.width=7, fig.height=5---------------------------------
X <- list(jerk = jerk)
plott(X, sampling_rate, line_colors = "blue")

## ---- message = FALSE, eval = FALSE-------------------------------------------
#  detect_peaks(data = Aw[1:63000, ], sr = sr, FUN = "njerk",
#                  thresh = NULL, bktime = NULL, plot_peaks = TRUE, sampling_rate = sampling_rate)

## ---- eval = FALSE------------------------------------------------------------
#  peaks <- detect_peaks(data = jerk, sr = sr, FUN = NULL,
#                            thresh = 0.874, bktime = 50, plot_peaks = TRUE)

## ---- echo = FALSE, fig.width=7, fig.height=5---------------------------------
plott(X, sampling_rate, line_colors = "blue")

## -----------------------------------------------------------------------------
str(peaks)

## -----------------------------------------------------------------------------
tpevents <- (63000 / sampling_rate) / 30

## ---- message=FALSE, echo=FALSE, results='hide'-------------------------------
events <- readr::read_csv('http://sldr.netlify.com/data/bw11_210aLungeTimes.csv')
events <- events$Ltimes * sampling_rate

## -----------------------------------------------------------------------------
head(events, 8)

## ---- echo=FALSE, message=FALSE, fig.width=7, fig.height=5--------------------
rates <- rates_test(data = Aw[1:63000, ], sampling_rate = 5, FUN = njerk, bktime = 30, indices = 63000, events = events, ntests = (1.75 / 0.05), testint = 0.05)
library(ggplot2)
ggplot2::ggplot((data.frame(rates)), aes(x = False_Positive_Rate, y = True_Positive_Rate)) + ggplot2::geom_point() + ggplot2::theme_bw() + ggplot2::theme(axis.text=element_text(size=15), axis.title=element_text(size=15,face="bold")) + ggplot2::geom_smooth(se = FALSE, span = 0.6)
head(rates, 37)

## -----------------------------------------------------------------------------
rates[5:14, 1] / rates[5:14, 2]

## ---- fig.width=7, fig.height=5-----------------------------------------------
peaks <- detect_peaks(data = Aw[1:63000, ], sr = 5, FUN = njerk, thresh = 0.65, bktime = 30, plot_peaks = FALSE, sampling_rate = 5)
str(peaks)

## ---- fig.width=7, fig.height=5-----------------------------------------------
depth <- bw11_210a_tagdata$depth
cropped_depth <- depth[1:63000]
klunge <- (((events / 5) / 60) / 60)
dettimes <- (((peaks$peak_time / 5) / 60) / 60)
depthevents <- cropped_depth[events]
depthdetections <- cropped_depth[peaks$peak_time]
Dive_Profile <- list(Dive_Profile = cropped_depth)
plott(Dive_Profile, 5, r = TRUE, par_opts = list(mar=c(1,5,0,0), oma=c(2,0,2,1), las=1, lwd=1, cex = 1))
graphics::points(x = klunge, y = depthevents, col = "red", cex = 1.4, pch = 16)
graphics::points(x = dettimes, y = depthdetections, col = "gold", cex = 1.4, pch = "+:")

