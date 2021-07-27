def datenum(datestr=None, formatMat=None, formatPy=None):
    
    """
    Convert date-time string to Matlab's serial date number.
    The serial date number represents the whole and fractional number of days from a fixed, preset date (January 0, 0000) in the proleptic ISO calendar.
    
    dn = datenum(datestr)
    
    Inputs:
    datestr is a string representing dates and times. If the format used in the text is known, specify the format as either: formatMat or formatPy.
    formatMat (optional) is a string with symbolic identifiers of date-time format used by Matlab 
    formatPy (optional) is a string with format codes used by Python's datetime package
    
    Output:
    dn is Matlab's serial date number
    
    dmwisniewska@gmail.com
    Last modified: 
    27 Jul 2021
    
    """
    
    from datetime import datetime
    
    dn = []
    if not datestr or not isinstance(datestr, str):
        print(help(datenum))
        return dn
    
    if formatMat and isinstance(formatMat, str):
        from tagiofuns.datestrformat import m2py
        formatPy = m2py(formatMat)
        
    if formatPy and isinstance(formatPy, str):
        dt = datetime.strptime(datestr,formatPy)
    else:
        from dateutil import parser
        dt = parser.parse(datestr)
        
    dn = dt.toordinal() + 366 + (dt.hour + dt.minute/60 + (dt.second + dt.microsecond*1e-6)/3600)/24
    return dn