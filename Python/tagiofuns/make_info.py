def make_info(depid=None, tagtype=None, species=None, owner=None):
    
    """
    info = make_info(depid,tagtype,species,owner)	# make an info dictionary
	or
   	make_info()		# shows a list of recognized tags, species and researchers

    Inputs:
    depid is a string containing the name assigned to this deployment, e.g., 'mn19_192a'.
    tagtype is a string containing the initials of the tag type. These are used to find a suitable template file to pre-populate some of
     the metadata. If a matching template file is not found, the metadata will be left mostly empty for you to fill out. Available tag types are:
     'dtag','acous','lleo','cats','mk10'. You can also input:
     'd4' DTAG version 4
     'd3' DTAG version 3
     'd2' DTAG version 2
     'ac' Acousonde
     'll' Little Leonardo
     'dd' Daily Diary (Wildlife Computers)
     'sm' SMRT tag (Wildlife Computers)
    species is a string containing the two letter species prefix, e.g. 'mn'. 
     This should match one or more of the species defined in the file user/species.csv. 
     If there is more than one match, you will be asked to select the species from a list of matches.
    owner is a string containing the initials of the nominal data owner (the person who will be identified in the sensor metadata as whom to
     approach for data access). This should match one or more of the researchers defined in the file user/researchers.csv. If there is 
     more than one match, you will be asked to select the person from a list of matches.

    Returns:
    info is a dictionary of metadata about a tag deployment containing a number of pre-filled keys. 
    You are free to change or add keys afterwards to improve the quality of the metadata.

    Valid: Python
    markjohnson@st-andrews.ac.uk
    Python implementation: dmwisniewska@gmail.com
    Last modified: 25 July 2021
    
    """
    
    from tagiofuns.get_species import get_species
    from tagiofuns.get_researcher import get_researcher
    from tagiofuns.csv2struct import csv2struct
    from datetime import datetime
    import tagiofuns.datestrformat as df
    from collections import OrderedDict
    import os
    
    info = []
    if not tagtype and not species and not owner:
        print(help(make_info))
        ttypes = ['dtag','cats','lleo','mk10','acous']
        print(' Recognized tag types:\n')
        print(*ttypes, sep="  ")
        print('\n Recognized species (from species.csv):\n') 
        get_species()
        print('\n Recognized researchers (from researchers.csv):\n')
        get_researcher()
        return info
    
    if tagtype and isinstance(tagtype, str):
        if tagtype.lower() == 'dtag':
            n = input(' Enter dtag version: 2, 3 or 4... ')
            n = int(n)
            if not n or n not in [2,3,4]:
                return info
            T = csv2struct(os.path.join(os.path.dirname(os.path.abspath(__file__)),f"d{n}_template.csv"))
        elif tagtype.lower() in ['sm','smrt']:
            T = csv2struct(os.path.join(os.path.dirname(os.path.abspath(__file__)),"sm_template.csv"))
        elif tagtype.lower() in ['d4','dtag4']:
            T = csv2struct(os.path.join(os.path.dirname(os.path.abspath(__file__)),"d4_template.csv"))
        elif tagtype.lower() in ['d3','dtag3']:
            T = csv2struct(os.path.join(os.path.dirname(os.path.abspath(__file__)),"d3_template.csv"))
        elif tagtype.lower() in ['d2','dtag2']:
            T = csv2struct(os.path.join(os.path.dirname(os.path.abspath(__file__)),"d2_template.csv"))
        elif tagtype.lower() == 'cats':
            T = csv2struct(os.path.join(os.path.dirname(os.path.abspath(__file__)),"cats_template.csv"))
        elif tagtype.lower() in ['ll','leo','lleo']:
            T = csv2struct(os.path.join(os.path.dirname(os.path.abspath(__file__)),"ll_template.csv"))
        elif tagtype.lower() in ['ac','acous']:
            T = csv2struct(os.path.join(os.path.dirname(os.path.abspath(__file__)),"ac_template.csv"))
        elif tagtype.lower() in ['dd','mk10']:
            T = csv2struct(os.path.join(os.path.dirname(os.path.abspath(__file__)),"mk10_template.csv"))
        else:
            print('Unknown tag type - fill out metadata by hand.\n')
            T = csv2struct(os.path.join(os.path.dirname(os.path.abspath(__file__)),"blank_template.csv"))
    
    T['depid'] = depid
    T['dtype_datetime_made'] = datetime.now().strftime(df.m2py(T['dephist_device_regset']))
    T['dtype_nfiles'] = 'UNKNOWN'
    T['dtype_source'] = 'UNKNOWN'
    T['device_serial'] = 'UNKNOWN'
    T['dephist_deploy_datetime_start'] = 'UNKNOWN'
    T['dephist_device_datetime_start'] = 'UNKNOWN'
    
    if T['device_make'] in ['DTAG','SMRT']:
        from tagiofuns.get_d3_cuetab import get_d3_cuetab
        try:
            C = get_d3_cuetab([],depid,'swv')
            T['dtype_nfiles'] = len(C['fnames'])
            T['dtype_source'] = ','.join(C['fnames'])
            T['device_serial'] = C['id']
            T['dephist_deploy_datetime_start'] = datetime.fromtimestamp(C['start_time']).strftime(df.m2py(T['dephist_device_regset']))
            T['dephist_device_datetime_start'] = T['dephist_deploy_datetime_start']
        except:
            pass
    
    if species and isinstance(species, str):
        S = get_species(species)
        if S:
            T['animal_species_common'] = S['Common_name']
            T['animal_species_science'] = S['Binomial']
            T['animal_dbase_url'] = S['URL']
            if 'ITIS' in S.keys():
                T['animal_dbase_itis'] = S['ITIS']

    if owner and isinstance(owner, str):
        S = get_researcher(owner)
        if S:
            T['provider_name'] = S['Name'] 
            T['provider_details'] = S['Details']
            T['provider_email'] = S['Email']
            T['provider_license'] = S['License']
            T['provider_cite'] = S['Cite']
            T['provider_doi'] = S['DOI']

    info = dict(OrderedDict(sorted(T.items())))  
    # struct2csv(depid,info)
    return info 