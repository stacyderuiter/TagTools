#' Read a CSV file with sensor data from a CATS tag
#'
#' Read in data from a CATS tag deployment (stored in a .csv file). This function is usable by itself but is more normally
#' called by \code{\link[tagtools]{read_cats}} which handles metadata and creates a NetCDF file.
#' @param fname is the file name of the CATS CSV file including the complete
#' path name if the file is not in the current working directory or in a
#' directory on the path. The .csv suffix is optional.
#' @param max_samps is optional and is used to limit reading to a maximum number of samples (rows) per sensor. This is useful to read in a part of a very large file
#' for testing. If max_samps is not given, the entire file is read.
#' @param skip_samps Number of lines of data to skip (excluding header) before starting to read in data. Defaults to 0 (start at the beginning of the file), but can be used to read in a part of a file, or to read in and process a large file in chunks.
#' @return A tibble data frame containing the data read from the file. The column names are
#'     names are taken from the first line of the CSV file and include units and axis. Some columns may be empty (if for example, a tag did not record data from a certain sensor type).
#' @export
#' @note CATS csv files can be extremely large; perhaps too large to read the entire file into memory at once and work with it.
#' @examples \dontrun{
#' V <- read_cats_csv("cats_test_segment")
#' }
read_cats_csv <- function(fname, max_samps = Inf, skip_samps = 0) {
  #****************************
  # check inputs
  #****************************
  if (missing(fname)) {
    stop("File name fname is required for read_cats_csv.\n")
  }

  if (missing(max_samps) | is.null(max_samps)) {
    max_samps <- Inf
  }

  # append .csv if needed
  if (stringr::str_sub(fname, -4) != ".csv") {
    fname <- paste(fname, ".csv", sep = "")
  }

  #****************************
  # end of input checks
  #****************************

  # read data file with header
  # note: readr has a function read_csv_chunked() to read in files part at a time,
  # but it's not meant to then read ALL of them in and then paste together -
  # may be useful though if ever actually doing processing on chunks.
  V <- suppressMessages(readr::read_csv(
    file = fname, col_names = TRUE,
    col_types = readr::cols(
      `Time (UTC)` = readr::col_character(),
      `GPS (raw) 1 [raw]` = readr::col_character(),
      `GPS (raw) 2 [raw]` = readr::col_character()
    ),
    na = c(NA, "", " "),
    trim_ws = TRUE,
    skip = skip_samps,
    n_max = max_samps
  ))
  # make mus and degree symbols and superscripts not show up as black diamonds with question marks inside
  # that make R throw errors...

  names(V) <- iconv(names(V), to = "iso_8859_2")

  # add date-time in POSIX format
  di <- which(stringr::str_detect(names(V), "Date "))
  ti <- which(stringr::str_detect(names(V), "Time "))

  V$Datetime <- lubridate::dmy_hms(paste(
    dplyr::pull(V[, di]),
    dplyr::pull(V[, ti])
  ))

  V <- cbind(V[, ncol(V)], V[, c(-di, -ti, -ncol(V))])
}
