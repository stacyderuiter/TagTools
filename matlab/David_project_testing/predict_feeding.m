function feeding_event = predict_feeding(s, fs)

if nargin < 2
    help feeding_event
end

%chunk
%speedsec = buffer(s, fs, 0, 'nodelay');
%ssec = zeros(size(speedsec, 2), 1);
%for h = 1:size(speedsec, 2)
%    ssec(h) = mean(speedsec(:, h));
%end
    
%calculate threshold to be used in first round of filtering through s
thresh = prctile(s, 95);

%find where s is greater than the 95 percentile
sp = find(s >= thresh);

%find when four consecutive seconds of s are below thresh follow sp_fast
dsp = find(diff(sp) >= (4 * fs));

%determine mean s of all determined acceleration and deceleration periods
st = sp(dsp);
md = zeros(length(st), 1);
for i = 1:length(st)
    md(i) = mean(s((st(i)+1):(st(i)+10)));
end
ma = zeros(length(dsp), 1);
for j = 1:length(dsp)
    if dsp(j) == dsp(1)
        ma(j) = mean(s(sp(1):sp(dsp(j))));
    else
    ma(j) = mean(s(sp(dsp(j-1)+1):sp(dsp(j))));
    end
end

%find feeding events
feeds = find((ma / md) <= 0.5);
