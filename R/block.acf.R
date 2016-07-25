block.acf <- function(resids, blocks, max.lag, makeplot, ...)
{
  library(stats)
  #residuals is a vector of model residuals (e.g. from a GEE)
  #block is a factor vector indicating the block structure 
  #used for the GEE
  #(resids and blocks should be the same length)
  #plot is logical (T=produce a plot, the default)
  # ... are additional arguments to be passed to plot.acf.
  #the function will return a vector of autocorrelation 
  #coefficients
  #at lags 0-max.lag, ignoring all lags that span blocks.
  #note that the zero-lag correlation 
  
  #input checks
  blocks <- as.factor(blocks)
  if (length(blocks) != length(resids)){
    warning("blocks and resids should be the same length.")
  }
  if (missing(max.lag)) {
    max.lag=min(tapply(blocks,blocks,length))
  }
  if (missing(makeplot)){
    makeplot=TRUE #default is to plot the result
  }
  #note: the function will let you specify a max.lag longer 
  #than the shortest block if you so choose.
  
  #get acf of full dataset, ignoring all lags that span blocks.
  #############################################################
  #get indices of last element of each block excluding the last
  i1 <- cumsum(as.vector(head(tapply(blocks,blocks,length),-1)))
  r <- resids
  block.acf <- matrix(1,nrow=max.lag+1, ncol=1)
  for (k in 1:max.lag){
    for (b in 1:length(i1)){
      r <- append(r, NA, i1[b])
    }
    #adjust for the growing r
    i1 <- i1 + head(c(0:(-1+nlevels(blocks))),-1)
    this.acf <- acf(r,lag.max=max.lag, type="correlation",
                    plot=FALSE, na.action=na.pass)
    block.acf[k+1] <- this.acf$acf[k+1,1,1] 
  }
  if (makeplot){
    #this is just to get an acf object...
    A <- acf(resids,lag.max=max.lag,plot=F) 
    #into which we'll insert our coefficients
    A$acf[,1,1] <- block.acf
    #and then plot OUR results
    plot(A, ...)
  }
  return(block.acf)
}
