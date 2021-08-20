function    [V,HDR,EMPTY] = read_cats_csv(fname,maxsamps)

%     [V,HDR,EMPTY] = read_cats_csv(fname,maxsamps)
%     Read a CSV file with sensor data from a CATS tag. CATS CSV files can be
%     very large and a number of steps are taken here to maximize speed and avoid
%     memory problems. This function is usable by itself but is more normally
%     called by read_cats() which handles metadata and creates a NetCDF file.
%
%     Input:
%     fname is the file name of the CATS CSV file including the complete 
%      path name if the file is not in the current working directory or in a
%      directory on the path. The .csv suffix is not needed.
%     maxsamps is optional and is used to limit reading to a maximum number of
%      samples per sensor. This is useful to read in a part of a very large file
%      for testing. If maxsamps is not given, the entire file is read.
%
%     Returns:
%     V is a matrix of data read from the file. V has a line for each data line in
%      the file. The number of columns is one less than the number of non-empty fields.
%      This is because date and time which appear as separate fields in the CSV file
%      are amalgamated into a date number in V(:,1). Empty fields, i.e., fields that do
%      not contain a number, are removed.
%     HDR is a cell array of strings containing the names of non-empty fields. The field
%      names are taken from the first line of the CSV file and include units and axis.
%      HDR has the same number of cells as there are columns in V.
%     EMPTY is a cell array of strings containing the names of empty fields.
%
%		Example:
%		 [V,HDR,EMPTY] = read_cats_csv('20160730-091117-Froback-11',100)
% 	    Reads 100 samples from file 20160730-091117-Froback 11.csv and returns the 
%      data and field information.
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     last modified: 21 July 2017

CHNK = 1e7 ;
MAXSIZE = 30e6 ;

if nargin<2,
   maxsamps = [] ;
end

% append .csv suffix to file name if needed
if length(fname)<3 || ~all(fname(end+(-3:0))=='.csv'),
   fname(end+(1:4))='.csv';
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
ss = sr(kl(1)+1:end) ;           % remainder of chunk to process later
kc = find(hdr==',') ;            % find fields in the header
HDR = cell(length(kc)+1,1) ;
kc = [0 kc length(hdr)] ;
for k=1:length(HDR),
   HDR{k} = hdr(kc(k)+1:kc(k+1)-1) ;
end

% find and remove empty fields
L = sr(kl(1)+1:kl(2)-1) ;           % first data line
kc = find(L==',') ;
if ~isempty(kc),
   ke = find(diff(kc)==1)+1;        % find empty fields
   EMPTY = {HDR{ke}} ;
   HDR = {HDR{~ismember(1:length(HDR),ke)}} ;
else
   EMPTY = {} ;
end

HDR = {HDR{[1 3:end]}} ;      % eliminate Time field as it will be combined with Date
nf = length(HDR)-1 ;
npartf = 0 ;
delete('_ttpart*.mat') ;
DN = [] ; X = [] ;

while 1,
   sr = fread(fin,CHNK,'uchar') ;
   cc = cc+1 ;
   s = [ss;sr] ;
   fprintf(' %d MB read: %s\n',cc*CHNK/1e6,s(1:19)) ;
   kl = find(s==10) ;
   if ~isempty(kl),
      ss = s(kl(end)+1:end) ;
   else
      ss = [] ;
   end
   D = cell(length(kl),1) ;
	DF = cell(length(kl),1) ;
   x = zeros(length(kl),nf) ;
   kl = [0;kl] ;
   for kk=1:length(kl)-1,    % for each line
      L = s(kl(kk)+1:kl(kk+1)-1) ;    % this line
      kc = find(L==',') ;
      L(kc) = 32 ;
		dt = char(L(1:kc(2)-1)') ;
		ke = find(dt=='.') ;      % Updated to allow compatibility with Octave datenum
		dt(ke(1:end-1)) = '-' ;
      D{kk} = dt(1:ke(end)-1) ;
		DF{kk} = dt(ke(end):end) ;
      xx = sscanf(char(L(kc(2)+1:end)'),'%f') ;
      if length(xx)>nf,
         fprintf('Too many fields in line: %d vs %d\n',length(xx),nf) ;
         break ;
      end
      x(kk,1:length(xx)) = xx' ;
   end
	df = str2double(DF) ;
   if ~isempty(D),
      dn = datenum(D,'dd-mm-yyyy HH:MM:SS')+df/3600/24 ; % Updated to allow compatibility with Octave datenum
   else
      dn = [] ;
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
   V(end+(1:length(x.DN)),:) = [x.DN(:) x.X] ;
end
