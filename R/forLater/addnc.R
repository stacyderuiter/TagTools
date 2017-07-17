addnc <-function(fname,X){

#		addnc(fname,X)
#		Add a variable to a NetCDF archive file. If the archive file does not exist,
#		it is created. The file is assumed to be in the current working directory 
#		unless a pathname is added to the beginning of fname.
#
#		Inputs:
  #		fname is the name of the metadata file. If the name does not include a .nc
#		 suffix, this will be added automatically.
#		X is a sensor or metadata structure. Only these kind of variables can be saved
#		 in a NetCDF file because the supporting information in these structures is
#		 needed to describe the contents of the file. For non-archive and non-portable
#		 storage of variables, consider using the usual 'save' function in Matlab and Octabe.
#
#		Example:
  #		 addnc('dog17_124a',A)
# 	    generates a file dog17_124a.nc and adds a variable A.
#
#     Valid: Matlab, Octave
#     markjohnson@st-andrews.ac.uk
#     last modified: 12 July 2017

if(is.missing(fname) | is.missing(X)){
  stop('Must have two arguments!') 
}

if( !is.list(X)){
  stop('savenc can only save sensor or metadata structures') 
}

# append .nc suffix to file name if needed
if (length(fname)<3 || !(fname[length(fname)+(-2:0)]=='.nc')){
  fname[length(fname)+(1:3)] <-'.nc'
}
  
# test if X is a metadata structure or a sensor structure
if(is.null(X[['name']])){
  vname <- c()
}
else{
  vname <- X$name
}


# check that the deployment ID of X matches the one in the file if the file
# already exists
depid <- c() ;
if(file.exists(fname)){
  S <- ncdf4::nc_open(fname)
  k = which(identical({S.Attributes[].Name},'depid'))
  if (length(k) != 0){
    depid = S.Attributes[k].Value 
    if (identical(depid,X$depid)==0){
      stop('File already associated with deployment id: %s. Choose a different file name.\n', depid)
    }
  }
  k <- which(identical({S.Variables[].Name},vname))
  if(length(k) != 0){
    stop('Variable %s already exists in file: choose a different name\n',vname)
  }
}




# now ready to save the structure
if (length(vname) != 0){ # X is a sensor structure
  if (is.null(X[['data']]) || length(X$data) == 0){
    ncdf4::nc_create(fname,vname)
  }
  else{
    ncdf4::nc_create(fname,vname,'Dimensions',{'samples',size(X.data,1),'axis',size(X.data,2)})
    ncdf4::nc_write(fname,vname,X.data)
  }
  ncwriteatt(fname,vname,'name',X.name)
  if(!is.null(X[['fs']])){
    ncwriteatt(fname,vname,'sampling','regular')
    ncwriteatt(fname,vname,'sampling_rate',X.fs)
    ncwriteatt(fname,vname,'sampling_rate_unit','Hz')
  }
  if (is.null(X[['meta']])){
    stop('Warning: No metadata in variable #s\n',X$name)
  }
  else{
    F <- fieldnames(X$meta) ;
    V <- struct2cell(X$meta) ;
    for(k in 1:length(F)){
      if(!is.chararacter(V[[k]])){
        fprintf('All metadata fields must be strings: leaving field #s blank\n',F{k}) ;
        ncwriteatt(fname,vname,c('meta_',F[[k]]),'') ;
      }
      else{
        ncwriteatt(fname,vname,c('meta_', F[[k]]),V[[k]])
      }
    }
  }# save some default file attributes if none are present
  
  
  
  if (length(depid) == 0){
    ncwriteatt(fname,'/','depid',X$depid);
    depid <- X$depid
  }
  ncwriteatt(fname,'/','creation_date',datestr(now));
  #return
}		




# Otherwise X is a metadata structure. Add it to the general attributes for the file
# Overwrite any field already present
if(length(depid) == 0){
  ncdf4::nc_create(fname,'_empty');
}



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



ncwriteatt(fname,'/','creation_date',datestr(now));

}