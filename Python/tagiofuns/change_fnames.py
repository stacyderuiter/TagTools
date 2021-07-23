def change_fnames(recdir=None, prefix=None, newprefix=None):
    
    """
    Change the names of files in a directory. This is useful for changing the names of a set of files from a tag deployment to a different format. 
    Only the first part of the name matching the prefix is changed - any trailing letters or numbers are kept.
    Careful: things can go very wrong when messing with valuable data files. Always do a check first on some dummy files. 
    There may also be better ways to do re-naming operations through your operating system.

    Inputs:
    recdir is a string containing the full or relative (to the current working directory) pathname of the directory where the files are stored.
    prefix is a string containing the part of the file name to be changed.
    newprefix is a string containing the replacement.

    Returns:
    n is the number of files that were re-named.

    Example:
     change_fnames('/tag/data/zc17','zc17_173a','zc17_172a')
    renames all files in /tag/data/zc17 called zc17_173a* to zc17_172a*.

    Valid: Python
    markjohnson@st-andrews.ac.uk
    Python implementation dmwisniewska@gmail.com
    last modified: 23 July 2021
    
    """
    import os
    
    n = 0

    if not all([recdir,prefix, newprefix]):
        print(help(change_fnames))
        return n

    if recdir.find('\\')>0:
        recdir = '/'.join(recdir.split('\\'))
    if not recdir.endswith('/'):
        recdir += '/'
    if recdir.startswith('/'):
        recdir = '.' + recdir

    ff = []
    ff += [each for each in os.listdir(recdir) if each.startswith(prefix)]		# get file names
    if not ff:
        print(f" No recordings starting with {prefix} found in directory {recdir}\n")
        return n

    for fn in ff:
        ofn = newprefix + fn[len(prefix):]
        try:
            os.rename(os.path.join(recdir,fn), os.path.join(recdir,ofn))
            n += 1
        except Exception as e:
            print('Failed with message: ' + str(e))

    return n   