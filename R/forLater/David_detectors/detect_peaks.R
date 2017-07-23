#' This function detects peaks in data that exceed a specfied threshold and returns each peak's start time, end time, maximum peak value, and time of the maximum peak.
#' 
#' @param data A vector (of all positive values) or matrix of data to be used in peak detection. If data is a matrix, you must specify a FUN to be applied to data.
#' @param FUN A function to be applied to data before the data is run through the peak detector. Only specify the function name (i.e. "njerk"). If left blank, the data input will be immediatly passed through the peak detector. The function name must be within quotation marks.
#' @param sr The sampling rate in Hz of the date. This is the same as fs in other tagtools functions. This is used to calculate the bktime in the case that the input for bktime is missing.
#' @param thresh The threshold level above which peaks in signal are detected. Inputs must be in the same units as the signal. If the input for thresh is missing/empty, the default level is the 0.99 quantile 
#' @param bktime The specified length of time between signal values detected above the threshold value that is required for each value to be considered a separate and unique peak. If the input for bktime is missing/empty, the default level for bktime is 5 times the sampling rate (fs). This is equivalent to 5 seconds of time.
#' @param plot_peaks A conditional input. If the input is TRUE or missing, an interactive plot is generated, allowing the user to manipulate the thresh and bktime values and observe the changes in peak detection. If the input is FALSE, the interactive plot is not generated. Look to the console for help on how to use the plot upon running of this function.
#' @param ... Additional inputs to be passed to FUN
#' @return peaks A list containing vectors for the start times, end times, peak times, peak maxima, thresh, and bktime. All times are presented as the sampling value. 
#' @note As specified above under the description for the input of plot_peaks, an interactive plot can be generated, allowing the user to manipulate the thresh and bktime values and observe the changes in peak detection. The plot output is only given if the input for plot_peaks is specified as true or if the input is left missing/empty.

detect_peaks <- function(data, sr, FUN = NULL, thresh = NULL, bktime = NULL, plot_peaks = NULL, ...) {
  if (missing(data) | missing(sr)) {
    stop("inputs for data and sr are both required")
  }
  
  #apply function specified in the inputs to data
  if (!is.null(FUN)) {
    dnew <- get(FUN)(data,  ...)
  } else {
    dnew <- data
  }
  
  if (is.null(thresh) == TRUE) {
    thresh <- stats::quantile(dnew, c(0.99))
  }
  if (is.null(bktime) == TRUE) {
    bktime <- 5 * sr
  }
  if (is.null(plot_peaks) == TRUE) {
    plot_peaks <- TRUE
  }
  
  #create matrix for data and corresponding sampling number
  d1 <- matrix(c(1:length(dnew)), ncol = 1)
  d2 <- matrix(dnew, ncol = 1)
  d <- cbind(d1, d2)
  
  #determine peaks that are above the threshold
  pt <- d[, 2] >= thresh
  pk <- d[pt, ]
  
  #determine start and end times for each peak
  dt <- diff(pk[, 1])
  pkst <- c(1, (dt >= bktime))
  start <- pkst == 1
  ending <- which((pkst == 1)) - 1
  start_time <- pk[start, 1]
  end_time <- c(pk[ending[2:length(ending)], 1], pk[length(pk)])
  #if the last peak does not end before the end of recording, the peak is removed from analysis
  if (pkst[length(pkst)] == 0) {
    start_time <- start_time[1:length(start_time - 1)]
    end_time <- end_time[1:length(end_time - 1)]
  }
  
  #determine the time and maximum of each peak
  peak_time <- matrix(0, length(start_time), 1)
  peak_max <- matrix(0, length(start_time), 1)
  for (a in 1:length(start_time)) {
    td = dnew[start_time[a]:end_time[a]]
    m <- max(td)
    mindex <- which.max(td)
    peak_time[a] <- mindex + start_time[a]
    peak_max[a] <- m
  }
  
  #create a list of start times, end times, peak times, peak maxima, thresh, and bktime
  peaks <- list(start_time = start_time, end_time = end_time, peak_time = peak_time, peak_max = peak_max, thresh = thresh, bktime = bktime)
  
  
  if (plot_peaks == TRUE) {
    #create a plot which allows for the thresh and bktime to be manipulated
    plot(dnew, type = "l", col = "blue", xlim = c(0, length(dnew)), ylim = c(0, max(dnew)))
    print("GRAPH HELP: For changing only the thresh level, click once within the plot and then click finish or push escape or push escape to specify the y-value at which your new thresh level will be. For changing just the bktime value, click twice within the plot and then click finish or push escape to specify the length for which your bktime will be. To change both the bktime and the thresh, click three times within the plot: the first click will change the thresh level, the second and third clicks will change the bktime. To return your results without changing the thresh and bktime from their default values, simply click finish or push escape.")
    x <- peaks$peak_time
    y <- peaks$peak_max
    par(new = TRUE)
    plot(x, y, pch = 9, type = "p", col = "orange", xlim = c(0, length(dnew)), ylim = c(0, max(dnew)), cex = .75)
    abline(a = thresh, b = 0, col = "red", lty=2)
    pts <- graphics::locator(n = 3)
    if (length(pts$x) == 3) {
      thresh <- pts$y[1]
      bktime <- max(pts$x[2:3]) - min(pts$x[2:3])
      peaks <- detect_peaks(dnew, sr, FUN = NULL, thresh, bktime, plot_peaks = FALSE)
    } else {
      if (length(pts$x) == 1) {
        thresh <- pts$y[1]
        peaks <- detect_peaks(dnew, sr, FUN = NULL, thresh = thresh, plot_peaks = FALSE)
      } else {
        if (length(pts$x) == 2) {
          bktime <- max(pts$x) - min(pts$x)
          peaks <- detect_peaks(dnew, sr, FUN = NULL, bktime = bktime, plot_peaks = FALSE)
        } else {
          peaks <- detect_peaks(dnew, sr, FUN = NULL, thresh, bktime, plot_peaks = FALSE)
        }
      }
    }
  } else {
    plot(dnew, type = "l", col = "blue", xlim = c(0, length(dnew)), ylim = c(0, max(dnew)))
    x <- peaks$peak_time
    y <- peaks$peak_max
    par(new = TRUE)
    plot(x, y, pch = 9, type = "p", col = "orange", xlim = c(0, length(dnew)), ylim = c(0, max(dnew)), cex = .75)
    abline(a = thresh, b = 0, col = "red", lty=2)
  }
  
  return(peaks)
}