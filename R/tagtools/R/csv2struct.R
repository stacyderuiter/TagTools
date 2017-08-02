#' Read tag metadata from csv
#'
#' Read a CSV metadata file and convert it into a metadata list.
#' A metadata file is a comma-separated text file (.csv) containing a line for each metadata
#' entry. The first comma-separated field in each line is the name of the
#' entry. The last field in each line contains the value to
#' be assigned to this metadata entry. The value can be a string or number
#' but is always saved as a string in the structure - it is up to downstream
#' users of the metadata to parse/decode the entries.
#' 
#' @param fname Name of the text file to be read. If no file extension is provided, '.csv' will be
#' added automatically. If the file is not located in the current working directory, then \code{file} must include the correct relative or absolute path.
#' @return a metadata list populated from \code{fname} (one list element per row in the file). All list elements are stored as \code{"character"} class objects (even if the field contains a number, a date, etc) - no attempt is made to determine the most appropriate class for each item.
#' @export
#' @example \dontrun{
#' S <- csv2struct('testset1')
#' }
#'
#'
csv2struct <- function(fname){
if (missing(fname)){
  stop('Please provide a file name for csv2struct')
}

if (!grepl('.csv', fname)){
  fname <- paste(fname, '.csv', sep='')
}

S0 <- utils::read.csv(file=fname, colClasses=c(params="character"))
S <- as.list(S0$params)
names(S) <- gsub(pattern='.', replacement='_', S0$field, fixed=TRUE)

return(S)
}
