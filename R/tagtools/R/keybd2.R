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
    #remove this dive from S and PRH
    S = S[-ke,]
    PRH = matrix(PRH[-ke,], ncol = 5, byrow = TRUE)
    # then need to re-plot figure 1 because fewer segments are there
    grDevices::dev.set(f1)
    plot_fig1(P, sampling_rate, PRH, xl)
    # then quit interaction with fig 2 
    # because cannot execute above code more than once without causing trouble
    return("Done")
  }
} # end of keybd2