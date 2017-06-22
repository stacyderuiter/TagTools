#' Convert a time in CST (sec since start of recording) to year, month, day, hours, minutes, seconds local time.
#'
#' @param tag The tag id string (eg "zc11_267a")
#' @param cst A scalar or a vector of times to convert (in seconds since start of recording)
#' @param d3 Give the value 0 if the tag was a dtag2, or 1 if a d3 (if 1, then it will be assumed that the TAGON in the cal file is in UTC and GMT2LOC will be used to covert to local).
#' @param tagon (optional) A vector with tagon time as [yyyy mm dd hh mm ss], in case there is no cal file for this tag avail.
#' @param GMT2LOC (optional) The conversion factor for GMT to local time, if d3=1 and tagon is given then GMT2LOC should be given as well.
#' @return hms The output for a date/time string which is a matrix of strings where row n is a string indicating the local date and time for entry n of csts.


cst2hms <- function(tag,cst, d3, TAGON, GMT2LOC) {
  if (d3 == 1) {
    TAGON[4] = TAGON[4] + GMT2LOC #convert GMT tagon time to local time
  }
  #calculate timing
  ttime <- pracma::repmat(t(TAGON), length(cst), 1) #get a matrix of the right size
  ttime[, 6] <- TAGON[6] + cst #last col is seconds.  add cst, which is seconds since tagon, to get time of points in cst
  #This will give POSIXct date-time object
  d <- as.POSIXct(ISOdatetime(ttime[,1], ttime[,2],ttime[,3], ttime[,4], ttime[,5], ttime[,6]))
  return(d)
}
                                                    