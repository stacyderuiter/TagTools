def csv2struct(dirpath=None, fname=None):

    """		
        S = csv2struct(fname)		# file is on the search path
		or
		S = csv2struct(dirpath,fname)		# specify where the file is

		Read a CSV metadata file and convert it into a metadata dictionary.
		A metadata file is a text file containing a line for each metadata
		entry. The first comma-separated field in each line is the name of the
		entry which is a dot-separated list of keys, e.g.,
		'animal.dbase.url'. The last field in each line contains the value to
		be assigned to this metadata entry. The value can be a string or number
		but is always saved as a string in the dictionary - it is up to downstream
		users of the metadata to parse/decode the entries.

		Inputs:
		dirpath is a string containing the path to the file. If the file is on
		 the search path, skip this argument.
		fname is the name of the metadata file. If the name does not include a .csv
		 suffix, this will be added automatically.

        Returns:
        S:  a metadata dictionary populated from the file

		Example:
		 S = csv2struct('testset1')
	    returns: S with keys including S['depid']='md13_134a'.

        Valid: Python
		Rene Swift (rjs@st-andrews.ac.uk), markjohnson@st-andrews.ac.uk, dmwisniewska@gmail.com
        last modified: 6 July 2021

    """

    import numpy as np
    import pandas as pd
    import os
    
    S = {}
    if not fname and not dirpath:
        help(csv2struct)
        return S
    elif not fname:
        fname = dirpath
        dirpath = []
    
    if len(fname)<4 or fname[-4:]!='.csv':
        fname += '.csv'
    
    if dirpath:
    #     if np.isin(dirpath[-1],['\\', '/']):
    #         dirpath = dirpath[:-1]
        fname = os.path.join(dirpath,fname)
    
    # Check to see if there is a header field
    if not os.path.exists(fname):
        print(f"Error: cannot find file {fname}\n")
        return S
    
    C = np.loadtxt(fname,dtype=str,delimiter=',',max_rows=1)
    if 'depid' in C:
        C = pd.read_csv(fname,header=None)
    else:
        C = pd.read_csv(fname)
        
    for i,key in enumerate(C.iloc[:,0]):
        key = key.replace('.','_')
        S[key] = C.iloc[i,-1]   
    
    return S