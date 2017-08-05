#' Plot tag data time series
#' 
#' Plot time series in a single or multi-paneled figure. This is useful, for example, for comparing measurements across different sensors in an animaltag data object. The time axis is automatically displayed in seconds, minutes, hours, or days according to the span of the data.
#' 
#' If the input data X is an \code{animaltag} object, then all sensor variables in the object will be plotted. To plot only selected sensors from the \code{animaltag} object \code{my_tag}, for example, the input X=list(my_tag$A, my_tag$M) would plot just the accelerometer and magnetometer data. If possible, the plot will have 
#' 
#' @param X List whose elements are either lists (containing data and metadata) or vectors/matrices of time series data. See details.
#' @param fsx (Optional) A numeric vector whose length matches the number of sensor data streams (list elements) in X. (If shorter, \code{fsx} will be recycled to the appropriate length). \code{fsx} gives the sampling rate in Hz for each data object. Sampling rates are not needed when the data object(s) \code{X} are list(s) that contain sampling rate information -- and beware, because \code{fsx} (if given) will override sensor metadata.
#' @param r (Optional) Logical. Should the direction of the y-axis be flipped? Default is FALSE. If \code{r} is of length one (or shorter than the number of sensor data streams in X) it will be recycled to match the number of sensor data streams.data object that it follows if r='r'. Reversed y-axes are useful, for example, for plotting dive profiles which match the physical situation (with greater depths lower in the display). If r is a number, it specifies the number of seconds time offset for the preceding data object.
#' @param offset (Optional) A vector of offsets, in seconds, between the start of each sensor data stream and the start of the first one. For example, if acceleration data collection started and then depth data collection commenced 436 seconds later, then the \code{offset} for the depth data would be 436.
#' @param date_time_axis (Optional) Logical. Should the x-axis units be date-times rather than time-since-start-of-recording?  Ignored if \code{recording_start} is not provided and \code{X} does not contain metadata on recording start time. Defaults is TRUE. 
#' @param recording_start (Optional) The start time of the tag recording as a \code{\link{POSIXct}} object. If provided, the time axis will show calendar date/times; if not, it will show days/hours/minutes/seconds (as appropriate) since time 0 = the start of recording. If a character string is provided it will be coerced to POSIXct with \code{\link{as.POSIXct}}.
#' @param panel_heights (Optional) A vector of relative or absolute heights for the different panels (one entry for each sensor data stream in \code{X}). Default is equal-height panels. If \code{panel_heights} is a numeric vector, it is interpreted as relative panel heights. To specify absolute panel heights in centimeters using \code{lcm} (see help for \code{\link[graphics]{layout}}).  
#' @param panel_labels (Optional) A list of y-axis labels for the panels. Defaults to names(X).
#' @param interactive (Optional) Should an interactive figure (allowing zoom/pan/etc.) be produced? Default is FALSE. Interactive plotting requires the zoom package for its \code{\link[zoom]{zm}} function.
#' @param par_opts (Optional) A list of options to be passed to \code{\link[graphics]{par}} before plotting. Default is mar=c(1,5,0,0), oma=c(2,0,2,1), las=1, lwd=1, cex=0.8.
#' @param line_colors (Optional) A list of colors for lines for multivariate data streams (for example, if a panel plots tri-axial acceleration, it will have three lines -- their line colors will be the first three in this list). May be specified in any specification R understands for colors. Defaults to c("#000000", "#009E73", "#9ad0f3", "#0072B2", "#e79f00", "#D55E00")
#' @param ... Additional arguments to be passed to \code{\link{plot}}.
#' @return A plot of time-series data 
#' @export
#' @note This is a flexible plotting tool which can be used to display and explore sensor data with different sampling rates on a uniform time grid. 
#' @example \dontrun{
#' HS <- harbor_seal
#' list <- list(depth = HS$P$data, A = HS$A$data)
#' plott(list, HS$P$sampling_rate, r = c(TRUE, FALSE))
#' }

