#' Return information about keyboard entries on interactive plot
#'
#' This is an internal function used by prh_predictor. It works with getGraphicsEvent() and returns keyboard entries.
#' @param buttons The keyboard button pressed
#' @return What the button is supposed to do
#' @noRd
#'
keybd1 <- function(key) {
  # make input lower case, except Z for zoom in
  key <- ifelse(key != "Z", tolower(key), key)

  if (key == "q") {
    return("Done")
  } # end of key q for quit

  if (key == "e") {
    return("edit")
  } # end of key e for edit

  if (key == "z") {
    return("zoom in")
  } # end z for zoom in

  if (key == "Z") {
    return("zoom out")
  } # end Z for zoom out

  if (key == "x") {
    return("delete point")
  } # end x for delete point
} # end of get keyboard fun