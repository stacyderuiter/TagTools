def m2py(formatMat=None):
    """
    Convert Matlab's datestr format's symbolic identifiers to Python's datetime format code list.
    
    formatPy = m2py(formatMat)
    
    Input:
    formatMat is a string with symbolic identifiers of date-time format used by Matlab
    
    Output:
    formatPy is a string with format codes used by Python's datetime package
    
    dmwisniewska@gmail.com
    Last modified: 
    24 Jul 2021
    
    """
    formatPy = ''
    
    if not formatMat or not isinstance(formatMat, str):
        print(help(m2py))
        return formatPy
        
    pyreg = []
    n=0
    while n < len(formatMat):
        if formatMat[n] == '/':
            pyreg.append('/')
            n += 1
        elif formatMat[n] == '-':
            pyreg.append('-')
            n += 1
        elif formatMat[n] == ' ':
            pyreg.append(' ')
            n += 1
        elif formatMat[n] == ':':
            pyreg.append(':')
            n += 1
        elif formatMat[n] == '.':
            pyreg.append('.')
            n += 1
        elif formatMat[n] == ',':
            pyreg.append(',')
            n += 1
        elif formatMat[n].lower() == 'd':
            ix = formatMat[n:min([n+5,len(formatMat)])].lower().rfind('d')
            if ix == 0: # day using capitalized first letter
                print('Day format using capitalized first letter not valid. Using weekday as a decimal number instead.')
                pyreg.append('%w')
                n += 1
            elif ix == 1: # day in two digits
                pyreg.append('%d')
                n += 2
            elif ix == 2: # day using first three letters
                pyreg.append('%a')
                n += 3
            elif ix == 3: # day using full name
                pyreg.append('%A')
                n += 4
        elif formatMat[n] == 'm':
            ix = formatMat[n:min([n+5,len(formatMat)])].rfind('m')
            if ix == 0: # month using capitalized first letter
                print('Month format using capitalized first letter not valid. Using month as a zero-padded decimal number instead.')
                pyreg.append('%m')
                n += 1
            elif ix == 1: # month in two digits
                pyreg.append('%m')
                n += 2
            elif ix == 2: # month using first three letters
                pyreg.append('%b')
                n += 3
            elif ix == 3: # month using full name
                pyreg.append('%B')
                n += 4
        elif formatMat[n].lower() == 'y':
            ix = formatMat[n:min([n+5,len(formatMat)])].lower().rfind('y')
            if ix == 1: # year in two digits
                pyreg.append('%y')
                n += 2
            elif ix == 3: # year in full
                pyreg.append('%Y')
                n += 4
        elif formatMat[n].lower() == 'h':
            if formatMat[-2:].upper() in ['AM','PM']:
                pyreg.append('%I') # 12-hour format 
            else:
                pyreg.append('%H') # 24-hour format
            n += 2
        elif formatMat[n] == 'M':
            pyreg.append('%M') # minute in two digits
            n += 2
        elif formatMat[n].lower() == 's':
            pyreg.append('%S') # second in two digits
            n += 2
        elif formatMat[n].lower() == 'f' and formatMat[n:min([n+4,len(formatMat)])].lower().rfind('f') == 2:
            pyreg.append('%f')
            n += 3
        elif formatMat[n].upper() == 'A' and formatMat[n+1].upper() == 'M':
            pyreg.append('%p')
            n += 2
        elif formatMat[n].upper() == 'P' and formatMat[n+1].upper() == 'M':
            pyreg.append('%p')
            n += 2

    formatPy = ''.join(pyreg)     
    return formatPy


def py2m(formatPy=None):
    """
    Convert Python's datetime format code to Matlab's datestr format's symbolic identifiers.
    
    formatMat = py2m(formatPy)
    
    Input:
    formatPy is a string with format codes used by Python's datetime package
        
    Output:
    formatMat is a string with symbolic identifiers of date-time format used by Matlab    
    
    dmwisniewska@gmail.com
    Last modified: 
    24 Jul 2021
    
    """
    formatMat = ''
    
    if not formatPy or not isinstance(formatPy, str):
        print(help(py2m))
        return formatMat
        
    matreg = []
    n=0
    while n < len(formatPy):
        if formatPy[n] == '/':
            matreg.append('/')
            n += 1
        elif formatPy[n] == '-':
            matreg.append('-')
            n += 1
        elif formatPy[n] == ' ':
            matreg.append(' ')
            n += 1
        elif formatPy[n] == ':':
            matreg.append(':')
            n += 1
        elif formatPy[n] == '.':
            matreg.append('.')
            n += 1
        elif formatPy[n] == ',':
            matreg.append(',')
            n += 1
        elif formatPy[n] == '%':
            if formatPy[n+1].lower() == 'w': # weekday as a decimal number
                print('Weekday as a decimal number not valid. Using capitalized first letter instead.')
                matreg.append('d')
            elif formatPy[n+1].lower() == 'd': # day of month as a zero-padded decimal number
                matreg.append('dd')   
            elif formatPy[n+1] == 'a': # abbreviated weekday name
                matreg.append('ddd')
            elif formatPy[n+1] == 'A': # full weekday name
                matreg.append('dddd')
            elif formatPy[n+1] == 'm': # month as a zero-padded decimal number
                matreg.append('mm')
            elif formatPy[n+1] == 'b': # abbreviated month name
                matreg.append('mmm')
            elif formatPy[n+1] == 'B': # full month name
                matreg.append('mmmm')
            elif formatPy[n+1] == 'y': # abbreviated month name
                matreg.append('yy')
            elif formatPy[n+1] == 'Y': # full month name
                matreg.append('yyyy')
            elif formatPy[n+1] in ['I','H']: # hour as a zero-padded decimal number
                matreg.append('HH')
            elif formatPy[n+1] == 'M': # minute in two digits
                matreg.append('MM')
            elif formatPy[n+1] == 'S': # second in two digits
                matreg.append('SS')
            elif formatPy[n+1].lower() == 'f': # microseconds
                matreg.append('fff') # milliseconds 
            elif formatPy[n+1].lower() == 'p':
                matreg.append('PM')
            n += 2 

    formatMat = ''.join(matreg)        
    return formatMat