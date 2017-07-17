savenc <- function(fname, ...){
#
#     savenc(fname,...)
#     Save one or more variables to a NetCDF archive file.
#     Warning, this will overwrite any previous NetCDF file with the same name.
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
  #		 savenc('dog17_124a',A,M,P,info)
# 	    generates a file dog17_124a.nc and adds variables A, M and P, and a metadata
#		 structure.
#
#     Valid: Matlab, Octave
#     markjohnson@st-andrews.ac.uk
#     last modified: 12 July 2017


if(missing(fname) && nargs() < 2){
  stop("Need 2 or more arguments")
}

# append .nc suffix to file name if needed
if (length(fname)<3 | !all(fname[length(fname)+(-2:0)]=='.nc')){
  fname[length(fname)+(1:3)]='.nc';
}

if file.exists(fname){
  file.remove(fname)
}
varagin <- as.list(match.call())
# save the variables to the file
for (k in 2:nargs()-1){
  addnc(fname,varargin[[k]]) 
} 

}