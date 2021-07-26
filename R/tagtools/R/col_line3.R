#' Plot coloured line(s) in 3 dimensions
#'
#' This function is used to plot three dimensional lines with each individual line possessing a different color.
#' @param x a vector or matrix of points on the horizontal (x) axis.
#' @param y A vector or matrix of points on the vertical (y) axis.
#' @param z A vector or matrix of points on the third (z) axis.
#' @param c A vector or matrix of values representing the colour to draw at each point.
#' @param col_lab A string to use as the label for the color legend
#' @param ... Additional inputs for plot_ly()
#' @result a plot_ly() graphics object
#' @examples 
#' col_line3(1:20, 1:20, 1:20, 1:20)
#' @export
#' @seealso \code{\link{col_line}}, \code{\link{cline}}
#' @note x, y, z and c must all be the same size vectors. The color axis will by default span the range of values in c, i.e., caxis will be c(min(min(c)), max(max(c))).

col_line3 <- function(x, y, z = 0, c) {
  if (missing(x) | missing(y)) {
    stop("Inputs x and y are required for col_line3 unless formula is provided.\n")
  }
  
  if (!inherits(x, 'formula')){
    x_formula <- stats::as.formula(paste("~", quote(x)))  
  }else{
    x_formula <- x
  }
  
  if (!inherits(y, 'formula')){
    y_formula <- stats::as.formula(paste("~", quote(y)))  
  }else{
    y_formula <- y
  }
  
  if (!inherits(z, 'formula')){
    z_formula <- stats::as.formula(paste("~ -", quote(z)))  
  }else{
    z_formula <- z
  }
  
 if (!plyr::is.formula(c)){
   color_formula <- stats::as.formula(paste("~", quote(c))) 
 }else{
   color_formula <- c
 }
  

  plotly::plot_ly(
    x = x_formula, y = y_formula, z = z_formula,
    type = "scatter3d", mode = "lines", color = color_formula,
    ...
  )
}