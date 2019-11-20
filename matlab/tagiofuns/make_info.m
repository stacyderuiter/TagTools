function    info = make_info(depid,tagtype,species,owner)

%    	info = make_info(depid,tagtype,species,owner)	% make an info structure
%	  	or
%    	make_info		% shows a list of recognized tags, species and researchers
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     Last modified: 2 March 2018
%     - changed name and added listing of available types when
%       called with <2 arguments.
%		8 June 2019 - added support for ITIS and ordered structure fields

info = [] ;
if nargin<2,
   help make_info
	ttypes = {'dtag','cats','lleo','mk10'} ;
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
		if isempty(n), return, end
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
   case 'mk10'
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
