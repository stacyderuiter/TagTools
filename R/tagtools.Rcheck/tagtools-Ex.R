pkgname <- "tagtools"
source(file.path(R.home("share"), "R", "examples-header.R"))
options(warn = 1)
options(pager = "console")
base::assign(".ExTimings", "tagtools-Ex.timings", pos = 'CheckExEnv')
base::cat("name\tuser\tsystem\telapsed\n", file=base::get(".ExTimings", pos = 'CheckExEnv'))
base::assign(".format_ptime",
function(x) {
  if(!is.na(x[4L])) x[1L] <- x[1L] + x[4L]
  if(!is.na(x[5L])) x[2L] <- x[2L] + x[5L]
  options(OutDec = '.')
  format(x[1L:3L], digits = 7L)
},
pos = 'CheckExEnv')

### * </HEADER>
library('tagtools')

base::assign(".oldSearch", base::search(), pos = 'CheckExEnv')
base::assign(".old_wd", base::getwd(), pos = 'CheckExEnv')
cleanEx()
nameEx("a2pr")
### * a2pr

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: a2pr
### Title: Pitch and roll from acceleration
### Aliases: a2pr

### ** Examples

## Not run: 
##D samplematrix <- matrix(c(0.77, -0.6, -0.22, 0.45, -0.32, 0.99, 0.2, -0.56, 0.5), 
##D                        byrow = TRUE, nrow = 3)
##D list <- a2pr(samplematrix)
## End(Not run)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("a2pr", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("absorption")
### * absorption

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: absorption
### Title: Calculates the absorption coefficient for sound in seawater
### Aliases: absorption

### ** Examples

