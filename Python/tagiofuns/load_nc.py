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

        
if __name__ == "__main__": # true when running the module as a script, i.e. directly
    print(load_nc([],'info'))