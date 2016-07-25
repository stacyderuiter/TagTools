#helper function to make a factor variable binning a continuous predictor
binify <- function(dat, nbins, xmin, xmax){
  #inputs:
  # dat is the original, continuous data
  # nbins is the number of bins into which to bin dat
  # xmax (optional) is the maximum value (top limit of top bin). 
  #    defaults to max(dat). Similar for xmin.
  
  if (missing(xmax)) {xmax <- max(dat,na.rm=T)}
  if (missing(xmin)) {xmin <- min(dat,na.rm=T)}
  
  locs <- seq(from=xmin,
              to=xmax, length.out=nbins+1)
  mids <- round(diff(locs) + locs[1:(length(locs)-1)], digits=2)
  groups <- cut(dat, breaks=locs, dig.lab=2)
  b <- list(locs=locs, mids=mids, groups=groups)
  return(b)
}