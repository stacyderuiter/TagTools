loadnc <- function(fname){
  


#     loadnc(fname)
#		or
#		X=loadnc(fname)
#     Load variables from a NetCDF archive file. The file is assumed to be in 
#		the current working directory unless a pathname is added to the beginning 
#		of fname. If no output argument is given, the variables will be created in
#		the current workplace, overwriting any variables with the same name that are
#		already there. If an output argument is given, the variables will be stored
#		as fields of a structure.
#
#		Inputs:
  #		fname is the name of the metadata file. If the name does not include a .nc
#		 suffix, this will be added automatically.
#
#		Returns:
  #		X, if specified, is a structure containing sensor and metadata structures. The
#		 field names in X will be the same as the names of the variables in the NetCDF
#		 file, e.g., if the file contains A and P, X will have fields X.A, X.P and
#		 X.info (the file metadata).
#
#		Example:
  #		 loadnc('testset1')
# 	    loads variables from file testset1.nc into the workplace.
#
#     Valid: Matlab, Octave
#     markjohnson@st-andrews.ac.uk
#     last modified: 12 July 2017

X <- c() 
if(missing(fname)){
  stop("Missing fname!")  
}


# append .nc suffix to file name if needed
if (length(fname)<3 || fname[end+(-2:0)]=='.nc'){
  fname[length(fname)+(1:3)] <- '.nc'
}


if !file.exists(fname){
  stop("File does not exist!")
}

T <- ncinfo(fname) 
F <- {T.Attributes[].Name} ;
V <- {T.Attributes[].Value} ;
info <- list()
for(k in 1:length(F)){
  info$(F[[k]]) = V[[k]] ;
}


#if nargout==0,
#assignin('caller','info',info) ;
#else
 # X.info = info ;
#end

# load the variables from the file
F = {T.Variables(:).Name} ;
for(k in 1:length(F)){
  fn = F[[k]]
  if(fn[1]=='_'){next}		# skip place-holder variable
  X$(fn)$data = ncdf4::nc_read(fname,fn);
  if(length(T$Variables(k))==1 & X$(fn)$data[1] == T$Variables[k]$FillValue){
    X$(fn)$data <- c()
  }
  attr <- T$Variables[k]$Attributes 
  if(length(attr) != 0){
    f <- {attr[]$Name} ;
    v = {attr[]$Value} ;
    for(kk in 1:length(f)){
      X$(fn)$(f[[kk]]) <- v[[kk]]
    }
  }
}



# if no output argument, push the variables into the calling workspace
if(nargout==0){
  for(k=1:length(F)){
    fn = F[[k]] ;
    if (fn[1]=='_'){ next}		# skip place-holder variable
    assignin('caller',fn,X.(fn)) ;
  }
  rm(X)
}

return(X)
}
