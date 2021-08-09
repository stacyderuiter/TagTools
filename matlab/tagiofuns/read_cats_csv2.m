function    [V,HDR,EMPTY,TXF,TXT] = read_cats_csv2(fname,maxsamps,txtfields)

%     [V,HDR,EMPTY,TXT,TXF] = read_cats_csv2(fname,maxsamps)
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
%     txtfields is optional and contains the name of non-numeric fields in
%      the CSV file. If not given, the following template will be used:
%      txtfields = {'System error', 'Flags', 'GPS', 'CC status'};
%
%     Returns:
%     V is a matrix of data read from the file. V has a line for each data line in
%      the file. The number of columns is one less than the number of non-empty numeric fields.
%      This is because date and time which appear as separate fields in the CSV file
%      are amalgamated into a date number in V(:,1). Empty fields, i.e., fields that do
%      not contain a number or text, are removed.
%     HDR is a cell array of strings containing the names of non-empty fields. The field
%      names are taken from the first line of the CSV file and include units and axis.
%      HDR has the same number of cells as there are columns in V.
%     EMPTY is a cell array of strings containing the names of empty fields.
%     TXF is a char array with non-numeric data read from the file. TXF has
%      a line for each data line in the file.
%     TXT is a cell array of strings containing the names of the
%     non-numeric fields. The field names are taken from the first line of
%     the CSV file and compared against the txtfields template.
%
%		Example:
%		 [V,HDR,EMPTY,TXF,TXT] = read_cats_csv2('mn16_212a\20160730-091117-Froback 11',100)
% 	    Reads 100 samples from file 20160730-091117-Froback 11.csv and returns the
%      data and field information.
%
%     Valid: Matlab, Octave
%     markjohnson@st-andrews.ac.uk
%     last modified: 03 Aug 2021 by dmw: 
%       - changed the way empty fields are handled to accommodate sparse GPS data
%       - added capability to handle non-numeric fields (e.g. in new CATS csv
%       files)
%       - added capability to handle multiple date-time columns (e.g. in new CATS csv
%       files)

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

% % find and remove empty fields
% L = sr(kl(1)+1:kl(2)-1) ;           % first data line
% kc = find(L==',') ;
% if ~isempty(kc),
%     ke = find(diff(kc)==1)+1;        % find empty fields
%     EMPTY = {HDR{ke}} ;
%     HDR = {HDR{~ismember(1:length(HDR),ke)}} ;
% else
%     EMPTY = {} ;
% end

% find and remove text fields
if nargin<3,
    txtfields = '^System error$|^Flags$|^GPS$|^CC Status$' ;
else
    txtfields = ['^',strjoin(txtfields,'$|^'),'$'];
end

