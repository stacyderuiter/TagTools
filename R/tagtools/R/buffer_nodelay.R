#' Buffers a signal vector into matrix of data frames with no delay.
#' 
#' @param vec The signal vector to be buffered
#' @param n The desired length of data segments (rows).
#' @param p The desired amount of overlap between consecutive frames (columns) in the output matrix
#' @return A matrix of the buffered signal vector "vec" with "n" data segments and an overlap between consecutive frames specified by "p".
#' @example vec <- c(1:20)
#'          n <- 5
#'          p <- 2
#'          buffer(vec, v, p)
#' # Results: [1 4 7  10 13 16
#' #           2 5 8  11 14 17
#' #           3 6 9  12 15 18
#' #           4 7 10 13 16 19
#' #           5 8 11 14 17 20]

buffer_nodelay <- function(vec, n, p){
  m <- floor((length(vec) - n)/(n - p)) + 1
  buffermatrix <-function(vec, m, n, p){
  retmat <- matrix(0, nrow = m, ncol = n)
  vecindex <- 1
  for(i in 1:m){
    if(i == 1){
    for(f in 1:n){
         retmat[i,f] <- vec[vecindex]
        vecindex <- vecindex + 1
      }
    }
    else{
      vecindex <- vecindex - p
      for(c in 1:n){
        retmat[i,c] <- vec[vecindex]
        vecindex <- vecindex + 1
      }
      }
  }
  return(retmat)
  }
  realretmat <- matrix(0, nrow = n, ncol = m)
  realretmat <- t(buffermatrix(vec, m,n,p))
  return(realretmat)
}