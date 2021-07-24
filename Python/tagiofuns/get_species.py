def get_species(initial=None):
    """
    s = get_species(initial)
    
    initial is a string specifying species initials
    
    s is a dictionary with species details
    
    """
    
    import pandas as pd
    import os
    
    s = {}
    try:
        S = pd.read_csv('./user/species.csv')
    except:
        S = pd.read_csv(os.path.join(os.path.dirname(os.path.abspath(__file__)),'species.csv'))
    if not initial:
        for k, init in enumerate(S.Initial):
            print(init, S.Common_name[k])
        return s
    
    # look for S.Initial that matches species initial
    k = [i for i,x in enumerate(S.Initial) if x.lower() == initial.lower()]

    if not k:
        print(f" No entry matching {initial} in species file - edit file and retry\n")
        return s
    
    if len(k)>1:
        print(f" Multiple entries matching {initial} in species file:\n")
        for kk in range(0,len(k)): 
            print(f" {kk} {S.Common_name[k[kk]]}")
        n = input(' Enter number for correct species... ') 
        n = int(n)
        import math
        if not n or math.isnan(n) or n<0 or n>len(k)-1:
            return s
        k = k[n]
    else:
        k = k[0] 

    s = S.iloc[k].to_dict()
    return s