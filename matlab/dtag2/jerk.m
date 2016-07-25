function jk = jerk(A,fs)
%calculate |jerk| in m/sec/sec
jk = sqrt(sum( ([0 0 0;(diff(A.*9.8).*fs)]).^2  ,2)); %the zeros are so it stays the same size as A
%what we did:
%A*9.8 to convert from gs to m/sec
%diff(A) to get change in acc between adjacent samples
%*fs to convert from m/sec/sample to m/sec/sec
% calculate the magnitude of the jerk vector at each point:
%   square each entry of the jerk matrix
%   sum by rows
%   take the square root of each row
