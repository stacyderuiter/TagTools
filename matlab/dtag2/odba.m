function ODBA = odba(Aw, fs, tagoff, tagon, smoothsec)
%calculate the overall dynamic body acceleration for a dtag deployment.
%
%reference:  
%Qasem L, Cardew A, Wilson A, Griffiths I, Halsey LG, et al. (2012)
%Tri-Axial Dynamic Acceleration as a Proxy for Animal Energy Expenditure;
%Should We Be Summing Values or Calculating the Vector? 
%PLoS ONE 7(2): e31187. doi:10.1371/journal.pone.0031187 
%
%   INPUTS
%   1. Aw and fs:  accelerometer data matrix and sampling rate
%   2. tagoff (optional) time in seconds since start of tag record when tag
%   fell off.  If provided, ODBA will only be calculated over the time
%   before tagoff; ODBA vector will be filled with zeros after tagoff.
%   3. tagon (optional) time in seconds since start of tag record when tag
%   was placed on animal.  If provided, ODBA will only be calculated over
%   the time after tagon; ODBA vector will be filled with zeros before
%   tagon.
%   4. smoothsec (optional) number of seconds over which to calculate the
%   running mean during DBA calculation.  Default value is 5; if nothing is
%   entered then 5 will be used.
%
%   OUTPUT
%   ODBA = abs(DBAx) + abs(DBAy) + abs(DBAz)
%   where DBA is the acceleration on the specified axis - running average
%   of acc on that axis over smoothsec seconds.  See ref for more details.
%   Units are m/s^2.
%
%   NOTES:
%   Set tag path before using this function (relevant to dtag2 data)
%
%   Stacy DeRuiter, Uni of St Andrews, June 2012
clear odba1 dba a2u a2uf
%verify inputs
if nargin < 2
    error('Not enough inputs - type "help odba" for help');
end
if nargin < 3 || isempty(tagoff)
    tagoff = floor(length(Aw)/fs);  
end
if nargin < 4 || isempty(tagon)
    tagon = 0;
end
if nargin< 5 || isempty(smoothsec)
    smoothsec = 5;
end

%convert indices from seconds to samples
ton = floor(tagon*fs) + 1;
toff = ceil(tagoff*fs);

%convert accelerometer units from g's to m/s^2
Aw = Aw.*9.8;

%narrow down the dataset to times when the tag was on the animal
a2u = Aw(ton:toff,:); %accelerometer data to use

ODBA = zeros*Aw(:,1); %preallocate space for results

%apply smoothing filter to a2u
a2uf = filter(ones(1,ceil(smoothsec*fs))/ceil(smoothsec*fs),1,a2u);

%calculate DBA for each channel
dba = a2u - a2uf ;

%calculate ODBA
odba1 = abs(dba(:,1)) + abs(dba(:,2)) + abs(dba(:,3));

%TaDa!  The result.
ODBA(ton:toff) = odba1(:);
