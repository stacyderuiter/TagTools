function    [M,CAL,mb, fs_M] = d3autocalmag(x,CAL,test,uchans,fs)

%    [M,CAL,mb] = autocalmag(s,CAL,[test])
%    Automatically performs a calibration sequence on the raw
%    magnetometer data in raw sensor matrix s. Calls calmag.m
%    for the actual calibration steps.
%    
% NOTES:
%   *search for ??????????? to find parts of this script that need editing
%       when d3 low-battery-comp and xml-input scripts are ready.
%    *CAL is expected to be a structure array of calibration constants
%    *x is expected to be a cell array of raw data, with uchans (channel id numbers) and fs (sampling rates) providing extra information on the data in x.
%   *alternatively, rather than having these inputs, input could be a tagID
%       string;  then the initial lines of the script should include reading in
%       the raw data and reading a cal xml file (resulting in CAL structure).
%    *fs_M (output) is the output (calibrated) mag sampling rate in Hz
%
%    mark johnson
%    majohnson@whoi.edu
%    last modified: 20 May 2006 + edit for d3 summer 2012 stacy deruiter,
%    university of st andrews

if nargin<2,
   help autocalmag
   return
end
%   ???????????????????????????????????????????????
% [x,k] = lowbattmcomp(x,CAL) ; %needs to be updated for d3
% if ~isfield(CAL,'MK'), %changed 'AK' to 'MK' here - stacy deruiter, may 2012
%    CAL.MK = 0.9*k ;                 % only calibrate over high battery data
% end

%combine data from mag +/- channels
M0 = [x{uchans==4353}(:), x{uchans==4354}(:), x{uchans==4355}(:), x{uchans==4369}(:), x{uchans==4370}(:), x{uchans==4371}(:)]; %make a matrix of all magnetometer data
[Mi,Md,fs_M] = interpmag(M0,fs(uchans==4353)); % interpolate mag data
%calculate magnetometer bridge voltage
mp = x{uchans==5889}*2;
mm = x{uchans==5891};
mb = (mp-mm)*3; % mb = (MBRI_HMC1043p_DIV2*2-MBRI_HMC1043m_20)*3 , per Mark Johnson


if nargin==3 & ~isempty(test)
   [M,CAL,mb,fs_M] = d3calmag(x,Mi,mb,CAL,test,uchans,fs);

else
   fprintf(' Hard iron calibration...\n') ;
   [M,CAL,mb,fs_M]=d3calmag(x,Mi,mb,CAL,'hard',uchans,fs);
   fprintf(' Temperature calibration...\n') ;
   [M,CAL,mb,fs_M]=d3calmag(x,Mi,mb,CAL,'mb',uchans,fs);
   fprintf(' Sensitivity calibration...\n') ;
   [M,CAL,mb,fs_M]=d3calmag(x,Mi,mb,CAL,'sens',uchans,fs);
   fprintf(' Soft iron calibration...\n') ;
   [M,CAL,mb,fs_M]=d3calmag(x,Mi,mb,CAL,'soft',uchans,fs);
   fprintf(' Pressure calibration...\n') ;
   [M,CAL,mb,fs_M]=d3calmag(x,Mi,mb,CAL,'p',uchans,fs);
end
