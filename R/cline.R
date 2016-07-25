#function to make a line plot and colour according to a FACTOR 
#NOTE this ADDS LINES to an EXISTING PLOT
cline <- function(x,y,z, color_vector){
  pe <- c(which(diff(unclass(z))!=0) , length(x))
  ps <- c(1, head(pe,-1)+1) #starts
  pz <- z[ps]
  for (L in 1:nlevels(z)){
    pix <- unlist(mapply(FUN=function(s,e) c(s:e, NA) , ps[pz==levels(z)[L]], pe[pz==levels(z)[L]]))
    lines(x[pix], y[pix], col=color_vector[L])
  }
}