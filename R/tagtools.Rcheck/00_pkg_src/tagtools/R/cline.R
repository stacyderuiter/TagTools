#' Add colored line segments to a plot
#'
#' This function adds colored line segments to an existing plot.  The line is plotted at points specified by inputs x and y, and colored according to factor input z (with one color for each level of z).
#' @param x x positions of points to be plotted
#' @param y y positions of points to be plotted
#' @param z a factor, the same length as x and y. Line segments in the resulting plot will be colored according to the levels of z.
#' @param color_vector a list of colors to use (length should match the number of levels in z).
#' @keywords visualization, time-series
#' @export
#' @examples
#' cline(x=ChickWeight$Time, y=ChickWeight$weight, 
#'       z=as.factor(ChickWeight$Diet), 
#'       color_vector=c('black', 'grey20', 
#'                      'grey50', 'grey70'))

cline <- function(x, y, z, color_vector) {
    # find places where colors will change
    pe <- c(which(diff(unclass(z)) != 0), length(x))
    # find places where new colors start
    ps <- c(1, utils::head(pe, -1) + 1) 
    #get values of z at the time of each color-change
    pz <- z[ps]
    for (L in 1:nlevels(z)) {
      # make a list of indices of all points that must be a given color
        pix <- unlist(mapply(FUN = function(s, e) c(s:e, NA), ps[pz == levels(z)[L]], pe[pz == levels(z)[L]]))
      # add line segmets of the given color to the plot
        graphics::lines(x[pix], y[pix], col = color_vector[L])
    }
}
