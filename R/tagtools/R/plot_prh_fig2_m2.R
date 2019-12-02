#' Plot second detail (one-dive) plot for prh_predictor method 2
#' 
#' This is an internal function used by prh_predictor. It plots the second figure window.
#' @param A 3-column Acceleration data matrix (columns are x, y, z in tag frame) 
#' @param v a vector of vertical speeds (same number of rows as A)
#' @param sampling_rate Sampling rate of A in Hz
#' @param seg information about which segments of data to plot. A one-row matrix with 2 columns: start end end times of box
#' @param prh one row of PRH info (start time, p0, r0, h0, quality) for the segment seg 
#' @param prompt Main title for top panel (prompt for user interaction)
#' @noRd
#' 
plot_fig2_m2 <- function(A, v, sampling_rate, seg, prh, prompt){
  #*****************************************
  # colors for PRH data
  #*****************************************
  rgb_cols <- matrix(c(0, 0.4470, 0.7410,
                       0.85, 0.3250, 0.098,
                       0.9290, 0.6940, 0.1250),
                     nrow = 3, byrow = TRUE)
  hex_cols <- grDevices::rgb(red = rgb_cols[,1],
                  green = rgb_cols[,2],
                  blue = rgb_cols[,3])
  names(hex_cols) <- c('p', 'r', 'h')
  
  YEXT <- 12.5     # vertical extent of accelerometry plots +/-m/s^2
  # x limits
  xl2 <- seg + c(-30, 30)
  # accel data in whale frame according to current prh values
  Aw <- A %*% t(euler2rotmat(prh[2], prh[3], prh[4]))
  
  # top plot
  graphics::par(mfrow = c(2,1), mar = c(4,5,3,1))
  graphics::plot(c(1:nrow(A))/sampling_rate, A[,1]*9.81,
       type = 'l', col = hex_cols[1],
       xlim = xl2, ylim = c(YEXT*c(-1, 1)),
       xaxt = 'n',
       main = prompt,
       xlab = '', ylab = latex2exp::TeX('Tag frame A, m/s^2')
  )
  # add x axis with no tick labels
  graphics::axis(side = 1, labels = FALSE)
  for (col in c(2:3)){
    graphics::lines(c(1:nrow(A))/sampling_rate, A[,col]*9.81,
          type = 'l', col = hex_cols[col])
  }
  graphics::grid()
  graphics::legend('bottomright', bty = 'n', legend = names(hex_cols),
         text.col = hex_cols, horiz = TRUE)
  # add box
  graphics::rect(xleft = seg[1], xright = seg[2], 
       ybottom = -0.9*YEXT, ytop = 0.9*YEXT,
       border = 'black')
  
  # bottom panel
  # need to convert from matlab
  msg <- paste('At ', round(prh[1]), ', ',
               'p0 = ', round(prh[2]*180/pi, digits = 1), ', ',
               'r0 = ', round(prh[3]*180/pi, digits = 1), ', ',
               'h0 = ', round(prh[4]*180/pi, digits = 1), ', ',
               'Quality: ', round(prh[5], digits = 3))
  
  graphics::plot(c(1:nrow(Aw))/sampling_rate, Aw[,1]*9.81,
       type = 'l', col = hex_cols[1],
       xlim = xl2, ylim = c(YEXT*c(-1, 1)),
       xlab = '', ylab = latex2exp::TeX('Animal frame A, m/s^2'),
       main = msg
  )
  for (col in c(2:3)){
    graphics::lines(c(1:nrow(Aw))/sampling_rate, Aw[,col]*9.81,
          type = 'l', col = hex_cols[col])
  }
  graphics::grid()
  # add boxes
  graphics::rect(xleft = seg[1], xright = seg[2], 
       ybottom = -0.9*YEXT, ytop = 0.9*YEXT,
       border = 'black')
}# end of plot_fig2