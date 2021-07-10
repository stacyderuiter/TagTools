def remove_nc(fname=None, vname=None):
    
    """
    Remove a variable from a NetCDF archive file. The file is assumed to be in the current working directory 
    unless a pathname is added to the beginning of fname.
    Only data variables can be deleted, not the info metadata structure.
    
    remove_nc(fname,vname)
    
    Inputs:
	fname is the name of the metadata file. If the name does not include a .nc suffix, this will be added automatically.
	vname is the name of the variable to be removed.

	Example:
	remove_nc('dog17_124a','A') 
    removes variable A from file dog17_124a.nc.

    Valid: Python
    markjohnson@st-andrews.ac.uk; dmwisniewska@gmail.com
    last modified: 8 July 2021

    """
    import netCDF4 as nc
    import os
    from .load_nc import load_nc
    from .add_nc import add_nc
    from .save_nc import save_nc
    
    if not fname or not vname:
        print(help(remove_nc))
        
    if not isinstance(vname,str):
        print('Variable name to remove_nc must be a string\n')
        return
    
    # append .nc suffix to file name if needed
    if len(fname)<3 or fname[-3:]!='.nc':
        fname += '.nc'
        
    try:
        ds = nc.Dataset(fname)
    except:
        print(f"Unable to find file {fname}\n")
        return
    
    if vname not in ds.variables.keys():
        if vname=='info':
            print('info metadata cannot be removed from an nc file\n')
        else:
            print(f"No variable called {vname} in file {fname}\n")
        return
    
    tempname = '_temp.nc'
    if os.path.exists(tempname):
        os.remove(tempname)
        
    X = load_nc(fname, 'info')
    save_nc(tempname, X['info'])

    # copy the variables from the source file
    for fn in ds.variables.keys():
        if fn[0]=='_' or fn==vname: 
            continue # skip place-holder or unwanted variables
        X = load_nc(fname, fn)
        add_nc(tempname, X[fn])
     
    # now overwrite old file with new file
    try: ds.close()  # just to be safe, make sure dataset is not already open.
    except: pass
    os.remove(fname) 
    import shutil
    try:
        shutil.move(tempname,fname)
    except BaseException as e:
        print('File rename failed with message: '+ e)
    
    # update 'creation_date'
    ds = nc.Dataset(fname,mode='a')
    from datetime import datetime
    ds.setncattr('creation_date',datetime.now().strftime("%d-%b-%Y %H:%M:%S"))
    ds.close()
    return