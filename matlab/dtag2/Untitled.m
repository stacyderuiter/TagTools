clc;
%PGA common mode volts
if 0
    r3 = 54.9e3;
    r2 = 0.25*r3;
    r2 = 13.7e3;
    r1 = 1.5*r3;
    r1 = 82.5e3;
    i = 3.3/(r1+r2+r3);
    v1 = 3.3*((r2+r3)/(r1+r2+r3));
    v2 = v1*(r3/(r2+r3));
    [r1 r2 r3]
    [v1 v2]
    i
end

%PGA Gain
if 0
    ri = 3.32e3;
    rf = 11.2*ri;rf = 37.4e3;
    rl = (2*rf*ri)/(-2*ri+rf);rl = 8.06e3;
    [ri rf rl]./1000
    en = sqrt((4*1.38e-23*298*rf)*(1+rf/ri));
    en/1e-9
    0.707/ri
end

%S&K no gain
if 0
    fc = 10e3;
    q = 0.541;
    c1 = 4.7e-9;
    c2 = 4*q^2*c1;
    r = 1/(6.8*fc*c1);
    r
    [c1 c2]
end
    

%S&K with gain
if 0
    r = 10e3;c2 = 10e-9;
    A = 1/(2*pi*10e3*r);
    c1 = 0.5*(A/1.307 + 0.25*c2);
    [c1 c2]
    c1 = 1.8e-9;
    fc = 1/(2*pi*r*sqrt(c1*c2))
    q = sqrt(c1*c2)/(2*c1 - 0.25*c2)
end
%S&K test
if 1
    r1 = 3.92e3;
    r2 = r1;
    c1 = 540e-12;
    c2 = 1650e-12;
    K = 1.25;
    fc = 1/(2*pi*sqrt(r1*r2*c1*c2))
    q = sqrt(r1*r2*c1*c2)/(r1*c1 + r2*c1 + r1*c2*(1 - K))
end
