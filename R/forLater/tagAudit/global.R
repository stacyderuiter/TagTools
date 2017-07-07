#code to run once at outset:
# data now hard coded. need to add data as input later (once data structure given)
############################################################################
require(R.matlab)

dat0 <- readMat('data/bp13_258cprh.mat')
dat <- data.frame(Ax=dat0$A[,1], Ay=dat0$A[,2], Az=dat0$A[,3],
                  head=dat0$head, p=dat0$p) 
calfname <- 'data/bp13_258ccal.xml'
require(XML)
xmlcal <- xmlTreeParse(calfname)#need to read dtag xml cal file to get start time. 
#get tag record start time
tagon0 <- xmlValue(xmlcal[[1]][[1]][[6]][[5]])
tagon <- as.POSIXct(strptime(tagon0, 
                             format="%Y %m %d %H %M %OS", 
                             tz="UTC"))#convert to Posix
#convert to local time
attr(tagon, "tzone") <-  "America/Los_Angeles"  
audit <- readMat('data/bp13_258c_lunges.mat')
ltimes <- sort(audit$time)
options(digits.secs=5)
source('../matlab2POS.R')
source('../panel_plot.R')

ltimes <- matlab2POS(ltimes,timez='America/Los_Angeles')
dat$time <- tagon + c(1:length(dat0$p))/rep(dat0$fs, length=length(dat0$p))
#######################################################################
