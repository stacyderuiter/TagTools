function feeding_events = predict_feeding(s, fs)
% Automated detection of feeding events based from velocity data
%
% INPUTS:
%   s = The speed vector in m/s.
%   fs = The sampling rate in Hz of the acceleration signals.
% 
% OUTPUTS:
%   feeding_events = Structure of feeding event times (sec) and their 
%       respective maximum speed estimates (m/s).
%
% Source:
%   Thomas Doniol-Valcroze, Véronique Lesage, Janie Giard, Robert Michaud; 
%       Optimal foraging theory predicts diving and feeding strategies of 
%       the largest marine predator. Behav Ecol 2011; 22 (4): 880-888. 
%       doi: 10.1093/beheco/arr038

if nargin < 2
    help feeding_event
end

%chunk s vector into sections the size of fs (one second)
[speedsec, ~] = buffer(s, fs, 0, 'nodelay');
ssec = zeros(size(speedsec, 2), 1);
for h = 1:size(speedsec, 2)
    ssec(h) = mean(speedsec(:, h));
end
    
%calculate threshold to be used in first round of filtering through s
thresh = prctile(ssec, 95);

%find where s is greater than the 95 percentile
sp = find(ssec >= thresh);

%find when four consecutive seconds of s are below thresh following sp
dsp = find(diff(sp) >= 4);

%determine mean s of all determined acceleration and deceleration periods
st = sp(dsp);
md = zeros(length(st), 1);
for i = 1:length(st)
    md(i) = mean(ssec((st(i)+1):(st(i)+10)));
end
ma = zeros(length(dsp), 1);
for j = 1:length(dsp)
    if dsp(j) == dsp(1)
        ma(j) = mean(ssec(sp(1):sp(dsp(j))));
    else
    ma(j) = mean(ssec(sp(dsp(j-1)+1):sp(dsp(j))));
    end
end

%find feeding events
feeding_times = find((ma ./ md) <= 0.5);
feeding_speeds = ssec(feeding_times);

%create structure containing feeding times and their respective speeds
field1 = 'feeding_times';  value1 = feeding_times;
field2 = 'feeding_speeds';  value2 = feeding_speeds;
feeding_events = struct(field1,value1,field2,value2);

end