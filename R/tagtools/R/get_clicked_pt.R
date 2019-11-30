#' Return (x,y) of mouse click position on plot
#' 
#' This is an internal function used by prh_predictor (and perhaps other interactive plots). It works with getGraphicsEvent() and draws returns the x, y location on a plot where the mouse is clicked.
#' @param buttons The keyboard button pressed
#' @param x The x location of the mouse (in ndc coordinates)
#' @param y The y location of the mouse (in ndc coordinates)
#' @noRd
#' 
get_clicked_pt <- function(buttons, x, y){ # ndc nfc npc device nic
  clicked_pt <- list(x = graphics::grconvertX(x, from = 'ndc', to = 'user'), 
                     y = graphics::grconvertY(y, from = 'ndc', to = 'user'))
  crosshairs(buttons, x, y)
  return(clicked_pt)
}