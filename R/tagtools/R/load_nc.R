#' Load a tag dataset from a netCDF file.
#' 
#' @description This function loads a tag dataset from a netCDF file (this is an archival file format supported by the tagtools package and suitable for submission to online data archives).
#' @param file File name (and path, if necessary) of netCDF file to be read, as a quoted character string.
#' @param which_vars (Optional) A list of quoted character strings giving the exact names of variables to be read in. Default is to read all variables present in the file. parameters should be read in.
#' @result An \code{animaltag} object (a list) containing sensor and metadata structures. The item names in X will be the same as the names of the variables in the NetCDF file (plus an "info" one), e.g., if the file contains A and P, output object X will have fields X$A, X$P and X$info (the file metadata).
#' @example \dontrun{load_nc('testset1.nc')}
#' 

 load_nc <- function(file, which_vars=NULL){
   file_conn <- ncdf4::nc_open(file)
   #get variable names present in this file
   vars <- names(file_conn$var)
   if (!is.null(which_vars)){
     vars <- vars[vars %in% which_vars]
   }
   #read in the variables one by one and store in a list
   X <- list()
   for (v in 1:length(vars)){
     #get metadata for variable v
     X[[v]] <- ncdf4::ncatt_get(file_conn, vars[v])
     # remove redundant name label
     X[[v]]$name <- NULL
     field_names <- names(X[[v]])
     # add the actual data matrix or vector
     X[[v]]$data <- ncdf4::ncvar_get(file_conn, vars[v])
     # make sure the sensor data is the first element of X[[v]]
     X[[v]] <- X[[v]][c('data', field_names)]
   }
   # entries of X should match variable names from netCDF file
   names(X) <- vars
   # get metadata and add it to X as "info"
   X$info <- ncdf4::ncatt_get( file_conn , 0 )
   ncdf4::nc_close(file_conn)
   class(X) <- c('animaltag', 'list')
   return(X)
 }
