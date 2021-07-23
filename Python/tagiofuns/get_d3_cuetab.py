def get_d3_cuetab(recdir=None, prefix=None, suffix='wav', tempdir=str()):
    
    """
        
        Get timing and file information for a set of WAV format files from a DTAG deployment. All data files with names like recdir/prefixnnn.suffix, 
		where nnn is a 3 digit number will be included. The suffix can be 'wav'	(the default) or 'swv' or any other suffix assigned to WAV-format data.
		This function is called by read_d3 and is not normally called directly.	The function tries to load a previously generated cue file. The cue file 
		is a helper file used to speed up finding sections of a long data stream. 
		The file (called _'prefix''suffix'cues.mat) is saved in the current working	directory or temporary directory (tempdir), if it is provided. 
        If this file is deleted, it is automatically re-generated the next time this function is run.

        C = get_d3_cuetab(recdir,prefix,suffix,tempdir)

		Inputs:
    recdir is a string containing the full path name to the directory where the files are stored. Use recdir=None if the files are in the current working directory. 
        All SWV / WAV files in the directory will be read. For each SWV / WAV file there must also be an XML file with the same name.
    prefix is the first part of the name of the files to analyse. The remainder of the file name should be a number that changes for each file. 
        For example, if the files have names like 'eg207a001.swv', use a prefix of 'eg207a'.
    suffix is an optional file suffix such as 'swv'. The default is 'wav'.
    tempdir is a optional temporary directory for cue files.

    Returns:
		C is a dictionary of timing information:
    C['cuetab'] is an array with a row for each contiguous block of data in the deployment.The columns of cuetab are:
       1. File number
       2. Start time in seconds since the start time (see below)
       3. Number of samples in the block
       4. Status of block (1=zero-filled, 0=data bearing, -1=data gap)
    C['fs'] is the base sampling rate of the sensors. For sensor suites with different sampling rates, this is the lowest sampling rate of any channel.
    C['fnames'] is a list of file names.
    C['recdir'] is the directory name for the recordings.
    C['id'] is the identification number for the recording device.
	C['start_time'] is the UNIX time at the start of the first recording.
	C['dtype'] is a string containing the tag type ('D3' or 'D4').

    Valid: Python
    markjohnson@st-andrews.ac.uk
    Python implementation: dmwisniewska@gmail.com
    Last modified: 23 July 2021
    
    """
    import numpy as np
    import os
    from scipy.io import loadmat
    
    TERR_THR = 0.005 ;       # report timing errors larger than this many seconds
    SERR_THR = 3 ;           # as long as they are also at least this many samples
    C = {} 
    if not prefix:
        print(help(get_d3_cuetab))
        return C
        
    if recdir:
        if recdir.find('\\')>0:
            recdir = '/'.join(recdir.split('\\'))
        if not recdir.endswith('/'):
            recdir += '/'

    if len(tempdir)>0:
        if tempdir.find('\\')>0:
            tempdir = '/'.join(tempdir.split('\\'))
        if not tempdir.endswith('/'):
            tempdir += '/'
    cuefname = tempdir + '_' + prefix + suffix + 'cues.mat'
    if os.path.exists(cuefname):
        annots = loadmat(cuefname)
        for key in annots['C'].dtype.fields.keys():
            if len(annots['C'][key][0][0])>0:
                if annots['C'][key].flat[0].shape[0]>1: # this is a bit clumsy, but works for now
                    C[key] = annots['C'][key].flat[0]
                elif annots['C'][key].flat[0].shape[0]==1 and len(annots['C'][key].flat[0].shape)==1:
                    C[key] = annots['C'][key].flat[0][0]
                else:
                    C[key] = annots['C'][key].flat[0].flat[0]
            else:
                print(key, annots['C'][key][0][0])
                C[key] = ''
        return C
    
    if not recdir:
        recdir = os.getcwd()
        print(f" No recdir provided. Searching for {suffix} files for {prefix} in current directory: {recdir}\n")
        # print(f" Cue file for {prefix} not found - run d3getcues or read_d3\n") # matlab code - not implemented
        # return C # matlab code - not implemented
    
    print(f" Generating cue file for {suffix} - will take a few seconds\n")
    ff = []
    ff += [each for each in os.listdir(recdir) if each.startswith(prefix) and each.endswith('.xml')]		# get file names
    if not ff:
        print(f" No recordings starting with {prefix} found in directory {recdir}\n")
        return C
    
    fn = list()
    for nm in ff:		# strip the suffix from the file names
        nm = ''.join(nm.split('.')[:-1])
        try:
            tmp = int(nm[-3:])
            fn.append(nm)
        except: pass
        
    print(f" Found {len(fn)} files. Checking file {1:03}")
    id, fs = ([] for i in range(2))
    BLKS = np.array([]).reshape((0,5))
    
    # read in XML metadata for each data file and assemble a cue table
    import sys
    from tagiofuns.read_d3_xml import read_d3_xml

    for k,file in enumerate(fn):
        sys.stdout.write("\033[F") #back to previous line 
        sys.stdout.write("\033[K") #clear line 
        print(f" Found {len(fn)} files. Checking file {k+1:03}")
        d3 = read_d3_xml(recdir + file + '.xml')
        if not d3:
            print(f" Error: unable to find or read file {file}.xml\n")
            return C

        # find the sampling rate if we don't already know it
        if not fs:
            fs,fsne,_ = getfs(d3,suffix)		# this function is in the same module
            id = getid(d3) ;							# this function is in the same module

        # find WAVBLK entries with the correct suffix
        blks = getwavblks(d3,suffix)    # check if WAVBLK entries are in the xml file
        if len(blks)==0:
            blks = getwavtblks(recdir+file, suffix)
        if len(blks)==0:
            print('\n Error: no WAVBLK data or timing files - check version of d3read and re-run\n')
            return blks

        # if a corresponding WAV file exists, check the sample count and rate
        fname = recdir + file + '.' + suffix
        if not os.path.exists(fname):
            print(f" No {suffix} file found for recording {file}, skipping\n")
        else:
            from sound.get_audio import get_audio
            s,fss,_ = get_audio(fname,'size')
            if not isinstance(fss,int) and len(fss)>1:
                fss = fss[0]
            if fsne!=fss:
                print(f" Warning: Sampling rate mismatch in recording {file}\n")
            if s[0]!=sum(blks[:,2]):
                print(f" Warning: Sample count mismatch in recording {file}\n")
        BLKS = np.vstack([BLKS, np.concatenate((np.tile(k,(blks.shape[0],1)), blks),axis=1)])
    print('\n')
    
    if not fs:
        print(' Warning: Unable to determine sampling rate for this configuration\n')
        return C

    if BLKS.shape[0] <= 1:
        return C

    # BLKS has columns: [file number,Unix time,microseconds,samples,type]
    frst = 1
    while 1:				# check the timing of the BLKS
        tpred = np.cumsum(BLKS[:-1,3])/fs
        tnxt = (BLKS[1:,1]-BLKS[0,1])+(BLKS[1:,2]-BLKS[0,2])*1e-6
        terr = tnxt - tpred
        serr = (terr*fs).round()   # time errors in samples
        k = [i for i,x in enumerate(terr) if (abs(x) > TERR_THR and abs(serr[i]) > SERR_THR)]
        if len(k)==0:
            BLKS[1:,2] = BLKS[1:,2] - terr*1e6
            break
        else:
            k = k[0]
        BLKS[1:k+1,2] = BLKS[1:k+1,2] - terr[:k]*1e6
        if frst:
            print(' Warning: Gaps found between data blocks\n')
            print('          Gaps are allowed and are managed by the tag tools but if gaps are\n') 
            print('          unexpected check version of d3read or d4read.\n') 
            frst = 0
        if k < BLKS.shape[0] and (BLKS[k,0]==BLKS[k+1,0]):
            print(f" => gap in file {fn[int(BLKS[k,0])]} of {terr[k]} seconds ({serr[k]} samples)\n")
        else:
            print(f" => gap between files {fn[int(BLKS[k,0])]} and {fn[int(BLKS[k+1,0])]} of %{terr[k]} seconds ({serr[k]} samples)\n")
        st = tpred[k] + BLKS[0,1] + BLKS[0,2]*1e-6
        ablks = [BLKS[k,0], st//1, st%1*1e6, serr[k], -1]
        BLKS = np.vstack([BLKS[:k+1,:], ablks, BLKS[k+1:,:]])   # add the gap lines to the block table

    k = [i for i,x in enumerate(terr) if (x < -TERR_THR and serr[i] < -SERR_THR)]
    if len(k)!=0:
        print(f" {len(k)} data overruns detected with maximum size {-min(terr)} seconds ({-min(serr)} samples)\n")

    # nominate a reference time and refer the cues to this time
    C['start_time'] = BLKS[0,1] + BLKS[0,2]*1e-6  # start time is time of 1st sample in the deployment
    ctimes = (BLKS[:,1]-BLKS[0,1])+(BLKS[:,2]-BLKS[0,2])*1e-6
    C['cuetab'] = np.vstack([BLKS[:,0], ctimes, BLKS[:,3], BLKS[:,4]]).transpose()
    C['fs'] = fs
    C['id'] = id
    C['fnames'] = fn
    C['recdir'] = recdir
    C['dtype'] = getdgen(d3) # not there in matlab

    import scipy
    scipy.io.savemat(cuefname, {"C": C})
    return C 
    

def getfs(d3=None, suffix='wav'):
    """
    """
    fs, fsne, k = ([] for i in range(3))

    if not d3 or 'CFG' not in d3.keys():
        return (fs,fsne,k)
    
    for k,c in enumerate(d3['CFG']):
        if '@FTYPE' not in c.keys(): continue
        if c['@FTYPE']!='wav': continue
        if 'SUFFIX' not in c.keys(): continue
        if not c['SUFFIX'].startswith(suffix): continue
        if 'FS' not in c.keys(): continue
        if 'EXP' in c.keys(): # not tested, but source of error in Matlab, so make sure it is correct
            expn = int(c['EXP'])
            print(f" Verify that d3['CFG']['EXP'] is equal to {expn} in the xml file.\n")
        else:
            expn = 0
        fsne = float(c['FS'])
        fs = fsne * 10**expn 
        break 
    return (fs,fsne,k)


def getid(d3=None):
    """
    """
    id = []
    if not d3 or 'DEVID' not in d3.keys():
        return id
    
    ss = d3['DEVID']
    Z = list()
    if ss.count(',')>0:
        Z = ss.split(',')
    else:
        Z = ss.split()

    if len(Z)<4:
        id = int(''.join(Z[:2]),16)
    else:
        id = int(''.join(Z[2:4]),16)

    return id


def getwavblks(d3=None, suffix='wav'):
    """
    """
    import numpy as np

    blks = []
    if not d3 or 'WAVBLK' not in d3.keys():
        return blks

    for c in d3['WAVBLK']:
        if 'SUFFIX' not in c.keys(): continue
        if c['SUFFIX']!=suffix: continue
        if 'RTIME' not in c.keys() or 'MTICKS' not in c.keys() or 'NSAMPS' not in c.keys(): continue
        blks.append([int(c['RTIME']), int(c['MTICKS']), int(c['NSAMPS']),0])
    
    blks = np.array(blks)
    return blks


def getwavtblks(fn=None, suffix='wav'):
    """
    WARNING: the function has not been tested on the old format. Please send the file to dmwisniewska@gmail.com for verification.
    """
    import os
    import pandas as pd
    import numpy as np

    blks = []
    if not fn:
        return blks

    fname = fn + '.wavt'  # first check if there are '.wavt' files in the new format
    if os.path.exists(fname):
        c = pd.read_csv(fname)
        ks = [i for i,x in enumerate(c.SUFFIX) if x.lower() == suffix.lower()]
        for kk in ks:
            x = []
            x.append(int(c.RTIME[kk]))
            x.append(int(c.MTICKS[kk]))
            x.append(int(c.NSAMPS[kk]))
            x.append(int(c.STATUS[kk]))
            blks.append(x)

    # if not, check for the old format
    if not blks or len(blks)==0:
        fname = fn + '.' + suffix + 't'
        if os.path.exists(fname):
            print(help(getwavtblks))
            blks.append(list(c.loc[0]))
    
    blks = np.array(blks)
    return blks


def getdgen(d3=None):
    """
    """
    dgen = []
    if not d3:
        return dgen
    
    if 'DGEN' in d3.keys():
        dgen = d3['DGEN']
    elif 'HOST' in d3.keys():
        dgen = d3['HOST']['@PROG'][:2].upper()
        
    return dgen