absorption(140e3,13,10)
         #Returns: 0.04354982 dB



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("absorption", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("acc_wgs84")
### * acc_wgs84

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: acc_wgs84
### Title: Calculate total acceleration
### Aliases: acc_wgs84

### ** Examples

acc_wgs84(50)
         #Returns: 9.8107 m/s^2



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("acc_wgs84", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("add_nc")
### * add_nc

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: add_nc
### Title: Save an item to a NetCDF or add one tag sensor or metadata
###   variable to a NetCDF archive file. Add one tag sensor or metadata
###   variable to a NetCDF archive file. If the archive file does not
###   exist, it is created. The file is assumed to be in the current
###   working directory unless a pathname is added to the beginning of
###   fname.
### Aliases: add_nc

### ** Examples

 ## Not run: 
##D  #if A is in workspace,
##D  #add_nc('dog17_124a',A)
##D  # generates a file dog17_124a.nc (if it does not already exist) and adds a variable A.
## End(Not run)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("add_nc", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("apply_cal")
### * apply_cal

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: apply_cal
### Title: Implement a calibration on tag sensor data
### Aliases: apply_cal

### ** Examples

#coming soon!



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("apply_cal", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("block_acf")
### * block_acf

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: block_acf
### Title: Compute autocorrelation function
### Aliases: block_acf
### Keywords: assessment correlation, model visualization,

### ** Examples

block_acf(resids=ChickWeight$weight, 
          blocks=ChickWeight$Chick)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("block_acf", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("block_mean")
### * block_mean

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: block_mean
### Title: Compute mean of sample blocks
### Aliases: block_mean

### ** Examples

samplematrix <- matrix(c(1,3,5,7,9,11,13,15,17), byrow = TRUE, ncol = 3)
         list <- block_mean(samplematrix, n = 3, nov = 1)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("block_mean", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("block_rms")
### * block_rms

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: block_rms
### Title: Compute RMS of sample blocks
### Aliases: block_rms

### ** Examples

X <- matrix(c(1:20), byrow = TRUE, nrow = 4)
block_rms(X, n = 2, nov = NULL)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("block_rms", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("body_axes")
### * body_axes

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: body_axes
### Title: Generate the cardinal axes of an animal
### Aliases: body_axes

### ** Examples

samplematrix1 <- matrix(c(7,2,3,6,4,9), byrow = TRUE, ncol = 3)
         samplematrix2 <- matrix(c(6,5,3,4,8,9), byrow = TRUE, ncol = 3)
         W <- body_axes(A = samplematrix1, M = samplematrix2, fc = NULL)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("body_axes", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("buffer")
### * buffer

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: buffer
### Title: Buffers a signal vector into matrix
### Aliases: buffer

### ** Examples

x <- c(1:10)
         n <- 3
         p <- 2
         opt <- c(2,1)
         list1 <- buffer(x, n, p, opt)
         list2 <- buffer(x, n, p, nodelay = TRUE)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("buffer", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("check_AM")
### * check_AM

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: check_AM
### Title: Compute field intensity of tag acceleration and magnetometer
###   data.
### Aliases: check_AM

### ** Examples

## Not run: 
##D AMcheck <- check_AM(A=matrix(c(-0.3,0.52,0.8), nrow=1),
##D                     M=matrix(c(22,-22,14), nrow=1),
##D                     fs=1)
##D #returns AMcheck$fstr = 1.0002, 34.11744 and AMcheck$incl = 0.20181 radians
## End(Not run)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("check_AM", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("cline")
### * cline

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: cline
### Title: Add colored line segments to a plot
### Aliases: cline
### Keywords: time-series visualization,

### ** Examples

cline(x=ChickWeight$Time, y=ChickWeight$weight, 
      z=as.factor(ChickWeight$Diet), 
      color_vector=c('black', 'grey20', 
                     'grey50', 'grey70'))



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("cline", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("crop")
### * crop

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: crop
### Title: Interactive data cropping tool.
### Aliases: crop

### ** Examples

data <- beaked_whale
         Pc <- crop(data$P)		#interactively select a section of data
         Ydata <- list(depth = Pc$Y)
         plott(Ydata)
         #plot shows the cropped section



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("crop", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("crop_all")
### * crop_all

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: crop_all
### Title: Reduce the time span of a dataset
### Aliases: crop_all

### ** Examples

d <- find_dives(beaked_whale$P,300)
         X <- crop_all(c(d$start[1], d$end[1]), beaked_whale)	#crop all data to 1st dive
         plott(X=list(X$P, X$A), r = c(1,0), panel_labels=c('Depth', 'Acc'))
         #plot shows the dive profile and acceleration of the second dive



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("crop_all", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("crop_to")
### * crop_to

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: crop_to
### Title: Reduce the time span of data
### Aliases: crop_to

### ** Examples

         d <- find_dives(beaked_whale$P,300)
         P2 <- crop_to(beaked_whale$P, tcues = c(d$start[1], d$end[1]))	#crop to 1st dive
         plott(list(P2$X), r=c(1), panel_labels=c('Depth'))
         #plot shows the dive profile of the selected dive



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("crop_to", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("csv2struct")
### * csv2struct

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: csv2struct
### Title: Read tag metadata from csv
### Aliases: csv2struct

### ** Examples

## Not run: 
##D S <- csv2struct('testset1')
## End(Not run)





base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("csv2struct", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("decdc")
### * decdc

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: decdc
### Title: Reduce the sampling rate
### Aliases: decdc

### ** Examples

s <- matrix(sin(2 * pi / 100 * c(0:1000) - 1), ncol = 1)
y <- decdc(x = s, df = 4)
#Returns: 0.0023



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("decdc", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("decz")
### * decz

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: decz
### Title: Decimate sampling rate recursively.
### Aliases: decz

### ** Examples

# Decimate beaked whale acceleration data from testset1 by a factor of 10
# in 3 chunks
## Not run: 
##D bw <- load_nc('data/testset1.nc')
##D a_rows <- nrow(bw$A$data)
##D a_ind <- data.frame(start=c(1, floor(a_rows/3), floor(2*a_rows/3)))
##D a_ind$end <- c(a_ind$start[2:3] - 1, a_rows)
##D df <- 10
##D Z <- NULL
##D y <- NULL
##D for (k in 1:nrow(a_ind)){
##D   decz_out <- decz(x=bw$A$data[c(a_ind[k,1]:a_ind[k,2]), ],
##D                      df=df, Z=Z)
##D   df <- NULL
##D   Z <- decz_out$Z 
##D   y <- rbind(y,decz_out$y)
##D }
## End(Not run)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("decz", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("depth2pressure")
### * depth2pressure

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: depth2pressure
### Title: Convert depth to pressure
### Aliases: depth2pressure

### ** Examples

depth2pressure(1000, 27)
         #Returns: 10075403 Pa



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("depth2pressure", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("depth_rate")
### * depth_rate

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: depth_rate
### Title: Estimate the vertical velocity
### Aliases: depth_rate

### ** Examples

## Not run: 
##D v <- depth_rate(p = beaked_whale$P)
##D plott(list(beaked_whale$P$data, v), fs=beaked_whale$P$sampling_rate, 
##D r=c(1,0), panel_labels=c('Depth\n(m)', 'Vertical Velocity\n(m/s)')) 
##D #plot of dive profile and depth rate
## End(Not run)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("depth_rate", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("detect_peaks")
### * detect_peaks

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: detect_peaks
### Title: Detect peaks in signal vector data
### Aliases: detect_peaks

### ** Examples

## Not run: 
##D BW <- beaked_whale
##D detect_peaks(data = BW$A$data, sr = BW$A$sampling_rate, FUN = njerk, thresh = NULL, bktime = NULL, plot_peaks = NULL, fs = BW$A$sampling_rate)
## End(Not run)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("detect_peaks", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("dsf")
### * dsf

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: dsf
### Title: Estimate the dominant stroke frequency
### Aliases: dsf

### ** Examples

#coming soon!




base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("dsf", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("euler2rotmat")
### * euler2rotmat

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: euler2rotmat
### Title: Make a rotation (or direction cosine) matrix
### Aliases: euler2rotmat

### ** Examples

vec1 <- matrix(c(1:10), nrow = 10)
         vec2 <- matrix(c(11:20), nrow = 10)
         vec3 <- matrix(c(21:30), nrow = 10)
         Q <- euler2rotmat(p = vec1, r = vec2, h = vec3) 



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("euler2rotmat", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("extract")
### * extract

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: extract
### Title: Extract a sub-sample of data
### Aliases: extract

### ** Examples

BW <- beaked_whale
extract(x = BW$A$data, sampling_rate = BW$A$sampling_rate, tst = 3, ted = 100)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("extract", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("extract_cues")
### * extract_cues

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: extract_cues
### Title: Extract multiple sub-samples of data
### Aliases: extract_cues

### ** Examples

BW <- beaked_whale
list <- extract_cues(x = BW$A$data, sampling_rate = BW$A$sampling_rate, cues = 6, len = 11)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("extract_cues", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("find_dives")
### * find_dives

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: find_dives
### Title: Find time cues for dives
### Aliases: find_dives

### ** Examples

BW <- beaked_whale
T <- find_dives(p = BW$P$data, sampling_rate = BW$P$sampling_rate, mindepth = 5, surface = 2, findall = NULL)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("find_dives", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("fir_nodelay")
### * fir_nodelay

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: fir_nodelay
### Title: Delay-free filtering
### Aliases: fir_nodelay

### ** Examples

## Not run: 
##D          #Make a waveform with two harmonics - one at 1/20 and another at 1/4 of the sampling rate.
##D          x <- sin(t(2 * pi * 0.05 * (1:100)) +
##D                 t(cos(2 * pi * 0.25 * (1:100))))
##D          Y <- fir_nodelay(x=x, n=30, fc=0.2, qual='low')
##D          plot(c(1:length(x)),x, type='l', col='grey42',
##D          xlab='index', ylab='input x and output y')
##D          lines(c(1:length(Y$y)),Y$y, lwd=2)
##D          #Returns: The input signal has the first and fifth harmonic. 
##D          #Applying the low-pass filter removes most of the fifth harmonic
##D          # so the output appears as a sinewave except for the first few 
##D          #samples which are affected by the filter startup transient.
##D          
## End(Not run)




base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("fir_nodelay", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("fix_offset_3d")
### * fix_offset_3d

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: fix_offset_3d
### Title: Estimate the offset in each axis
### Aliases: fix_offset_3d

### ** Examples

#Will come soon!



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("fix_offset_3d", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("fix_pressure")
### * fix_pressure

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: fix_pressure
### Title: Correct a depth or altitude profile
### Aliases: fix_pressure

### ** Examples

#Example Coming Soon!



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("fix_pressure", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("hilbert_env")
### * hilbert_env

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: hilbert_env
### Title: Compute the envelope of X using Hilbert transform.
### Aliases: hilbert_env

### ** Examples

## Not run: 
##D s <- matrix(sin(0.1*c(1:10000)), ncol=1)*
##D      matrix(sin(0.001*c(1:10000)), ncol=1)
##D E <- hilbert_env(s)
##D #E contains 3 positive half cycles of a sine wave that trace 
##D #the upper limit of signal s.
##D plot(c(1:length(s)), s, col='grey34')
##D lines(c(1:length(E)), E, col='black')
## End(Not run)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("hilbert_env", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("htrack")
### * htrack

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: htrack
### Title: Simple horizontal dead-reckoned track
### Aliases: htrack

### ** Examples

## Not run: 
##D BW <- beaked_whale
##D htrack(A = BW$A$data, M = BW$M$data, s = 4, sampling_rate = BW$A$sampling_rate, fc = NULL)
## End(Not run)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("htrack", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("inclination")
### * inclination

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: inclination
### Title: Estimate the inclination angle
### Aliases: inclination

### ** Examples

## Not run: 
##D A <- matrix(c(1, -0.5, 0.1, 0.8, -0.2, 0.6, 0.5, -0.9, -0.7),
##D            byrow = TRUE, nrow = 3, ncol = 3)
##D M <- matrix(c(1.3, -0.25, 0.16, 0.78, -0.3, 0.5, 0.5, -0.49, -0.6),
##D                       byrow = TRUE, nrow = 3, ncol = 3)
##D incl <- inclination(A, M)
##D #Results: incl = -0.91595 radians.
## End(Not run)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("inclination", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("inv_axis")
### * inv_axis

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: inv_axis
### Title: Identify invariant axis in triaxial movement measurements.
### Aliases: inv_axis

### ** Examples

 ## Not run: 
##D  s <- matrix(sin(2*pi*0.1*c(1:100)), ncol=1)
##D  A <- s %*% c(0.9, -0.4, 0.3) + s^2 %*% c(0, 0.2, 0.1)
##D  inv_axis_out <- inv_axis(A)
##D    
## End(Not run)
 



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("inv_axis", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("julian_day")
### * julian_day

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: julian_day
### Title: Convert between dates and Julian day numbers.
### Aliases: julian_day

### ** Examples

julian_day(y = 2016, d = 12, m =10) #Returns: 286
         julian_day(y = 2016, 286) #Returns: "2016-10-12"



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("julian_day", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("load_nc")
### * load_nc

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: load_nc
### Title: Load a tag dataset from a netCDF file.
### Aliases: load_nc

### ** Examples

## Not run: 
##D #Note: must have the file testset1.nc saved in current working directory for this to work
##D #load_nc('testset1.nc')
## End(Not run)




base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("load_nc", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("m2h")
### * m2h

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: m2h
### Title: Heading from accelerometer and magnetometer data
### Aliases: m2h

### ** Examples

## Not run: 
##D m2h_out <- m2h(M = matrix(c(22, -24, 14), nrow = 1), 
##D                         A = matrix(c(-0.3, 0.52, 0.8), nrow = 1))
##D #Returns: h=0.89486 radians, v=34.117, incl=0.20181 radians.
## End(Not run)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("m2h", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("m_dist")
### * m_dist

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: m_dist
### Title: Calculate Mahalanobis distance
### Aliases: m_dist

### ** Examples

## Not run: 
##D BW <- beaked_whale
##D dframe <- m_dist(BW$A$data, BW$A$sampling_rate)
## End(Not run)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("m_dist", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("make_specgram")
### * make_specgram

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: make_specgram
### Title: Plot a spectrogram with default settings
### Aliases: make_specgram

### ** Examples

## Not run: 
##D x <- signal::chirp(seq(from=0, by=0.001, to=2),f0=0,
##D t1=2,f1=500)
##D fs <- 2
##D nfft <- 256
##D numoverlap <- 128
##D window = signal::hanning(nfft)
##D #Spectrogram plot
##D make_specgram(x,nfft,fs,window,numoverlap) 
##D # or calculate and don't plot
##D S <- make_specgram(x,nfft,fs,window,numoverlap, draw_plot=FALSE) 
## End(Not run)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("make_specgram", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("mean_absorption")
### * mean_absorption

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: mean_absorption
### Title: Calculate the mean absorption in salt water
### Aliases: mean_absorption

### ** Examples

mean_absorption(c(25e3, 60e3), 1000, c(0, 700))
         #Returns: 7.728188 dB/m



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("mean_absorption", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("median_filter")
### * median_filter

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: median_filter
### Title: Computes the nth-order median filter
### Aliases: median_filter

### ** Examples

v <- matrix(c(1, 3, 4, 4, 20, -10, 5, 6, 6, 7), ncol = 1)
w <- median_filter(v, n=3)
#Returns : c(1, 3, 4, 4, 4, 5, 5, 6, 6, 7)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("median_filter", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("merge_fields")
### * merge_fields

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: merge_fields
### Title: Merge the fields of two lists
### Aliases: merge_fields

### ** Examples

s1 <- list( a = 1, b = c(2,3,4))
         s2 <- list( b = 3, c = 'cat')
	      s <- merge_fields(s1,s2)
	      s #yields list( a = 1, b = c(2,3,4), c = 'cat')



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("merge_fields", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("msa")
### * msa

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: msa
### Title: Compute MSA
### Aliases: msa

### ** Examples

sampleMatrix = matrix(c(1, -0.5, 0.1, 0.8, -0.2, 0.6, 0.5, -0.9, -0.7),
                      byrow = TRUE, nrow = 3, ncol = 3)
msa(A=sampleMatrix, ref=1)  
#Results: c(0.122497, 0.019804, 0.24499)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("msa", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("njerk")
### * njerk

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: njerk
### Title: Compute the norm-jerk
### Aliases: njerk

### ** Examples

## Not run: 
##D sampleMatrix = matrix(c(1, 2, 3, 2, 2, 4, 1, -2, 4, 4, 4, 4), byrow = TRUE, nrow = 4, ncol = 3)
##D njerk(A=sampleMatrix, sampling_rate=5)  
##D #Results: c(7.0711, 20.6155, 33.541, 0)
## End(Not run)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("njerk", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("norm2")
### * norm2

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: norm2
### Title: Compute the row-wise vector norm
### Aliases: norm2

### ** Examples

sampleMatrix = matrix(c(0.2, 0.4, -0.7,-0.3, 1.1, 0.1), byrow = TRUE, nrow = 2, ncol = 3)
norm2(X=sampleMatrix)
#Result: c(0.83066, 1.14455)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("norm2", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("ocdr")
### * ocdr

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: ocdr
### Title: Estimate the forward speed
### Aliases: ocdr

### ** Examples

## Not run: 
##D HS <- harbor_seal
##D s <- ocdr(p = HS$P$data, A = HS$A$data, sampling_rate = HS$P$sampling_rate, fc = NULL, plim = NULL)
##D speed <- list(s = s)
##D plott(speed, testset2$P$sampling_rate)
## End(Not run)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("ocdr", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("odba")
### * odba

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: odba
### Title: Compute ODBA
### Aliases: odba

### ** Examples

## Not run: 
##D BW <- beaked_whale
##D e <- odba(A = BW$A$data, sampling_rate = BW$A$sampling_rate, fh = 4)
##D ba <- list(e = e)
##D plott(ba, BW$A$sampling_rate)
## End(Not run)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("odba", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("plott")
### * plott

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: plott
### Title: Plot tag data time series
### Aliases: plott

### ** Examples

## Not run: 
##D HS <- harbor_seal
##D list <- list(depth = HS$P$data, A = HS$A$data)
##D plott(list, HS$P$sampling_rate, r = c(TRUE, FALSE))
## End(Not run)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("plott", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("ptrack")
### * ptrack

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: ptrack
### Title: Estimate simple dead-reckoned track
### Aliases: ptrack

### ** Examples

## Not run: 
##D  
##D BW <- beaked_whale
##D list <- ptrack(A = BW$A$data, M = BW$M$data, s = 3, sampling_rate = BW$A$sampling_rate, fc = NULL, include_pe = TRUE)
## End(Not run)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("ptrack", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("rotate")
### * rotate

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: rotate
### Title: Rotate data.
### Aliases: rotate

### ** Examples

 my_events <- 1500*stats::runif(10) #10 events at "times" between 0 and 1500
 my_events
 rotated_events <- rotate(my_events, full_period=c(0,1500))
 rotated_events
 



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("rotate", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("rotate_vecs")
### * rotate_vecs

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: rotate_vecs
### Title: Rotate triaxial vector measurements
### Aliases: rotate_vecs

### ** Examples

## Not run: 
##D x <- (pi / 180) * matrix(c(25, -60, 33), ncol = 3)
##D Q <- euler2rotmat(x[, 1], x[, 2], x[, 3])
##D V <- rotate_vecs(c(0.77, -0.6, -0.22), Q)
##D #Returns: V = c(0.7072485, -0.1255922, 0.6966535)
## End(Not run)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("rotate_vecs", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("rotation_test")
### * rotation_test

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: rotation_test
### Title: Carry out a rotation randomization test.
### Aliases: rotation_test

### ** Examples

r <- rotation_test(event_times = 
2000*runif(500), 
exp_period = c(100,200), 
return_rot_stats=TRUE, ts_fun=mean)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("rotation_test", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("rough_cal_3d")
### * rough_cal_3d

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: rough_cal_3d
### Title: Estimate scale factors and offsets
### Aliases: rough_cal_3d

### ** Examples

## Not run: 
##D  BW <- beaked_whale
##D          rcal <- rough_cal_3d(BW$M$data, fstr = 38.2) 
##D          #fstr matches records for field strength in 
##D          #El Hierro when the tag was used
##D          cal <- list(rcal = rcal$X)
##D          plott(cal, BW$sampling_rate)
##D          
## End(Not run)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("rough_cal_3d", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("save_nc")
### * save_nc

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: save_nc
### Title: Save a tag dataset to a netCDF file.
### Aliases: save_nc

### ** Examples

## Not run: 
##D save_nc('dog17_124a',A,M,P,info)
##D #or equivalently:
##D save_nc('dog17_124a',X=list(A,M,P,info))
##D #generates a file dog17_124a.nc and adds variables A, M and P, and a metadata structure.
## End(Not run)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("save_nc", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("sens2var")
### * sens2var

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: sens2var
### Title: Extract data from a sensor structure. This function extracts
###   loose data variables from tag sensor data lists. It can also be used
###   to check two sensor data lists for compatibility (i.e., same duration
###   and sampling rate).
### Aliases: sens2var

### ** Examples

#no example given because hard to figure out when you'll use it!    



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("sens2var", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("sens_struct")
### * sens_struct

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: sens_struct
### Title: Generate a sensor structure from a sensor data vector or matrix.
### Aliases: sens_struct

### ** Examples

## Not run: 
##D #example will only work if data matrix Aw is in your workspace.
##D #A <- sens_struct(data=Aw,fs=fs,depid='md13_134a', type='acc')
## End(Not run)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("sens_struct", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("smooth")
### * smooth

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: smooth
### Title: Low pass filter a time series
### Aliases: smooth

### ** Examples

## Not run: 
##D  x <- sin((2*pi*0.05)%*%t(c(1:100)))+cos((2*pi*0.25)%*%t(c(1:100)))
##D          y <- smooth(x, n = 4)
##D          
## End(Not run)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("smooth", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("sound_speed")
### * sound_speed

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: sound_speed
### Title: Sound speed estimation
### Aliases: sound_speed

### ** Examples

sound_speed(8, 1000, 34)
         #Returns: 1497.7 m/s



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("sound_speed", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("spec_lev")
### * spec_lev

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: spec_lev
### Title: Compute the spectrum level of a signal x.
### Aliases: spec_lev

### ** Examples

## Not run: 
##D BW <- beaked_whale
##D list <- spec_lev(x = BW$P$data, nfft = 4, sampling_rate = BW$P$sampling_rate)
## End(Not run)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("spec_lev", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("spectrum_level")
### * spectrum_level

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: spectrum_level
### Title: Compute the spectrum level of a signal x.
### Aliases: spectrum_level

### ** Examples

## Not run: 
##D BW <- beaked_whale
##D list <- spec_lev(x = BW$P$data, nfft = 4, sampling_rate = BW$P$sampling_rate)
## End(Not run)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("spectrum_level", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("tortuosity")
### * tortuosity

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: tortuosity
### Title: Measure tortuosity index
### Aliases: tortuosity

### ** Examples

## Not run: 
##D  
##D BW <- beaked_whale
##D T <- ptrack(A = BW$A$data, M = BW$M$data, s = 3, 
##D sampling_rate = BW$A$sampling_rate, 
##D fc = NULL, include_pe = TRUE)$T
##D t <- tortuosity(T, sampling_rate = BW$A$sampling_rate, intvl = 25)
## End(Not run)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("tortuosity", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("track3D")
### * track3D

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: track3D
### Title: Reconstruct a track from pitch, heading and depth data, given a
###   starting position
### Aliases: track3D

### ** Examples

## Not run: 
##D p <- a2pr(A=beaked_whale$A$data) 
##D h <- m2h(M=beaked_whale$M$data,A=beaked_whale$A$data) 
##D track=track3D(z=beaked_whale$P$data,phi=p$p,psi=h$h,sf=beaked_whale$A$sampling_rate,r=0.001,q1p=0.02,q2p=0.08,q3p=1.6e-05,tagonx=1000,tagony=1000,enforce=T,x=NA,y=NA)
##D par(mfrow=c(2,1),mar=c(4,4,0.5,0.5))
##D plot(-beaked_whale$P$data,pch=".",ylab="Depth (m)",xlab="Time")
##D plot(track$fit.rx,track$fit.ry,xlab="X",ylab="Y",pch=".")
##D points(track$fit.rx[c(1,length(track$fit.rx))],track$fit.ry[c(1,length(track$fit.rx))],pch=21,bg=5:6)
##D legend("bottomright",cex=0.7,legend=c("Start","End"),col=c(5,6),pt.bg=c(5,6),pch=c(21,21))
## End(Not run)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("track3D", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("undo_cal")
### * undo_cal

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: undo_cal
### Title: Undo calibrations steps
### Aliases: undo_cal

### ** Examples

## Not run: 
##D  
##D BW <- beaked_whale
##D undo_cal(BW)
##D          
## End(Not run)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("undo_cal", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("zero_crossings")
### * zero_crossings

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: zero_crossings
### Title: Find zero-crossings in a vector
### Aliases: zero_crossings

### ** Examples

## Not run: 
##D  list( K = K, s = s) <- zero_crossings(sin(2 * pi * 0.033 * c(1:100)), 0.3)
##D          #Returns: K = c(15.143, 30.286, 45.429, 60.628, 75.771, 90.914)
##D                    s = c(-1, 1, -1, 1, -1, 1)
##D                    
## End(Not run)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("zero_crossings", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
### * <FOOTER>
###
cleanEx()
options(digits = 7L)
base::cat("Time elapsed: ", proc.time() - base::get("ptime", pos = 'CheckExEnv'),"\n")
grDevices::dev.off()
###
### Local variables: ***
### mode: outline-minor ***
### outline-regexp: "\\(> \\)?### [*]+" ***
### End: ***
quit('no')
