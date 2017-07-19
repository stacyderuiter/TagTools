#' Plot sensor time series against time in a single or multi-paneled figure with linked x-axes. This is useful for comparing measurements across different sensors. The time axis is automatically displayed in seconds, minutes, hours, or days according to the span of the data.
#' 
#' @description Possible input combinations: plott(X) if X is a list, plott(X,r) if X is a list, plott(X,fsx) if X is a vector or matrix, plott(X,fsx,r) if X is a vector or matrix, plott(X,Y,.....) if X and Y and etc. are lists, plott(X,fsx,Y,fsy,.....) if X and Y and etc. are vectors or matrices.
#' @param X X, Y, etc, Lists or vectors/matrices of time series data.
#' @param fsx fsx, fsy, etc, The sampling rates in Hz for each data object. Sampling rates are not needed when the data object is a list.
#' @param r (optional) Can be used reverse the direction of the y-axis for the data object that it follows if r='r'. This is useful for plotting dive profiles which match the physical situation i.e., with greater depths lower in the display. If r is a number, it specifies the number of seconds time offset for the preceding data object. A positive value means that these data were collected later than the other objects and so should be plotted more to the right-hand side.
#' @return ax A vector of handles to the axes created.
#' @note This is a flexible plotting tool which can be used to display and explore sensor data with different sampling rates on a uniform time grid. Zooming any of the panels should cause all of the panels to zoom in or out to match the x-axis.

plott <- function(...) {
  ax <- c()
  h <- c()
  if (nargs() < 1) {
    stop("Need one input to continue")
  }
  brk <- c(0, 2e3, 2e4, 5e5) 	  	      #break points for plots in seconds, mins, hours, days
  div <- c(1, 60, 3600, 24 * 3600) 	    #corresponding time multipliers
  L <- c('s', 'min', 'hr', 'day') 	    #and xlabels
  #each data object can have one or two qualifying arguments. Scan through varargin to find the objects and their qualifiers.
  #args_container <- as.list(match.call())
  args_container <- list(...)
  fsrt <- matrix(0, length(args_container), 4) 
  X <- list()
  for (k in 1:length(args_container)) {
    x <- args_container[[k]] 
    if (is.list(x)) {
      # this input is a sensor structure
      if(!is.null(x[['fs']]) && !is.null(x[['data']])) {
        X[[length(X)+1]] <- x$data
        fs[length(X),1] <- x$fs
      } else {
        stop("sensor structure must have data and fs fields!")
      }
    } else {
      if (is.matrix(x) | is.vector(x) && (length(x) >1) ) {
        X[[length(X) + 1]] <-  x
      } else {
        if (typeof(x) == "character") {
          fsrt[length(X), 2] = (x[1] == 'r')
        } else {
          if (fsrt[length(X), 1] == 0) {
            fsrt[length(X), 1] <- x 
          } else {
            fsrt[length(X), 3] <- x
          }
        }
      }
    }
  }
  fsrt <- fsrt[1:length(X), ]
  if(is.vector(fsrt)){
    if (length(which(fsrt[1] != 0)) == 0) {
      stop("Error: sampling rate undefined for data object")
    }
  }
  else{
    if (length(which(fsrt[, 1] != 0)) == 0) {
      stop("Error: sampling rate undefined for data object")
    }
  }
  ax <- rep(0, length(X)) 
  ns <- 0 
  for (k in 1:length(X)) {
    ns <- max(ns, nrow(X[[k]]) / fsrt[k, 1] + fsrt[3])
  }
  graphics::split.screen(c(length(X), 1)) 
  for (divk in seq(from = length(brk), by = -1, to = 1)) {
    if (ns >= brk[divk]) {
      break
    }
  }
  ddiv <- div[divk]
  xlims <- c((min(fsrt[, 3]) / ddiv), ns / ddiv)
  h <- list()
  for (k in 1:length(X)) { #now we are ready to plot
    if (fsrt[k, 2] == 1) {
      matplot((((1:nrow(X[[k]])) / fsrt[k, 1] + fsrt[k, 3]) * (1 / ddiv)), X[[k]], xlim = xlims, ylim = rev(NULL))
    } else {
      matplot((((1:nrow(X[[k]])) / fsrt[k, 1] + fsrt[k, 3]) * (1 / ddiv)), X[[k]], xlim = xlims, xlab = "Time (%s)", type = "l")
    }
  }
  return(ax)
}
