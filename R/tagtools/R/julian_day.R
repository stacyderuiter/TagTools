#' Convert between dates and Julian day numbers.
#'
#' This function is used to convert between dates and Julian day numbers. There are three different input arrangements, each of which returns a different output. For a discription of the different input arrangements, see below.
#'
#' Possible input combinations: (n <- julianday) returns the Julian day number for today. (n = julianday(y,d)) where y is a single year or a vector of years and d is a single day number or a vector of daynumbers, returns the date vector [year,month,day] for each year, day pair. (n = julianday(y,m,d)) where y is a single year or a vector of years, m is a single month or vector of months, and d is a single month day or a vector of month days, returns the Julian day number for each year, month, day.
#' @param y A single year or vector of years
#' @param d A single day or vector of days
#' @param m A single month or vector of months
#' @return See the description section for details on the return.
#' @export
#' @examples julian_day(y = 2016, d = 12, m = 10) # Returns: 286
#' julian_day(y = 2016, 286) # Returns: "2016-10-12"

julian_day <- function(y = NULL, m = NULL, d = NULL) {
  if (nargs() == 0) {
    floor(as.numeric(julian(Sys.time())) - 17166)
  }
  if (missing(d)) {
    d <- m
    k <- max(c(length(y), length(m)))
    if (length(y) < k) {
      y[length(y) + 1:k] <- y[length(y)]
    }
    if (length(d) < k) {
      d[length(d) + 1:k] <- d[length(d)]
    }
    startdate <- as.Date(ISOdate(y, 01, 01))
    n <- startdate + (d - 1)
    return(n)
  }
  k <- max(c(length(y), length(m), length(d)))
  if (length(y) < k) {
    y[length(y) + 1:k] <- y[length(y)]
  }
  if (length(m) < k) {
    m[length(m) + 1:k] <- m[length(m)]
  }
  if (length(d) < k) {
    d[length(d) + 1:k] <- d[length(d)]
  }
  dvec <- as.Date(ISOdate(y, m, d))
  t <- as.POSIXlt(dvec)
  n <- t$yday + 1
  return(n)
}