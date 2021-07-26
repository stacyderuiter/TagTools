#' Plot coloured line(s) in 2 dimensions
#'
#' This function is used to plot two dimensional lines with each individual line possessing a different color.
#' @param formula formula of the form y ~ x where y and x are the (unquoted) names of the variables to put on the x and y axes of the plot
#' @param color one-sided formula of the form ~ c giving the (unquoted) name of the variable by which to color. Ideally c should be a factor or character variable.
#' @param data data.frame or tibble in which variables x, y, and c are found.
#' @param ... Additional inputs to be passed to gf_path()
#' @return a ggplot object with the requested plot
#' #' @export

col_line <- function(formula, color, data = NULL, ...) {
  ggformula::gf_path(formula, color = color, 
                     data = data)
}
