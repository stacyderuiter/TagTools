#' Merge the fields of two structures. If there are duplicate fields, the fields in s1 are taken.
#'
#' @param s1 Arbitrary structurese.g., containing metadata or settings.
#' @param s2 Arbitrary structurese.g., containing metadata or settings.
#' @return s A structure containing all of the fields in s1 and s2
#' @export
#' @example s1 <- data.frame( a = 1, b = c(2,3,4))
#'          s2 <- data.frame( b = 3, c = 'cat')
#'		      s <- mergefields(s1,s2)

mergefields <- function(s1,s2) {
  s <- vector(mode = "numeric", length = 0)
  if(missing(s1) | missing(s2)){
    stop("inputs for both s1 and s2 are required")
  }
  
  if (!is.data.frame(s1) & !is.data.frame(s2)){
    stop('Both inputs must be data frames in mergefields\n') 
  }
  
  s <- s2 
  Z <- names(s1) 
  s <- cbind(s1,s) 
  s <- s[, !duplicated(colnames(s))]
  return(s)
}