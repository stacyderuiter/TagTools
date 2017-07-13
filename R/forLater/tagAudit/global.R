#code to run once at outset:
# data now hard coded. need to add data as input later (once data structure given)
############################################################################
library(R.matlab)
library(readr)

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


dolphin <- list(faces = 1 + as.matrix(read_delim(file='data/dolphin.knx', delim=' ', 
                                   col_names=c('tab', 'junk', 'v1', 'v2', 'v3', 'v4'))[,c(3:5)]),
                vertices = as.matrix(read_delim(file='data/dolphin.pts', delim=' ', 
                                      col_names=c('tab', 'junk1', 'junk2', 'junk3', 'x', 'y', 'z'))[,c(5:7)]))
                
dolphin$vertices[,1] <- -1*dolphin$vertices[,1]
#note: tmesh3d expects one COLUMN per vertex or face
#so need to transpose inputs if they have one ROW per.
dolphin$mesh  <- tmesh3d(t(asHomogeneous(dolphin$vertices)), t(dolphin$faces), homogeneous = TRUE)
#make 3d plot and rotate it using RGL?

prh <- matrix(data=seq(from=0,to=2*pi,length.out=100), ncol=1) %*%
  matrix(data=c(0, 1, 0), nrow=1)
shade3d(dolphin$mesh, col='grey54')
view3d(userMatrix=rotationMatrix(matrix=rotmatrix(eulerzyx(0,0,pi/2))@x[,,1]))
library(orientlib)
#view3d(userMatrix=rotationMatrix(matrix=rotmatrix(eulerzyx(0,pi/6,0))@x[,,1])
for (k in c(1:nrow(prh)){
  Q <- rotmatrix(eulerzyx(prh[k,3], prh[k,1], prh[k,2]))@x[,,1]
  view3d(userMatrix=rotationMatrix(matrix=Q))
  sys.sleep(0.1)
    #euler2rotmat(p=prh[,1], r=-prh[,2], h=-prh[,3])
}
view3d(userMatrix=rotationMatrix(matrix=Q[,,2])))

Q = euler2rotmat(prh(k,:))' ;
tpts = F.P*Q ;
set(F.p,'Vertices',[tpts(:,1) -tpts(:,2) tpts(:,3)]) ;
