#' Save a tag dataset to a netCDF file.
#'
#' This function saves a tag dataset to a netCDF file (this is an archival file format supported by the tagtools package and suitable for submission to online data archives).
#'
#' Warning: this will overwrite any previous NetCDF file with the same name. The file is assumed to be in the current working directory unless \code{file} includes file path information.
#' @param file The name of the data and metadata file to be written. If \code{file} does not include a .nc suffix, this will be added automatically.
#' @param X An \code{animaltag} object, or a list of tag sensor and/or metadata lists. Alternatively, sensor and metadata lists may be input as multiple separate unnamed inputs. Only these kind of variables can be saved
#' 		 in a NetCDF file because the supporting information in these structures is
#' 		 needed to describe the contents of the file. For non-archive and non-portable
#' 		 storage of variables, consider using \code{\link{save}} or various functions to write data to text files.
#' @param ... Additional sensor or metadata lists, if user has not bundled them all into a list already but is providing individual structures.
#' @examples
#' \dontrun{
#' save_nc("dog17_124a", A, M, P, info)
#' # or equivalently:
#' save_nc("dog17_124a", X = list(A, M, P, info))
#' # generates a file dog17_124a.nc and adds variables A, M and P, and a metadata structure.
#' }
#' @export

save_nc <- function(file, X, ...) {
  # append .nc suffix to file name if needed
  if (!grepl("\\.nc", file)) {
    file <- paste(file, ".nc", sep = "")
  }

  # if one or more loose inputs are given, collect into a list
  if (length(X$depid) > 0) {
    xname <- X$name
    X <- list(X, ...)
    names(X)[1] <- xname
  }

  # if there are multiple inputs, make sure that info
  # (global attributes) is not the first one.
  # this is because we can't create an empty nc file with
  # no variable and only global attributes.
  if (!is.null(names(X))) {
    if (names(X)[1] == "info") {
      X <- c(X[2:length(X)], X[1])
    }
  }

  # write sensors and metadata to file
  for (k in 1:length(X)) {
    var_name <- ifelse("name" %in% names(X[[k]]), X[[k]]$name, "info")
    add_nc(file, X[[k]], vname = var_name)
  }
}
