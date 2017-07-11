#' Convert between dates and Julian day numbers.
#' 
#' @description (n <- julianday) returns the Julian day number for today. (n = julianday(y,d)) where y is a single year or a vector of years and d is a single day number or a vector of daynumbers, returns the date vector [year,month,day] for each year,day pair. (n = julianday(y,m,d)) where y is a single year or a vector of years, m is a single month or vector of months, and d is a single month day or a vector of month days, returns the Julian day number for each year, month, day.
#' @param y A single year or vector of years
#' @param d A single day or vector of days
#' @param m A single month or vector of months
#' @return n See the description section for details on the return.
#' @example julian_day(y = 2016, d = 12, m =10) #Returns: 286
#'          julian_day(y = 2016, d =286) #Returns: c(2016, 10, 12)

julian_day <- function(y = NULL, d = NULL, m = NULL) {
  if (nargs() == 0) {
    floor(as.numeric(julian(Sys.time())) - 17166)
  }
  if (missing(m)) {
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
  n <- floor(as.numeric(julian(ISOdate(y, m, d))) - 16800)
  for (j in 1:length(n)) {
    if (n[j] > 365) {
      n[j] <- n[j] - 366
    }
  }
  return(n)
}