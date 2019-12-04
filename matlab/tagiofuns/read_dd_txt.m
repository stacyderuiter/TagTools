function    [V,HDR] = read_dd_txt(fname,maxsamps)

%     [V,HDR] = read_dd_txt(fname,maxsamps)
%     Read a text file with tab-separated sensor data from a Daily Diary tag. 
%     Sensor data files can be very large and a number of steps are taken here 
%     to maximize speed and avoid memory problems. This function is usable by 
%     itself but is more normally called by read_dd() which handles metadata 
%     and creates a NetCDF file.
%
%     Input:
%     fname is the file name of the Daily Diary text file including the complete 
%      path name if the file is not in the current working directory or in a
%      directory on the path. The .txt suffix is not needed.
%     maxsamps is optional and is used to limit reading to a maximum number of
%      samples per sensor. This is useful to read in a part of a very large file
%      for testing. If maxsamps is not given, the entire file is read.
%
%     Returns:
%     V is a matrix of data read from the file. V has a line for each data line in
%      the file. The number of columns is one less than the number of fields.
%      This is because date and time which appear as separate fields in the text file
%      are amalgamated into a date number in V(:,1). Empty fields, i.e., fields that do
%      not contain a number, are removed.
%     HDR is a cell array of strings containing the names of fields. The field
%      names are taken from the first line of the CSV file and include units and axis.
%      HDR has the same number of cells as there are columns in V.
%
%		Example:
%		 [V,HDR] = read_dd_txt('oa14_319a_data',100)
% 	    Reads 100 samples from file oa14_319a_data.txt and returns the 
%      data and field information.
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     last modified: 21 July 2017

CHNK = 1e7 ;
MAXSIZE = 30e6 ;
suffix = '.txt' ;
delim = 9 ;          % tab delimiter

if nargin<2,
   maxsamps = [] ;
end

% append .txt suffix to file name if needed
if length(fname)<3 || ~all(fname(end+(-length(suffix)+1:0))==suffix),
   fname(end+(1:length(suffix)))=suffix;
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
HDR = cell(length(kc)+1,1) ;
kc = [0 kc length(hdr)] ;
for k=1:length(HDR),
   hh = hdr(kc(k)+1:kc(k+1)-1) ;
   kw = ~isspace(hh) ;
   k1 = max(1,find(kw,1)) ;
   k2 = min(length(hh),find(kw,1,'last')) ;
   HDR{k} = hh(k1:k2) ;
end

% find date and time fields
kd = find(strncmpi(HDR,'Date',4)) ;
kt = find(strncmpi(HDR,'Time',4)) ;
HDR = {HDR{[kd(1) find(~ismember((1:length(HDR)),[kd kt]))]}} ;      % eliminate Time field as it will be combined with Date
nf = length(HDR)-1 ;          % number of non-date and time fields
npartf = 0 ;
delete('_ttpart*.mat') ;
DN = [] ; X = [] ;

while 1,
   sr = fread(fin,CHNK,'uchar') ;
   if isempty(sr) || all(sr(1:10)==0), break, end
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
   x = zeros(length(kl),nf) ;
   kl = [0;kl] ;
   for kk=1:length(kl)-1,    % for each line
      L = s(kl(kk)+1:kl(kk+1)-1)' ;    % this line
      kc = find(L==delim) ;
      L(kc) = 32 ;
      kc = [0 kc length(L)] ;
		% split line into the date and time fields, and the remainder
		kdt = [kc(kd)+1:kc(kd+1) kc(kt)+1:kc(kt+1)] ;
      D{kk} = char(L(kdt)) ;
		L(kdt) = '_' ;
      xx = sscanf(char(L(L~='_')),'%f') ;
      if length(xx)>nf,
         fprintf('Too many fields in line: %d vs %d\n',length(xx),nf) ;
         break ;
      end
      x(kk,1:length(xx)) = xx' ;
   end
   
   dn = datenum(D,'dd/mm/yyyy HH:MM:SS') ;
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
   V(end+(1:length(x.DN)),:) = [x.DN(:) x.X] ;
end
