function captures = PrCA(A, fs, thresV)

if nargin < 2
    help PrCA
end

%calculate magnitute in acceleration
magA = zeros(size(A, 1), 1);
for i = 1:size(A, 1)
    magA(i) = sqrt(A(i, 1)^2 + A(i, 2)^2 + A(i, 3)^2);
end

%calculate the change in magA over one second of time
var = buffer(magA, fs, 0, 'nodelay');
for j = 1:size(var, 2)
    varS_col(:, j) = abs(diff(var(:, j)));
    varS(j) = sum(varS_col(:, j));
end

%calculate per second running average of change in acceleration
varA = movmean(varS, 11);

%find prey capture attempts
cap = varS >= (varA + thresV);
cap_varS = varS(cap);
end
