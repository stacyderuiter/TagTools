def read_cats_csv(fname=None, maxsamps=None):
    
    """
    Read a CSV file with sensor data from a CATS tag. CATS CSV files can be very large and a number of steps are taken here to maximize speed and avoid  memory problems. 
    This function is usable by itself but is more normally called by read_cats() which handles metadata and creates a NetCDF file.

    V,HDR,EMPTY = read_cats_csv(fname,maxsamps)

    Input:
    fname is the file name of the CATS CSV file including the complete path name if the file is not in the current working directory or in a directory on the path. The .csv suffix is not needed.
    maxsamps is optional and is used to limit reading to a maximum number of samples per sensor. This is useful to read in a part of a very large file for testing. 
     If maxsamps is not given, the entire file is read.

    Returns:
    A tuple with the following elements:
    V is an array of data read from the file. V has a row for each data line in the file. The number of columns is one less than the number of non-empty fields.
     This is because date and time, which appear as separate fields in the CSV file, are amalgamated into a Matlab date number in V[:,0]. 
     Empty fields, i.e., fields that do not contain a number, are removed.
    HDR is a list of strings containing the names of non-empty fields. The field names are taken from the first line of the CSV file and include units and axis.
     HDR has the same number of items as there are columns in V.
    EMPTY is a list of strings containing the names of empty fields.

		Example:
		 V,HDR,EMPTY = read_cats_csv('mn16_212a\20160730-091117-Froback 11',100)
	    Reads 100 samples from file 20160730-091117-Froback 11.csv and returns the data and field information.

    Valid: Python
    markjohnson@st-andrews.ac.uk
    Python implementation: dmwisniewska@gmail.com
    last modified: 28 July 2021

    
    """
    import os
    import numpy as np
    import re
    import glob
    from tagiofuns.datenum import datenum
    
    CHNK = 1e7
    MAXSIZE = 30e6

    # append .csv suffix to file name if needed
    if len(fname)<4 or fname[-4:]!='.csv':
        fname += '.csv'
        
    V, HDR, EMPTY = ([] for i in range(3))

    with open(fname, 'rb') as fid:
        cc = 0
        sr = np.fromfile(fid, np.ubyte, int(CHNK))
        kl = np.where(sr==10)[0]
        if kl.size==0:
            print('No header found in file\n')
            return (V, HDR, EMPTY)

        if sr[kl[0]-1]==13:
            hdr = ''.join(map(chr, sr[:kl[0]-1]))
        else:
            hdr = ''.join(map(chr, sr[:kl[0]]))
        ss = sr[kl[0]+1:]             # remainder of chunk to process later
        kc = [i for i,l in enumerate(hdr) if l==',']            # find fields in the header
        kc.insert(0,-1)
        kc.append(len(hdr))
        HDR = [None] * (len(kc)-1)
        for k in range(len(kc)-1):
            HDR[k] = hdr[kc[k]+1:kc[k+1]]

        # # find and remove empty fields
        # L = sr[kl[0]+1:kl[1]]           # first data line
        # kc = [i for i,l in enumerate(''.join(map(chr, L))) if l==',']
        # if kc:
        #     ke = np.where(np.diff(kc)==1)[0]+1   # find empty fields
        #     EMPTY = [HDR[i] for i in ke]
        #     HDR = [HDR[i] for i in range(len(HDR)) if i not in ke]
        # else:
        #     EMPTY = list()
        
        HDR.pop(1)      # eliminate Time field as it will be combined with Date
        kg = [i for i,l in enumerate(HDR) if l=='GPS (raw) 2 [raw]']
        HDR.pop(kg[0]) # eliminate GPS time field (GPS (raw) 2) as it will be combined with GPS date (GPS (raw) 1)
        nf = len(HDR) - 1
        npartf = 0
        if glob.glob(os.getcwd() + '/_ttpart*.mat'):
            for f in glob.glob(os.getcwd() + '/_ttpart*.mat'):
                os.remove(f)
        DN = np.array([])  
        X = np.empty((0, nf))

        while 1:
            sr = np.fromfile(fid, np.ubyte, int(CHNK))
            cc += 1
            s = np.hstack((ss,sr))
            print(f" {int(cc*CHNK/1e6)} MB read: {''.join(map(chr, s[:19]))}\n")
            kl = np.where(s==10)[0]
            if kl.size != 0:
                ss = s[kl[-1]+1:]
            else:
                ss = np.array([])
            D = [None] * len(kl)
            DF = [None] * len(kl)
            x = np.zeros((len(kl),nf))
            kl = np.hstack((-1,kl))
            for kk in range(len(kl)-1):    # for each line
                L = s[kl[kk]+1:kl[kk+1]]    # this line
                kc = [i for i,l in enumerate(''.join(map(chr, L))) if l==',']
                L[kc] = 32
                
                # deal with GPS time fields:
                ke = np.where(np.diff(kc)==1)[0]+1   # find empty fields
                if ke.size != 0:
                    Lp = np.append(L[:kc[ke[0]]],np.array([78,97,78]))
                    L = np.append(Lp,L[kc[ke[0]]+1:])
                else:
                    dg = ''.join(map(chr, L[kc[kg[0]-1]+1:kc[kg[0]+1]]))
                    ke = [i for i,l in enumerate(dg) if l=='.']
                    dg = dg.replace('.','-',len(ke)-1)
                    dgf = float(dg[ke[-1]:])
                    dg = dg[:ke[-1]]
                    dgn = datenum(dg,formatMat='dd-mm-yyyy HH:MM:SS')+dgf/3600/24
                    Lp = np.append(L[:kc[kg[0]-1]+1],np.array([ord(c) for c in str(dgn)]))
                    L = np.append(Lp,L[kc[kg[0]+1]:])      

                dt = ''.join(map(chr, L[:kc[1]]))
                ke = [i for i,l in enumerate(dt) if l=='.']
                dt = dt.replace('.','-',len(ke)-1)
                D[kk] = dt[:ke[-1]]
                DF[kk] = dt[ke[-1]:]
                xx = re.findall(r"[+-]? *(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?|(?:NaN)",''.join(map(chr,L[kc[1]+1:])))
                if len(xx) > nf:
                    print(f"Too many fields in line: {len(xx)} vs {nf}.\n")
                    break
                x[kk,:len(xx)+1] = xx
            df = [float(d) for d in DF]
            if any(D):
                dn = [datenum(d,formatMat='dd-mm-yyyy HH:MM:SS')+f/3600/24 for f,d in zip(df,D)]
            else:
                dn = []
            X = np.append(X, x, axis=0)
            DN = np.append(DN, np.array(dn), axis=0)

            if maxsamps:
                maxsamps = maxsamps - len(dn)
                if maxsamps < 0:
                    DN = DN[:maxsamps]
                    X = X[:maxsamps,:]
                    break

            sz = X.size * X.itemsize
            if sz > MAXSIZE:
                npartf += 1
                tfn = f"_ttpart{npartf}.npz"
                np.savez(os.getcwd() + '/' + tfn, DN=DN, X=X)
                DN = np.array([])  
                X = np.empty((0, nf))

            if len(sr)==0 or all(sr[:10]==0): break

    print(' Assembling results...\n') 

    # reload part files
    npartf += 1
    tfn = f"_ttpart{npartf}.npz"
    np.savez(os.getcwd() + '/' + tfn, DN=DN, X=X)
    V = np.empty((0, len(HDR)))
    for k in range(1,npartf+1):
        fname = f"_ttpart{k}.npz"
        with np.load(os.getcwd() + '/' + fname) as data:
            xDN = data['DN']
            xX = data['X']
        os.remove(os.getcwd() + '/' + fname)
        V = np.append(V, np.column_stack((xDN,xX)), axis=0)

    # find and remove empty fields
    ke = []
    for i in range(V.shape[1]):
        if all(np.isnan(V[:,i])):
            ke.append(i)
    if ke:
        EMPTY = [HDR[i] for i in ke]
        HDR = [HDR[i] for i in range(len(HDR)) if i not in ke]
        for i in sorted(ke,reverse=True):
            V = np.delete(V, i, 1)  

    return (V, HDR, EMPTY)