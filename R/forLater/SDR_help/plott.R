#' Plot sensor time series against time in a single or multi-paneled figure with linked x-axes. This is useful for comparing measurements across different sensors. The time axis is automatically displayed in seconds, minutes, hours, or days according to the span of the data.
#' 
#' @description Possible input combinations: plott(X) if X is a list, plott(X,r) if X is a list, plott(X,fsx) if X is a vector or matrix, plott(X,fsx,r) if X is a vector or matrix, plott(X,Y,.....) if X and Y and etc. are lists, plott(X,fsx,Y,fsy,.....) if X and Y and etc. are vectors or matrices.
#' @param X List whose elements are either lists (containing data and metadata) or vectors/matrices of time series data.
#' @param fsx (Optional) A numeric vector whose length matches the number of sensor data streams (list elements) in X. (If shorter, \code{fsx} will be recycled to the appropriate length). \code{fsx} gives the sampling rate in Hz for each data object. Sampling rates are not needed when the data object(s) \code{X} are list(s) that contain sampling rate information.
#' @param r (Optional) Logical. Should the direction of the y-axis be flipped? Default is FALSE. If \code{r} is of length one (or shorter than the number of sensor data streams in X) it will be recycled to match the number of sensor data streams.data object that it follows if r='r'. Reversed y-axes are useful, for example, for plotting dive profiles which match the physical situation (with greater depths lower in the display). If r is a number, it specifies the number of seconds time offset for the preceding data object.
#' @param offset (Optional) A vector of offsets, in seconds, between the start of each sensor data stream and the start of the first one. For example, if acceleration data collection started and then depth data collection commenced 436 seconds later, then the \code{offset} for the depth data would be 436.
#' @param recording_start (Optional) The start time of the tag recording as a \code{\link{POSIXct}} object. If provided, the time axis will show calendar date/times; if not, it will show days/hours/minutes/seconds (as appropriate) since time 0 = the start of recording.
#' @param panel_heights (Optional) A vector of relative or absolute heights for the different panels (one entry for each sensor data stream in \code{X}). Default is equal-height panels. If \code{panel_heights} is a numeric vector, it is interpreted as relative panel heights. To specify absolute panel heights in centimeters using the \code{\link{graphics::lcm}} function, see the help for \code{\link{graphics::layout}}.  
#' @param panel_labels (Optional) A list of y-axis labels for the panels. Defaults to names(X).
#' @param interactive (Optional) UNDER DEVELOPMENT Should an interactive plotly figure (allowing zoom/pan/etc.) be produced? Default is FALSE.
#' @param par_opts (Optional) A list of options to be passed to \code{\link{graphics::par}} before plotting. Default is mar=c(1,5,0,0), oma=c(2,0,2,1), las=1, lwd=1, cex=0.8.
#' @param line_colors (Optional) A list of colors for lines for multivariate data streams (for example, if a panel plots tri-axial acceleration, it will have three lines -- their line colors will be the first three in this list). May be specified in any specification R understands for colors. Defaults to c("#000000", "#009E73", "#9ad0f3", "#0072B2", "#e79f00", "#D55E00")
#' @param ... Additional arguments to be passed to \code{\link{plot}}.
#' @return F (only if interactive is true) A plotly object corresponding to the figure produced 
#' @note This is a flexible plotting tool which can be used to display and explore sensor data with different sampling rates on a uniform time grid. 

plott <- function(X, fsx=NULL, r=FALSE, offset=0, recording_start=NULL,
                  panel_heights=rep.int(1, length(X)),
                  panel_labels=names(X), line_colors,
                  interactive=FALSE, par_opts, ...) {
  # time is time since recording start....
  # ===================================================
  if (length(r) < length(X)){
    r <- rep.int(r, length(X))
    }
  if (missing(par_opts)){
    par_opts <- list(mar=c(1,5,0,0), oma=c(2,0,2,1), las=1, lwd=1, cex=0.8)
  }
  if (missing(line_colors)){
    lcols <- c("#000000", "#009E73", "#9ad0f3", "#0072B2", "#e79f00", "#D55E00")
  }
  
  if (interactive){
    stop('Interactive plots are still under development. Please set interactive=FALSE.')
  }

  times <- list()
  fs <- list()
  for (s in 1:length(X)){
    if (!missing(fsx) & !sum(is.null(fsx)) & !sum(is.na(fsx))){
      if (length(fsx) < length(X)){
        fsx <- rep(fsx, length.out=length(X))
      }# end of recycling fsx to length(X)
      fs[s] <- fsx[s] 
    }else{# end of "if fsx is given"
      fs[s] <- X[[s]]$fs
    }
    times[[s]] <- c(1:length(X[[s]]$data))/X[[s]]$fs
  }# end loop over sensor streams to get times vectors
  x_lim <- range(sapply(times, range, na.rm=TRUE), na.rm=TRUE)
  
  # if recording_start is given, then use date/time objects
  # ==============================================================
  if (!sum(grepl('POSIX', class(recording_start)))){
    times <- lapply(times, function(x, rs) lubridate::seconds(x) +
                      rs, rs=recording_start)
    x_lim <- recording_start + lubridate::seconds(x_lim)
  }
  
  # adjust time axis units and get x axis label
  # ======================================================
  brk <- data_frame(secs=c(0,2e3,2e4,5e5)) # break points for plots in seconds, mins, hours, days
  brk$units <- c('Time (sec.)', 'Time (min.)', 'Time (hours)', 'Time (days)')
  brk$div <- c(1, 60, 3600, 24*3600) #divide time in sec by div to get new units
  
  if (sum(grepl('POSIX', class(times[[1]])))){
    x_lab <- 'Time'
  }else{
    t_ix <- match(1, max(x_lim) < brk$secs)
    for (i in 1:length(X)){
      times[[i]] <- times[[i]]/brk[t_ix, 'div']
    }
    x_lab <- brk[t_ix,'units']
  }

  # set up plot layout
  # ===============================================================
  layout(matrix(c(1:length(X)), ncol=1),
         widths=rep.int(1, length(X)), 
         heights=panel_heights)
  par(par_opts)
  
  # draw plot
  # ===============================================================
  for (i in 1:length(X)){
    # get data for this sensor stream -- may be a vector or matrix
    # =============================================================
    data_i <- X[[i]]
    if (is.list(data_i)) {data_i <- data_i$data} 
    #if data is univariate
    ylim <- 1.1*range(data_i, na.rm=TRUE)
    if (r[i]){
      y_lim <- c(y_lim[2], y_lim[1])
    }
    if (!is.matrix(data_i)){
        y_data <- data_i
      }else{
        y_data <- data_i[,1]
      }
    plot(x=times[[i]], y=y_data, ylab=panel_labels[i],
           xaxt="n", xlim=x_lim, type='l', ylim=y_lim,
           col=lcols[1])
      draw_axis(side=1, x=times[[i]], 
                date_time=sum(grepl('POSIX', class(times[[i]]))),
                last_panel=(i == length(X)))
    if (is.matrix(data_i)){
      for (c in 2:ncol(data_i)){
        lines(x=times[[i]], y=data_i[,c], col=lcols[c])
      }
    }
  }
  graphics::mtext(x_lab, side=1, line=1)
  
return(F)
}
