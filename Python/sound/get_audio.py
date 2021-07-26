def get_audio(fname=None, samples=None, indexing='matlab'):

    """
    	This is a wrapper function for Matlab's wavread functions. This	function provides the legacy functionality of wavread.
        
        x,fs,nbits = get_audio(fname)		# read an entire WAV file; return audio data in a numpy array
		or
		x,fs,nbits = get_audio(fname,samples)	# read a section of a WAV file; return audio data in a numpy array
		or
		x,fs,nbits = get_audio(fname,'size')	# get the size and sampling rate
        
        Inputs:
		fname is the full filename (including path if the file is not in the current working directory or saved path) of the
		 WAV file. Include the .wav suffix (or any other suffix that may be used.
		samples is a two-element list containing the start and end sample to read in. 
         If indexing is set to 'matlab', matlab indexing is used (i.e. samples in the file start at 1, end inclusive).
         If the string 'size' is specified instead of a 2-element list, the size of the file is returned in x. 
         x will be a two-element list containing the number of samples-per-channel and the number of channels.

         Returns:
        x : numpy array with the sound OR list with size of audio data
        fs : sampling frequency.
        nbits : Bit depth.

		Example:
		x,fs,_=getaudio(sound_sample1.wav','size')
	    returns: x=[576000,2], fs=192000

    Valid: Python
    Based on Matlab::wavread and wavpy module by Samuele Carcagno <sam.carcagno@gmail.com>
    markjohnson@st-andrews.ac.uk, dmwisniewska@gmail.com
    Last modified: 16 July 2021

    """
    
    from scipy.io import wavfile
    import numpy as np
    from numpy import float32, int16, int32
    
    x, fs, nbits = ([] for i in range(3))
    if not fname and not samples:
        print(help(get_audio))
        return (x,fs,nbits)

    if not samples:
        samples = []

    fs, snd = wavfile.read(fname)
    if snd.dtype == "int16":
        snd = snd / (2.**15)
        nbits = 16
    elif snd.dtype == "int32":
        snd = snd / (2.**31)
        nbits = 32
    elif snd.dtype == "float32":
        nbits = 32

    if isinstance(samples,str) and samples.lower()=='size':
        x = [snd.shape[0], int(snd.size/snd.shape[0])] 
    elif not samples:
        x = snd
    else:
        if indexing=='matlab':
            samples[0] -= 1
        x = snd[samples[0]:samples[1]]

    return (x,fs,nbits)  
