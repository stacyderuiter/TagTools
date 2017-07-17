#' Automated detection of prey catch attempts (PrCA) from triaxial acceleration data from seals.
#' 
#' @param A The acceleration matrix with columns [ax ay az]. Acceleration can be in any consistent unit (e.g. g or m/s^2).
#' @param fs The sampling rate in Hz of the acceleration signals.
#' @param thresV (optional) A user selectable threshold in the same units as A which is used in the process of checking for prey catpure attempts from the equation varS >= varA + thresV at a given second in time. varS is the change in magA (magnitute in acceleration) over one second of time. varA is the per second running average of change in acceleration. The default value is half of the 0.99 quantile of varA.
#' @return captures A list containing vectors for the capture times (seconds since start of data recording) and capture varS (change in magA over one second of time) values.
#' @note Source: Cox, S. L., Orgeret, F., Gesta, M., Rodde, C., Heizer, I., Weimerskirch, H. and Guinet, C. (), Processing of acceleration and dive data on-board satellite relay tags to investigate diving and foraging behaviour in free-ranging marine predators. Methods Ecol Evol. Accepted Author Manuscript. doi:10.1111/2041-210X.12845 

prca <- function(A, fs, thresV) {
  if (missing(fs)) {
    stop("Inputs for A and fs are both required")
  }
  
  #calculate magnitute in acceleration
  magA <- matrix(0, nrow(A), 1)
  for (i in 1:nrow(A)) {
    magA[i] <- sqrt(A[i, 1]^2 + A[i, 2]^2 + A[i, 3]^2)
  }
  
  #calculate the change in magA over one second of time
  var <- buffer_nodelay(magA, fs, 0)
  varS_col <- matrix(0,(nrow(var) - 1), ncol(var))
  varS <- matrix(0, 1, ncol(var))
  for (j in 1:ncol(var)) {
    varS_col[, j] <- abs(diff(var[, j]))
    varS[j] <- sum(varS_col[, j])
  }
  
  #calculate per second running average of change in acceleration
  ma <- function(x, n) {
    ans <- matrix(0,1, ncol(varS))
    for (k in 1:length(varS)) {
      if (k < 6) {
        ans[k] <- mean(x[1: (k + 5)])
      } else {
        if (k >= 6 & k < (length(x) - 4)) {
          ans[k] <- mean(x[(k - 5):(k + 5)])
        } else {
          if (k >= (length(x) - 4)) {
            ans[k] <- mean(x[(k - 5):length(x)])
          }
        }
      }
    }
    return(ans)
  }
  varA <- ma(varS, 11)
  
  if (missing(thresV)) {
    thresV <- stats::quantile(varA, c(.99)) / 2
  }
  
  #find prey capture attempts
  cap <- which(varS >= (varA + thresV))
  vars <- matrix(c(1:ncol(varS), varS), nrow = 2, byrow = TRUE)
  captures_times <- vars[1, cap]
  captures_varS <- varS[cap]
  
  #create a list of capture times and capture varS values
  captures <- list(captures_times = captures_times, captures_varS = captures_varS)
  
  return(captures)
}