#' Plot main plot for prh_predictor
#'
#' This is an internal function used by prh_predictor. It plots the main figure window
#' @param P Depth data
#' @param sampling_rate Sampling rate of P in Hz
#' @param PRH matrix with 5 columns giving start time in sec since start, p0, r0, h0, and quality
#' @param xl x axis limits for plots
#' @param prompt Main title for top panel (prompt for user interaction)
#' @noRd
#'
plot_prh_fig1 <- function(P, sampling_rate, PRH, xl, prompt) {
  #*****************************************
  # colors for PRH data
  #*****************************************
  rgb_cols <- matrix(c(
    0, 0.4470, 0.7410,
    0.85, 0.3250, 0.098,
    0.9290, 0.6940, 0.1250
  ),
  nrow = 3, byrow = TRUE
  )
  hex_cols <- grDevices::rgb(
    red = rgb_cols[, 1],
    green = rgb_cols[, 2],
    blue = rgb_cols[, 3]
  )
  names(hex_cols) <- c("p", "r", "h")

  # plot with 3 subplots in 1 column
  graphics::par(mfrow = c(3, 1), mar = c(4, 4, 3, 1))
  # top plot
  graphics::plot((1:length(P)) / sampling_rate, P,
    type = "l", col = "black",
    xlim = xl, ylim = c(ceiling(max(P, na.rm = TRUE) / 100) * 100, 0),
    xlab = "", ylab = "Depth (m)",
    main = prompt
  )
  graphics::grid()

  # middle plot
  graphics::plot(PRH[, 1], rep(min(c(PRH[, 5], 0.15), na.rm = TRUE), nrow(PRH)),
    type = "b", pch = 8,
    xlim = xl, ylim = c(0, 0.15),
    xlab = "Time cue", ylab = "Quality"
  )
  graphics::grid()

  # bottom plot
  # note: this plot is moved to last because get-mouse-click uses the last-plotted axes (?<!?#*&%@(*#)...)
  # get ylim
  yl <- c(
    max(c(-91, floor(min(PRH[, 2:4] / pi * 180 / 10, na.rm = TRUE)) * 10)),
    min(c(91, ceiling(max(PRH[, 2:4] / pi * 180 / 10, na.rm = TRUE)) * 10))
  )
  graphics::plot(PRH[, 1], PRH[, 2] * 180 / pi,
    col = hex_cols[1], type = "b", pch = 8,
    xlim = xl, ylim = yl,
    ylab = "PRH (degrees)"
  )
  for (row in c(3:4)) {
    graphics::lines(PRH[, 1], PRH[, row] * 180 / pi,
      col = hex_cols[row - 1], type = "b", pch = 8
    )
  }
  graphics::grid()
} # end of plot_prh_fig1