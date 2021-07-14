def plott(*varargin):

    """
    Function for plotting tag data.

    Plot sensor time series against time in a single or multi-paneled figure with linked
	x-axes. This is useful for comparing measurements across different sensors. The
	time axis is automatically displayed in seconds, minutes, hours, or days according
	to the span of the data.

    
    fig,axes,h=plott(X)			% X is a sensor dictionary
	   or
    fig,axes,h=plott(X,r)			% X is a sensor dictionary
	   or
    fig,axes,h=plott(X,fsx)		% X is an array of sensor data
	   or
    fig,axes,h=plott(X,fsx,r)	% X is an array of sensor data
	   or
    fig,axes,h=plott(X,Y,...)	% X, Y etc are sensor dictionaries
	   or
    fig,axes,h=plott(X,fsx,Y,fsy,...)	% X, Y etc are arrays of sensor data

    
	   Inputs:
		X, Y, etc, are sensor dictionaries or arrays of time series data.
		fsx, fsy, etc, are the sampling rates in Hz for each data object. Sampling
		 rates are not needed when the data object is a sensor structure. 
		r is an optional argument which has several uses:
        If r='r', the direction of the y-axis is reversed for the data
        object being plotted. This is useful for plotting dive profiles which 
        match the physical situation i.e., with greater depths lower in the
	    display. Note that 'r' is the default for a sensor structure if the
        axes field has a value of 'D' for down.
        If r='i', the preceding data is taken as irregularly sampled. The
         data must have at least 2 columns with the first one being the
        sampling times. In this case, data are plotted as single points
        rather than a continuous line.
        If r is a number, it specifies the number of seconds time offset 
		for the preceding data object. A positive value means that these 
        data were collected later than the other objects and so should be 
        plotted more to the right-hand side. Note that the correct time
         offset is automatically used if the input is a sensor dictionary with
        a start_offset key.

		Returns:
        a tuple with the following items:
  	    fig is a matplotlib figure object.
        axes is a matplotlib axes object.
		h is a list of handles to the lines plotted. There is a list item of
		handles for each axis.

		This is a flexible plotting tool which can be used to display and explore sensor
		data with different sampling rates on a uniform time grid. Zooming any of the
	    panels should cause all of the panels to zoom in or out to match the x-axis.

		Example:
		 loadnc('testset3');
		 plott(P,A,PCA)				% plot depth, acceleration and prey-capture-attempts

    Valid: Python
    markjohnson@st-andrews.ac.uk; dmwisniewska@gmail.com


    """
    
    import numpy as np
    import math
    import matplotlib.pyplot as plt

    def indices(a, func):
        return [i for (i, val) in enumerate(a) if func(val)]

    fig, axes, h = ([] for i in range(3))

    if not varargin:
        help(plott)
        return (fig,axes,h)
 

    brk = [0,2e3,2e4,5e5] 		# break points for plots in seconds, mins, hours, days
    div = [1, 60, 3600, 24*3600] 	# corresponding time multipliers
    L = ['s','min','hr','day'] 	# and xlabels

    # each data object can have one or two qualifying arguments. Scan through varargin
    # to find the objects and their qualifiers.
    X = list()
    T = list()
    ylab = list()
    leg = list()

    # fsrt is a variable to collect the sampling rate, reverse flag and time
    # offset of each panel
    fsrt = np.zeros((len(varargin),3)) 
    for x in varargin:
        if isinstance(x,dict): # this input is a sensor dictionary
            if ('sampling' in x.keys()) and ('data' in x.keys()):
                if x['sampling']=='regular':
                    X.append(x['data'])
                    T.append([])
                    fsrt[len(X)-1,0] = x['sampling_rate'] 
                else:
                    if x['data'].size/x['data'].shape[0]>1:
                        X.append(x['data'][:,1:])
                    else:
                        X.append(np.ones((len(x['data']),1)))
                    T.append(x['data'][:,0])
                    fsrt[len(X)-1,0] = -1

                if 'start_offset' in x.keys():
                    fsrt[len(X)-1,2] = x['start_offset']

                if ('axes' in x.keys()) and (len(x['axes'])==1):
                    fsrt[len(X)-1,1] = x['axes'].upper()=='D'

                if ('full_name' in x.keys()) and ('unit' in x.keys()):
                    ylab.append(f"{x['full_name']} ({x['unit']})")
            
                if 'column_name' in x.keys():
                    leg.append(x['column_name'].split(','))
                elif 'name' in x.keys():
                    leg.append(x['name'])

            else:
                print('Error: sensor structure must have data and sampling fields\n')
                return (fig,axes,h)

        elif x.shape[0]>1 or x.size/x.shape[0]>1: # this input is a vector or a matrix
            X.append(x)
            T.append([])

        else: # this input is a qualifier
            if  isinstance(x, str) and len(x) == 1:
                if x[0]=='r':
                    fsrt[len(X)-1,1] = 1
                elif x[0]=='i':
                    fsrt[len(X)-1,0] = -1
                    T[len(X)-1,:] = X[-1][:,0]
                    if X[-2].size/X[-2].shape[0]>1:
                        X[-1] = X[-1][:,1:]
                    else:
                        X[-1] = np.ones((len(X[-1]),1))
                else:
                    print(f"Unknown option to plott {x[0]}, skipping\n")
            else:
                if fsrt[len(X)-1,0]==0:
                    fsrt[len(X)-1,0] = x
                else:
                    fsrt[len(X)-1,2] = x
                    
    
    fsrt = fsrt[:len(X),:]
    if any(fsrt[:,0]==0):
        inds = indices(fsrt[:,0], lambda x: x == 0)
        print(f"Error: sampling rate undefined for data object {inds[0]}\n")
        return (fig,axes,h)

    fig, axes = plt.subplots(len(X), 1, sharex=True, figsize=(12,8), squeeze=False)

    nst = math.inf
    ned = 0 

    for k,x in enumerate(X):
        if fsrt[k,0]>0:
            nst = min(nst,fsrt[k,2])
            ned = max(ned,len(x)/fsrt[k,0]+fsrt[k,2])
        else:
            nst = min(nst,fsrt[k,2]+min(T[k]))
            ned = max(ned,max(T[k])+fsrt[k,2])

    spann = ned-nst
    for divk in range(len(brk)-1,0,-1):
        if spann>=brk[divk]:
            break

    ddiv = div[divk]
    xlims = np.divide([nst, ned],ddiv)
    h = list()
    for k,x in enumerate(X):
        if fsrt[k,0]>0:
            h.append(axes[k,0].plot((np.arange(0,len(x))/fsrt[k,0] + fsrt[k,2])*(1/ddiv),x))
            axes[k,0].grid()
        else:
            h.append(axes[k,0].plot((T[k]+fsrt[k,2])*(1/ddiv),x,marker='.'))
            axes[k,0].grid()
        axes[k,0].set_xlim(xlims)
        if fsrt[k,1]==1:
            axes[k,0].set_ylim(axes[k,0].get_ylim()[::-1])
        if leg and len(leg)==len(X):
            axes[k,0].legend(leg[k])
        if ylab and len(ylab)==len(X):
            axes[k,0].set_ylabel(ylab[k])
            
    xlab = f"Time ({L[divk]})"
    axes[-1,0].set_xlabel(xlab)
    # plt.show()

    return (fig,axes,h)