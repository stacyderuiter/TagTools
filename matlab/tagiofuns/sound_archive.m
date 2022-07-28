function    SA = sound_archive(depid)

%    SA = sens_struct(depid)   % use default name
%
%    Generate a sound archive structure for a deployment.
%
%    Inputs:
%    depid is a string containing the deployment identifier.
%
%    Returns:
%    X is a sound archive structure with metadata fields pre-populated. 
%		 Change these as needed to the correct values.
%
%
%    Valid: Matlab, Octave
%    markjohnson@st-andrews.ac.uk
%    Last modified: 7 June 2019

SA = [] ;
if nargin<1,
   help sound_archive
   return
end

X.depid = depid ;
X.type = 'archive' ;
X.name = 'SA' ;
X.full_name = 'sound_archive' ;
X.description = 'Sound data archive listing' ;

[ct,ref_time,fs,fn] = d3getcues([],depid) ;
if isempty(fn),
	fprintf('No directory for this deployment - run d3getcues\n') ;
	return
end

sz = zeros(length(fn),1) ;
for k=1:length(fn),
	sz(k) = sum(ct(ct(:,1)==k & ct(:,4)>=0,3)) ;
end

% change format of block status from 0==data to 1==data
kk = ct(:,4)>=0 ;
ct(kk,4) = ct(kk,4)==0 ;

X.file_names = reshape([strvcat(fn) repmat('.wav,',length(fn),1)]',1,[]) ;
X.file_number = length(fn) ;
X.file_format = 'wav' ;
X.file_resolution = 16 ;
X.file_compression = 'none' ;
X.file_size = sz ;
X.file_size_unit = 'samples' ;
X.file_location = 'SMRU, Univ St Andrews, St Andrews, Fife KY16 8LB, UK' ;
X.file_url = '' ;
X.file_doi = '' ;
X.file_contact_email = 'mj26@st-andrews.ac.uk' ;
X.file_contact_person = 'Mark Johnson' ;
X.file_contact_url = 'www.soundtags.org' ;
X.archive_status = 'complete' ;
X.channel_num = 1 ;
X.channel_separation = 0 ;
X.channel_separation_unit = 'm' ;
X.channel_sensitivity = -173 ;
X.channel_sensitivity_unit = 'Decibels re volt per micropascal' ;
X.channel_sensitivity_label = 'dB re V/\muPa' ;
X.channel_sensitivity_explanation = 'Total recording sensitivity from water to wav file denoting full-scale in the wav file as 1.0 Volt' ;
X.channel_sensitivity_includes_gain = 'yes' ;
X.channel_gain = 12 ;
X.channel_gain_unit = 'Decibels' ;
X.sampling = 'regular' ;
X.sampling_rate = fs ;
X.sampling_rate_unit = 'Hz' ;
X.sampling_3dB_low = 'UNKNOWN' ;
X.sampling_3dB_high = 'UNKNOWN' ;
X.data = ct ;
X.data_row_name = 'block' ;
X.data_column_name = 'file,time,samples,status' ;
X.data_column_description_status = '1=data,0=zero-filled,-1=gap' ;
X.data_column_description_file = 'number of file in file_names' ;
X.data_column_description_time = 'time in seconds since start_time' ;
X.data_column_description_samples = 'number of sound samples per channel in block' ;
X.contig_within_files = 'yes' ;
X.contig_across_files = 'yes' ;
X.start_time = datestr(d3datevec(ref_time),'yyyy/mm/dd HH:MM:SS.FFF') ;
X.start_time_tzone = 'UTC' ;
X.calibration_method = 'UNKNOWN' ;
X.calibration_date = 'UNKNOWN' ;
X.selfnoise_file = [fn{1} '.wav'] ;
X.selfnoise_cue_start = 0 ;
X.selfnoise_cue_end = 6 ;
X.selfnoise_cue_unit = 'second into file' ;
X.creation_date = datestr(now,'yyyy/mm/dd HH:MM:SS') ;
X.history = 'd3getcues,sound_archive' ;
SA = orderfields(X) ;
