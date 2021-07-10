def add_nc(fname=None, X=None):
    
    """
    	Add a variable to a NetCDF archive file. If the archive file does not exist, it is created. The file is assumed to be in the current working directory 
		unless a pathname is added to the beginning of fname.
        
        add_nc(fname,X)
        
        Inputs:
		fname is the name of the metadata file. If the name does not include a .nc
		 suffix, this will be added automatically.
		X is a sensor or metadata structure. Only these kind of variables can be saved
		 in a NetCDF file because the supporting information in these structures is
		 needed to describe the contents of the file. For non-archive and non-portable
		 storage of variables, consider using the usual 'save' function in Matlab and Octave.

		Example:
		 add_nc('dog17_124a',A)
	    generates a file dog17_124a.nc and adds a variable A.

        Valid: Python
        markjohnson@st-andrews.ac.uk, dmwisniewska@gmail.com
        last modified: 8 Jul 2021

    """
    
    import os
    import netCDF4 as nc
    from .remove_nc import remove_nc
    import numpy as np
    from datetime import datetime

    if not fname or not X:
        print(help(add_nc))
        return
        
    if not isinstance(X,dict):
        print('add_nc can only save sensor or metadata dictionaries\n')
        return
    
    # append .nc suffix to file name if needed
    if len(fname)<3 or fname[-3:]!='.nc':
        fname += '.nc'
        
    # test if X is a metadata structure or a sensor structure
    if 'data' not in X.keys():    # only sensor structures have a data key
        vname = None
    else:
        vname = X['name']
    
    # check that the deployment ID of X matches the one in the file if the file already exists
    depid = None
    if os.path.exists(fname):
        ds = nc.Dataset(fname)
        if 'depid' in ds.ncattrs():
            depid = ds.getncattr('depid')
            if depid != X['depid']:
                print(f"File already associated with deployment id: {depid}. Choose a different file name.\n")
                return

        # check if there is already a variable with this name in the file
        if vname in ds.variables.keys():
            s = f"Variable {vname} already exists in file: do you want to replace it y/n? "
            y = input(s)
            if y[0] != 'y':
                return
            ds.close()
            remove_nc(fname,vname)
        ds.close()
    else:
        ds = nc.Dataset(fname,mode='w',format='NETCDF4_CLASSIC')
        ds.close()
    
    # now ready to save the dictionary
    if vname:		# X is a sensor dictionary
        if 'data' not in X.keys() or X['data'].size==0:
            ncfile = nc.Dataset(fname,mode='a',format='NETCDF4_CLASSIC') 
            ncfile.createDimension(vname, 1)
            ncfile.createVariable(vname,np.float64,(vname,))
            ncfile.close()
        else:
            if X['data'].size/X['data'].shape[0]>1:
                ncfile = nc.Dataset(fname,mode='a',format='NETCDF4_CLASSIC') 
                ncfile.createDimension(vname+'_samples', X['data'].shape[0])
                ncfile.createDimension(vname+'_axis', X['data'].size/X['data'].shape[0])
                ncfile.createVariable(vname,np.float64,(vname+'_samples',vname+'_axis'))
            else:
                ncfile = nc.Dataset(fname,mode='a',format='NETCDF4_CLASSIC') 
                ncfile.createDimension(vname+'_samples', X['data'].shape[0])
                ncfile.createVariable(vname,np.float64,(vname+'_samples',))
            ncfile.variables[vname][:]=X['data']

            V = list(X.values())
            for k,key in enumerate(X.keys()):
                if key=='data': continue
                if isinstance(V[k],list) or isinstance(V[k],dict):
                    print(f"Metadata must be strings or numbers: leaving key {key} blank\n")
                    ncfile.variables[vname].setncattr(key,'')
                else:
                    ncfile.variables[vname].setncattr(key,V[k])

            # save some default file attributes if none are present
            if not depid:
                ncfile.setncattr('depid',X['depid'])
                depid = X['depid']
            ncfile.setncattr('creation_date',datetime.now().strftime("%d-%b-%Y %H:%M:%S"))
            ncfile.close()
            return
    
    # Otherwise X is a metadata dictionary. Add it to the general attributes for the file
    # Overwrite any key already present
    if not depid:
        ncfile = nc.Dataset(fname,mode='a',format='NETCDF4_CLASSIC') 
        ncfile.createDimension('_empty', 1)
        ncfile.createVariable('_empty',np.float64,('_empty',))

    V = list(X.values())
    for k,key in enumerate(X.keys()):
        try: ncfile.close()  # just to be safe, make sure dataset is not already open.
        except: pass
        ncfile = nc.Dataset(fname,mode='a',format='NETCDF4_CLASSIC')
        if V[k] and isinstance(V[k],list) or isinstance(V[k],dict):
            print(f"Metadata must be strings or numbers: leaving key {key} blank\n")
            ncfile.setncattr(key,'')
        else:
            ncfile.setncattr(key,V[k])

    ncfile.setncattr('creation_date',datetime.now().strftime("%d-%b-%Y %H:%M:%S"))
    ncfile.close()
    return     