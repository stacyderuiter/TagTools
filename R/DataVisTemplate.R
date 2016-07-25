## ----setup, echo=FALSE, message=FALSE, results='hide'--------------------
require(RColorBrewer)
require(R.matlab)
require(stringr)
#require(gdata)
require(lubridate)
opts_chunk$set(fig.width=6.5, fig.height=8, cache=FALSE )
source("cline.R")

## ----whichwhale----------------------------------------------------------
#select whale of interest
#(shouldn't need to change other things when changing whales)
whale <- 'gg13_266b'
#also need to enter tag number for D_plusmockdata.mat!
tagnum <- 22

## ----meta_in-------------------------------------------------------------
meta <- read.csv(file='Experiment_timeline_SOCAL_GG.csv')
#get tag on day in R "date" format
meta[,'Date'] <- dmy(meta[,'Date'], tz="America/Los_Angeles")
#get tag record start time in R "time" format
meta[,"TagRecordStartLocal"]<- hms(meta$TagRecordStartLocal,tz="America/Los_Angeles")[1:nrow(meta)]
tagstart <- meta[meta$Tag.ID==whale, "Date"] + 
  meta[meta$Tag.ID==whale, "TagRecordStartLocal"]
tagon <- meta[meta$Tag.ID==whale, "Date"] + 
  meta[meta$Tag.ID==whale, "TagRecordStartLocal"] +
  meta[meta$Tag.ID==whale, "TagOnWhaleSecSinceStart"]
tagoff <- meta[meta$Tag.ID==whale, "Date"] + 
  meta[meta$Tag.ID==whale, "TagRecordStartLocal"] +
  meta[meta$Tag.ID==whale, "TagOffWhaleSecSinceStart"]
exp.start <- tagon + meta[meta$Tag.ID==whale, "ExposureStartSec"]
exp.end <- tagon + meta[meta$Tag.ID==whale, "ExposureEndSec"]

## ----dive_data_in--------------------------------------------------------
D <- data.frame(readMat('D_plusmockdata.mat'))
names(D) <- str_replace_all(unlist(readMat('D_column_headings.mat')),"\\s+","_")
#get whale of interest only
D <- subset(D, subset=tag_nr==tagnum)

## ----social_data_in------------------------------------------------------
soc = read.csv("SOCIAL_BEHAVIOUR_DATA_compiled_290416.csv")
#get subset of data
#only for whale of interest
soc <- subset(soc, subset=Tag_ID==whale)
#make the date-time a date-time object in R
datetimes <- ydm_hms(soc[,3], tz="America/Los_Angeles")
datetimes[is.na(datetimes)] <- dmy_hms(soc[,3], tz="America/Los_Angeles")[is.na(datetimes)]
datetimes[is.na(datetimes)] <- mdy_hm(soc[,3], tz="America/Los_Angeles")[is.na(datetimes)]
soc$DATETIME_local <- datetimes

## ----prh_data_in---------------------------------------------------------
prh <- data.frame(readMat(paste(whale, 'prh.mat', sep="")))
#add seconds-since-tag-recording-start to prh data
prh$cst <- c(0:(nrow(prh)-1))/prh$fs[1]
#add datetime to prh data
prh$time <- tagon + seconds(c(1:nrow(prh))/prh$fs[1])
#add dive type data to PRH file
prh$diveclass <- "surface" #1-shallow, 2-deep
classes <- c("shallow", "deep")
for (k in 1:nrow(D)){
  prh$diveclass[ prh$cst > D[k,"start_dive"] &
    prh$cst <= D[k, "end_dive"]] <- 
    classes[D[k,"dive_class"]]  
}
prh$diveclass <- factor(prh$diveclass)
levels(prh$diveclass) <- union(levels(prh$diveclass), c("surface", "shallow", "deep"))
prh$diveclass <- relevel(prh$diveclass, ref="shallow")
prh$diveclass <- relevel(prh$diveclass, ref="surface")
#add MSA to PRH data
prh$MSA <- as.numeric(9.81*abs(sqrt(prh[,grep('A.', names(prh), fixed=TRUE)]^2 %*% matrix(c(1,1,1),nrow=3))-1) )

