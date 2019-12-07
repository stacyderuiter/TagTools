#' Plot coloured line(s) in 3 dimensions
#' 
#' This function is used to plot three dimensional lines with each individual line possessing a different color.
#' @param formula a formula of the form y ~ x giving the (unquoted) variable names to plot
#' @param x ignored if a formula is provided. A vector or matrix of points on the horizontal axis.
#' @param y ignored if a formula is provided. A vector or matrix of points on the vertical axis.
#' @param c A vector or matrix of values representing the colour to draw at each point.
#' @param c_lab A string to use as the label for the color legend
#' @param data (optional) a data.frame containing variables used for plotting
#' @param interactive logical. Plot interactive or static figure? Note: For some reason it is much faster to plot a static figure and then call ggplotly() outside this function, e.g., F <- col_line(y~x, c = z); ggplotly(F)
#' @param ... Additional inputs for plot_ly()
#' @export
#' @seealso \code{\link{col_line}}, \code{\link{cline}}
#' @note x, y, z and c must all be the same size vectors. The color axis will by default span the range of values in c, i.e., caxis will be c(min(min(c)), max(max(c))). 

col_line3 <- function(formula = NULL, x, y, z = 0, c, col_lab = quote(c),
                      interactive = FALSE, data = parent.frame(), ...) {
  if (missing(formula) | is.null(formula)){
    if (missing(x) | missing(y)){
      stop('Inputs x and y are required for col_line3 unless formula is provided.\n')
    }
    x_formula <- as.formula(paste('~', quote(x)))
    y_formula <- as.formula(paste('~', quote(y)))
  }
  
  z_formula <- as.formula(paste('~ -', quote(z)))
  
  color_formula <- as.formula(paste('~', quote(c)))
  
  plot_ly(x = x_formula, y = y_formula, z = z_formula,
          type="scatter3d", mode="lines", color = color_formula, 
          data = data, ...)
}