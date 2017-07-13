#' This function detects peaks in jerk data that exceed a specfied threshold and returns each peak's start time, end time, maximum jerk value, and time of the maximum jerk.
#' 
#' @param A The acceleration matrix with columns [ax ay az]. Acceleration can be in any consistent unit (e.g. g or m/s^2). This is used to calculate the jerk using n_jerk().
#' @param fs The sampling rate in Hz of the acceleration signals. This is used to calculate the bktime in the case that the input for bktime is missing.
#' @param thresh The threshold level above which peaks in the jerk signal are detected. If the input for thresh is missing/empty, the default level is the 0.99 quantile 
#' @param bktime The specified length of time between jerk values detected above the threshold value that is required for each value to be considered a separate and unique peak. If the input for bktime is missing/empty, the default level for bktime is 5 times the sampling rate (fs). This is equivalent to 5 seconds of time.
#' @param plot_jerk A conditional input. If the input is TRUE or missing, an interactive plot is generated, allowing the user to manipulate the thresh and bktime values and observe the changes in peak detection. If the input is FALSE, the interactive plot is not generated.
#' @return peaks A list containing vectors for the start times, end times, peak times, and peak maxima. All times are presented as the sampling value. Peak maxima are presented in the same units as A. If A is in m/s^2, the peak maxima have units of m/s^3. If the units of A are in g, the peak maxima have unit g/s.
#' @note As specified above under the description for the input of plot, an interactive plot can be generated, allowing the user to manipulate the thresh and bktime values and observe the changes in peak detection. The plot output is only given if the input for plot is specified as true or if the input is left missing/empty.

find_peaks <- function(A, fs, thresh = NULL, bktime = NULL, plot_jerk = NULL) {
  if (missing(A) | missing(fs)) {
    stop("inputs for A and fs are both required")
  }
  
  #calculate jerk of A
  j <- n_jerk(A, fs)
  
  if (is.null(thresh) == TRUE) {
    thresh <- stats::quantile(j, c(0.99))
  }
  if (is.null(bktime) == TRUE) {
    bktime <- 5 * fs
  }
  if (is.null(plot_jerk) == TRUE) {
    plot_jerk <- TRUE
  }
  
  #create matrix for jerk and corresponding sampling number
  jerk1 <- matrix(c(1:length(j)), ncol = 1)
  jerk2 <- matrix(j, ncol = 1)
  jerk <- cbind(jerk1, jerk2)
  
  #determine peaks that are above the threshold
  pt <- jerk[, 2] >= thresh
  pk <- jerk[pt, ]
  
  #determine start and end times for each peak
  dt <- diff(pk[, 1])
  pkst <- c(1, (dt >= bktime))
  start <- pkst == 1
  ending <- which((pkst == 1)) - 1
  start_time <- pk[start, 1]
  end_time <- c(pk[ending[2:length(ending)], 1], pk[length(pk)])
  #if the last peak does not end before the end of recording, the peak is
  # removed from analysis
  if (pkst[length(pkst)] == 0) {
    start_time <- start_time[1:length(start_time - 1)]
    end_time <- end_time[1:length(end_time - 1)]
  }
  
  #determine the time and maximum of each peak
  peak_time <- matrix(0, length(start_time), 1)
  peak_max <- matrix(0, length(start_time), 1)
  for (a in 1:length(start_time)) {
    tj = j[start_time[a]:end_time[a]]
    m <- max(tj)
    mindex <- which.max(tj)
    peak_time[a] <- mindex + start_time[a]
    peak_max[a] <- m
  }
  
  #create a list of start times, end times, peak times, and peak maxima
  peaks <- list(start_time = start_time, end_time = end_time, peak_time = peak_time, peak_max = peak_max)
  
  
  if (plot_jerk == TRUE) {
    #create a plot which allows for the thresh and bktime to be manipulated
    plot(j, type = "l", col = "blue", xlim = c(0, nrow(A)), ylim = c(0, max(j)))
    x <- peaks$peak_time
    y <- peaks$peak_max
    par(new = TRUE)
    plot(x, y, pch = 9, type = "p", col = "orange", xlim = c(0, nrow(A)), ylim = c(0, max(j)), cex = .75)
    pts <- graphics::locator(n = 3)
    thresh <- pts$y[1]
    bktime <- pts$x[3] - pts$x[2]
    peaks <- find_peaks(A, fs, thresh, bktime, plot_jerk = FALSE)
  } else {
    plot(j, type = "l", col = "blue", xlim = c(0, nrow(A)), ylim = c(0, max(j)))
    x <- peaks$peak_time
    y <- peaks$peak_max
    par(new = TRUE)
    plot(x, y, pch = 9, type = "p", col = "orange", xlim = c(0, nrow(A)), ylim = c(0, max(j)), cex = .75)
  }
  
  return(peaks)
}