## ----audit_data_in-------------------------------------------------------
audit <- read.table(file= paste(whale, 'aud.txt', sep=''), 
                    header=FALSE, sep="\t")
names(audit) <- c("cst", "duration", "type")
#add sounds to prh dataset
#round audit call times to 1/10 of a second
audit$cst <- lapply(audit$cst, FUN=function(x) 
  prh$cst[which.min(abs(prh$cst-x))])
prh <- merge(prh, audit, all.x=TRUE)

## ----plots---------------------------------------------------------------
#to save the plot as a hi-res jpg,
# (to the current working directory)
#change save_plot to TRUE:
save_plot <- TRUE
if (save_plot){
  jpeg(filename = paste(soc$Tag_ID[1], "_timeseries.jpg", sep=""),
       width = 6, 
       height = 8, 
       units = "in", 
       pointsize = 12,
       quality = 75,
       bg = "white", 
       res = 300)
}
#colors to use
colrs <- brewer.pal(8, 'Set2')
## Add an alpha value to a colour
add.alpha <- function(col, alpha=1){
  if(missing(col))
    stop("Please provide a vector of colours.")
  apply(sapply(col, col2rgb)/255, 2, 
                     function(x) 
                       rgb(x[1], x[2], x[3], alpha=alpha))  
}

#make the actual plot:
#set up number of panels
layout(matrix(data=c(1,1,1,2,2,3,4,5,5),
              nrow=9, ncol=1, byrow=TRUE))
par(mar=c(1,5,0,0), 
    oma=c(2,0,2,1), 
    las=1, lwd=2, cex=1)
#figure out what x limits should be
#(Time axis)
endplot <- ifelse(is.na(tagoff), max(prh$time), tagoff)
xl <- as.numeric(c(tagon,endplot))

#top: dive profile
yl <- c(max(prh$p)+0.1*max(prh$p),0)
plot(x=0, y=0, type='l', col=colrs[8],
     xlab="", ylab="Depth (m)",
     xaxt="n", xlim=xl,
     ylim=yl)
axis.POSIXct(side=1, x=prh$time,
             labels = FALSE)
# add lines for start/end of exposure
abline(v=exp.start, lty='dashed', col=colrs[8])
abline(v=exp.end, lty='dashed', col=colrs[8])


#add dive profile line
cline(x=prh$time, y=prh$p, z=prh$diveclass,
      color_vector=colrs[c(8,3,1)] )

#add call types
#want to show wbp, bp, and buzz
#wbps
wbpi <- which(prh$type=='whistlebp')
points(x=tagon+prh$cst[wbpi],
       y=prh$p[wbpi], pch=21, 
       col='black', lwd=1,
       bg=colrs[2], cex=0.6)
#bp
bpi <- which(prh$type=='bp')
points(x=tagon+prh$cst[bpi],
       y=prh$p[bpi], pch=22, lwd=1, 
       col='black', bg=colrs[4], cex=0.6)
#buzz
buzzi <- which(prh$type=='buzz')
points(x=tagon+prh$cst[buzzi],
       y=prh$p[buzzi], pch=23, lwd=1,
       col='black', bg=colrs[6], cex=0.6)
#legend for dive profile
whichtypes <- as.numeric(unique(prh$diveclass))
legend('bottomleft', cex=0.75,
       bty='n',#no box around legend
       legend=c( c("Surface", "Shallow", "Deep")[whichtypes],
                "WhistleBP", "BP", "Buzz"),
       x.intersp=0.5, #makes small spacing between legend items
       col=c( colrs[c(8,3,1)[whichtypes]], colrs[c(2,4,6)] ),
       horiz=TRUE, 
       lwd=c(rep(2, length(whichtypes)),NA, NA, NA), 
       pch=c(rep(NA, length(whichtypes)), 21,22,23))

#PRH data
par(lwd=1)
plot(x=prh$time, y=prh$MSA, xlim=xl,
     col=colrs[8], type='l',
     xaxt='n', ylab='MSA (m/sec/sec)', xlab='' )

# add lines for start/end of exposure
abline(v=exp.start, lty='dashed', col=colrs[8])
abline(v=exp.end, lty='dashed', col=colrs[8])

