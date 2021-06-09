#' Correct a depth or altitude profile
#'
#' This function is used to correct a depth or altitude profile for offsets caused by miscalibration and temperature. This function finds minima in the dive/altitude profile that are consistent with surfacing/landing. It uses the depth/height at these points to fit a temperature regression.
#' @param p A sensor list or vector of depth/altitude in meters
#' @param t A sensor list or vector of temperature in degrees Celsius
#' @param sampling_rate The sampling_rate of p and t in Hz. This is only needed if p and t are not sensor lists. The depth and temperature must both have the same sampling rate (use `decdc` if needed to achieve this).
#' @param maxp The maximum depth or altitude reading in the pressure data for which the animal could actually be at the surface. This is a rough measurement of the potential error in the pressure data. The unit is meters. Start with a small value, e.g., 2m and rerun fix_pressure with a larger value if there are still obvious temperature-related errors in the resulting depth/altitude profile.
#' @return A list with 2 elements:
#' \itemize{
#'  \item{\strong{p: }} A sensor list or vector of corrected depth/altitude measurements at the same sampling rate as the input data. If the input is a sensor list, the output will also be.
#'  \item{\strong{pc: }} A list containing the pressure offset and temperature correction coefficients. It has fields: pc$tref which is the temperature compensation polynomial. This is used within the function to correct pressure as follows: p + stats::polyval(pc$tcomp, t - pc$tref).
#' }
#' @note This function makes a number of assumptions about the depth/altitude data and about the behaviour of animals: First, the depth data should have few incorrect outlier (negative) values that fall well beyond the surface. These can be reduced using median_filter.m before calling fix_depth. Second, the animal is assumed to be near the surface at least 2% of the time. If the animal is less frequently at the surface, you may need to change the value of PRCTSURF near the start of the function. Third, potential surfacings are detected by looking for zero-crossings in the vertical speed and this requires defining a threshold in vertical speed that must be crossed by each zero crossing. The value used is 0.05 m/s but this may be too high for animals that move very slowly near the surface. In which case, change MAXSPEED near the start of the function.
#' @examples # Example Coming Soon!
#' @export

fix_pressure <- function(p, t, sampling_rate, maxp = NULL) {
  MAXSPEED <- 0.05 # maximum speed in metres/second of points at the surface to accept
  ASYMM <- 0.2 # maximum assymmetry between positive and negative residuals
  TREF <- 20 # standard temperature reference to use
  PRCTSURF <- 2 # minimum percent of time animal is near surface
  pc <- c()
  if (missing(t)) {
    stop("inputs for p and t are required")
  }
  if (is.list(p)) {
    pp <- p$data
    tt <- t$data
    sampling_rate <- p$sampling_rate
    if (is.null(pp)) {
      stop("depth data cannot be empty")
    }
    if ("cal_tcomp" %in% names(p) == TRUE) {
      pp <- pp - signal::polyval(c(p$cal_tcomp, 0), tt - p$cal_tref)
    }
    if (nargs() > 3) {
      maxp <- sampling_rate
    } else {
      maxp <- c()
    }
  } else {
    if (nargs() < 3) {
      stop("Sampling rate is a required input when p and t are not sensor structures")
    }
    pp <- p
    tt <- t
    if (length(p) != length(t)) {
      stop("p and t must have the same length")
    }
    if (nargs() < 4) {
      maxp <- c()
    }
  }
  if (is.null(maxp)) {
    maxp <- 5
  }
  if (sampling_rate > 5) {
    df <- round(sampling_rate / 5)
    pp <- decdc(pp, df) # decimate depth and temperature to around 5Hz
    tt <- decdc(tt, df)
    sampling_rate <- sampling_rate / df
  }
  v <- depth_rate(pp, sampling_rate) # compute vertical velocity with 5s timeconstant
  if (is.null(v)) {
    stop("invalid depth_rate calculated from data")
  }
  # do initial offset correction - just using the 2%ile of the depth. This
  # assumes animals spend at least 2% of their time at or close to the
  # surface. Lower the percentile if this is not the case.
  p0 <- -stats::quantile(pp, c(PRCTSURF / 100))
  pp <- pp + p0
  k <- which(pp < maxp)
  pp <- pp[k]
  tt <- tt[k]
  v <- v[k]
  zc <- zero_crossings(v, MAXSPEED) # find zero crossings of vertical velocity
  K <- zc$K
  s <- zc$s
  KK <- zc$KK
  KK <- KK[(s > 0), ] # pick just the positive zero crossings
  # these are when the animal goes from descending to ascending if flying
  # or from ascending to descending is swimming

  # select depth samples around each zero crossing
  k <- matrix(0, length(v), 1)
  for (kk in 1:nrow(KK)) {
    k[KK[kk, 1]:KK[kk, 2]] <- 1
  }
  for (j in 1:length(k)) {
    if (is.na(k[j])) {
      k[j] <- FALSE
    }
  }
  k <- which(k == 1)
  ps <- pp[k] # pick just the 'surface' samples of pressure
  ts <- tt[k] - TREF # and temperature
  # do several iterations of regression followed by removal of the largest
  # positive residuals - these are non-surface points that have survived the
  # previous data selection steps. This approach relies on there being a
  # relatively small proportion of non-surface samples by this point,
  # certainly less than 50%. If this is not true, then the previous data
  # selection must be improved.
  for (j in 1:10) { # put an upper limit on the number of iterations
    x <- cbind(ts^2, ts)
    y <- ps
    lmob <- stats::lm(y ~ x)
    summ <- summary(lmob)
    stats <- (1 - stats::pf(summ$fstatistic[1], summ$fstatistic[2], summ$fstatistic[3]))
    r <- summ$residuals
    coefs <- stats::coef(lmob)
    b <- rbind(coefs[2], coefs[3], coefs[1])
    rr <- sqrt(c(sum(r[r > 0]^2), sum(r[r < 0]^2))) # RMS of +ve and -ve residuals
    if ((abs(diff(rr)) / mean(rr)) < ASYMM) {
      break
    }
    kk <- which(r < stats::quantile(r, c(.9)))
    ps <- ps[kk]
    ts <- ts[kk]
  }
  # compute the correction terms
  pc$tref <- TREF
  if (stats > .05) { # if the regression didn't help, just keep the offset adjustment
    pc$tcomp <- c(0, 0)
    pc$poly <- c(1, p0)
  } else {
    pc$tcomp <- -b[1:2]
    pc$poly <- c(1, (p0 - b[3]))
  }
  # correct the original pressure
  if (!is.list(p)) {
    p <- p + signal::polyval(c(pc$tcomp, pc$poly[2]), (t - TREF))
    return(list(p = p, pc = pc))
  }
  p$data <- p$data + signal::polyval(c(pc$tcomp, pc$poly[2]), (t$data - TREF))
  p$cal_tref <- TREF
  p$cal_tcomp <- pc$tcomp
  if ("cal_poly" %in% names(p) == TRUE) {
    p$cal_poly <- p$cal_poly * pc$poly[1] + c(0, pc$poly[2])
  } else {
    p$cal_poly <- pc$poly
  }
  if (("history" %in% names(p) == TRUE) | is.null(p$history)) {
    p$history <- "fix_depth"
  } else {
    p$history <- c(p$history, "fix_depth")
  }
  return(list(p = p, pc = pc))
}
