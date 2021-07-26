def get_start_time(info=None):
    
    """
    t = get_start_time(info)
    
    """
    from datetime import datetime
    import dateutil.parser
    
    t = []
    if not info:
        print(help(get_start_time))
        return t
    
    if not isinstance(info, dict):
        print('Argument to get_start_time must be an info dictionary.\n')
        return t
    
    if 'dephist_device_datetime_start' in info.keys():
        t = info['dephist_device_datetime_start']
        
    if not t and 'dephist_device_datetime_start' in info.keys():
        t = info['dephist_device_datetime_start']
        
    if not t:
        print('No valid start time in the info dictionary.\n')
        return t
    
    try:
        t = dateutil.parser.parse(t)
        ms = t.microsecond * 1e-6
        t = list(t.timetuple()[:6])
        t[-1] = t[-1] + ms
    except Exception:
        print('Unable to convert time string to a date vector/list.\n') 

    return t    