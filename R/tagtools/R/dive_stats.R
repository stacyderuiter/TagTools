#' Compute summary statistics for dives or flights
#' 
#' Given a depth/altitude profile and a series of dive/flight start and end times,
#' compute summary dive statistics. 
#' 
#' In addition to the maximum excursion and duration, \code{dive_stats} divides each excursion into three phases:
#' "to" (descent for dives, ascent for flights), "from" (ascent for dives, descent for flights), and "destination". 
#' The "destination" (bottom for dives and top for flights) 
#' phase of the excursion is identified using a "proportion of maximum depth/altitude" method,
#' whereby for example the bottom phase of a dive lasts from the first to the last time the depth exceeds a stated proportion of the maximum depth.
#' Average vertical velocity is computed for the to and from phases using a simple method: total depth/altitude change divided by total time.
#' If an angular data variable is also supplied (for example, pitch, roll or heading),
#' then the circular mean (computed via \code{\link[CircStats]{circ.mean}}) and variance (computed via \code{\link[CircStats]{circ.disp}} and reporting the \code{var} output)
#' are also computed for each dive phase and the dive as a whole.
#' 
#' @param P Depth data. A vector (or one-column matrix), or a tag sensor data list.
#' @param X (optional) Another data stream (as a vector (or a one-column matrix) or a tag sensor data list) for which to compute mean and variability. If \code{angular} is TRUE, interpreted as angular data (for example pitch, roll, or heading) and means and variances are computed accordingly. 
#'  The unit of measure must be radians (NOT degrees). Currently, \code{X} must be regularly sampled.
#' @param dive_cues A two-column data frame or matrix with dive/flight start times in the first column and dive/flight end times in the second. May be obtained from \code{\link{find_dives}}. Units should be seconds since start of tag recording.
#' @param sampling_rate (optional and ignored if \code{P} or \code{X} are tag sensor data lists) Sampling rate of \code{P} (and \code{X}, if \code{X} is given). If omitted, then input data must be sensor data lists. If one value is given and both \code{P} and \code{X} are input, they are assumed to have the same sampling rate. If \code{P} and \code{X} have different sampling rates, then this input can have two elements (first for \code{P}, second for \code{X}).
#' @param prop The proportion of the maximal excursion to use for defining the "destination" phase of a dive or flight. For example, if \code{prop} is 0.85 (the default), then the destination phase lasts from the first to the last time depth/altitude exceeds 0.85 times the within-dive maximum.
#' @param angular Is X angular data? Defaults to FALSE. 
#' @param X_name A short name to use for X variable in the output data frame. For example, if X is pitch data, use X_name='pitch' to get outputs column names like mean_pitch, etc. Defaults to 'angle' for angular data and 'aux' for non-angular data.
#' @param na.rm Logical, default is TRUE. If TRUE, then returned mean values ignore missing values, computing an average over all non-missing observations.
#' @export
#' @return A data frame with one row for each dive/flight and columns as detailed below. All times are in seconds, and rates in units of x/sec where x is the units of \code{P}.
#' \itemize{
#' \code{max} { The maximum depth or altitude}
#' \code{st} {start time of dive (seconds) - from input dive_cues}
#' \code{et} {end time of dive (seconds) - from input dive_cues}
#' \code{dur} { The duration of the excursion}
#' \code{dest_st} { The start time of the destination phase in seconds since start of tag recording (which is also the end time of to phase)}
#' \code{dest_et} { The end time of the destination phase in seconds since start of tag recording (which is also the start of the from phase).}
#' \code{dest_dur} { The duration in seconds of destination phase}
#' \code{to_dur} { The duration in seconds of to phase}
#' \code{from_dur} { The duration in seconds of from phase}
#' \code{mean_angle} { If angular=TRUE and X is input, the mean angle for the entire excursion. Values for each phase are also provided in columns \code{mean_to_angle}, \code{mean_dest_angle}, and \code{mean_from_angle}.}
#' \code{angle_var} { If angular=TRUE and X is input, the angular variance for the entire excursion. Values for each phase are also provided individually in columns \code{to_angle_var}, \code{dest_angle_var}, and \code{from_angle_var}.}
#' \code{mean_aux} { If angular=FALSE and X is input, the mean value of X for the entire excursion. Values for each phase are also provided in columns \code{mean_to_aux}, \code{mean_dest_aux}, and \code{mean_from_aux}.}
#' \code{aux_sd} { If angular=FALSE and X is input, the standard deviation of X for the entire excursion. Values for each phase are also provided individually in columns \code{to_aux_sd}, \code{dest_aux_sd}, and \code{from_aux_sd}.}
#'#' }
#' @seealso \code{\link{find_dives}}

