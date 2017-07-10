#' Convert between dates and Julian day numbers.
#' 
#' @description (n <- julianday) returns the Julian day number for today. (n = julianday(y,d)) where y is a single year or a vector of years and d is a single day number or a vector of daynumbers, returns the date vector [year,month,day] for each year,day pair. (n = julianday(y,m,d)) where y is a single year or a vector of years, m is a single month or vector of months, and d is a single month day or a vector of month days, returns the Julian day number for each year, month, day.
#' @param y A single year or vector of years
#' @param m A single month or vector of months
#' @param d A single day or vector of days
#' @return n See the description section for details on the return.
#' @example julianday(2016,10,12) #Returns: 286
#'          julianday(2016,286) #Returns: c(2016, 10, 12)

julian_day <- function(y, m, d) {
  
}