#' Buffers a signal vector into matrix of data frames with no delay.
#' 
#' @param vec The signal vector to be buffered
#' @param n The desired length of data segments (rows).
#' @param p The desired amount of overlap between consecutive frames (columns) in the output matrix
#' @return A matrix of the buffered signal vector "vec" with "n" data segments and an overlap between consecutive frames specified by "p".
#' @export
#' @example vec <- c(1:20)
#'          n <- 5
#'          p <- 2
#'          buffer(vec, v, p)
#' #Results: [1 4 7  10 13 16
#'            2 5 8  11 14 17
#'            3 6 9  12 15 18
#'            4 7 10 13 16 19
#'            5 8 11 14 17 20]

buffer_nodelay <- function(vec, n, p){
  m <- floor((length(vec) - n)/(n - p)) + 1
  buffer_matrix <-function(vec, m, n, p){
  ret_mat <- matrix(0, nrow = m, ncol = n)
  vec_index <- 1
  for(i in 1:m){
    if(i == 1){
      ret_mat[i, 1:n] <- vec[1:n]
      vec_index <- vec_index + n
    }
    else{
      ret_mat[i,(1:p)] <- ret_mat[i-1, (-(n-p):0)]
      ret_mat[i,(p+1):n] <- vec[vec_index:(vec_index + (n-p-1))]
        vec_index <- vec_index + (n-p)
      }
  }
  return(ret_mat)
  }
  real_ret_mat <- matrix(0, nrow = n, ncol = m)
  real_ret_mat <- t(buffer_matrix(vec, m,n,p))
  return(real_ret_mat)
}