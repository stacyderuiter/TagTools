function captures = PrCA(A, fs, thresV)
% Automated detection of prey catch attempts (PrCA) from triaxial
%   acceleration data from seals.
%
% INPUTS:
%   A = The acceleration matrix with columns [ax ay az]. Acceleration can
%       be in any consistent unit (e.g. g or m/s^2).
%   fs = The sampling rate in Hz of the acceleration signals.
%   thresV = A user selectable threshold in the same units as A which is
%       used in the process of checking for prey catpure attempts from the
%       equation varS >= varA + thresV at a given second in time. varS is
%       the change in magA (magnitute in acceleration) over one second of
%       time. varA is the per second running average of change in
%       acceleration. The default value is half of the 0.99 quantile of
%       varA.
%
% OUTPUTS:
%   captures =  A structure containing vectors for the capture times 
%       (seconds since start of data recording) and capture varS (change in
%       magA over one second of time) values.
%
% Source: 
%   Cox, S. L., Orgeret, F., Gesta, M., Rodde, C., Heizer, I., 
%       Weimerskirch, H. and Guinet, C. (), Processing of acceleration and 
%       dive data on-board satellite relay tags to investigate diving and 
%       foraging behaviour in free-ranging marine predators. Methods Ecol 
%       Evol. Accepted Author Manuscript. doi:10.1111/2041-210X.12845 

if nargin < 2
    help PrCA
end

%calculate magnitute in acceleration
magA = zeros(size(A, 1), 1);
for i = 1:size(A, 1)
    magA(i) = sqrt(A(i, 1)^2 + A(i, 2)^2 + A(i, 3)^2);
end

%calculate the change in magA over one second of time
[var, ~] = buffer(magA, fs, 0, 'nodelay');
for j = 1:size(var, 2)
    varS_col(:, j) = abs(diff(var(:, j)));
    varS(j) = sum(varS_col(:, j));
end

%calculate per second running average of change in acceleration
varA = movmean(varS, 11);

if nargin < 3 || isempty(thresV)
    thresV = quantile(varA, .99) / 2;
end

%find prey capture attempts
cap = varS >= (varA + thresV);
vars = [1:size(varS, 2); varS];
captures_times = vars(1, cap);
captures_varS = varS(cap);

%create structure of prey capture times and their respective varS values
field1 = 'captures_times';  value1 = captures_times;
field2 = 'captures_varS';  value2 = captures_varS;
captures = struct(field1,value1,field2,value2);

end
