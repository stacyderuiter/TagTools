import datetime

def julian_day(y = None, m = None, d = None):
    """ Convert between dates and Julian day numbers.

    This function is used to convert between dates and Julian day numbers. There are three different input arrangements, each of which returns a different output. For a discription of the different input arrangements, see below.

    Possible input combinations: 
    (n <- julianday) returns the Julian day number for today. 
    (n = julianday(y,d)) where y is a single year or a vector of years and d is a single day number or a vector of daynumbers, 
    returns the date vector [year,month,day] for each year, day pair. 
    (n = julianday(y,m,d)) where y is a single year or a vector of years, m is a single month or vector of months, and d is a single month day or a vector of month days, 
    returns the Julian day number for each year, month, day.
    :param y: A single year or vector of years
    :param d: A single day or vector of days
    :param m: A single month or vector of months
    :returns: See the description section for details on the return.

    Example: 
    julian_day(y = 2016, d = 12, m = 10) # Returns: 286
    julian_day(y = 2016, 286) # Returns: "2016-10-12" """
    if ((y == None) and (m == None) and (d == None)):
        now = datetime.datetime.now()
        return(now)
    if (d == None):
        d = m
        k = max(len(y), len(m))
        if (len(y) < k):
            y[len(y) + 1:k] = y[len(y)]
        if (len(d) < k):
            d[len(d) + 1:k] = d[len(d)]
        startdate = datetime.date(year = y, month = 1, day = 1)
        n = startdate + (d - 1)
        return(n)
    k = max(len(y), len(m), len(d))
    if (len(y) < k):
        y[len(y) + 1:k] = y[len(y)]
    if (len(m) < k):
        m[len(m) + 1:k] = m[len(m)]
    if (len(d) < k):
        d[len(d) + 1:k] = d[len(d)]    
    


julian_day()