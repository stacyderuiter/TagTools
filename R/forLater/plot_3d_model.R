#' Plot a 3d model in a gimbal frame for visualizing animal orientation.
#' 
#' @param fname The optional name of a pair of files containing the points and connections of a wire frame. These files should have suffix .pts and .knx, respectively. If fname is not given, files for a 3d plot of a dolphin will be loaded.
#' @return F A structure containing handles to the components of the display which can then be manipulated using rot_3d_model.
#' @note The 3d model is plotted in the current figure. This function clears any plot already in the figure to ensure that the plot will appear.
#' @example F <- plot_3d_model()
#'          rot_3d_model(F,t(seq(0,(2*pi), len = 100))*c(0, 1, 0))
#'          #Plots a dolphin in a gimbal and animates it through a corkscrew roll.

plot_3d_model <- function(fname = NULL){
  if (is.null(fname)){
    fname <- "dolphin" 
  }
  
  SZ <- 5 			  #size of the gimbal
  CSZ <- 1.07 	  #multiplier for size of the compass wheel
  PLOT_RINGS <- 0 
  
  #read in file data
  P <- read.table(paste(fname,".pts", sep = ""), header = FALSE, sep = " ")
  K <- read.table(paste(fname,".knx", sep = ""), header = FALSE, sep = " ") 
  while(TRUE) {
    if (!all(is.na(P[,1]))) {
      break
    }
    if (all(is.na(P[,1]))) {
      P <- P[,-1]
    }
  }
  while(TRUE) {
    if (!all(is.na(K[,1]))) {
      break
    }
    if (all(is.na(K[,1]))) {
      K <- K[,-1]
    }
  }
  if(!is.null(dev.list())) {
    dev.off()
  }  
  
  P <- cbind(-P[, 1], P[, 2:3])
  for (i in 1:nrow(P)) {
    rgl::polygon3d(x = P[i, 1], y = -P[i, 2], z = P[i, 3], coords = (K[,1:3]+1), alpha = 1.0, col = P[, 3])
    colormap:colormap(colormap = colormaps$bone, reverse = TRUE)
  }
  
  c <- exp(j * 2 * pi * t((0:(500 - 1))) / 500)
  CX <- SZ * cbind(real(c), Im(c), matrix(0, 500, 1))
  
  if (PLOT_RINGS) {
    rgl::lines3d(CX[, 3] ~ CX[, 1] * -CX[, 2], col = "gray60")
    rgl::lines3d(CX[, 2] ~ CX[, 3] * -CX[, 1], col = "gray60")
    rgl::lines3d(CX[, 1] ~ CX[, 2] * -CX[, 3], col = "gray60")
    set(C,'color',0.6*c(1, 1, 1))
  } else {
    C <-  c()
  }
  
  rgl::lines3d(CX[, 3] ~ (CSZ * CX[, 1]) * (CSZ * CX[, 2]), "black", lwd = 1)
  a1 <- matrix(c(CSZ * SZ * matrix(c(1, 0, -1, 0, CSZ, 0, -CSZ, 0), byrow = TRUE, nrow = 2)))
  a2 <- matrix(c(CSZ * SZ * matrix(c(0, 1, 0, -1, 0, CSZ, 0, -CSZ), byrow = TRUE, nrow = 2)))
  a3 <- matrix(0, 2, 4)
  rgl::lines3d(x = a1, y = a2, z = a3, col = "black", lwd = 1)
  rgl::text3d(CSZ^3 * SZ, 0, 0, "N", col = "black")
  LX <- SZ * matrix(c(-1, 0, 0, 1, 0, 0), byrow = TRUE, nrow = 2) 
  rgl::lines3d(LX[, 3] ~ LX[, 1] * -LX[, 2], col = "blue", lwd = 1.5)
  rgl::lines3d(LX[, 2] ~ LX[, 3] * -LX[, 1], col = "green", lwd = 1.5)
  rgl::lines3d(LX[, 1] ~ LX[, 2] * -LX[, 3], col = "red", lwd = 1.5)
  AX <- SZ * c(1, 0, 0)
  rgl::lines3d(LX[2, 3] ~ LX[2, 1] * -LX[2, 2], col = "blue", cex = 14)
  rgl::lines3d(LX[2, 2] ~ LX[2, 3] * -LX[2, 1], col = "green", cex = 14)
  rgl::lines3d(LX[2, 1] ~ LX[2, 2] * -L[2, 3], col = "red", cex = 14)
  return(F)
}
        