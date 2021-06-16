#' Plot coloured line(s) in 2 dimensions
#'
#' This function is used to plot two dimensional lines with each individual line possessing a different color.
#' @param formula a formula of the form y ~ x giving the (unquoted) variable names to plot
#' @param x ignored if a formula is provided. A vector or matrix of points on the horizontal axis.
#' @param y ignored if a formula is provided. A vector or matrix of points on the vertical axis.
#' @param c A vector or matrix of values representing the colour to draw at each point.
#' @param c_lab A string to use as the label for the color legend
#' @param data (optional) a data.frame containing variables used for plotting
#' @param interactive logical. Plot interactive or static figure? Note: For some reason it is much faster to plot a static figure and then call ggplotly() outside this function, e.g., F <- col_line(y~x, c = z); ggplotly(F)
#' @param ... Additional inputs to be passed to gf_path()
#' @return If output is assigned to an object, it will be a ggplot (or ggplotly) object and no plot will be displayed. Otherwise, the plot will be rendered.
#' @importFrom magrittr "%>%"
#' @examples 
#' col_line(1:20, 1:20, 1:20)
#' @note x, y and c must all be vectors of the same size.
#' @export

col_line <- function(formula, x = NULL, y = NULL, c, c_lab = quote(c),
                     data = NULL, interactive = FALSE, ...) {
  if (missing(formula) | is.null(formula)) {
    if (missing(x) | missing(y)) {
      stop("Inputs x and y are required for col_line unless formula is provided.\n")
    }
    formula <- as.formula(paste(y, "~", x))
  }

  color_formula <- as.formula(paste("~", quote(c)))

  if (interactive == TRUE) {
    fig <- plotly::plot_ly(
      x = as.formula(paste("~", as.character(formula[3]))),
      y = as.formula(paste("~", as.character(formula[2]))),
      data = data,
      type = "scatter", mode = "markers",
      color = color_formula,
      marker = list(size = 1)
    )
  } else {
    fig <- ggformula::gf_path(formula, data = data, color = color_formula, ...) %>%
      ggformula::gf_labs(color = c_lab)
  }
  fig
}
