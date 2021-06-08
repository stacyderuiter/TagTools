#' Draw time axis on plott plot.
#'
#' @description This function is called by \code{\link{plott}} to add a time axis to a plot created by \code{\link{plott}}. Users are unlikely to need to call the function directly.
#' @inheritParams graphics::axis.POSIXct
#' @param date_time Logical. Is the data being plotted date-time (POSIX) or time in seconds?
#' @param last_panel Logical. Is this the last panel (in other words, should x axis tick labels be drawn)?
#' @export

draw_axis <- function(side = 1, x = NULL, date_time, last_panel) {
  if (date_time) {
    graphics::axis.POSIXct(side = 1, x = x, labels = last_panel)
  } else {
    graphics::axis(side = 1, labels = last_panel)
  }
}