axis.POSIXct(side=1, x=prh$time,
             labels = FALSE)
# plot(x=prh$time, y=prh$pitch*180/pi, xlim=xl,
#      ylim=c(-210, 230), col=colrs[1], type='l',
#      xaxt='n', ylab='Degrees' )
# axis.POSIXct(side=1, x=prh$time,
#              labels = FALSE)
# lines(x=prh$time, y=prh$roll*180/pi, 
#       col=add.alpha(colrs[2], 0.6))
# lines(x=prh$time, y=prh$head*180/pi, 
#       col=add.alpha(colrs[3], 0.6))
# legend("top", lwd=2, cex=0.75, bg='white' , bty='n', 
#        legend=c("Pitch", 'Roll', "Heading"),
#        col=c(colrs[c(1,2,3)]), horiz=TRUE)

#group size, n in area, spacing
yl <- c(0, max(c(soc$GRSIZE_BEST, 
                   soc$NR_200M), na.rm=TRUE))
plot(x=soc$DATETIME_local, y=soc$GRSIZE_BEST,
      xlim=xl, ylim=yl, col=colrs[1], 
     type='s', lwd=2, xaxt='n',
     xlab="", ylab='Count')
points(x=soc$DATETIME_local, y=soc$GRSIZE_BEST,
      col=colrs[1], type='p',pch=19)
axis.POSIXct(side=1, x=soc$DATETIME_local,
             labels = FALSE)
lines(x=soc$DATETIME_local, y=soc$NR_200M,
      col=add.alpha(colrs[2],0.6), type='s', lwd=2)
points(x=soc$DATETIME_local, y=soc$NR_200M,
      col=colrs[2], type='p',pch=19)

# add lines for start/end of exposure
abline(v=exp.start, lty='dashed', col=colrs[8])
abline(v=exp.end, lty='dashed', col=colrs[8])

legend('topleft', lwd=2, col=colrs[c(1,2)],
       legend=c("Group Size", "Number in Area"),
       bty='n', cex=0.6)
# (spacing)
plot(x=soc$DATETIME_local, y=soc$IND_SPACING,
      xlim=xl, col=colrs[1], 
     type='s', pch=19, lwd=2, xaxt='n',
     xlab="", ylab='Spacing')
points(x=soc$DATETIME_local, y=soc$IND_SPACING,
      col=colrs[1], type='p',pch=19)
axis.POSIXct(side=1, x=soc$DATETIME_local,
             labels = FALSE)

# add lines for start/end of exposure
abline(v=exp.start, lty='dashed', col=colrs[8])
abline(v=exp.end, lty='dashed', col=colrs[8])


#display events: Log, SH, TS, BR, IC, HB, FD
disps <- c("LOG_PR", "SH_PR",  "TS_PR",  "BR_PR",
           "IC_PR",  "HB_PR", "FD_PR" )
disp.names <- c('Log', 'Spyhop', 'Tail Slap',
                'Breach', 'In Contact',
                'Head Bang', 'Fast Dive')
plot(x=soc$DATETIME_local, y=rep(NA, nrow(soc)),
      xlim=xl, ylim=c(0,8), axes=FALSE,
     xlab='', ylab='')
axis.POSIXct(side=1, x=soc$DATETIME_local,
             labels = TRUE)
mtext('Local Time', side=1, line=2)
mtext(soc$Tag_ID[1], side = 3, 
      line=0, adj = 0.5, outer=TRUE) #add super title (tag ID)
axis(side=2, at=c(1:7), labels=disp.names,
     las=1, cex.axis=0.8)

# add lines for start/end of exposure
abline(v=exp.start, lty='dashed', col=colrs[8])
abline(v=exp.end, lty='dashed', col=colrs[8])

for (d in 1:length(disps)){
  ix <- which(soc[,disps[d]]==1)
  lines(x=xl,
        y=rep(d, 2), 
        lty='dashed', lwd=0.5, col=colrs[8])
  points(x=soc$DATETIME_local[ix],
         y=d*soc[ix,disps[d]], pch=19,
         col=colrs[d])
}

if (save_plot){dev.off()}

