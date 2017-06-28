function acf = acf_nan(x, lmax)
% Calculates the autocorrelation function while passing over NaN values
%  This produces the same output as that found from the acf.R function in
%  the stats package.
n = size(x, 1);
ns = size(x, 2);
nl = lmax;
acf = zeros(lmax * ns * ns,1);
d1 = nl+1;
d2 = ns*d1;

for u = 1:ns
    for v = 1:ns
        for lag = 1:nl+1
            sum = 0;
            nu = 0;
            for i = 1:(n-lag-1)
                if ~isnan(x(i + lag + (n*u)))
                    nu = nu +1;
                    sum = sum + (x(i + lag + (n*u)) * x(i + (n*v)));
                end
                if nu > 0 
                    acf(lag + (d1*u) + (d2*v)) = sum/(nu +lag);
                else
                    acf(lag + (d1*u) + (d2*v)) = [];
                end
            end
        end
    end
end

if n == 1
    for u = 1:ns
        acf(0 + (d1*u) + (d2*u)) = 1;
    end
else
    se = zeros(ns,1);
    for u = 1:ns
        se(u) = sqrt(acf(0 + (d1*u) + d2*u));
        for v = 1:ns
            for lag = 1:nl+1
                a = acf(lag + (d1*u) + (d2*v)) / (se(u)*se(v));
                if a > 1
                    acf(lag + (d1*u) + (d2*v)) = 1;
                elseif a < -1
                    acf(lag + (d1*u) + (d2*v)) = -1;
                else
                    acf(lag + (d1*u) + (d2*v)) = a;
                end
            end
        end
    end
end



        