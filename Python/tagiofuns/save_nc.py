def save_nc(fname=None, X=None, verbose=0, *varargin):
    
    """Save one or more variables to a NetCDF archive file.
    
    Warning, this will overwrite any previous NetCDF file with the same name.
	The file is assumed to be in the current working directory unless a pathname is added to the beginning of fname.
    
    save_nc(fname,X,verbose,...)
    
    :param fname: The name of the metadata file. If the name does not include a .nc suffix, this will be added automatically.
	:param X: (and any subsequent inputs) A sensor or metadata dictionary, or a set of sensor dictionaries. 
        Only these kind of variables can be saved in a NetCDF file because the supporting information in these dictionaries
        is needed to describe the contents of the file. For non-archive and non-portable storage of variables, consider using the 
        'save' function in Python's numpy package.
    :param verbose: If this is set to 1, information on which dictionaries are added to the file will be displayed in the terminal. 
        If verbose is 0 or not provided, no information will be displayed.
    :raises TypeError: if sensor or metadata dictionaries are not input, save_nc cannot save them.

	Example:
	save_nc('dog17_124a',A,M,P,info)
	generates a file dog17_124a.nc and adds variables A, M and P, and a metadata dictionary.

    Valid: Python
    markjohnson@st-andrews.ac.uk, dmwisniewska@gmail.com
    last modified: 10 July 2021
    
    """
    import os
    from .add_nc import add_nc
    
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