function detections_acc = acc_test(detections, events, fs, tpevents)
% Determines the number of true positives, false negatives, and false 
%   positives automatically detected events from tagtools (i.e. 
%   detect_peak.m) and known event occurences from manual determination 
%   methods. It also calculates the hits and false_alarms rates.
%   This is useful for plotting ROC curves.
%
% INPUTS:
%   detections = A vector containing the times (indices from start of tag
%       recording) at which an automatically detected event was determined
%       to have taken place.
%   events = A vector containing the known times (indices from start of tag
%       recording) at which an event was known to have taken place from
%       manual determination methods or a matrix/cell array containing the
%       start and end times of a known event.
%   fs = The sampling rate in Hz of the detections and events data.
%   tpevents = The number of total possible events that could have occurred
%       throughout the time of the tag recording. Can be determined by the
%       equation: (indices / fs) / (necessary time between events)
%
% OUTPUTS:
%   detection_acc = A structure containing the number of hits, misses, and
%       false alarmss found between the detection and events inputs. A hit
%       constitutes a correct detection of an event. A miss constitutes an
%       event that was not detected. A false alarms constitues an incorrect
%       detection of a nonexistant event. The hit rate and false alarm rate
%       are also included in the structure.

if nargin < 4
    help acc_test
end

if isempty(events)
    count_hits = 0;
    count_misses = NaN;
    hits_rate = 0;
    false_alarms_rate = 1;
    count_false_alarms = length(detections);
    %create structure of count_hits, count_false_alarmss, and count_misses
    field1 = 'count_hits';  value1 = count_hits;
    field2 = 'count_false_alarms';  value2 = count_false_alarms;
    field3 = 'count_misses';  value3 = count_misses;
    field4 = 'hits_rate'; value4 = hits_rate;
    field5 = 'false_alarms_rate'; value5 = false_alarms_rate;
    detections_acc = struct(field1,value1,field2,value2,field3,value3,field4,value4,field5,value5);
    return
end

if iscell(events)
    ke = [];
    for i = 1:size(events, 1)
        ke = [ke; events{i}(:,2:3)];
    end
    events = table2array(ke);
end

if size(events, 1) < size(events, 2)
    events = events';
end

if size(events, 2) == 2
    count_hits = 0;
    count_false_alarms = 0;
    e = events;
    for j = 1:length(detections)
        detend = detections(j) <= e(:, 2);
        detstart = detections(j) >= e(:, 1);
        det = detend == detstart;
        e1 = e(detections(j) >= e(:, 2), :);
        e2 = e(detections(j) <= e(:, 1), :);
        e = [e1; e2];
        if sum(det(1:end)) == 1
            count_hits = count_hits + 1;
        elseif sum(det(1:end)) == 0
            count_false_alarms = count_false_alarms + 1;
        end
    end
    count_misses = size(events, 1) - count_hits;
    hits_rate = count_hits / size(events, 1);
    false_alarms_rate = count_false_alarms / tpevents;
end

if size(events, 2) == 1
    count_hits = 0;
    count_false_alarms = 0;
    e = events;
    for j = 1:length(detections)
        detplus = detections(j) <= (e + (5 * fs));
        detminus = detections(j) >= (e - (5 * fs));
        det = detplus == detminus;
        e1 = e(detections(j) >= (e + (5 * fs)));
        e2 = e(detections(j) <= (e - (5 * fs)));
        e = [e1; e2];
        if sum(det(1:end)) == 1
            count_hits = count_hits + 1;
        elseif sum(det(1:end)) == 0
            count_false_alarms = count_false_alarms + 1;
        end
    end
    count_misses = length(events) - count_hits;
    hits_rate = count_hits / length(events);
    false_alarms_rate = count_false_alarms / tpevents;
end


%create structure of count_hits, count_false_alarmss, and count_misses
field1 = 'count_hits';  value1 = count_hits;
field2 = 'count_false_alarms';  value2 = count_false_alarms;
field3 = 'count_misses';  value3 = count_misses;
field4 = 'hits_rate'; value4 = hits_rate;
field5 = 'false_alarms_rate'; value5 = false_alarms_rate;
detections_acc = struct(field1,value1,field2,value2,field3,value3,field4,value4,field5,value5);

end