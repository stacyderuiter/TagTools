function    info = make_info(depid,tagtype,species,owner)

%    	info = make_info(depid,tagtype,species,owner)	% make an info structure
%	  	or
%    	make_info		% shows a list of recognized tags, species and researchers
%
%     Inputs:
%     depid is a string containing the name assigned to this deployment,
%      e.g., 'mn19_192a'.
%     tagtype is a string containing the initials of the tag type. These
%      are used to find a suitable template file to pre-populate some of
%      the metadata. If a matching template file is not found, the metadata
%      will be left mostly empty for you to fill out. Available tag types are:
%      'dtag','acous','lleo','cats','mk10'. You can also input:
%      'd4' DTAG version 4
%      'd3' DTAG version 3
%      'd2' DTAG version 2
%      'ac' Acousonde
%      'll' Little Leonardo
%      'dd' Daily Diary (Wildlife Computers)
%      'sm' SMRT tag (Wildlife Computers)
%     species is a string containing the two letter species prefix, e.g. 'mn'. 
%      This should match one or more of the species defined in the file 
%      user/species.csv. If there is more than one match, you will be asked 
%      to select the species from a list of matches.
%     owner is a string containing the initials of the nominal data owner
%      (the person who will be identified in the sensor metadata as whom to
%      approach for data access). This should match one or more of the 
%      researchers defined in the file user/researchers.csv. If there is 
%      more than one match, you will be asked to select the person from a 
%      list of matches.
%
%     Returns:
%     info is a structure of metadata about a tag deployment containing a
%      number of pre-filled fields. You are free to change or add fields
%      afterwards to improve the quality of the metadata.
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     Last modified: 2 March 2018
%     - changed name and added listing of available types when
%       called with <2 arguments.
%		8 June 2019 - added support for ITIS and ordered structure fields
%     19 Jan 2020 - added additional tag types.

info = [] ;
if nargin<2,
   help make_info
	ttypes = {'dtag','cats','lleo','mk10','acous'} ;
   fprintf(' Recognized tag types:\n') ;
   fprintf(' %s',ttypes{:});
   fprintf('\n\n Recognized species (from species.csv):\n') ;
 	get_species ;
   fprintf('\n Recognized researchers (from researchers.csv):\n') ;
 	get_researcher ;
   return
end

switch(lower(tagtype)),
	case 'dtag'
		s = input(' Enter dtag version: 2, 3 or 4... ','s') ;
		n = str2double(s) ;
		if isempty(n) || ~ismember(n,[2,3,4]), return, end
      T = csv2struct(sprintf('d%d_template.csv',n)) ; 
   case {'sm','smrt'}
      T = csv2struct('sm_template.csv') ; 
   case {'d4','dtag4'}
      T = csv2struct('d4_template.csv') ; 
   case {'d3','dtag3'}
      T = csv2struct('d3_template.csv') ;
   case {'d2','dtag2'}
      T = csv2struct('d2_template.csv') ;
   case 'cats'
      T = csv2struct('cats_template.csv') ;
   case {'ll','leo','lleo'}
      T = csv2struct('ll_template.csv') ;
   case {'ac','acous'}
      T = csv2struct('ac_template.csv') ;
   case {'dd','mk10'}
      T = csv2struct('mk10_template.csv') ;
   otherwise
      fprintf('Unknown tag type - fill out metadata by hand\n') ;
      T = csv2struct('blank_template.csv') ;
end

T.depid = depid ;
T.dtype_datetime_made = datestr(now,T.dephist_device_regset) ;
T.dtype_nfiles = 'UNKNOWN' ;
T.dtype_source = 'UNKNOWN' ;
T.device_serial = 'UNKNOWN' ;
T.dephist_deploy_datetime_start = 'UNKNOWN' ;
T.dephist_device_datetime_start = 'UNKNOWN' ;

if any(strcmp(T.device_make,{'DTAG','SMRT'})),
	try
   C = get_d3_cuetab([],depid,'swv') ;
   T.dtype_nfiles = length(C.fn) ;
   T.dtype_source = reshape([strvcat(C.fn) repmat(',',length(C.fn),1)]',1,[]) ;
   T.device_serial = C.id ;
   T.dephist_deploy_datetime_start = datestr(d3datevec(C.ref_time),T.dephist_device_regset) ;
   T.dephist_device_datetime_start = T.dephist_deploy_datetime_start ;
	catch
	end
end

if nargin>2,
   S = get_species(species) ;
   if ~isempty(S),
      T.animal_species_common = S.Common_name ;
      T.animal_species_science = S.Binomial ;
      T.animal_dbase_url = S.URL ;
		if isfield(S,'ITIS'),
			T.animal_dbase_itis = S.ITIS ;
		end
   end

   if nargin>3,
      S = get_researcher(owner) ;
      if ~isempty(S),
         T.provider_name = S.Name ;
         T.provider_details = S.Details ;
         T.provider_email = S.Email ;
         T.provider_license = S.License ;
         T.provider_cite = S.Cite ;
         T.provider_doi = S.DOI ;
      end
   end
end

info = orderfields(T) ;
%struct2csv(depid,info) ;
