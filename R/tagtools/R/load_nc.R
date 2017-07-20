#' Load a tag dataset from a netCDF file.
#' 
#' @description This function loads a tag dataset from a netCDF file (this is an archival file format supported by the tagtools package and suitable for submission to online data archives).
#' @param file File name (and path, if necessary) of netCDF file to be read, as a quoted character string.
#' @result X, if specified, is a structure containing sensor and metadata structures. The field names in X will be the same as the names of the variables in the NetCDF file, e.g., if the file contains A and P, X will have fields X$A, X$P and X$info (the file metadata).
#' @example \dontrun{load_nc('testset1.nc')}
#' 

 load_nc <- function(file){
   file_conn <- ncdf4::nc_open(file)
   #get variable names present in this file
   vars <- names(file_conn$var)
   #read in the variables one by one and store in a list
   X <- list()
   for (v in 1:length(vars)){
     #get metadata for variable v
     X[[v]] <- ncdf4::ncatt_get(file_conn, vars[v])
     # remove redundant name label
     X[[v]]$name <- NULL
     #add the actual data matrix or vector
     X[[v]]$data <- ncdf4::ncvar_get(file_conn, vars[v])
   }
   # entries of X should match variable names from netCDF file
   names(X) <- vars
   # get metadata and add it to X as "info"
   X$info <- ncdf4::ncatt_get( file_conn , 0 )
   ncdf4::nc_close(file_conn)
   class(X) <- c('tagtools', 'list')
   return(X)
 }
