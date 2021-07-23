"""Module storing netcdf functions in tagiofuns: load_nc, save_nc, add_nc, remove_nc.
"""

def load_nc(fname=None, vname=None):
    
    """
    Load variables from a NetCDF archive file.
    
    The file is assumed to be in 
		the current working directory unless a pathname is added to the beginning 
		of fname. If fname is not specified, a file selection window is opened.
        Output argument must be specified. The variables will be stored
		as key-value pairs of a dictionary.
    
        X = load_nc()

		or
		X=load_nc(fname)
    or
		X=load_nc(fname,vname)
     

		Inputs:
		fname is the name of the metadata file. If the name does not include a .nc
		 suffix, this will be added automatically.
    vname is the name of a single variable to read in. If not specified, all variables
     in the file are read.

		Returns:
		X is a dictionary containing sensor and metadata structures. The
		 keys in X will be the same as the names of the variables in the NetCDF
		 file, e.g., if the file contains A and P, X will have fields X['A'], X['P'] and
		 X['info'] (the file metadata).

		Example:
		X = load_nc('testset1')
	    loads variables from file testset1.nc into the workplace.

    Valid: Python
    markjohnson@st-andrews.ac.uk, dmwisniewska@gmail.com
    last modified: 30 June 2021
  
    """
    import numpy as np
    import os
    import netCDF4 as nc
    import platform


    X = {}

    if not fname:
        pth = []
        udir = []

        if os.path.exists('_loadnctemp.txt'):
            x = np.genfromtxt("_loadnctemp.txt", dtype=None)
            pth = ''.join([chr(int(c)) for c in x.tolist()])

        if pth and os.path.isdir(pth):
            udir = os.getcwd()
            os.chdir(pth)

        import tkinter as tk
        from tkinter import filedialog
        root = tk.Tk()
        fname = filedialog.askopenfilename(initialdir=pth)
        root.destroy()

        if udir:
            os.chdir(udir)

        if not fname:
            print(help(load_nc))
            return X

        if platform.system()=='Windows':
            if fname.find('/')>0:
                pth = '\\'.join(os.path.dirname(fname).split('/'))+'\\'
            else:
                pth = os.path.dirname(fname) + '\\'
        else:
            pth = os.path.dirname(fname) + '/'
        pascii = np.array([ord(c) for c in list(pth)])
        np.savetxt('_loadnctemp.txt',pascii.reshape(1,pascii.size),delimiter=' ')

    # append .nc suffix to file name if needed
    if len(fname)<3 or fname[-3:]!='.nc':
        fname += '.nc'

    if not os.path.exists(fname):
        print(f' File {fname} not found\n')
        return X

    ds = nc.Dataset(fname)
    if ds.__dict__.keys():
        if not vname or 'info' in vname:
            X['info'] = ds.__dict__

    # load the variables from the file
    for fn in ds.variables.keys():
        if fn[0]=='_': continue # skip place-holder variable  
        if vname and fn not in vname: continue

        v = ds.variables[fn][:]
        tmp = ds.variables[fn].__dict__.copy()
        if 'column_names' in tmp.keys():
            tmp['column_name'] = tmp.pop('column_names')
        if len(v.data.shape)>1 and v.data.shape[1]!=len(tmp['column_name'].split(',')):
            X[fn] = {'data': v.data.transpose()}
        else:
            X[fn] = {'data': v.data}

        if (X[fn]['data'].shape[0]==1) & any(np.repeat(X[fn]['data'][0],2) == v.fill_value):
            X[fn]['data'] = np.array([])

        if ds.variables[fn].__dict__: # if 'column_name' wanted for variables with 'column_names', this dictionary should be replaced with tmp
            X[fn] = {**X[fn],**ds.variables[fn].__dict__}
            len(X[fn].keys())
    ds.close()

    if not X:
        return X
    
    return X 


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


def save_nc(fname=None, X=None, verbose=0, *varargin):
    
    """
    Save one or more variables to a NetCDF archive file.
    Warning, this will overwrite any previous NetCDF file with the same name.
	The file is assumed to be in the current working directory unless a pathname is added to the beginning of fname.
    
    save_nc(fname,X,verbose,...)
    
    Inputs:
	fname is the name of the metadata file. If the name does not include a .nc suffix, this will be added automatically.
	X (and any subsequent inputs) is a sensor or metadata dictionary, or a set of sensor dictionaries. 
        Only these kind of variables can be saved in a NetCDF file because the supporting information in these dictionaries
        is needed to describe the contents of the file. For non-archive and non-portable storage of variables, consider using the 
        'save' function in Python's numpy package.
    if verbose is 1, information on which dictionaries are added to the file will be displayed in the terminal, if verbose is 0 or 
        not provided - no information will be displayed.

	Example:
	save_nc('dog17_124a',A,M,P,info)
	generates a file dog17_124a.nc and adds variables A, M and P, and a metadata dictionary.

    Valid: Python
    markjohnson@st-andrews.ac.uk, dmwisniewska@gmail.com
    last modified: 10 July 2021
    
    """
    import os
        
    if not fname or not X:
        print(help(add_nc))
        return
    
    # append .nc suffix to file name if needed
    if len(fname)<3 or fname[-3:]!='.nc':
        fname += '.nc'
        
    if not isinstance(X,dict):
        print('save_nc can only save sensor or metadata dictionaries\n')
        return
  
    if verbose!=0 and verbose!=1:
        varargin = list(varargin)+[verbose]
        verbose = 0
    
    if os.path.exists(fname):
        os.remove(fname)
    
    if 'info' in X.keys():      # X is a set of sensor dictionaries
        for key in X.keys():
            add_nc(fname, X[key])
            if verbose==1:
                print(f"Added {key} to {fname}")
    else:
        add_nc(fname,X)
        if verbose==1:
            print(f"Added {X['name']} to {fname}")
        
    # save the remaining variables to the file
    for x in varargin:
        add_nc(fname,x)
        if verbose==1:
            print(f"Added {x['name']} to {fname}")


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