function    [V,HDR] = read_tdr10dd_csv(fname,maxsamps)

%     [V,HDR] = read_tdr10dd_csv(fname,maxsamps)
%     Read a text file with comma-separated sensor data from a Wildlife Computers 
%     TDR10DD Daily Diary tag. These tags have a different data format than the 
%     Wildbytes Daily Diary tags. For these, use read_wbdd_txt.
%     Sensor data files can be very large and a number of steps are taken here 
%     to maximize speed and avoid memory problems. This function is usable by 
%     itself but is more normally called by read_dd() which handles metadata 
%     and creates a NetCDF file.
%
%     Input:
%     fname is the file name of the Daily Diary text file including the complete 
%      path name if the file is not in the current working directory or in a
%      directory on the path. The .csv suffix is not needed.
%     maxsamps is optional and is used to limit reading to a maximum number of
%      samples per sensor. This is useful to read in a part of a very large file
%      for testing. If maxsamps is not given, the entire file is read.
%
%     Returns:
%     V is a matrix of data read from the file. V has a line for each data line in
%      the file and a column for each numeric data field in the input. Two kinds of
%      fields in the CSV file are not imported: empty fields, i.e., fields that do
%      not contain a header labeling the column, and Event fields (which are text
%      fields describing householding actions in the tag).
%     HDR is a cell array of strings containing the names of fields. The field
%      names are taken from the first line of the CSV file and include units and axis
%      where these are provided. HDR has the same number of cells as there are 
%      columns in V.
%
%		Example:
%		 [V,HDR] = read_tdr10dd_csv('cu11_247a_data',100)
% 	    Reads 100 samples from file cu11_247a_data.csv and returns the 
%      data and field information.
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     last modified: 31 July 2017

CHNK = 1e7 ;
MAXSIZE = 30e6 ;
suffix = '.csv' ;
delim = ',' ;           % comma delimiter
drop = {'Events',','} ;     % list of fields to drop because they are not numeric
V = [] ; HDR = [] ;

if nargin<2,
   maxsamps = [] ;
end

% append .txt suffix to file name if needed
if length(fname)<3 || ~all(fname(end+(-length(suffix)+1:0))==suffix),
   fname(end+(1:length(suffix)))=suffix;
end

if ~exist(fname,'file'),
   fprintf(' Unable to find file %s\n', fname) ;
   return
end

fin = fopen(fname,'rb') ;
cc = 0 ;
sr = fread(fin,CHNK,'uchar') ;
kl = find(sr==10) ;    % find line returns

if isempty(kl),
   fprintf('No header found in file\n') ;
   fclose(fin) ;
   return
end

hdr = char(sr(1:kl(1)-1))' ;
ss = sr(kl(1)+1:end) ;           	% remainder of chunk to process later
kc = find(hdr==delim) ;            	% find fields in the header
if kc(end)>=length(hdr)-1,
   kc = kc(1:end-1) ;
end
HDR = {} ;
kc = [0 kc length(hdr)] ;
for k=1:length(kc)-1,
   hh = hdr(kc(k)+1:kc(k+1)-1) ;
   kw = ~isspace(hh) ;
   k1 = max(1,find(kw,1)) ;
   k2 = min(length(hh),find(kw,1,'last')) ;
   hn = hh(k1:k2) ;
   if ~isempty(hn) && ~ismember(hn,drop),
      HDR{end+1} = hh(k1:k2) ;
   end
end

% time field
nf = length(HDR)-1 ;          % number of non-date and time fields
npartf = 0 ;
delete('_ttpart*.mat') ;
DN = [] ; X = [] ;

while 1,
   sr = fread(fin,CHNK,'uchar') ;
   cc = cc+1 ;
   s = [ss;sr] ;
   fprintf(' %d MB read\n',cc*CHNK/1e6) ;
   kl = find(s==10) ;
   if ~isempty(kl),
      ss = s(kl(end)+1:end) ;
   else
      ss = [] ;
   end
   D = cell(length(kl),1) ;
   fracs = zeros(length(kl),1) ;
   x = zeros(length(kl),nf) ;
   kl = [0;kl] ;
   for kk=1:length(kl)-1,    % for each line
      L = s(kl(kk)+1:kl(kk+1)-1)' ;    % this line
      kc = find(L==delim) ;
      if isempty(kc), continue, end    % skip lines with no commas
      L(kc) = 32 ;
		% split line into the date and time fields, and the remainder
      dd = char(L(1:kc(1))) ;
      D{kk} = dd ;
      fracs(kk) = any(dd=='.') ;       % detect if date-time has fractional seconds
		L = char(L(kc(1)+1:kc(nf)-1)) ;    % rest of the line
      
      xx = sscanf(char(L),'%f') ;      % convert to numbers
      kg = find(diff(kc)~=1) ;         % find which fields the numbers go in
      xn = NaN*zeros(nf,1) ;
      xn(kg(1:length(xx))) = xx ;      % reassemble the numeric data
      x(kk,1:length(xn)) = xn' ;
   end
   
   % handle time strings with and without fractional milliseconds
   s = sum(fracs) ;
   if s>0,
      dn(fracs==1) = datenum({D{fracs==1}},'HH:MM:SS.FFF dd-mmm-yyyy') ;
   end
   if s<length(fracs),
      dn(fracs==0) = datenum({D{fracs==0}},'HH:MM:SS dd-mmm-yyyy') ;
   end

   X(end+(1:size(x,1)),1:size(x,2)) = x ;
   DN(end+(1:length(dn))) = dn ;

   if ~isempty(maxsamps),
      maxsamps = maxsamps - length(dn) ;
      if maxsamps<0,
         DN = DN(1:end+maxsamps) ;
         X = X(1:end+maxsamps,:) ;
         break ;
      end
   end

   sz = whos('X') ;
   if sz.bytes > MAXSIZE,
      npartf = npartf+1 ;
      tfn = sprintf('_ttpart%d.mat',npartf) ;
      save(tfn,'DN','X') ;
      DN = [] ; X = [] ;
   end
   if isempty(sr) || all(sr(1:10)==0), break, end
end
fclose(fin) ;
fprintf(' Assembling results...\n') ;

% reload part files
npartf = npartf+1 ;
tfn = sprintf('_ttpart%d.mat',npartf) ;
save(tfn,'DN','X') ;
V = [] ;
for k=1:npartf ;
   fname = sprintf('_ttpart%d.mat',k) ;
   x = load(fname) ;
   delete(fname) ;
   if length(x.DN)~=size(x.X,1),
      if length(x.DN)<size(x.X,1),
         x.X = x.X(1:length(x.DN),:) ;
      else
         x.DN = x.DN(1:size(x.X,1)) ;
      end
   end
   V(end+(1:length(x.DN)),:) = [x.DN(:) x.X] ;
end

% skip initial rows with no data
k = find(any(~isnan(V(1:min(100,size(V,1)),2:end)),2),1) ;
V = V(k:end,:) ;
return