ktx = find(~cellfun(@isempty,regexpi(HDR,txtfields))) ;
if ~isempty(ktx),
    TXT = {HDR{ktx}} ;
    HDR = {HDR{~ismember(1:length(HDR),ktx)}} ;
    L = sr(kl(1)+1:kl(2)-1) ;           % first data line
    kc = find(L==',') ;
    T = [];
    for i = length(ktx):-1:1
        T = [T, L(kc(ktx(i)-1):kc(ktx(i))-1)'];
    end
    nt = size(T,2)-1;
else
    TXT = {} ;
end

ditch = find(contains(HDR,'Time'));
kg = find(~cellfun(@isempty,regexp(HDR,'GPS.*2')));
HDR([ditch,kg]) = [];
nf = length(HDR)-length(ditch);
npartf = 0 ;
delete('_ttpart*.mat') ;
DN = [] ; X = [] ; TX = [] ;

while 1,
    sr = fread(fin,CHNK,'uchar') ;
    cc = cc+1 ;
    s = [ss;sr] ;
    if ~isempty(s)
        fprintf(' %d MB read: %s\n',cc*CHNK/1e6,s(1:19)) ;
        kl = find(s==10) ;
        if ~isempty(kl),
            ss = s(kl(end)+1:end) ;
        else
            ss = [] ;
        end
        D = cell(length(kl),max([1,length(ditch)])) ;
        DF = cell(length(kl),max([1,length(ditch)])) ;
        if ~isempty(ktx)
            T = zeros(length(kl),nt) ;
        end
        x = zeros(length(kl),nf) ;
        kl = [0;kl] ;
        for kk=1:length(kl)-1,    % for each line
            L = s(kl(kk)+1:kl(kk+1)-1)' ;    % this line
            kc = find(L==',') ;
            L(kc) = 32 ;
            
            % deal with text fields:
            if ~isempty(ktx)
                t = [];
                for i = length(ktx):-1:1
                    t = [t, L(kc(ktx(i)-1):kc(ktx(i))-1)];
                    L(kc(ktx(i)-1):kc(ktx(i))-1) = [];
                end
                T(kk,:) = fliplr(t(2:end));
            end
            
            % deal with GPS time fields:
            ke = find(diff(kc)==1)+1;        % find empty fields
            if ~isempty(ke)
                for i = length(ke):-2:2
                    L = [L(1:kc(ke(i)-1)-1), [78,97,78] , L(kc(ke(i)):end)] ;
                end
            else
                for i = length(kg):-1:1
                    dg = char(L(kc(kg(i)-2)+1:kc(kg(i))-1)) ;
                    ke = find(dg=='.') ;      % Updated to allow compatibility with Octave datenum
                    dg(ke(1:end-1)) = '-' ;
                    dgf = str2double(dg(ke(end):end)) ;
                    try
                        dgn = mdatenum(dg(1:ke(end)-1))+dgf/3600/24 ;
                    catch
                        dgn = datenum(dg(1:ke(end)-1),'dd-mm-yyyy HH:MM:SS')+dgf/3600/24 ;
                    end
                    L = [L(1:kc(kg(i)-2)), double(char(sprintf('%.10f',dgn))) , L(kc(kg(i)+1):end)] ;
                end
            end
            dt = char(L(1:kc(2)-1)) ;
            ke = find(dt=='.') ;      % Updated to allow compatibility with Octave datenum
            dt(ke(1:end-1)) = '-' ;
            D{kk,1} = dt(1:ke(end)-1) ;
            DF{kk,1} = dt(ke(end):end) ;
            if length(ditch)>1 && all(diff(ditch)==2),
                for i = 2:length(ditch)
                    dt = char(L(kc(ditch(i)-2)+1:kc(ditch(i))-1)) ;
                    ke = find(dt=='.') ;      % Updated to allow compatibility with Octave datenum
                    dt(ke(1:end-1)) = '-' ;
                    D{kk,i} = dt(1:ke(end)-1) ;
                    DF{kk,i} = dt(ke(end):end) ;
                end
            end
            
            xx = sscanf(char(L(kc(ditch(end))+1:end)),'%f') ;
            if length(xx)>nf,
                fprintf('Too many fields in line: %d vs %d\n',length(xx),nf) ;
                break ;
            end
            x(kk,1:length(xx)) = xx' ;
        end
        df = str2double(DF) ;
        if ~isempty(D),
            dn = NaN*ones(size(D));
            for i = 1:size(D,2)
                dn(:,i) = datenum(D(:,i),'dd-mm-yyyy HH:MM:SS')+df(:,i)/3600/24 ; % Updated to allow compatibility with Octave datenum
            end
        else
            dn = [] ;
        end
        X(end+(1:size(x,1)),1:size(x,2)) = x ;
        DN(end+(1:size(dn,1)),1:length(ditch)) = dn ;
        if ~isempty(ktx)
            TX(end+(1:size(T,1)),1:size(T,2)) = T;
        end
        
        if ~isempty(maxsamps),
            maxsamps = maxsamps - length(dn) ;
            if maxsamps<0,
                DN = DN(1:end+maxsamps,:) ;
                X = X(1:end+maxsamps,:) ;
                if ~isempty(TX)
                    TX = TX(1:end+maxsamps,:) ;
                end
                break ;
            end
        end
        
        sz = whos('X') ;
        if sz.bytes > MAXSIZE,
            npartf = npartf+1 ;
            tfn = sprintf('_ttpart%d.mat',npartf) ;
            save(tfn,'DN','X','TX') ;
            DN = [] ; X = [] ; TX = [] ;
        end
    end
    if isempty(sr) || all(sr(1:10)==0), break, end
end
fclose(fin) ;
fprintf(' Assembling results...\n') ;

% reload part files
npartf = npartf+1 ;
tfn = sprintf('_ttpart%d.mat',npartf) ;
save(tfn,'DN','X','TX') ;
V = [] ;
TXF = [];
for k=1:npartf ;
    fname = sprintf('_ttpart%d.mat',k) ;
    x = load(fname) ;
    delete(fname) ;
    V(end+(1:size(x.DN,1)),:) = [x.DN x.X] ;
    TXF(end+(1:size(x.TX,1)),:) = x.TX;
end
TXF = char(TXF);

% find and remove empty fields
ke = [];
for i = 1:size(V,2)
    if all(isnan(V(:,i)))
        ke = [ke; i];
    end
end
if ~isempty(ke)
    EMPTY = {HDR{ke}} ;
    HDR = {HDR{~ismember(1:length(HDR),ke)}} ;
    V(:,ke) = [] ;
else
    EMPTY = {} ;
end


function D = mdatenum(S)
% usage
%  mdatenum('30-10-2010') % ans = 734421
%
% Copyright: zhang@zhiqiang.org, 2010
% modified by dmwisniewska@gmail.com, 2021

tmp = sscanf(S, '%02d-%02d-%04d %02d:%02d:%02d');
D = datenummx(tmp(3), tmp(2), tmp(1), tmp(4), tmp(5), tmp(6));