dive_stats <- function(P, X = NULL, dive_cues, sampling_rate = NULL, 
                       prop = 0.85, angular = FALSE, X_name = NULL,
                       na.rm = TRUE){
  if (!is.list(P) & missing(sampling_rate)){
    stop('For vector input data, sampling_rate must be provided')
  }
  
  if (is.null(X_name)){
    if (angular){
      X_name = 'angle'
    }else{
      X_name = 'aux'
    }
  }
  
  if (is.list(P) & hasName(P, 'data') & hasName(P, 'sampling_rate')){
    fs <- P$sampling_rate
    P <- as.matrix(P$data, ncol=1)
  } else{
    fs <- unlist(head(sampling_rate,1))
  }
  
  if (is.list(X) & hasName(X, 'data') & hasName(X, 'sampling_rate')){
    if (X$sampling_rate != fs){
      xfs <- X$sampling_rate
      #stop('Sampling rates of P and X must match.')
    } else {
      xfs <- fs
    }
    X <- as.matrix(X$data, ncol=1)
  } else {
    if (!is.null(X)){
      X <- as.matrix(X, ncol=1)
      xfs <- unlist(tail(sampling_rate,1))
      if (xfs == fs & nrow(X) != nrow(P)){
        warning('inputs P and X have different numbers of observations, but the same sampling rate. Use sampling_rate input if you need to specify different sampling rates for each one.')
      }
    }
  }
  
  di <- round(dive_cues*fs)
  
  Y <- data.frame(num=c(1:nrow(dive_cues)))
  
  for (d in 1:nrow(dive_cues)){#loop over dives
    z <- P[di[d,1]:di[d,2]] 
    Y$max[d] <- max(z, na.rm=TRUE)
    pt <- range(which(z > prop * max(z)), na.rm=TRUE)
    Y$dur[d] <- dive_cues[d,2] - dive_cues[d,1]
    Y$dest_st[d] <- pt[1]/fs + dive_cues[d,1]
    Y$dest_et[d] <- pt[2]/fs + dive_cues[d,1]
    Y$dest_dur[d] <- Y$dest_et[d] - Y$dest_st[d]
    Y$to_dur[d] <- pt[1]/fs
    Y$to_rate[d] <- (z[pt[1]] - z[1])/Y$to_dur[d]
    Y$from_dur[d] <- (1/fs)*(length(z)-pt[2])
    Y$from_rate[d] <- (utils::tail(z,1) - z[pt[2]])/Y$from_dur[d]
    if (!is.null(X)){
      if (xfs != fs){
        dix <- round(dive_cues*xfs)
        ptx <- round(pt / fs * xfs)
      } else{
        dix <- di
        ptx <- pt
      }
      if (angular){#angular data
        a <- X[dix[d,1]:dix[d,2]] 
        at <- a[c(1:ptx[1])]
        af <- a[c(ptx[2]:length(a))]
        ad <- a[c(ptx[1]:ptx[2])]
        if (na.rm){
          # CircStats functions return NA if any NAs present
          # (no na.omit input avail)
          a <- na.omit(a)
          at <- na.omit(at)
          af <- na.omit(af)
          ad <- na.omit(ad)
        }
        Y$mean_angle[d] <- CircStats::circ.mean(a)
        Y$angle_var[d] <- CircStats::circ.disp(a)$var
        Y$mean_to_angle[d] <- CircStats::circ.mean(at)
        Y$mean_dest_angle[d] <- CircStats::circ.mean(ad)
        Y$mean_from_angle[d] <- CircStats::circ.mean(af)
        Y$to_angle_var[d] <- CircStats::circ.disp(at)$var
        Y$dest_angle_var[d] <- CircStats::circ.disp(ad)$var
        Y$from_angle_var[d] <- CircStats::circ.disp(af)$var
      }else{
        #not angular data
        a <- X[dix[d,1]:dix[d,2]] 
        at <- a[c(1:ptx[1])]
        af <- a[c(ptx[2]:length(a))]
        ad <- a[c(ptx[1]:ptx[2])]
        Y$mean_aux[d] <- mean(a, na.rm=TRUE)
        Y$aux_sd[d] <- stats::sd(a, na.rm=TRUE)
        Y$mean_to_aux[d] <- mean(at, na.rm=TRUE)
        Y$mean_dest_aux[d] <- mean(ad, na.rm=TRUE)
        Y$mean_from_aux[d] <- mean(af, na.rm=TRUE)
        Y$to_aux_sd[d] <- stats::sd(at, na.rm=TRUE)
        Y$dest_aux_sd[d] <- stats::sd(ad, na.rm=TRUE)
        Y$from_aux_sd[d] <- stats::sd(af, na.rm=TRUE)
      }
    }#end processing X
  }#end loop over dives
  
  #change output column names if needed
  if (!(X_name %in% c('angle', 'aux'))){
    names(Y) <- gsub(pattern='angle', replacement=X_name, x=names(Y))
    names(Y) <- gsub(pattern='aux', replacement=X_name, x=names(Y))    
  }
  
  # add in dive start/end times from input dive_cues
  # and start-end times of each phase
  Y$st <- dive_cues[,1]
  Y$et <- dive_cues[,2]
  
  Y <- dplyr::select(Y, num, max, st, et, dur, 
                     dest_st, dest_et, dest_dur,
                     to_dur, from_dur,
                     dplyr::everything())
  
  return(Y)
  }
