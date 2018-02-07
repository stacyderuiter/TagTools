function    cal = load_cal(fname)

%     cal = load_cal(fname)
%		or
%     cal = load_cal(depid)
%		or
%     cal = load_cal(X)
%
%     Load a calibration file and convert it into a calibration
%     structure. Calibration files and structures have a specific
%     format. See the comment column in file 'cal_file_example.csv'.
%
%     Input:
%     fname is a string containing the complete filename of a
%      calibration file to be loaded.
%
%     Returns:
%     cal is a calibration structure populated with values in the file.
%
%     Example:
%      cal = load_cal('cal_file_example.csv')
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     Last modified: 30 July 2017

cal = [] ;
if nargin<1,
	fname = [] ;
end

if isstruct(fname),
	if isfield(fname,'depid'),
		fname = fname.depid ;
	elseif isfield(fname,'info'),
		fname = fname.info.depid ;
	end
end

if ischar(fname),
	% fname could be a complete cal file name or deployment id
	% first try making a cal file name out of it:
	fn = ['cal' fname '.csv'] ;
	if exist(fn,'file'),
		fname = fn ;
	end
	% otherwise it must be a full cal file name
end

% append .csv suffix to file name if needed
if length(fname)<4 || ~all(fname(end+(-3:0))=='.csv'),
   fname(end+(1:4))='.csv';
end

if isempty(fname) || ~exist(fname,'file'),
   [fn,npth]=uigetfile('cal*.csv','Select cal file') ;
   if fn==0,
		return
	end
   fname = [npth fn] ;
end

[S,h]=read_csv(fname,1);
if isempty(S),
	fprintf(' File %s is empty or cannot be read\n') ;
   return
end

% Concatenate the three value fields and run a simple parser:
% If there is an axis label, the field is numeric, otherwise it is a
% string.
for k=1:length(S),
   v = [S(k).value1,' ',S(k).value2,' ',S(k).value3] ;
   if ~isempty(S(k).axis),
      S(k).v = sscanf(v,'%f') ;
   else
      S(k).v = v(1:find(~isspace(v),1,'last')) ;
   end
end

types=unique({S.type}) ;
cal = struct ;
for kt=1:length(types),                % for each type of sensor
   type = types{kt} ;
   k=find(strcmpi({S.type},type)) ;    % just the entries for this type
   if strcmpi(type,'cal'), % cal attributes go straight into the structure
      for ka=k,
         cal.(S(ka).attribute) = S(ka).v ;
      end
      continue
   end
   
   names = unique({S(k).name}) ;       % what sensor names are there?
   for kn=1:length(names),             % for each sensor name
      ks = k(strcmpi({S(k).name},names{kn})) ;  % just the entries for this sensor
      attr = unique({S(ks).attribute}) ;  % which attributes are there?
      c = struct('name',names{kn}) ;
      for ka=1:length(attr),              % for each attribute
         kk=find(strcmpi({S(ks).attribute},attr{ka})) ;
         if ischar(S(ks(kk(1))).v),  
            c.(attr{ka}) = S(ks(kk(1))).v ;
         else     % sort axes in increasing ascii order (x,y,z)
            ax = {S(ks(kk)).axis} ;
            [z,I] = sort(ax) ;
            c.(attr{ka}) = horzcat(S(ks(kk(I))).v)' ;
         end
      end
      if ~isfield(cal,type),
         cal.(type) = c ;
      else
         cal.(type)(end+1) = c ;
      end
   end
end
return
