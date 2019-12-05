#' Find matching species in a list of marine mammals
#' 
#' @param initial a two-letter code for the species of interest (first letter of Genus and first letter of species)
#' @noMd

get_species <- function(initial){
  S <- utils::read.csv(system.file('extdata', 'species.csv', package='tagtools'),
                       stringsAsFactors = FALSE)

  if (missing(initial)){
    print(S)
    return()
  }
  
  # look for S.Initial that matches species initial
  k <- initial == S$Initial
  if (sum(k) == 0){
    stop(sprintf(' No entry matching "%s" in species file - edit file and retry\n',initial))
  }
  
  if (sum(k) > 1){
    matches <- S[k,]
    print(matches)
    r <- readline(prompt = 'Type the row number of the correct match: ')
    r <- as.numeric(r)
    if (length(n) == 0 | is.na(n) | n < 1 | n > nrow(matches)){
      stop('User input not recognized.')
    }
    k <- matches[r,'Common_name'] == S$common_name
  }
  return(S[k,])
  }