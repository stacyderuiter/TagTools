#' Merge the fields of two structures. If there are duplicate fields, the fields in s1 are taken.
#'
#' @param s1 Arbitrary structurese.g., containing metadata or settings.
#' @param s2 Arbitrary structurese.g., containing metadata or settings.
#' @return s A structure containing all of the fields in s1 and s2
#' @example s1 <- struct('a',1,'b',[2 3 4])
#'          s2 <- struct('b',3,'c','cat')
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
  for (k in 1:length(Z)){ #Still needs a lot of work and love here. 
    s <- merge(s,s1, by = Z[k]) ;
  }
  return(s)
}