#' Save a tag dataset to a netCDF file.
#' 
#' This function loads a tag dataset from a netCDF file (this is an archival file format supported by the tagtools package and suitable for submission to online data archives).
#' 
#' Warning: this will overwrite any previous NetCDF file with the same name. The file is assumed to be in the current working directory unless \code{file} includes file path information.
#' @param file The name of the data and metadata file to be written. If \code{file} does not include a .nc suffix, this will be added automatically.
#' @param X An \code{animaltag} object, or a list of tag sensor and/or metadata lists. Alternatively, sensor and metadata lists may be input as multiple separate unnamed inputs. Only these kind of variables can be saved
#'		 in a NetCDF file because the supporting information in these structures is
#'		 needed to describe the contents of the file. For non-archive and non-portable
#'		 storage of variables, consider using \code{\link{save}} or various functions to write data to text files. 
#' @example
#' \dontrun{savenc('dog17_124a',A,M,P,info)
#' #or equivalently:
#' savenc('dog17_124a',X=list(A,M,P,info))
#' #generates a file dog17_124a.nc and adds variables A, M and P, and a metadata structure.
#' }

save_nc <- function(file, X, ...){
  # append .nc suffix to file name if needed
  if (!grepl('.nc', file)){
    file <- paste(file, '.nc', sep='')
  }
  
  # if one or more loose inputs are given, collect into a list
  if (length(X$depid) > 0 | length(X$sampling_rate)>0){
    X <- list(X, ...)
  }
  # write sensors and metadata to file
  for (k in 1:length(X)){
      add_nc(file, X[[k]])
  }
}