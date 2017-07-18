preyCatchAttemptBehaviours <- function (x, x2, fs, fc, timeDays = 0) 
  
  #########################################################
## Method to identify prey catch attempt behaviours at 1 second intervals.
## Based on:
# - Viviant, M., A. W. Trites, D. A. S. Rosen, P. Monestiez, and C. Guinet. 2010. Prey capture attempts can be detected in Steller sea lions and other marine predators using accelerometers. Polar Biol. 33: 713–719.

## x = data.table object containing c("time", "ax", "ay", "az", "segementID").
# - where time is denoted in 1 second blocks/groupings as posixct.
## x2 = segmentID identifying continuous time segments.
## fs = sampling frequency of signal (default is 16Hz).
## fc = frequency above which signals across x, y and z axes are retained. 
## timeDays = time period over which kmeans (clustering of negative and postiive prey catch attempt behaviours) should be performed.  Leave as zero to have no time grouping in kmeans generation.
#########################################################

{
  stopifnot(require("data.table"))
  stopifnot(require("signal"))
  stopifnot(require("RcppRoll"))
  
  timeRef <- copy(x$time)
  
  if(timeDays != 0){
    timeSinceStart <- timeRef - rep(timeRef[1],length(timeRef))
    timeSinceStart <- as.numeric(timeSinceStart)/(24*60*60)
    refMax <- floor(max(timeSinceStart)/timeDays)
    refBreak <- (seq(from = 0, to = refMax, by = 1)* timeDays)
    refBreak[refMax+1] <- refBreak[refMax+1] + timeDays
    rm(refMax)
    
    timeBin <- .bincode(timeSinceStart, breaks = refBreak, right = FALSE, include.lowest = TRUE)
    rm(refBreak, timeSinceStart)
  }
  
  bf_pca <- butter(3, W = fc/(0.5 * fs), type = "high")
  if (!is.data.table(x)) 
    x <- data.table(x, key = "time")
  .f <- function(x) as.numeric(filtfilt(bf_pca, x))
  x <- x[, `:=`(2:4, lapply(.SD, .f)), by = x2, .SDcols = 2:4]
  rm(.f)
  gc()
  
  nas <- lapply(x[, 2:4, with = FALSE], is.na)
  nas_vector <- Reduce("|", nas)
  if (any(nas_vector)) {
    warning("NAs found and replaced by 0. NA proportion:", 
            mean(nas_vector))
    x$ax[nas$ax] <- 0
    x$ay[nas$ay] <- 0
    x$az[nas$az] <- 0
  }
  gc()
  
  .f <- function(x, fs) c(rep(0, floor((floor(1.5*fs)/2))), roll_sd(x, ceiling(1.5 * fs)), rep(0, floor((ceiling(1.5*fs)/2))))
  x <- x[, `:=`(2:4, lapply(.SD, .f, fs = fs)), .SDcols = 2:4]
  rm(.f)
  gc()
  
  .f <- function(x) {
    km_mod <- kmeans(x, 2)
    high_state <- which.max(km_mod$centers)
    logicalHigh <- as.logical(km_mod$cluster == high_state)
    return(as.numeric(logicalHigh))
  }
  
  if(timeDays != 0){
    x <- x[, `:=`(2:4, lapply(.SD, .f)), by = timeBin, .SDcols = 2:4]
  } else {
    x <- x[, `:=`(2:4, lapply(.SD, .f)), .SDcols = 2:4]
  }
  
  x <- as.numeric(Reduce("&", x[, `:=`(time, NULL)]))
  
  temp_x <- data.frame(pca = x, time = timeRef)
  rm(timeRef)
  
  temp_x <- as.data.table(temp_x)
  setkey(temp_x, time)
  
  temp_x <- temp_x[, lapply(.SD, max), by = time, .SDcols = "pca"]
  return(temp_x)
  
}