panel_plot <- function(data, time, variables=names(data), 
                      panel_size=NULL, events=NULL,
                      event_panels=NULL, panel_labels=NULL,
                      xlab=NULL, xlim=NULL ){
  
  if (is.null(panel_size)){panel_size <- rep.int(1, length(variables))}
  if (is.null(panel_labels)){panel_labels <- variables}
  if (is.null(xlim)){xlim <- range(time)}
  
  tz <- attr(time,"tzone")
  
  pdata <- data[data$time >= min(xlim) & data$time <= max(xlim),]
  ptime <- time[data$time >= min(xlim) & data$time <= max(xlim)]
  
  layout(matrix(c(1:length(variables)), ncol=1),
         widths=rep.int(1, length(variables)), 
         heights=panel_size)
  par(mar=c(1,5,0,0), oma=c(2,0,2,1), las=1, lwd=1, cex=0.8)
  
  for (i in 1:length(variables)){
    if (variables[i]=='p'){ylim=c(1.1*max(pdata[,variables[i]], na.rm=TRUE), 0)
    }else{ylim=range(data[,variables[i]], na.rm=TRUE)}
    plot(x=ptime, y=pdata[,variables[i]], ylab=panel_labels[i],
         xaxt="n", xlim=xlim, type='l', ylim=ylim)
    if (i < length(variables)){
      axis.POSIXct(side=1, x=ptime, labels = FALSE)
    }else{
      axis.POSIXct(side=1, x=ptime, labels = TRUE,
                   format='%H:%M:%S')
    }
  }
  

}