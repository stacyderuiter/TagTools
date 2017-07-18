#' Carry out a rotation test (as applied in Miller et al. 2004 and detailed in DeRuiter and Solow 2008). This test is a
#' variation on standard randomization or permutation tests that is appropriate for time-series of non-independent events 
#' (for example, time series of behavioral events that tend to occur in clusters). This implementation of the rotation test compares a test statistic (some summary of
#' an "experimental" time-period) to its expected value during non-experimental periods. Instead of resampling random subsets of observations from the original dataset,
#' the rotation test samples many contiguous blocks from the original data, each the same duration as the experimental period. The summary statistic,
#' computed for these "rotated" samples, provides a distribution to which the test statistic from the data can be compared.
#' 
#' @param event_times A vector of the times of events. Times can be given in any format. If \code{event_times} should not be sorted prior to analysis (for example, if times are given in hours of the day and the times in the dataset span several days), be sure to specify \code{skip_sort=TRUE}.
#' @param test_period A two-column vector, matrix, or data frame specifying the start and end times of the "experimental" period for the test. If a matrix or data frame is provided, one column should be start time(s) and the other end time(s),
#' @param n_rot Number of rotations (randomizations) to carry out. Default is \code{n_rot=10000}.
#' @param ts_fun A function to compute the test statistic. Input provided to this function will be the times of events that occur during the "experimental" period.  The default function is \code{length} - in other words, the default test statistis is the number of events that happen during the experimental period.
#' @param skip_sort Logical. Should times be sorted in ascending order? Default is \code{skip_sort=FALSE}.
#' @param return_CI Logical. Should output include a percentile-based block-bootstrap (rotation) confidence interval for the observed test statistic? Default is \code{boot_CI=TRUE}.
#' @param conf_level Confidence level to be used for the bootstrap CI calculation, specified as a proportion. (default is \code{conf_level=0.95}, or 95\% confidence.)
#' @param return_rot_stats Logical. Should output include the test statistics computed for each rotation of the data? Default is \code{return_rot_stats=FALSE}.
#' @param ... Additional inputs to be passed to \cod{ts_fun}
#' @return A list containing the following components:
#'   \item{result}{A one-row data frame with rows:
#'      \item{statistic}{Test statistic (from original data)}
#'      \item{p_value}{P-value of the test}
#'      \item{n_rot}{Number of rotations}
#'      \item{CI_low}{Lower bound on confidence interval}
#'      \item{CI_up}{Upper bound on confidence interval}
#'      \item{conf_level}{Confidence level, as a proportion}
#'      }
#'   \item{rot_stats}{(If \code{return_rot_stats} is TRUE), a vector of \code{n_rot} statistics from the rotated datasets}
#' @export
#' @references
#'    @bibliography TagTools.bib
#'    @cite Miller2004
#'    @cite Deruiter2008
#' @seealso Advanced users seeking more flexibility may want to use the underlying function \code{\link{rotate}} to carry out customized rotation resampling. \code{\link{rotate}} generates one rotated dataset from \code{event_times} and \code{test_period}.
#' @examples 

rotation_test <- function(event_times, test_period, n_rot=10000, test_ID=NULL, 
                          ts_fun=length, skip_sort=FALSE, return_CI=TRUE, 
                          conf_level=0.95, return_rot_stats=FALSE, ...)  
  # Input checking
  #============================================================================
  if (missing(event_times) | missing(test_period)){
    stop('event_times and test_period are required inputs.')
  }
  
  if (sum(is.na(test_period)) > 0){
      stop('start/end times in can not contain any missing (NA) values.')
  }
 
# arrange test_period as a data frame with columns st and et (start and end time(s))
  if (length(test_period) > 2){
    test_period <- data.frame(test_period)
    names(test_period) <- c('st', 'et')
  }else{
    test_period <- data.frame(st=min(test_period), et=max(test_period))
  }
# sort times if skip_sort is FALSE
  if (skip_sort=='FALSE'){
    event_times <- event_times[order(event_times)]
  }
  
# Carry out rotation test
#==================================================================

#compute test statistic for observed dataset
get.ts <- 
  
  #find TS for n_rot rotations
  
  #find p-value
  #compute CI if boot_CI=TRUE
  #make results data.frame
                          
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


