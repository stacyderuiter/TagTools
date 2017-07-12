PrCA <- function(A, fs, thresV){
  #calculate magnitute in acceleration
  magA <- matrix(0, nrow(A), 1)
  for (i in 1:nrow(A)) {
    magA[i] <- sqrt(A[i, 1]^2 + A[i, 2]^2 + A[i, 3]^2)
  }
  #calculate the change in magA over one second of time
  var <- buffer_no_delay(magA, fs, 0)
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
}