# some helper functions for caclulating dive
# variables
require(CircStats)
#in all cases,
# i1 and i2 are the (scalar) start and end times of interest
# units of i1 and i2 are SAMPLES (not seconds, minutes, etc)

#find maximum depth
#(or max of any measured quantity 
# over a certain interval)
zmax <- function(i1, i2, full.depth.profile) {
  z <- full.depth.profile[i1:i2]
  zm <- max(z)
}

# sfs is the sampling frequency in Hz of the data
# prop is the proportion of maximum depth that is the
#   threshold for bottom time (so bottom time lasts from the
#   first to the last time prop*maxdepth is exceeded.)
# calculate the ascent rate in m/sec
# (dive profile data units should be metres)
arate <- function(i1, i2, full.depth.profile, sfs, prop) {
  if (missing(prop)) {prop<-0.85}
  z <- full.depth.profile[i1:i2]
  ed <- which(z > prct * max(z))
  sa <- tail(ed, 1)
  dz.a <- z[sa] - tail(z, 1)
  dt.a <- (length(z) - sa)/sfs
  ar <- dz.a/dt.a
  return(ar)
}

#similar to above - for descent rate
drate <- function(i1, i2, full.depth.profile, sfs, prop) {
  if (missing(prop)) {prop<-0.85}
  z <- full.depth.profile[i1:i2]
  ed <- which(z > prop * max(z))
  ed <- ed[1]
  dz.d <- z[ed] - z[1]
  dt.d <- ed/sfs
  dr <- dz.d/dt.d
  return(dr)
}

#calculate bottom time in minutes
# prop is the proportion of maximum depth that is the
#   threshold for bottom time (so bottom time lasts from the
#   first to the last time prop*maxdepth is exceeded.)
bottomt <- function(i1, i2, full.depth.profile, sfs, prop){
  if (missing(prop)){prop <- 0.85}
  z <- full.depth.profile[i1:i2]
  ed <- which(z > prop * max(z))
  bt <- (tail(ed,1) - head(ed,1)) * (1/sfs) * (1/60) 
  return(bt)
}

#find (circular) mean value of an angle over an interval
# angle.data and depth.data should be sampled at same rate
# prop is the proportion of maximum depth that is the
#   threshold for bottom time (so bottom time lasts from the
#   first to the last time prop*maxdepth is exceeded.)
mean.angle <- function(i1, i2, angle.data, depth.data, 
                       type, prop) {
  if (missing(prop)){prop <- 0.85}
  # type can be 'ascent' 'descent' 'dive'
  if (grepl("dive", type, ignore.case = TRUE)) {
    pd.mean <- circ.mean(angle.data[i1:i2])
  }
  if (grepl("ascent", type, ignore.case = TRUE)) {
    z <- depth.data[i1:i2]
    ed <- which(z > (prop * max(z)))
    sa <- tail(ed, 1)
    pd.mean <- circ.mean(angle.data[(i1 + sa):i2])
  }
  if (grepl("descent", type, ignore.case = TRUE)) {
    z <- depth.data[i1:i2]
    ed <- which(z > (prop * max(z)))
    ed <- ed[1]
    pd.mean <- circ.mean(angle.data[i1:(i1 + ed)])
  }
  return(pd.mean)
}

#find (circular) variance of angle data (in radians)
# over an interval
angle.var <- function(i1, i2, angle.data) {
  pd <- angle.data[i1:i2]
  pv <- circ.disp(pd)
  return(as.vector(pv$var))
}

#given a time "cst" in seconds-since-start-of record
# and a list of event-start-times "dstarts" also in seconds
# find the dive number for the dive starting at "cst" seconds
find.dnum <- function(cst, dstarts) {
  da <- which(dstarts >= cst)
  dnum <- da[1] - 1
}
