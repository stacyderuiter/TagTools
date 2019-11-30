#' Return information about keyboard entries on interactive plot
#' 
#' This is an internal function used by prh_predictor. It works with getGraphicsEvent() and returns keyboard entries.
#' @param buttons The keyboard button pressed
#' @noRd
#' 
keybd2 <- function(key) {
  # make input lower case
  key <- tolower(key)
  if (key %in% c('Q', 'q')){
    return("Done")
  }
  
  if (key %in% c('1', '2', '3', '4')){
    return(key)
  }
  
  if (key == 'x'){
    return('x')
  }
} # end of keybd2