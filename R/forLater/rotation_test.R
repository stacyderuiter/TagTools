## NOT DONE - need to make generic!------------------------------------------------------------------------
#should take a list of event times and a function to compute a test statistic.
#also a simple alternative for event counts during a certain time? or just make that an example?
#then it rotates the times (optionally respecting an "ID" variable?)
#using rotate sub-function?

rotation_test <- function(times, types, test.type){
  #times is a variable containing call start times
  #types is a variable with labels that divide the times into groups
  #test.type is the value of "types" of interest (here , A2)
  
  #find total duration of deployment (start time to start of last call)
  total.dur <- max(times,na.rm=TRUE) 
  #a random fraction of the total duration by which to rotate the times of A2 calls
  rot.dur <- runif(1, min=0, max=total.dur)
  #allocate space for new, rotated call times
  rtimes <- times
  #rotate times of A2 calls by rot.dur amount
  rtimes[types==test.type] <-
        rtimes[types==test.type] + rot.dur
  #some calls will now fall after the "end" of the deployment. Subtract rot.dur from those times to move them back "within" the deployment time, at the start
  rtimes[rtimes > total.dur] <- 
        rtimes[rtimes > total.dur] - total.dur
  #put results in a data frame
  rotated.data <- data.frame(rtypes=types,
                             rtimes=rtimes)
  #sort in (rotated) time order
  rotated.data <- rotated.data[order(rtimes),]
  #result will be the data frame
  #containing variables types and times
  return(rotated.data)
}

## ------------------------------------------------------------------------
N <- 100
#loop over all tags
rotated.stats <- list()
deployment.pvals <- numeric(length=length(fnames))
ts.data <- numeric(length=length(fnames))
for (t in 1:length(fnames)){
  #read in data file using openxlsx package
  calls <- read.xlsx(xlsxFile=fnames[t],
                     detectDates=TRUE)

  #get "time since start" variable
  converter <- data.frame(hour=c(1,2,3,4),
                          start.sec=c(0,7200, 14400, 21600))
  #the following assumes that the file is sorted by ascending day (1st day, 2nd day, etc) and that the "hour" designations are the same for all days.
  calls$CTime <- calls$BeginTime -
    #convert to seconds since start of hour
    converter[calls$HourNumber,'start.sec'] +
    #then convert to seconds within day
    #(counting only analysed hours)
    (calls$HourNumber-1)*3600 +
    #then add 4 hours per day (so day 2 starts right at the end of day 1)
    4*3600*as.numeric(calls$Date-calls$Date[1])
    
  ts.data[t] <- get.ts(times=calls$CTime,
                    types=calls$SoundType,
                    test.type='A2')
  ts.rot <- numeric(length=N)
  for (n in c(1:N)){
    r <- rotate(times=calls$CTime,
                types=calls$SoundType,
                test.type='A2')
    ts.rot[n] <- get.ts(times=r$rtimes,
                        types=r$rtypes,
                        test.type='A2')
  }
  hist(ts.rot)
  deployment.pvals[t] <- sum(ts.rot <=
                               ts.data[t])/N
  rotated.stats[[t]] <- ts.rot 
}
#print out results: p-value of test by individual deployment
deployment.pvals
#here is where we would compute a modified test statistic for "all deployments" if desired, for example the median test stat averaged over all deployments, and then compute a p-value.


