def strip_quotes(s=None):
    """
    Remove bracketing double quotes from string or list containing strings.
    
    s = strip_quotes(s)

    Valid: Python
    markjohnson@st-andrews.ac.uk; dmwisniewska@gmail.com
    last modified: 07 July 2021

    """

    if not s:
        help(strip_quotes)
        return []
        
    if isinstance(s,str):
        s = s.strip()
        if len(s)>=2 and (s[0]=='"' and s[-1]=='"'):
            s = s[1:-1]
        return s
    
    for k,ss in enumerate(s):
        if ss and isinstance(ss,str):
            ss = ss.strip()
            if len(ss)>=2 and (ss[0]=='"' and ss[-1]=='"'):
                ss = ss[1:-1]
            s[k] = ss
    return s