#' Merge the fields of two lists
#' 
#'  This function is used to merge the fields of two lists. If there are duplicate fields, the fields in s1 are taken.
#' @param s1 Arbitrary list e.g., containing metadata or settings.
#' @param s2 Arbitrary list e.g., containing metadata or settings.
#' @return s A list containing all of the fields in s1 and s2
#' @export
#' @example s1 <- list( a = 1, b = c(2,3,4))
#'          s2 <- list( b = 3, c = 'cat')
#'		      s <- merge_fields(s1,s2)

merge_fields <- function(s1,s2) {
  if(missing(s1) | missing(s2)){
    stop("inputs for both s1 and s2 are required")
  }
  if (!is.list(s1) | !is.list(s2)){
    stop('Both inputs must be data frames in mergefields\n') 
  }
  s <- s2 
  s <- append(s1,s)
  s <- s[!duplicated(names(s))]
  return(s)
}