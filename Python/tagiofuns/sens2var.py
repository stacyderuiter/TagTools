def sens2var(Sx=None, Sy=None, r=None):
    
    """Extract data from a sensor dictionary.
    
    :param Sx: dictionary you want data from
    :type: must be a dictionary
    :param Sy: dictionary you want data from
    :type: must be a dictionary
    :param r: can stand in for fs or T:
        fs: sampling rate, a scalar
        T: sample times, a vector
    
    Ways to call the function:
       X,fs = sens2var(Sx)     % regularly sampled data
       or
       X,T = sens2var(Sx)      % irregularly sampled data
       
    Can also be called with two variables, in which case, they are checked for compatibility (i.e., same length and sampling):
       X,Y,fs = sens2var(Sx,Sy); % regularly sampled data
       or
       X,Y,T = sens2var(Sx,Sy);  % irregularly sampled data
       
    Can also be called with a trailing string 'regular' to check if the sensor dictionaries are regularly sampled. If not, X will be
    returned empty.
    
    :raises TypeError: 
    Sx, Sy must be sensor dictionaries. If not X will be returned empty.
    
    :returns:
        A tuple where:
            X, Y are arrays of sensor data. These are in the unit and frame as stored in the input sensor dictionaries.
            fs is the sampling rate of the sensor data in Hz (samples per second).
            T is the time in seconds of each measurement in data for irregularly sampled data. The time reference (i.e., the 0 time) is with
            respect to the start time of the data in the sensor dictionary.
    
    
    Example:
    load_nc('testset3')
    [pca_dur,pca_time] = sens2var(PCA)
    
    Valid: Python
    markjohnson@st-andrews.ac.uk; dmwisniewska@gmail.com
    Last modified: 08 July 2021

    """

    import numpy as np
    
    X, Y, fs = ([] for i in range(3))

    if not Sx:
        print(help(sens2var))
        return (X,Y,fs)
    
    if not (isinstance(Sx,dict) and ('data' in Sx.keys()) and ('sampling' in Sx.keys())):
        print(' Error: input argument must be a sensor dictionary\n')
        return (X,Y,fs)
    
    if Sy:
        if isinstance(Sy,str):
            r = Sy
            Sy = None
    
    if Sy:
        if not isinstance(Sy,dict) or 'data' not in Sy.keys() or 'sampling' not in Sy.keys():
            print(' Error: input argument must be a sensor dictionary\n')
            return (X,Y,fs)
    
    R = [Sx['sampling']=='regular']*2
    if Sy:
        R[1] = Sy['sampling']=='regular'
    if r and r=='regular' and sum(R)<2:
        print(' Error: input argument must be regularly sampled\n')
        if Sy:
            return (X,Y,fs)
        else:
            return (X,fs)
        return
    
    if sum(R)==1:
        print(' Error: input arguments must both be sampled in the same way\n')
        return (X,Y,fs)
    
    if R[0]:
        X = Sx['data']
        fs = Sx['sampling_rate']
    else:
        fs = Sx['data'][:,0]
        if Sx['data'].size/Sx['data'].shape[0]>1:
            X = Sx['data'][:,1:]
        else:
            X = np.ones((len(fs),1))

    if not Sy:
        return (X,fs)
    
    # here on for two input variables
    if R[1]:
        if fs != Sy['sampling_rate']:
            print(' Error: input arguments must both have the same sampling rate\n')
            X, Y, fs = ([] for i in range(3))
            return (X,Y,fs)
        Y = Sy['data']

    else:
        if Sy['data'].size/Sy['data'].shape[0]>1:
            Y = Sy['data'][:,1:]
        else:
            Y = np.ones((len(Sy['data']),1))

    if X.shape[0] != Y.shape[0]:
        print(' Error: input arguments must both have the same number of samples\n')
        X, Y, fs = ([] for i in range(3))
        return (X,Y,fs)  
    
    return (X,Y,fs)