#' Draw crosshairs at mouse position on plot
#' 
#' This is an internal function used by prh_predictor (and perhaps other interactive plots). It works with getGraphicsEvent() and draws crosshairs on a plot when the mouse is clicked.
#' @param buttons The keyboard button pressed
#' @param x The x location of the mouse (in ndc coordinates)
#' @param y The y location of the mouse (in ndc coordinates)
#' @noRd
#' 
crosshairs <- function(buttons, x, y){
  trans_black <- grDevices::rgb(0, 0, 0, alpha = 0.4)
  xp <- graphics::grconvertX(x, from = 'ndc', to = 'user') 
  yp <- graphics::grconvertY(y, from = 'ndc', to = 'user')
  graphics::abline(h = yp, col = trans_black)
  graphics::abline(v = xp, col = trans_black)
}