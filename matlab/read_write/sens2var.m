function    [X,fs] = sens2var(S)

%    [X,fs] = sens2var(S)     % regularly sampled data
%    or
%    [X,T] = sens2var(S)      % irregularly sampled data
%    Extract data from a sensor structure.
%
%    Inputs:
%    S is a sensor structure.
%
%    Returns:
%    X is a vector or matrix of sensor data. This is in the unit and
%     frame as stored in the sensor structure.
%    fs is the sampling rate of the sensor data in Hz (samples per second).
%    T is the time in seconds of each measurement in data for irregularly
%     sampled data. The time reference (i.e., the 0 time) is with
%     respect to the start time of the data in the sensor structure.
%
%    Example:
%     loadnc('testset3')
%     [pca_dur,pca_time] = sens2var(PCA)
%
%    Valid: Matlab, Octave
%    markjohnson@st-andrews.ac.uk
%    Last modified: 22 July 2017

if ~isstruct(S) || ~isfield(S,'data') ~isfield(S,'sampling')
   fprintf('Error: input argument must be a sensor structure\n') ;
   return
end

if strcmp(S.sampling,'regular'),
   X = S.data ;
   fs = S.sampling_rate ;
else
   fs = S.data(:,1) ;
   if size(S.data,2)>1,
      X = S.data(:,2:end) ;
   else
      X = ones(length(fs),1) ;
   end
end
