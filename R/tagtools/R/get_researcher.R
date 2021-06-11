#' Find matching researcher in a list of known tag researchers
#' 
#' @param initial a two-letter code for the researcher of interest (first letter of first name and first letter of last name)
#' @noMd

get_researcher <- function(initial) {
  S <- utils::read.csv(system.file('extdata', 'researchers.csv', package = 'tagtools'),
                       stringsAsFactors = FALSE)
  
  if (missing(initial)) {
    print(S)
  }
  # look for S$Initial that matches researcher initial
  k <- initial == S$Initial
  if (sum(k) == 0) {
    stop(sprintf(' No entry matching "%s" in researcher file - edit file and retry\n', initial))
  }
  
  if (sum(k) > 1) {
    matches <- S[k,]
    print(matches)
    r <- readline(prompt = 'Type the row number of the correct match: ')
    r <- as.numeric(r)
    if (length(n) == 0 | is.na(n) | n < 1 | n > nrow(matches)) {
      stop('User input not recognized.')
    }
    k <- matches[r,'Name'] == S$Name
  }
  return(S[k,])
}