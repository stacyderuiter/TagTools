#' Convert a time in CST (sec since start of recording) to hours min sec local time or convert a time in CST to a matlab serial date number indicating local time.
#'
#' @param tag The tag id string (eg "zc11_267a")
#' @param cst A scalar or a vector of times to convert (in seconds since start of recording)
#' @param d3 Give the value 0 if the tag was a dtag2, or 1 if a d3 (if 1, then it will be assumed that the TAGON in the cal file is in UTC and GMT2LOC will be used to covert to local).
#' @param tagon (optional) A vector with tagon time as [yyyy mm dd hh mm ss], in case there is no cal file for this tag avail.
#' @param GMT2LOC (optional) The conversion factor for GMT to local time, if d3=1 and tagon is given then GMT2LOC should be given as well.
#' @param output Specifies whether you would like to be given a datenumber or a date/time string. If output == "datenum", this function will convert a time in CST to a matlab serial date number indicating local time (may be useful to plot with date number as y axis of plot, using datetick to label the axis in human-legible local time...). If output = "datestr", this function will convert a time in CST (sec since start of recording) to hours min sec local time.
#' @return hms The output for a date/time string which is a matrix of strings where ro n is a string indicating the local time for entry n of csts.
#' @return d The output for a datenumber which is a vector of serial date numbers.


cst2hms_or_datenum <- function(tag,cst, d3, TAGON, GMT2LOC, output) {
  if (d3 == 1) {
    TAGON[4] = TAGON[4] + GMT2LOC #convert GMT tagon time to local time
  }
  #calculate timing
  ttime <- pracma::repmat(t(TAGON), length(cst), 1) #get a matrix of the right size
  ttime[, 6] <- TAGON[6] + cst #last col is seconds.  add cst, which is seconds since tagon, to get time of points in cst
  if (output == "datenum") {
    
  }
  if (output == "datestr") {
    
  }
}
                                                    