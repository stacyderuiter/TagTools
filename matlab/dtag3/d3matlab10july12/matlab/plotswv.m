function plotswv(varargin)
%   plotswv(recdir,prefix)  OR plotswv(X)
%simple script to import raw dtag3 movement sensor data and produce plots.
%the purpose is simply to have a look at the (raw, uncalibrated) data to
%assure oneself that the sensors were actually measuring things and the
%data seem uncorrupted.
%   prefix is the tag deployment id string as found in the swv file names.  eg, if swv files
%       are 'zc12_123a001.swv' then "prefix" should be 'zc12_123a'.  There is no set
%       name convention - any file name will work, as long as it is same for all
%       swv files of a tagout and followed by a 3 digit number indicating chip
%       number.
%   recdir is the path to the directory containing the swv files.
%
%   If either recdir or prefix is not given, or is empty ([]), then
%   the script will prompt the user to select the appropriate file/folder
%   via a GUI.
%
%   alternate calling syntax:  if user calls 
%   plotswv(X)
%   where X is a cell array of d3 sensor data (obtained by a call to d3readswv), the function
%   will plot the raw *uncalibrated* sensor data without re-reading in data
%   from the swv file.  This option is faster IF you have already generated
%   X.  It is unneccessary to input recdir or prefix if you are supplying X
%   as input.
%
%stacy deruiter, creem/u of st andrews, june 2012

% if X is given, move on.  Else, if recdir and/or prefix is not specified, get the user to tell you where the swv files are.  They all need to be in
%one folder.  
if nargin==1 %&& iscell(varargin{1})
    X = varargin{1};
    %no need to read in data
else
    if nargin<2 || ~ischar(varargin{1})
       [prefix1, recdir, FILTERINDEX] = uigetfile('*.swv', 'Choose any one .swv file from the dataset you want to check.');
        prefix = prefix1(1:(end-7));
    else
        recdir = varargin{1};
        prefix = varargin{2};
    end
    %read in data if it was not provided
    X=d3readswv(recdir,prefix);
end

M0 = [X.x{X.cn==4353}(:), X.x{X.cn==4354}(:), X.x{X.cn==4355}(:), X.x{X.cn==4369}(:), X.x{X.cn==4370}(:), X.x{X.cn==4371}(:)]; %make a matrix of all magnetometer data
[Mi,Md,fs_M] = interpmag_old(M0,X.fs(X.cn==4353)); % interpolate mag data

%plot accelerometer data 
figure(1); clf;
set(gca,'FontSize',20);
set(gcf,'Color','w');
plot((1:length(X.x{X.cn==4609}))/X.fs(X.cn==4609)/60 , [X.x{X.cn==4609}(:) X.x{X.cn==4610}(:) X.x{X.cn==4611}(:)]);
title('Accelerometer Data');
xlabel('Time (minutes since start of recording)');
ylabel('Raw Accelerometer Data');
legend('X','Y','Z');

%plot magnetometer data 
figure(2); clf;
set(gca,'FontSize',20, 'Color','w');
set(gcf,'Color','w');
plot((1:length(Mi))/fs_M(1)/60 , Mi);
title('Magnetometer Data');
xlabel('Time (minutes since start of recording)');
ylabel('Raw Magnetometer Data');
legend('X','Y','Z');

%plot depth data
figure(3); clf;
set(gcf,'Color','w');
set(gca,'FontSize',20, 'Color','w');
plot((1:length(X.x{X.cn==4869}))/X.fs(X.cn==4869)/60 , X.x{X.cn==4869}, 'k');
axis ij;
title('Raw Pressure Sensor Data');
xlabel('Time (minutes since start of recording)');
ylabel('Raw Pressure Sensor Data');

