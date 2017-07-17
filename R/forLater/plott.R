plott <- function(...){
  
  #     [ax,h]=plott(X)			# X is a sensor structure
  #	   or
  #     [ax,h]=plott(X,r)			# X is a sensor structure
  #	   or
  #     [ax,h]=plott(X,fsx)		# X is a vector or matrix of sensor data
  #	   or
  #     [ax,h]=plott(X,fsx,r)	# X is a vector or matrix of sensor data
  #	   or
  #     [ax,h]=plott(X,Y,...)	# X, Y etc are sensor structures
  #	   or
  #     [ax,h]=plott(X,fsx,Y,fsy,...)	# X, Y etc are vectors or matrices of sensor data
  #     Plot sensor time series against time in a single or multi-paneled figure with linked
  #	   x-axes. This is useful for comparing measurements across different sensors. The
  #		time axis is automatically displayed in seconds, minutes, hours, or days according
  #		to the span of the data.
  #
  #	   Inputs:
  #		X, Y, etc, are sensor structures or vectors/matrices of time series data.
  #		fsx, fsy, etc, are the sampling rates in Hz for each data object. Sampling rates
  #		 are not needed when the data object is a sensor structure.
  #		r is an optional argument which can be used reverse the direction of the y-axis 
  #		 for the data object that it follows if r='r'. This is useful for plotting dive 
  #		 profiles which match the physical situation i.e., with greater depths lower in 
  #	    the display. If r is a number, it specifies the number of seconds time offset 
  #		 for the preceding data object. A positive value means that these data were collected
  #		 later than the other objects and so should be plotted more to the right-hand side.
  #
  #		Returns:
  #   	ax is a vector of handles to the axes created.
  #		h is a cell array of vectors of handles to the lines plotted. There is a cell of
  #		 handles for each axis.
  #
  #		This is a flexible plotting tool which can be used to display and explore sensor
  #		data with different sampling rates on a uniform time grid. Zooming any of the
  #	   panels should cause all of the panels to zoom in or out to match the x-axis.
  #
  #		Example:
  #		 loadncdf('testdata1');
  #		 plott(P,'r',A,M)				# plot depth, acceleration and magnetometer
  #
  #     Valid: Matlab, Octave
  #     markjohnson@st-andrews.ac.uk
  #     Last modified: 8 June 2017
  
  ax<-c()
  h<-c()
  if(missing(varagin)){
    stop("Need one input to continue")
  }
  
  brk <- c(0,2e3,2e4,5e5) 		# break points for plots in seconds, mins, hours, days
  div <- c(1,60,3600,24*3600) 	# corresponding time multipliers
  L <- c('s','min','hr','day') 	# and xlabels
  
  # each data object can have one or two qualifying arguments. Scan through varargin
  # to find the objects and their qualifiers.
  args_container <- as.list(match.call())
  fsrt <- matrix(0,length(args_container),4) 
  X <- list()
  for (k in 2:length(args_container)){
    x <- args_container[[k]] 
    if (is.list(x)){
      # this input is a sensor structure
      if(is.null(x[['fs']]) && is.null(x[['data']])){
        X[[length(x)+1]] <- x$data
        fs[length(X),1] <- x$fs
      }
      else{
        stop("sensor structure must have data and fs fields!")
      }
    }
    else{
      if(is.matrix(x)|| is.vector(x)){
        X[[length(x)+1]] <-  x
      }
      else{
        if (typeof(x) == "character"){
          fsrt[length(X),2] = (x[1]=='r') ;
        }
        else{
          if(fsrt[length(X),1] == 0){
            fsrt[length(X),1] <- x 
          }
          else{
            fsrt[length(X),3] <- x
          }
        }
      }
    }
  }
  
  
  
  fsrt <- fsrt[1:length(X), ]
  if(which(fsrt[,1] !=0) == 0){
    stop('Error: sampling rate undefined for data object %d\n')
  }
  
  ax <- reps(0,length(X)) 
  ns <- 0 
  for (k in 1:length(X)){
    #ax[k] = subplot(length(X),1,k) 
    ns = max(ns,nrow(X[[k]])/fsrt[k,1]+fsrt[3])
  }
  
  for(divk in seq(from = length(brk), by = -1, to= 1)) 
    if (ns>=brk[divk]){
      break
    }
  ddiv <- div[divk]
  xlims <- c(min(fsrt[,3])/ddiv, ns/ddiv)
  h <- list()
  for(k in 1:length(X))		# now we are ready to plot
  {
    axis(ax[k]) 
    h[[k]]=plot(((1:size(X[[k]],1))/fsrt(k,1)+fsrt(k,3))*(1/ddiv),X[[k]])
    set(ax(k),'XLim',xlims)
    if(fsrt[k,2]==1){
      set(ax(k),'YDir','reverse')
    }
    
  }
  
  xlab = sprintf('Time (%s)',L[[divk]]) ;
  xlabel(ax(end),xlab) ;
  linkaxes(ax,'x')
  return(ax,h)
}