plott <- function(X, fsx=NULL, r=FALSE, offset=0, 
                  date_time_axis=TRUE,
                  recording_start=NULL,
                  panel_heights=rep.int(1, length(X)),
                  panel_labels=names(X), line_colors,
                  interactive=FALSE, par_opts, ...) {
  if (length(r) < length(X)){
    r <- rep.int(r, length(X))
    }
  if (missing(par_opts)){
    par_opts <- list(mar=c(1,5,0,0), oma=c(2,0,2,1), las=1, lwd=1, cex=0.8)
  }
  if (missing(line_colors)){
    line_colors <- c("#000000", "#009E73", "#9ad0f3", "#0072B2", "#e79f00", "#D55E00")
  }
  if (length(offset) < length(X)){
    offset <- rep(offset, length.out=length(X))
  }
  if ('animaltag' %in% class(X)){
    info <- X$info
    X <- X[names(X) != 'info']
  }
  
  times <- list()
  fs <- numeric(length=length(X))
  for (s in 1:length(X)){
    if (suppressWarnings(!missing(fsx) & 
                         !sum(is.null(fsx)) & 
                         !sum(is.na(fsx)))){
      if (length(fsx) < length(X)){
        fsx <- rep(fsx, length.out=length(X))
      }# end of recycling fsx to length(X)
      fs[s] <- fsx[s]
      if ('data' %in% names(X[[s]])){
        #if X[[s]] is a sensor data structure
        n_obs <- min(nrow(X[[s]]$data), length(X[[s]]$data))
      }else{
        n_obs <- min(nrow(X[[s]]), length(X[[s]]))
      }
    }else{# end of "if fsx is given"
      if (length(X[[s]]$sampling_rate)<1){
        stop('If X does not contain sensor data lists (with sampling_rate entry), then fsx must be provided.')
      }else{
        fs[s] <- X[[s]]$sampling_rate
      }
      n_obs <- min(nrow(X[[s]]$data), length(X[[s]]$data))
    }
      times[[s]] <- c(-1+(1:n_obs))/fs[s] + offset[s]
  }# end loop over sensor streams to get times vectors
  x_lim <- range(sapply(times, range, na.rm=TRUE), na.rm=TRUE)
  
  # if recording_start is given or available, 
  # then use date/time objects
  # ==============================================================
  if (date_time_axis){
    if (exists('info')){
      recording_start <- info$dephist_device_datetime_start
    }
    if (class(recording_start)=='character'){
      # try to coerce recording start time to POSIX if needed
      recording_start <- as.POSIXct(recording_start, tz='GMT')
    }
    if (sum(grepl('POSIX', class(recording_start)))){
      times <- lapply(times, function(x, rs) lubridate::seconds(x) +
                      rs, rs=recording_start)
      x_lim <- recording_start + lubridate::seconds(x_lim)
    }else{
      # not enough info for date_time_axis
      date_time_axis=FALSE
    }
  }
  
  # adjust time axis units and get x axis label
  # ======================================================
  brk <- data.frame(secs=c(0,2e3,2e4,5e5)) # break points for plots in seconds, mins, hours, days
  brk$units <- c('Time (sec.)', 'Time (min.)', 'Time (hours)', 'Time (days)')
  brk$div <- c(1, 60, 3600, 24*3600) #divide time in sec by div to get new units
  
  if (sum(grepl('POSIX', class(times[[1]])))){
    x_lab <- 'Time'
  }else{
    t_ix <- match(1, max(x_lim) < brk$secs)
    for (i in 1:length(X)){
      times[[i]] <- times[[i]]/as.numeric(brk[t_ix, 'div'])
    }
    x_lim=x_lim/as.numeric(brk[t_ix, 'div'])
    x_lab <- as.character(brk[t_ix,'units'])
  }

  # set up plot layout
  # ===============================================================
  graphics::layout(matrix(c(1:length(X)), ncol=1),
         widths=rep.int(1, length(X)), 
         heights=panel_heights)
  graphics::par(par_opts)
  
  # draw plot
  # ===============================================================
  for (i in 1:length(X)){
    # get data for this sensor stream -- may be a vector or matrix
    # =============================================================
    data_i <- X[[i]]
    if (is.list(data_i)) {data_i <- data_i$data} 
    #if data is univariate
    y_lim <- 1.1*range(data_i, na.rm=TRUE)
    if (r[i]){
      y_lim <- c(y_lim[2], y_lim[1])
    }
    if (!is.matrix(data_i)){
        y_data <- data_i
      }else{
        y_data <- data_i[,1]
      }
    graphics::plot(x=times[[i]], y=y_data, ylab=panel_labels[i],
           xaxt="n", xlim=x_lim, type='l', ylim=y_lim,
           col=line_colors[1])
      draw_axis(side=1, x=times[[i]], 
                date_time=sum(grepl('POSIX', class(times[[i]]))),
                last_panel=(i == length(X)))
    if (is.matrix(data_i)){
      if (dim(data_i)[2]>1){
      for (c in 2:ncol(data_i)){
        graphics::lines(x=times[[i]], y=data_i[,c], col=line_colors[c])
      }
    }}
  }
  graphics::mtext(x_lab, side=1, line=2)
  
if (interactive){
  zoom::zm()
}
}

