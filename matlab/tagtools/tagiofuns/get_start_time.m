function       t = get_start_time(info)

%       t = get_start_time(info)

if nargin<1,
   help get_start_time
   return
end

if ~isstruct(info),
   fprintf('Argument to get_start_time must be an info structure\n') ;
   return
end

t = [] ;
if isfield(info,'dephist_device_datetime_start'),
   t = info.dephist_device_datetime_start ;
end

if isempty(t) && isfield(info,'dephist_device_datetime_start'),
   t = info.dephist_device_datetime_start ;
end

if isempty(t),
   fprintf('No valid start time in the info structure\n') ;
   return
end

if isfield(info,'dephist_device_regset'),
   r = info.dephist_device_regset ;
else
   r = 'dd/mm/yyyy HH:MM:SS' ;
end

try
   t=datevec(t,r) ;
catch
   fprintf('Unable to convert time string in info structure\n') ;
end


