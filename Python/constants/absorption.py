def absorption(f, T, d):
    """Calculates the absorption coefficient for sound in seawater. 
    After Kinsler and Frey pp. 159-160.

    :param f: frequency in Hz
    :type: scalar or vector
    :param T: temperature in degrees C
    :type: scalar or vector
    :param d: depth in meters
    :type: scalar or vector
    Input arguments can be scalars, or a mixture of vectors and scalars as long as each argument is either a vector of length nx1 (with n being the same for all vector arguments) or a scalar.

    :raises: missing inputs: if you input less than three arguments, the function will not accept it. All three are required.

    :return: The sound absorption in db per meter
    :rtype: scalar, if all inputs were scalars. If one or more were vectors, return is a vector.

    Example: absorption(140000, 13, 10) 
    # returns 0.04354982 dB/m

    """
    if (d == None):
        print("Error: all inputs are required")
        return None
    from math import exp
    Ta = T + 273.0
    Pa = 1.0 + d / 10.0
    f1 = 1320.0 * Ta * exp(-1700 / Ta)
    f2 = 15500000.0 * Ta * exp(-3052.0 / Ta)
    A = 0.0000000895 * (1.0 + .023 * T - .00051 * T**2)
    B = 0.000000488 * (1.0 + .013 * T) * (1.0 - 0.0009 * Pa)
    C = .000000000000476 * (1.0 - .040 * T + .00059 * T**2) * (1.0 - .00038 * Pa)
    absp = A * f1 * f**2 / (f1**2 + f**2) + B * f2 * f**2 / (f2**2 + f**2) + C * f**2
    return absp

print(absorption(140000.0, 13.0, 10.0))