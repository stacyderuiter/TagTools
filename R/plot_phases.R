plot_phases <- function(tagdat, mdists, cee.times, which_vars, thr, sim, hourlim, withlegend){
  #plot input data and mahalanobis distance time-series
  #note: this code is currently overly specific to one analysis previously done.
  #it could be generalized to make nice multi-panel plots of multivariate time
  #series data, possibly with different sampling rates, and colored by some factor variable (here dive phase)
  #  --check with Stacy DeRuiter for more help. January 2015
  # tagdat   is the input data
  # which_vars    is a list of the names of input vars to be included in the plot
  #     (if missing, all will be plotted)
  # mdists is an output from mdist analysis, a data frame with cols t and dist.
  # if mdists is missing or NA, then not plotted.
  # cee.times is start and end of CEE
  # thr is response threshold
  # sim is logical -- TRUE if simulated data (changes var names)
  #hourlim is x axis max in hours
  
  #required packages & scripts
  require(RColorBrewer)
  source("cline.R")
  
  #input checking, preliminaries:
  if (missing(which_vars)) {
    which_vars <- c("depth", "Acc", "pitch", "roll", "heading", "nmsa", 
                    "nodba", "verticalvelocity")
  }
  if (missing(mdists) | is.na(mdists)){
    npanels <- length(which_vars)
    plotmd <- FALSE
  }else{
    npanels <- length(which_vars) + 1
    plotmd <- TRUE
  }
  if (missing(withlegend)) withlegend <- FALSE
  
  #set up the figure window & color schemes:
  if (plotmd) {
    layout(matrix(data=c(1:npanels, npanels), nrow=npanels+1,
                  ncol=1, byrow=TRUE))
  }else{
    layout(matrix(data=c(1:npanels), nrow=npanels, 
                  ncol=1, byrow=TRUE))
  }
  par(mar=c(1,8,0,2), oma=c(5,8,3,0), las=1, lwd=2, cex=1,
      cex.lab=3, cex.axis=3, 
#      col.axis="white", col.lab="white",
#      font=2, col="white")
      col.axis="black", col.lab="black",
      font=2, col="black")
  colrs <- c("black", brewer.pal(8,"Set2"))
  pcols <- cbPalette[2:6]
  
  #calculations re: inputs
  whale <- try(tagdat[1,ID])
  if (class(whale)=="try-error"){whale <- "simwhale"}
  if (sim){
    setkey(tagdat,t) #make sure data are sorted by time
    #get indices to CEE period in tagdat matrix
    ceet <- which(tagdat$t >= min(cee.times) &
                    tagdat$t <= max(cee.times))
  }else{
  setkey(tagdat,cst) #make sure data are sorted by time
  #get indices to CEE period in tagdat matrix
  ceet <- which(tagdat$cst >= min(cee.times) &
                  tagdat$cst <= max(cee.times))
  }
  if (sim){
    hr <- (tagdat$t-min(tagdat$t))/3600
  }else{
    hr <- (tagdat$cst- min(tagdat$cst))/3600 
  }
  #get xlim to make sure they match for all panels
  xl <- c(0,hourlim)
  
  
  #################
  # MAKE PLOTS
  #################
  #Depth
  if ("depth" %in% which_vars){
  if (sim){
    plot(hr,tagdat$z, type="l", col="black", 
         ylab="", xlab="", xaxt="n", yaxt="n",
         ylim=c(2500,-50), xlim=xl)
    cline(hr,tagdat$z,tagdat$phase,pcols)
  }else{
    plot(hr,tagdat$depth, type="l", col="black", 
         ylab="",
         xlab="", xaxt="n", yaxt="n",
         ylim=c(2500,-50), xlim=xl)
    cline(hr,tagdat$depth,tagdat$phase,pcols)
  }
  axis(side=1,labels=FALSE,tick=TRUE)
  axis(side=2,labels=TRUE,tick=TRUE)
  mtext("Depth (m)", side=2, line=8, cex=3, las=3)
  }
  
  if ("Acc" %in% which_vars){
  #Ax, Ay, Az (NOT coloured by phase)
  plot(hr, tagdat$Ax, type="l", col="black",
       ylim=c(-1.2, 1.2), xlim=xl,
      ylab="" ,
       xlab="", xaxt="n", yaxt="n")
  lines(hr, tagdat$Ay, type="l", col="red")
  lines(hr, tagdat$Az, type="l", col="blue")
  axis(side=1,labels=FALSE,tick=TRUE)
  axis(side=2,labels=TRUE,tick=TRUE)
  mtext("Acc (g)", side=2, line=8, cex=3, las=3)
  }
  
  if ("pitch" %in% which_vars){
  #pitch
  plot(hr,tagdat$pitch/pi*180, type="l", col="black", 
       ylab="",
       xlab="", xaxt="n", yaxt="n",
       ylim=c(-180,180), xlim=xl)
  cline(hr,tagdat$pitch/pi*180,tagdat$phase,pcols)
  axis(side=1,labels=FALSE,tick=TRUE)
  axis(side=2,labels=TRUE,tick=TRUE)
  mtext(text=expression(Pitch*degree), side=2, line=8, cex=3, las=3)
  }
  
  if ("roll" %in% which_vars){
  #roll
  plot(hr,tagdat$roll/pi*180, type="l", col="black", 
       ylab="",
       xlab="", xaxt="n", yaxt="n",
       ylim=c(-180,180), xlim=xl)
  cline(hr,tagdat$roll/pi*180,tagdat$phase,pcols)
  axis(side=1,labels=FALSE,tick=TRUE)
  axis(side=2,labels=TRUE,tick=TRUE)
  mtext(text=expression(Roll*degree), side=2, line=8, cex=3, las=3)
  }
  
  if ("heading" %in% which_vars){
  #heading
  plot(hr,tagdat$heading/pi*180, type="l", col="black", 
       ylab="",
       xlab="", xaxt="n", yaxt="n",
       ylim=c(-180,180), xlim=xl)
  cline(hr,tagdat$heading/pi*180,tagdat$phase,pcols)
  axis(side=1,labels=FALSE,tick=TRUE)
  axis(side=2,labels=TRUE,tick=TRUE)
  mtext(text=expression(Heading*degree), side=2, line=8, cex=3, las=3)
  }
  
  if ("nmsa" %in% which_vars){
  #nMSA
  plot(hr,tagdat$nmsa, type="l", col="black", 
       ylab="",
       xlab="", xaxt="n", yaxt="n",
       ylim=c(0, 40), xlim=xl)#max(data$nmsa, na.rm=T)))
  cline(hr,tagdat$nmsa,tagdat$phase,pcols)
  axis(side=1,labels=FALSE,tick=TRUE)
  axis(side=2,labels=TRUE,tick=TRUE)
  mtext(text=expression(atop("nMSA " , paste("(", m, " ", sec^{-2}, ")"))), side=2, line=8, cex=3, las=3)
  }
  
  if ("nodba" %in% which_vars){
  #nODBA
  plot(hr,tagdat$nodba, type="l", col="black", 
       ylab="",
       xlab="", xaxt="n", yaxt="n",
       ylim=c(0, 15), xlim=xl)#max(data$nodba, na.rm=T)))
  cline(hr,tagdat$nodba,tagdat$phase,pcols)
  axis(side=1,labels=FALSE,tick=TRUE)
  axis(side=2,labels=TRUE,tick=TRUE)
  mtext(text=expression(atop("nODBA " , paste("(", m, " ", sec^{-2}, ")"))), side=2, line=8, cex=3, las=3)
  }
  
  if ("verticalvelocity" %in% which_vars){
  #vertical velocity
  plot(hr,tagdat$verticalvelocity, type="l", col="black", 
       ylab="", xlim=xl,
       xlab="", xaxt="n", yaxt="n",
       ylim=c(-3,3))
  cline(hr,tagdat$verticalvelocity,tagdat$phase,pcols)
  
  
  mtext(text=expression(atop("Vv " , paste("(", m, " ", sec^{-1}, ")"))), side=2, line=8, cex=3, las=3)
  }
  
  if (!plotmd){
    axis(side=1,labels=TRUE,tick=TRUE)
    if ("verticalvelocity" %in% which_vars){
    par(las=0)
    axis(side=2,labels=TRUE,tick=TRUE)
    }
    mtext("Time (h)", side=1, line=4, cex=4)
  }else{
    axis(side=1,labels=TRUE,tick=TRUE)
    axis(side=2,labels=FALSE,tick=TRUE)
  }
  
  if (plotmd){
    #M Dist
    yl <- c(0,max(mdists$dist, na.rm=T))
    mdt <- mdists$t/3600
    plot(x=0, y=0, ylab="M. Distance",
         xlab="", xlim=xl, ylim=yl, xaxt="n")
    rect(xleft=hr[ceet[1]], xright=hr[tail(ceet,1)],
         ybottom=yl[1], ytop=yl[2], col=colrs[9]) 
    lines(mdt, mdists$dist, col=colrs[1])
    #     lines(mdt[bli], dat$dist[bli], col=colrs[6]) 
    abline(h=thr, lty="dashed", lwd=2, col="lightgrey") #response thresh
    #   axis(side=1, labels = TRUE, tick=TRUE)
    #axis and main labels
    par(las=0)
    axis(side=2,labels=TRUE,tick=TRUE)
    mtext("Time (h)", side=1, line=4, cex=4)
  }
  
  #legend
  if (withlegend){
  if (plotmd){
    legend("topright", legend=c("Data", "CEE", "Baseline", "Response Threshold"), #"Threshold (max)"), 
           lwd=3, lty=c(rep("solid",3), "dashed"),#, "dotted"),
           border="black", bty="n", 
           col=c(colrs[c(1,9,6)], #"lightgrey",
                 "darkgrey"), cex=0.8)
  }else{
    legend("topright", legend=c("Data", "CEE"),  
           lwd=3, lty="solid",
           border="black", bty="n", 
           col=colrs[c(1,9)], cex=0.8)
  }
  }
}


    
