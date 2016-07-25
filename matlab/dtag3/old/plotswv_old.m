function plotswv(tag, chips)
%simple script to import raw dtag3 movement sensor data and produce plots.
%the purpose is simply to have a look at the (raw, uncalibrated) data to
%assure oneself that the sensors were actually measuring things and the
%data seem uncorrupted.
%   tag is the tag id string as found in the swv file names.  eg, if swv files
%       are 'zc12_123a001.swv' then "tag" should be 'zc12_123a'.  There is no set
%       name convention - any file name will work, as long as it is same for all
%       swv files of a tagout and followed by a 3 digit number indicating chip
%       number.
%   chips are the chip numbers to read in (corresponding to the dtg and swv
%       file numbers).  Enter a vector of integers - e.g. [1:10] for chips 1-10,
%       corresponding to files with names like 001, 002, 003...010.
%
%stacy deruiter, creem/u of st andrews, june 2012

%get the user to tell you where the swv files are.  They all need to be in
%one folder.
[thefilename, thepath, FILTERINDEX] = uigetfile('*.swv', 'Choose any one .swv file from the dataset you want to check.');

%generate file names for all the swv files that are to be read in
for j = 1:length(chips)
    if chips(j)<10
        fnames{j} = [thepath tag '00' num2str(chips(j)) '.swv'  ];
    elseif chips(j)>=10
        fnames{j} = [thepath tag '0' num2str(chips(j)) '.swv'  ];
    end
end

%read in data
X = []; %preallocate empty variable
for j = 1:length(chips) %loop over all channels
    clear s x
    [x,fs,uchans] = d3parseswvx(fnames{j}(1:end-4)); %get data (x), sampling rates (fs) and channel id info from xml file
    %interpolate and combine +/- magnetometer data
    mm = [x{uchans==}(:), x{2}(:), x{3}(:), x{4}(:), x{5}(:), x{6}(:)]; %make a matrix of all magnetometer data
    [Mi,Md,fsmag] = interpmag(mm,fs(1)); % interpolate mag data
    fs(1:3) = repmat(fsmag(1),3,1); % replace old magnetometer sampling rate with new one
    for gg = 1:3
        x{gg} = Mi(:,gg); %replace old magnetometer data with new
    end
    %calculate magnetometer bridge voltage
    mp = x{14}*2;
    mm = x{15};
    mb = (mp-mm)*3; % mb = (MBRI_HMC1043p_DIV2*2-MBRI_HMC1043m_20)*3 , per Mark Johnson
    %put mag bridge voltage in column 15 of x
    x{15} = mb(:);
   %CONCATENATE data -- DECIMATED to 1 sample per second -- from all channels
   s = [x{1}(1:fs(1):end) x{2}(1:fs(1):end) x{3}(1:fs(1):end) x{7}(1:fs(1):end) x{8}(1:fs(1):end) x{9}(1:fs(1):end) x{10}(1:fs(1):end)];
    X = [X; s]; %full sensor matrix is matrix so far + the chip just read in...
end

%plot accelerometer data -- columns
figure(1); clf;
set(gca,'FontSize',20);
set(gcf,'Color','w');
hold on;
plot((1:length(X(:,4)))/60 , X(:,4), 'b');
plot((1:length(X(:,5)))./60 , X(:,5), 'g');
plot((1:length(X(:,6)))./60 , X(:,6), 'r');
hold off;
title('Accelerometer Data');
xlabel('Time (minutes since start of recording');
ylabel('Raw Accelerometer Data');
legend('X','Y','Z');

%plot magnetometer data -- cols 1-3 in X
figure(2); clf;
set(gca,'FontSize',20, 'Color','w');
set(gcf,'Color','w');
hold on;
plot((1:length(X(:,1)))./60 , X(:,1), 'b');
plot((1:length(X(:,2)))./60 , X(:,2), 'g');
plot((1:length(X(:,3)))./60 , X(:,3), 'r');
hold off;
title('Magnetometer Data');
xlabel('Time (minutes since start of recording');
ylabel('Raw Magnetometer Data');
legend('X','Y','Z');

%plot depth data
figure(3); clf;
set(gcf,'Color','w');
set(gca,'FontSize',20, 'Color','w');
plot((1:length(X(:,7)))./60 , X(:,7), 'k');
axis ij;
title('Raw Pressure Sensor Data');
xlabel('Time (minutes since start of recording');
ylabel('Raw Pressure Sensor Data');

