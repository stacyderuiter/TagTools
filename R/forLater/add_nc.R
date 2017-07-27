#'	Save an item to a NetCDF Add one tag sensor or metadata variable to a NetCDF archive file. file. 
#'		
#'	Add one tag sensor or metadata variable to a NetCDF archive file.If the archive file does not exist,
#'	it is created. The file is assumed to be in the current working directory 
#'	unless a pathname is added to the beginning of fname. 
#'	
#'	@param file The name of the netCDF file to which to save. If the name does not include a .nc suffix, this will be added automatically.
#'	@param X The sensor data or metadata list to be saved. a list of tag sensor and/or metadata lists. Alternatively, sensor and metadata lists may be input as multiple separate unnamed inputs. Only these kind of variables can be saved in a NetCDF file because the supporting information in these structures is needed to describe the contents of the file. For non-archive and non-portable storage of variables, consider using \code{\link{save}} or various functions to write data to text files. 
#'	@seealso \code{\link{save_nc}}, \code{\link{load_nc}}	
#'	@export
#'  @example
#'  \dontrun{
#'  add_nc('dog17_124a',A)
#'  # generates a file dog17_124a.nc (if it does not already exist) and adds a variable A.
#'  }

add_nc <-function(file,X){
  # input checking
  if(!is.list(X) | "animaltag" %in% class(X)){
    stop('save_nc can only save individual sensor or metadata structures.') 
  }

  # append .nc suffix to file name if needed
  if (!grepl('.nc', file)){
    file <- paste(file, '.nc', sep='')
  }
  
  # test if X is a metadata structure or a sensor structure
  if(length(X$depid) > 0 | length(X$sampling_rate)>0){
    
  }
  
  #get name of input data structure
  vname <- as.character(substitute(X))

  # check that the deployment ID of X matches the one in the file if the file
  # already exists
  prev_depid <- c() ;
  if(file.exists(file)){
    S <- ncdf4::nc_open(file)
    prev_depid <- ncdf4::ncatt_get( S , 0 )$depid
    if (length(prev_depid) != 0){
      if (!identical(prev_depid,X$depid)){
        e_msg <- paste('Chosen file name is already associated with deployment id: ',
                       prev_depid, '. Choose a different file name.\n',
                       sep='')
        stop(e_msg)
      }
    }
    
    prev_vars <- names(S$var)
    if(vname %in% prev_vars){
      e_msg <- paste('Variable ', vname,
                     ' already exists in file. Choose a different name.\n',
                     sep='')
      stop(e_msg)
    }
  }# end of "if file already exists" checks

  # now ready to save the data or metadata
  if ('data' %in% names(X)){ # X is a sensor structure
    if (length(X$data) == 0){
      # if X is empty...
      ncv <- ncdf4::ncvar_def(name=vname, 
                              units='',#X$meta_unit,
                              dim=list(),
                              missval=NA)
      ncdf4::nc_create(file,ncv)
    }
    else{ #if there is some data
      dims <- list(ncdf4::ncdim_def(name='samples', 
                                    units='number', 
                                    vals=c(1:dim(X$data)[1])),
                   ncdf4::ncdim_def(name='axis', 
                                    units='number',
                                    vals=c(1:dim(X$data)[2])))
      
      ncv <- ncdf4::ncvar_def(name=vname, 
                              units=X$meta_unit,
                              dim=dims,
                              missval=NA,
                              longname=X$meta_full_name)
      if (!exists(file)){
        # if the file doesn't exist create it with this var
        nc_conn <- ncdf4::nc_create(file,ncv)
      }else{
        # if file already exists add variable to it
        nc_conn <- ncdf4::nc_open(file, write=TRUE)
        ncdf4::ncvar_put(nc_conn, ncv, 
                         vals=as.vector(X$data),
                         count=dim(X$data))
      }
    }# end of writing sensor data
    
    # add metadata (from sensor data structure)
    i_meta <- which(names(X)!='data')
    for (m in i_meta){
      ncdf4::ncatt_put(nc_conn, varid=ncv, 
                       attname=names(X)[m],
                       attval=X[[m]])  
    }

    if (length(i_meta==0)){
      w_msg <- paste('No metadata in variable ',
                     vname, '.\n')
      warning(w_msg)
    }
        
    if (length(prev_depid) == 0){
      #if this is a new file make sure the depid is specified
      # here the default is to use the file name string as depid
      ncdf4::ncatt_put(nc_conn, varid=ncv, 
                       attname='depid',
                       attval=sub('.nc', '', basename(file)))
    }
  }	#end of "if it's a sensor data structure	
 
  # Otherwise X is a metadata structure. Add it to the general attributes for the file
  # Overwrite any field already present
  if(length(depid) == 0){
    ncdf4::nc_create(fname,'_empty');
  }
  #need to use with new testsets above; they have depid in the sensor data.
  # check for other changes too?
  
  
  F = fieldnames(X) 
  V = struct2cell(X) 
  for (k in 1:length(F)){
    if(!ischar(V[[k]])){
      fprintf('All metadata fields must be strings: leaving field #s blank\n',F[[k]]) ;
      ncwriteatt(fname,'/',F[[k]],'') 
    }
    else{
      ncwriteatt(fname,'/',F[[k]],V[[k]]) ;
    }
  }

  # add creation date (whether it was sensor or meta)
  ncdf4::ncatt_put(nc_conn, ncv,
                   attname='creation_date',
                   attval=Sys.time());
  
  ncdf4::nc_close()
}
